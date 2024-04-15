#ifndef FABRIC_LIGHTING_INCLUDE
#define FABRIC_LIGHTING_INCLUDE

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

TEXTURE2D(_PreIntegratedFGD);
SAMPLER(s_linear_clamp_sampler);

#define FGDTEXTURE_RESOLUTION (64)

struct AnisotropicData
{
    half anisotropic;
    half anisotropicRotation;
    half3 tangentWS;
    half3 bitangentWS;
    float roughnessT;
    float roughnessB;
};

inline void InitializeBRDFData(half3 albedo, half metallic, half3 specular, half smoothness, out BRDFData outBRDFData)
{
#ifdef _SPECULAR_SETUP
    half reflectivity = ReflectivitySpecular(specular);
    half oneMinusReflectivity = half(1.0) - reflectivity;
    half3 brdfDiffuse = albedo * (half3(1.0, 1.0, 1.0) - specular);
    half3 brdfSpecular = specular;
#else
    half oneMinusReflectivity = OneMinusReflectivityMetallic(metallic);
    half reflectivity = half(1.0) - oneMinusReflectivity;
    half3 brdfDiffuse = albedo * oneMinusReflectivity;
    half3 brdfSpecular = lerp(kDieletricSpec.rgb, albedo, metallic);
#endif

    outBRDFData = (BRDFData)0;
   // outBRDFData.albedo = albedo;
    outBRDFData.diffuse = brdfDiffuse;
    outBRDFData.specular = brdfSpecular;
    outBRDFData.reflectivity = reflectivity;

    outBRDFData.perceptualRoughness = 1 - smoothness;
    outBRDFData.roughness           = PerceptualRoughnessToRoughness(outBRDFData.perceptualRoughness);
    outBRDFData.roughness2          = outBRDFData.roughness * outBRDFData.roughness;
    outBRDFData.grazingTerm         = saturate(smoothness + reflectivity);
    outBRDFData.normalizationTerm   = outBRDFData.roughness * half(4.0) + half(2.0);
    outBRDFData.roughness2MinusOne  = outBRDFData.roughness2 - half(1.0);
}

void InitializationAnisotropicData(float3 normalWS, float3 tangentWS, float perceptualRoughness, inout AnisotropicData anisotropicData)
{
#ifdef _ANISOTROPIC
    anisotropicData.anisotropic = _Anisotropic;
    anisotropicData.anisotropicRotation = 0;
    anisotropicData.tangentWS = Orthonormalize(tangentWS, normalWS);
    anisotropicData.bitangentWS = cross(normalWS, anisotropicData.tangentWS);
    ConvertAnisotropyToRoughness(perceptualRoughness, anisotropicData.anisotropic, anisotropicData.roughnessT, anisotropicData.roughnessB);
    anisotropicData.roughnessT = max(0.001, anisotropicData.roughnessT);
    anisotropicData.roughnessB = max(0.001, anisotropicData.roughnessB);
#endif
}

float DV_SmithJointGGXAniso_HighQuality(real TdotH, real BdotH, real NdotH, real NdotV,
                           real TdotL, real BdotL, real NdotL,
                           real roughnessT, real roughnessB, real partLambdaV)
{
    float a2 = roughnessT * roughnessB;
    float3 v = real3(roughnessB * TdotH, roughnessT * BdotH, a2 * NdotH);
    float  s = dot(v, v);

    float lambdaV = NdotL * partLambdaV;
    float lambdaL = NdotV * length(real3(roughnessT * TdotL, roughnessB * BdotL, NdotL));

    float2 D = real2(a2 * a2 * a2, s * s);  // Fraction without the multiplier (1/Pi)
    float2 G = real2(1, lambdaV + lambdaL); // Fraction without the multiplier (1/2)

    // This function is only used for direct lighting.
    // If roughness is 0, the probability of hitting a punctual or directional light is also 0.
    // Therefore, we return 0. The most efficient way to do it is with a max().
    return (INV_PI * 0.5) * (D.x * G.x) / max(D.y * G.y, FLT_MIN);
}

AnisotropicData anisotropicData = (AnisotropicData)0;
CBSDF EvaluateFabricBRDF(InputData inputData, BRDFData brdfData, Light light)
{
    CBSDF cbsdf;

    float3 H = normalize(inputData.viewDirectionWS + light.direction);
    float NdotL = dot(inputData.normalWS, light.direction);
    float NdotV = dot(inputData.normalWS, inputData.viewDirectionWS);
    float clampNdotL = max(saturate(NdotL), 0.00001);
    float clampNdotV = ClampNdotV(NdotV);
    float NdotH = saturate(dot(inputData.normalWS, H));

    float diffTerm = 0;
    float3 specTerm = 0;
#ifdef _FABRIC_SILK_MATERIAL
    float LdotH = dot(light.direction, H);
    float LdotV = dot(light.direction, inputData.viewDirectionWS);
    diffTerm =  DisneyDiffuse(clampNdotV, (NdotL), LdotV, brdfData.perceptualRoughness);
    float TdotH = dot(anisotropicData.tangentWS, H);
    float TdotL = dot(anisotropicData.tangentWS, light.direction);
    float BdotH = dot(anisotropicData.bitangentWS, H);
    float BdotL = dot(anisotropicData.bitangentWS, light.direction);
    float TdotV = dot(anisotropicData.tangentWS, inputData.viewDirectionWS);
    float BdotV = dot(anisotropicData.bitangentWS, inputData.viewDirectionWS);
    float anisoPartLambdaV = GetSmithJointGGXAnisoPartLambdaV(TdotV, BdotV, clampNdotV, anisotropicData.roughnessT, anisotropicData.roughnessB);
    float DV = DV_SmithJointGGXAniso_HighQuality(TdotH, BdotH, NdotH, clampNdotV, TdotL, BdotL, abs(clampNdotL), anisotropicData.roughnessT, anisotropicData.roughnessB, anisoPartLambdaV);
    float3 F = F_Schlick(brdfData.specular, LdotH);
    specTerm = F * clamp(DV, 0, 100) ;    
#else
    diffTerm = FabricLambert(brdfData.roughness);
    float D =  D_Charlie(NdotH, brdfData.roughness) ;
    float V = V_Ashikhmin(clampNdotL, clampNdotV) ;
    //V = min(V, 10);
    float3 F = brdfData.specular;
    specTerm = F * V * D;
#endif

    cbsdf.diffR = diffTerm * clampNdotL;
    cbsdf.specR = specTerm * clampNdotL;
    cbsdf.diffT = 0;
    cbsdf.specT = 0;
    return cbsdf;
}

void PhysicallyBaseDirectLighting(InputData inputData, BRDFData brdfData, Light light, inout float3 diffuseLighting, inout float3 specularLighting)
{
    half ShadowMask = light.distanceAttenuation * light.shadowAttenuation;
    half3 lighting = light.color * ShadowMask;
    CBSDF cbrdf = EvaluateFabricBRDF(inputData, brdfData, light);
  
    diffuseLighting += cbrdf.diffR * brdfData.diffuse * lighting;
    specularLighting += cbrdf.specR  * lighting;
}

float3 IBL_EnvironmentReflection(float3 viewDirWS, float3 normalWS, float roughness)
{
    float3 reflectDirectionWS = reflect(-viewDirWS, normalWS);
    float square_roughness = roughness * (1.7 - 0.7 * roughness);
    float Midlevel = square_roughness * 6;
    float4 specularColor = SAMPLE_TEXTURECUBE_LOD(unity_SpecCube0, samplerunity_SpecCube0, reflectDirectionWS, Midlevel);
    #if !defined(UNITY_USE_NATIVE_HDR)
        return DecodeHDREnvironment(specularColor, unity_SpecCube0_HDR).rgb;
    #else
        return specularColor.xyz;
    #endif
}

void GetPreIntegratedGGX(float NdotV, float perceptualRoughness, float3 fresnel0, out float3 specularFGD, out float3 diffuseFGD)
{
#ifdef _FABRIC_SILK_MATERIAL
    float2 coordLUT = Remap01ToHalfTexelCoord(float2(sqrt(NdotV), perceptualRoughness), FGDTEXTURE_RESOLUTION);
    float3 preFGD = SAMPLE_TEXTURE2D_LOD(_PreIntegratedFGD, s_linear_clamp_sampler, coordLUT, 0).xyz;
    specularFGD = lerp(preFGD.xxx, preFGD.yyy, fresnel0);
    diffuseFGD = preFGD.z + 0.5;
#else
    float2 coordLUT = Remap01ToHalfTexelCoord(float2(NdotV, perceptualRoughness), FGDTEXTURE_RESOLUTION);
    float3 preFGD = SAMPLE_TEXTURE2D_LOD(_PreIntegratedFGD, s_linear_clamp_sampler, coordLUT, 0).xyz;
    specularFGD = lerp(preFGD.xxx, preFGD.yyy, fresnel0) * 2.0f * PI;
    diffuseFGD = preFGD.z;
#endif
}

void ImageBaseInDirectLighting(InputData inputData, BRDFData brdfData, Light light, inout float3 diffuseLighting, inout float3 specularLighting)
{
    float NdotV = max(saturate(dot(inputData.normalWS, inputData.viewDirectionWS)), 0.00001);
    half3 iblNormalWS = inputData.normalWS;
    half iblPerceptualRoughness = brdfData.perceptualRoughness;
#ifdef _ANISOTROPIC
    GetGGXAnisotropicModifiedNormalAndRoughness(anisotropicData.bitangentWS, anisotropicData.tangentWS,
        inputData.normalWS, inputData.viewDirectionWS, anisotropicData.anisotropic, brdfData.perceptualRoughness,
        iblNormalWS, iblPerceptualRoughness);
#endif

    half3 diffuseGI = inputData.bakedGI;
    half3 specularGI = IBL_EnvironmentReflection(inputData.viewDirectionWS, iblNormalWS, iblPerceptualRoughness);
  
    half3 diffuseFGD;
    half3 specularFGD;
    GetPreIntegratedGGX(NdotV, brdfData.perceptualRoughness, brdfData.specular, specularFGD, diffuseFGD);
    diffuseLighting += diffuseGI * brdfData.diffuse * diffuseFGD;
    specularLighting += specularGI * specularFGD;
  
}

void PhysicallyBaseDirectAdditionalLighting(InputData inputData, BRDFData brdfData, inout half3 diffuse, inout half3 specular)
{
#ifdef _ADDITIONAL_LIGHTS
    uint pixelLightCount = GetAdditionalLightsCount();
    for (uint lightIndex = 0u; lightIndex < pixelLightCount; ++lightIndex)
    {
        Light light = GetAdditionalLight(lightIndex, inputData.positionWS, inputData.shadowMask);
        PhysicallyBaseDirectLighting(inputData, brdfData, light, diffuse, specular);
    }
#endif
}

float4 FabricLit(InputData inputData, SurfaceData surfaceData , float3 tangent)
{
    Light mainLight = GetMainLight(inputData.shadowCoord, inputData.positionWS, inputData.shadowMask);
#if defined(LIGHTMAP_ON) && defined(_MIXED_LIGHTING_SUBTRACTIVE)
    inputData.bakedGI = SubtractDirectMainLightFromLightmap(mainLight, inputData.normalWS, inputData.bakedGI);
#endif

#ifdef _FABRIC_SILK_MATERIAL
    InitializationAnisotropicData(inputData.normalWS, tangent , 1.0 - surfaceData.smoothness, anisotropicData);
#endif

    BRDFData brdfData;
    InitializeBRDFData(surfaceData.albedo, surfaceData.metallic, surfaceData.specular, surfaceData.smoothness, brdfData);
//  Anisotropic -----------------------------------------------------------------------------------

//  -----------------------------------------------------------------------------------------------

    half3 diffuseLighting = float3(0, 0, 0);
    half3 specularLighting = float3(0, 0, 0);
    PhysicallyBaseDirectLighting(inputData, brdfData, mainLight, diffuseLighting, specularLighting);

    ImageBaseInDirectLighting(inputData, brdfData, mainLight, diffuseLighting, specularLighting);
 
    PhysicallyBaseDirectAdditionalLighting(inputData, brdfData, diffuseLighting, specularLighting);

// #if defined(_SCREEN_SPACE_OCCLUSION)
//     AmbientOcclusionFactor aoFactor = GetScreenSpaceAmbientOcclusion(inputData.normalizedScreenSpaceUV);
//     diffuseLighting *= min(surfaceData.occlusion, aoFactor.indirectAmbientOcclusion);
//     specularLighting *= min(surfaceData.occlusion, aoFactor.indirectAmbientOcclusion);
// #else
//     diffuseLighting *= surfaceData.occlusion;
//     specularLighting *= surfaceData.occlusion;
// #endif
 
    half3 color = diffuseLighting + specularLighting;

    half alpha = surfaceData.alpha;

    return float4(color, alpha);
}
#endif