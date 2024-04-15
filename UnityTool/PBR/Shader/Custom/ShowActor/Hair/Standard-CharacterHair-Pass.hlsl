#ifndef STANDARD_CHARACTER_HAIR_PASS
#define STANDARD_CHARACTER_HAIR_PASS

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

#define DEFAULT_HAIR_SPECULAR_VALUE 0.0465

void GetTBByN(SurfaceData surfaceData, half3x3 tangentToWorld, half normalAniso, inout half3 t, inout half3 b)
{
    half3 tangentTS = normalize(surfaceData.normalTS.x * half3(0, 0, 1) * normalAniso + half3(1, 0, 0));
    t = TransformTangentToWorld(tangentTS, tangentToWorld);
    t = NormalizeNormalPerPixel(t);

    half3 bitangentTS = normalize(surfaceData.normalTS.y * half3(0, 0, 1) * normalAniso + half3(0, 1, 0));
    b = TransformTangentToWorld(bitangentTS, tangentToWorld);
    b = NormalizeNormalPerPixel(b);
}

float RoughnessToBlinnPhongSpecularExponent(float roughness)
{
    return clamp(2 * rcp(roughness * roughness) - 2, FLT_EPS, rcp(FLT_EPS));
}


struct DirectLighting
{
    half3 diffuseLighting;
    half3 specularLighting;
};

struct Attributes
{
    float4 positionOS : POSITION;
    float3 normalOS : NORMAL;
    float4 tangentOS : TANGENT;
    float2 uv : TEXCOORD0;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct Varyings
{
    float4 positionCS : SV_POSITION;
    float3 positionVS : VAR_POSITIONVS;
    float3 positionWS : VAR_POSITION;
    float3 normalWS : VAR_NORMAL;
    float3 tangentWS : VAR_TANGENT;
    float3 bitangentWS : VAR_BITANGENT;
    float3 viewDirWS : VAR_VIEW;
    float2 uv : VAR_UV;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

Varyings LitVertex(Attributes input)
{
    Varyings output = (Varyings)0;
    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_TRANSFER_INSTANCE_ID(input, output);

    VertexPositionInputs positionInputs = GetVertexPositionInputs(input.positionOS.xyz);
    VertexNormalInputs normalInputs = GetVertexNormalInputs(input.normalOS, input.tangentOS);
    output.positionWS = positionInputs.positionWS;
    output.positionVS = positionInputs.positionVS;
    output.positionCS = positionInputs.positionCS;
    output.normalWS = normalInputs.normalWS;
    output.tangentWS = normalInputs.tangentWS;
    output.bitangentWS = normalInputs.bitangentWS;
    output.viewDirWS = SafeNormalize(_WorldSpaceCameraPos.xyz - positionInputs.positionWS);
    output.uv = input.uv * _MainTex_ST.xy + _MainTex_ST.zw;
    return output;
}

float4 LitFragment(Varyings input) : SV_TARGET
{
    UNITY_SETUP_INSTANCE_ID(input);
    float2 uv = input.uv;
//  Base Texture ---------------------------------------------------------------------------------------------------
    float geoNdotV = max(saturate(dot(input.normalWS, input.viewDirWS)), 0.00001);
    SurfaceData surfaceData;
    

    ///É¾³ýÔë²¨Í¼

//    half noiseMap = 0;
//#ifndef _DISABLED_NOISE_COLOR
//    float2 noiseUV = input.uv * _NoiseMap_ST.xy;
//    noiseMap = SAMPLE_TEXTURE2D(_NoiseMap, sampler_NoiseMap, noiseUV).r;
//#endif

    half4 albedoAlpha = SampleAlbedoAlpha(uv, _MainTex, sampler_MainTex);
   half alpha = albedoAlpha.r;
    albedoAlpha.rgb *= lerp(_FresnelColor.rgb, _BaseColor.rgb, geoNdotV * geoNdotV);
 //   albedoAlpha.rgb = albedoAlpha.rgb * noiseMap + albedoAlpha.rgb;
    albedoAlpha.a = alpha * _BaseColor.a;
    half3 normalTS = half3(0, 0, 1);
#ifdef _NORMALMAP
    normalTS = UnpackNormalScale(SAMPLE_TEXTURE2D(_NormalMap, sampler_NormalMap, uv), _NormalIntensity);
#endif

    _Smoothness = clamp(_Smoothness, 0.001, 0.999);
    _SecondarySmoothness = clamp(_SecondarySmoothness, 0.001, 0.999);


    surfaceData.albedo = albedoAlpha.rgb;
    surfaceData.metallic = _Metallic;
    surfaceData.smoothness = _Smoothness;
    surfaceData.normalTS = normalTS;
    surfaceData.alpha = saturate(albedoAlpha.a / (_TransparentWeight));
    #ifdef _ALPHATEST_ON
    clip(surfaceData.alpha - _Cutoff);
    #endif
 
//  InputData ------------------------------------------------------------------------------------------------------
    InputData inputData;
    inputData.positionWS = input.positionWS;
    inputData.normalWS = NormalizeNormalPerPixel(TransformTangentToWorld(surfaceData.normalTS, float3x3(input.tangentWS, input.bitangentWS, input.normalWS)));
    inputData.viewDirectionWS = input.viewDirWS;
#if defined(MAIN_LIGHT_CALCULATE_SHADOWS) || !defined(_MAIN_LIGHT_SHADOWS_CASCADE)
    inputData.shadowCoord = TransformWorldToShadowCoord(input.positionWS);
#else
    inputData.shadowCoord = float4(0, 0, 0, 0);
#endif
//  ----------------------------------------------------------------------------------------------------------------
//  BRDF Data ------------------------------------------------------------------------------------------------------
    BRDFData brdfData = (BRDFData)0;
    half diffuseReflectivity = (1 - DEFAULT_HAIR_SPECULAR_VALUE)  * (1 - surfaceData.metallic);
    brdfData.diffuse = surfaceData.albedo * diffuseReflectivity;
    brdfData.specular = lerp(DEFAULT_HAIR_SPECULAR_VALUE, surfaceData.albedo, surfaceData.metallic);
    brdfData.perceptualRoughness = 1 - surfaceData.smoothness;

    Light mainLight = GetMainLight(inputData.shadowCoord);
    float3 T = input.tangentWS;
    float3 B = input.bitangentWS;
    GetTBByN(surfaceData, float3x3(input.tangentWS, input.bitangentWS, input.normalWS), _NormalAniso, T, B);
    float3 N = inputData.normalWS;
    float3 L = mainLight.direction;
    float3 V = input.viewDirWS;
    float3 H = normalize(L + V);
//  -----------------------------------------------------------------------------------------------------------------------------------------
//  Kajiya ----------------------------------------------------------------------------------------------------------------------------------
    half shiftMap = 1;
#ifndef _DISABLED_NOISE_COLOR
    float2 shiftUV = input.uv * _ShiftMap_ST.xy + _ShiftMap_ST.zw;
    shiftMap = SAMPLE_TEXTURE2D(_ShiftMap, sampler_ShiftMap, shiftUV).r;
#endif

    half3 hairSpec1 = 0;
    half3 hairSpec2 = 0;
    half specularExponent = RoughnessToBlinnPhongSpecularExponent(brdfData.perceptualRoughness * brdfData.perceptualRoughness);
    float3 t1 = ShiftTangent(B, N, _Shift);
    hairSpec1 = _SpecularTint.rgb * shiftMap * D_KajiyaKay(t1, H, specularExponent) * _SpecularMultiplyer;

 
#ifndef _DISABLED_SECONDARY_SPECULAR
    half secondarySpecularExponent = RoughnessToBlinnPhongSpecularExponent((1 - _SecondarySmoothness) * (1 - _SecondarySmoothness));
    float3 t2 = ShiftTangent(B, N, _SecondaryShift);
    hairSpec2 = _SecondarySpecularTint.rgb * shiftMap * D_KajiyaKay(t2, H, secondarySpecularExponent) * _SecondarySpecularMultiplyer;
#endif
//  -----------------------------------------------------------------------------------------------------------------------------------------
//  Direct BRDF Lighting --------------------------------------------------------------------------------------------------------------------
    float LdotH = dot(L, H);
    float NdotL = max(saturate(dot(N, L)), 0.00001);
    float NdotV = max(saturate(dot(N, V)), 0.00001);
    float3 F = F_Schlick(brdfData.specular, LdotH);

    DirectLighting directLighting;
    half3 shadowColor = lerp(_ShadowColor.rgb, half3(1, 1, 1), mainLight.shadowAttenuation * mainLight.distanceAttenuation * NdotL);
    half3 lighting = mainLight.color * shadowColor * _LightingMultiplyer;
    directLighting.specularLighting = 0.25 * F * (hairSpec1 + hairSpec2) * saturate(NdotV * FLT_MAX) * lighting;
 
    half3 scatterLight = saturate(_SactterColor.rgb + NdotL) * saturate((NdotL + _ScatterOffset) / (1 + _ScatterOffset));
    directLighting.diffuseLighting = brdfData.diffuse * scatterLight * lighting;

//  -----------------------------------------------------------------------------------------------------------------------------------------
//  Additional Lighting ---------------------------------------------------------------------------------------------------------------------
#ifndef _DISABLED_ADDITIONAL_LIGHTING
#ifdef _ADDITIONAL_LIGHTS
    uint pixelLightCount = GetAdditionalLightsCount();
    DirectLighting additionalLighting;
    for (uint lightIndex = 0u; lightIndex < pixelLightCount; ++lightIndex)
    {
        Light light = GetAdditionalLight(lightIndex, inputData.positionWS);
        float addNdotL = max(saturate(dot(input.normalWS, light.direction)), 0.00001);
        half3 addNdotLColor = addNdotL * light.color * _LightingMultiplyer * light.shadowAttenuation * light.distanceAttenuation;
        half3 scatterAddLight = saturate(_SactterColor.rgb + addNdotLColor) * saturate((addNdotLColor + _ScatterOffset) / (1 + _ScatterOffset));
        additionalLighting.diffuseLighting = brdfData.diffuse * scatterAddLight * addNdotLColor;
        float3 addH = normalize(light.direction + V);
        float addLdotH = dot(light.direction, addH);
        float3 addF = F_Schlick(brdfData.specular, addLdotH);
        half3 addHairSpec = _SpecularTint.rgb * shiftMap * D_KajiyaKay(t1, addH, specularExponent) * _SpecularMultiplyer;
        additionalLighting.specularLighting = 0.25 * addF * addHairSpec * saturate(NdotV * FLT_MAX) * addNdotLColor;
        directLighting.diffuseLighting += additionalLighting.diffuseLighting;
        directLighting.specularLighting += additionalLighting.specularLighting;
    }
#endif
#endif
//  -----------------------------------------------------------------------------------------------------------------------------------------
    half3 color = directLighting.diffuseLighting + directLighting.specularLighting;
    return half4(color, surfaceData.alpha);
}
#endif