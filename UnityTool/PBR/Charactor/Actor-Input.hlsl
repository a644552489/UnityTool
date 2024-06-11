
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/CommonMaterial.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

#if defined(_DETAIL_MULX2) || defined(_DETAIL_SCALED)
    #define _DETAIL
#endif

// NOTE: Do not ifdef the properties here as SRP batcher can not handle different layouts.
CBUFFER_START(UnityPerMaterial)

    float _VertexColor;
    float _IndirectBright;
    float _Saturation;
    float _DirectBright;
    float _EnvReflectionScale;

    float4 _BaseMap_ST;
    half4 _BaseColor;
    half _BaseColorDensity;
    half _ShadowColorDensity;
    half4 _DetailBaseColorTexture_ST;
    float _DetailBlend;

    float4 _Layer2_BaseColorTexture_ST;
    float4 _Layer2Normal_ST;
    float _Layer2Blend;

    half _Cutoff;
    half _Smoothness;
    half _Metallic;
    half _BumpScale;
    // half _Parallax;
    half _Occlusion;
    // half _ClearCoatMask;

    half4 _DetailNormal_ST;
    half4 _SpecularColor;
    half _FuzzStrength;
    half4 _FuzzColor;
    half4 _FuzzMap_ST;
    half _NormalIntensity;

    float _ShadowStep;
    float _ShadowOffset;
    half _ShadowFalloff;
    half _StepShadowStrenth;
    

    #ifdef _FABRIC_SILK_MATERIAL
    #define _ANISOTROPIC
        half _Anisotropic;
    #endif
    ///
    ///Skin
    ///
    float4 _FrenelColor;

    //RIM
    float _FresnelAddPow;
    float3 _FresnelAddColor;
    float _FresnelAddSmooth;
    float _FresnelMixL;

    float _FresnelMulPointLight;
    float _FresnelFalloffValue;

    half4 _TransColor;
    //Hair
    half _LightingMultiplyer;
    half4 _ShiftMap_ST;
    half4 _SpecularTint;
    half _SpecularMultiplyer;
    half _Shift;
    half4 _SecondarySpecularTint;
    half _SecondarySpecularMultiplyer;
    half _SecondarySmoothness;
    half _SecondaryShift;
    
    float _NormalAniso;
    
    half4 _SactterColor;
    half _ScatterOffset;
    

    float _StylizedReflectionWeight;
    float _StylizedReflectionDensity;

    

CBUFFER_END

TEXTURE2D(_DetailBaseColorTexture);
SAMPLER(sampler_DetailBaseColorTexture);
TEXTURE2D(_Layer2_BaseColorTexture);
SAMPLER(sampler_Layer2_BaseColorTexture);

TEXTURE2D(_MSAMap);
SAMPLER(sampler_MSAMap);

TEXTURE2D(_FuzzMap);
SAMPLER(sampler_FuzzMap);

TEXTURE2D(_DetailNormal);
SAMPLER(sampler_DetailNormal);
TEXTURE2D(_Layer2_NormalTexture);
SAMPLER(sampler_Layer2_NormalTexture);

TEXTURE2D(_3SRampMap);
SAMPLER(sampler_3SRampMap);

TEXTURE2D(_NoiseMap);
SAMPLER(sampler_NoiseMap);

TEXTURE2D(_ShiftMap);
SAMPLER(sampler_ShiftMap);

TEXTURE2D(_StylizedReflectionMap);
SAMPLER(sampler_StylizedReflectionMap);

TEXTURE2D(_CustomShadowMap);
SAMPLER(sampler_CustomShadowMap);

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

#ifdef _SPECULAR_SETUP
    #define SAMPLE_METALLICSPECULAR(uv) SAMPLE_TEXTURE2D(_SpecGlossMap, sampler_SpecGlossMap, uv)
#else
    #define SAMPLE_METALLICSPECULAR(uv) SAMPLE_TEXTURE2D(_MetallicGlossMap, sampler_MetallicGlossMap, uv)
#endif

half CustomAlpha(half albedoAlpha, half4 color, half cutoff)
{
    #if !defined(_SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A) && !defined(_GLOSSINESS_FROM_BASE_ALPHA)
    half alpha = albedoAlpha * color.a;
    #else
    half alpha = color.a;
    #endif

    #if defined(_ALPHATEST_ON)
    clip(alpha - cutoff);
    #endif

    return alpha;
}

float Pow2(float x)
{
    return x*x;
}



float RemapFloatValue(float oldLow, float oldHigh, float newLow, float newHigh, float invalue)
{
    return newLow + (invalue - oldLow) * (newHigh - newLow) / (oldHigh - oldLow);
}

float3 RemapFloat3Value(float oldLow, float oldHigh, float newLow, float newHigh, float3 invalue)
{
    float3 Ret = 0.0f;
    Ret.r = RemapFloatValue(oldLow, oldHigh, newLow, newHigh, invalue.r);
    Ret.g = RemapFloatValue(oldLow, oldHigh, newLow, newHigh, invalue.g);
    Ret.b = RemapFloatValue(oldLow, oldHigh, newLow, newHigh, invalue.b);
    return Ret;
}

half3 ComputeFresnelAdd(half NoV,half mask)
{
    half fresnel = saturate(pow(saturate(1 - NoV),_FresnelAddPow));
    fresnel = fresnel * mask;
    return lerp(half3(0,0,0),_FresnelAddColor,smoothstep(0.5-_FresnelAddSmooth,0.5+_FresnelAddSmooth,fresnel));   
    
}

half3 ComputeFresnelAdd(half NoV,half mask,half3 color)
{
    half fresnel = saturate(pow(saturate(1 - NoV),_FresnelAddPow));
    fresnel = fresnel * mask;
    return lerp(half3(0,0,0),color,smoothstep(0.5-_FresnelAddSmooth,0.5+_FresnelAddSmooth,fresnel));   
}

half3 ComputeAddLitDir(float3 positionWS,half3 normalWS)
{
    half3 PointLightResult = 0.0;
    
    #ifdef _ADDITIONAL_LIGHTS
    uint pixelLightCount = GetAdditionalLightsCount();
    for (uint lightIndex = 0u; lightIndex < pixelLightCount; ++lightIndex)
    {
        half3 zeroPositionWS = TransformObjectToWorld(float3(0,0,0));
        Light light = GetAdditionalLight(lightIndex, positionWS.xyz);
        // lambert
        half NoL = saturate(dot(normalize(normalWS), light.direction));// 算兰伯特
        half attenuation = light.distanceAttenuation;
        PointLightResult += attenuation * NoL * light.color;// * adobleColor;
        //#endif
    }
    #endif
    
    return PointLightResult;
}

half3 RimEdge(float3 positionWS , float3 normalWS ,float positionOS_Y, float halfLambert , float NoV  )
{
    half3 pointLightFresnel = ComputeAddLitDir(positionWS,normalWS) * _FresnelMulPointLight;// *lambert;
    half fresnelMask = smoothstep(0.3,0.6,saturate(halfLambert + 0.5 - _FresnelMixL));
    half  falloff = positionOS_Y;
    falloff = saturate(falloff + -_FresnelFalloffValue*2);
    fresnelMask = smoothstep(0,0.5,falloff)*fresnelMask;

    //final *= lerp(half3(1.0,1.0,1.0),ComputeFresnelMul(NoVSam ,halfLambert ,var_Ramp0.rgb),_FresnelOn* var_Illum.a);// 一个MUL
    float3 final =0;
    //主光Rim
    final += ComputeFresnelAdd(NoV, fresnelMask);// 一个Add
    //点光Rim
    final += ComputeFresnelAdd(NoV, 1,pointLightFresnel);// 一个Add
    return final;
}

half2 EnvBRDFApproxLazarov(half Roughness, half NoV)
{
    // [ Lazarov 2013, "Getting More Physical in Call of Duty: Black Ops II" ]
    // Adaptation to fit our G term.
    const half4 c0 = { -1, -0.0275, -0.572, 0.022 };
    const half4 c1 = { 1, 0.0425, 1.04, -0.04 };
    half4 r = Roughness * c0 + c1;
    half a004 = min(r.x * r.x, exp2(-9.28 * NoV)) * r.x + r.y;
    half2 AB = half2(-1.04, 1.04) * a004 + r.zw;
    return AB;
}
half3 EnvBRDFApprox( half3 SpecularColor, half Roughness, half NoV )
{
    half2 AB = EnvBRDFApproxLazarov(Roughness, NoV);

    // Anything less than 2% is physically impossible and is instead considered to be shadowing
    // Note: this is needed for the 'specular' show flag to work, since it uses a SpecularColor of 0
    float F90 = saturate( 50.0 * SpecularColor.g );

    return SpecularColor * AB.x + F90 * AB.y;
}


#define REFLECTION_CAPTURE_ROUGHEST_MIP 1
#define REFLECTION_CAPTURE_ROUGHNESS_MIP_SCALE 1.2

half ComputeReflectionCaptureMipFromRoughness(half Roughness, half CubemapMaxMip)
{
    // Heuristic that maps roughness to mip level
    // This is done in a way such that a certain mip level will always have the same roughness, regardless of how many mips are in the texture
    // Using more mips in the cubemap just allows sharper reflections to be supported
    half LevelFrom1x1 = REFLECTION_CAPTURE_ROUGHEST_MIP - REFLECTION_CAPTURE_ROUGHNESS_MIP_SCALE * log2(max(Roughness, 0.001));
    return CubemapMaxMip - LevelFrom1x1 + 1;
}

//reflect : 2 * dot(V,N)* N -V;
float3 GetSkyLightReflection(float3 V , float3 N ,float roughness )
{
    float3 refl = 2 * dot(V , N) * N - V;
    
    float Mip = ComputeReflectionCaptureMipFromRoughness(roughness,UNITY_SPECCUBE_LOD_STEPS);
    
    float4 Reflection = SAMPLE_TEXTURECUBE_LOD(unity_SpecCube0 , samplerunity_SpecCube0 ,refl ,Mip);
    
   // float3  irradiance = DecodeHDREnvironment(Reflection, unity_SpecCube0_HDR);
    
    return Reflection;

}

/**
 * 
 * 
 * 
 * 
 * 
 * 
 */
struct BxDFContext
{
    half NoV;
    half NoL;
    half VoL;
    half NoH;
    half VoH;
};
void Init(inout BxDFContext Context, half3 N, half3 V, half3 L)
{
    Context = (BxDFContext)0;

    Context.NoL = dot(N, L);
    Context.NoV = dot(N, V);
    Context.VoL = dot(V, L);
    float InvLenH = rsqrt(2 + 2 * Context.VoL);
    Context.NoH = saturate((Context.NoL + Context.NoV) * InvLenH);
    Context.VoH = saturate(InvLenH + InvLenH * Context.VoL);
}

half4 SampleMetallicSpecGloss(float2 uv, half albedoAlpha)
{
    half4 specGloss;

    #ifdef _METALLICSPECGLOSSMAP
        specGloss = SAMPLE_METALLICSPECULAR(uv);
        #ifdef _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
            specGloss.a = albedoAlpha * _Smoothness;
        #else
            specGloss.a *= _Smoothness;
        #endif
    #else // _METALLICSPECGLOSSMAP
        #if _SPECULAR_SETUP
            specGloss.rgb = _SpecColor.rgb;
        #else
            specGloss.rgb = _Metallic.rrr;
        #endif

        #ifdef _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
            specGloss.a = albedoAlpha * _Smoothness;
        #else
            specGloss.a = _Smoothness;
        #endif
    #endif

    return specGloss;
}

half SampleOcclusion(float2 uv)
{
    #ifdef _OCCLUSIONMAP
    // TODO: Controls things like these by exposing SHADER_QUALITY levels (low, medium, high)
        #if defined(SHADER_API_GLES)
            return SAMPLE_TEXTURE2D(_OcclusionMap, sampler_OcclusionMap, uv).g;
        #else
            half occ = SAMPLE_TEXTURE2D(_OcclusionMap, sampler_OcclusionMap, uv).g;
            return LerpWhiteTo(occ, _OcclusionStrength);
        #endif
    #else
        return 1.0;
    #endif
}

half3 ApplyDetailNormal(float2 detailUv, half3 normalTS)
{
    half3 detailNormalTS = UnpackNormalScale(SAMPLE_TEXTURE2D(_DetailNormal, sampler_DetailNormal, detailUv), _NormalIntensity);
    // With UNITY_NO_DXT5nm unpacked vector is not normalized for BlendNormalRNM
    // For visual consistancy we going to do in all cases
    detailNormalTS = normalize(detailNormalTS);
    return BlendNormalRNM(normalTS, detailNormalTS); // todo: detailMask should lerp the angle of the quaternion rotation, not the normals
}

// Returns clear coat parameters
// .x/.r == mask
// .y/.g == smoothness
half2 SampleClearCoat(float2 uv)
{
    #if defined(_CLEARCOAT) || defined(_CLEARCOATMAP)
        half2 clearCoatMaskSmoothness = half2(_ClearCoatMask, _ClearCoatSmoothness);

        #if defined(_CLEARCOATMAP)
            clearCoatMaskSmoothness *= SAMPLE_TEXTURE2D(_ClearCoatMap, sampler_ClearCoatMap, uv).rg;
        #endif

        return clearCoatMaskSmoothness;
    #else
        return half2(0.0, 1.0);
    #endif  // _CLEARCOAT
}

half3 BlendPinLight(float3 blendOpSrc,float3 blendOpDest,float a)
{
    return lerp(blendOpDest,(( blendOpSrc > 0.5 ) ? max( blendOpDest, 2.0 * ( blendOpSrc - 0.5 ) ) : min( blendOpDest, 2.0 * blendOpSrc ) ),a);
}

inline void InitializeStandardLitSurfaceData(float2 uv, out SurfaceData outSurfaceData,half3 msa)
{
    outSurfaceData = (SurfaceData)0;
    half4 albedoAlpha = SampleAlbedoAlpha(uv.xy, TEXTURE2D_ARGS(_BaseMap, sampler_BaseMap));
    outSurfaceData.alpha = Alpha(albedoAlpha.a, _Cutoff);
    
    outSurfaceData.albedo =albedoAlpha.rgb * _BaseColor.rgb;

    outSurfaceData.metallic =msa.r * _Metallic;
    outSurfaceData.specular = half3(0.h, 0.h, 0.h);//half3(0.5h, 0.5h, 0.5h);

    outSurfaceData.smoothness = saturate(msa.g * _Smoothness);
    outSurfaceData.normalTS = SampleNormal(uv.xy, TEXTURE2D_ARGS(_BumpMap, sampler_BumpMap), _BumpScale);
    outSurfaceData.occlusion = msa.b * _Occlusion;
    // #if defined (_EMISSION_DYNAMIC)
    //     float emissionMask = SAMPLE_TEXTURE2D(_WaveMap,sampler_WaveMap,uv.zw).r;
    //     outSurfaceData.emission = SampleEmission(uv.xy, _EmissionColor.rgb * emissionMask, TEXTURE2D_ARGS(_EmissionMap, sampler_EmissionMap));
    // #else
    //     outSurfaceData.emission = SampleEmission(uv.xy, _EmissionColor.rgb, TEXTURE2D_ARGS(_EmissionMap, sampler_EmissionMap));
    // #endif

    #if defined(_CLEARCOAT) || defined(_CLEARCOATMAP)
        half2 clearCoat = SampleClearCoat(uv.xy);
        outSurfaceData.clearCoatMask       = clearCoat.r;
        outSurfaceData.clearCoatSmoothness = clearCoat.g;
    #else
        outSurfaceData.clearCoatMask       = 0.0h;
        outSurfaceData.clearCoatSmoothness = 0.0h;
    #endif

    #ifdef _DETAIL
        float2 detailUV = uv * _DetailNormal_ST.xy + _DetailNormal_ST.zw;
        float3 BlendNormal = ApplyDetailNormal(detailUV ,outSurfaceData.normalTS);
        outSurfaceData.normalTS = BlendNormal;
    #endif

    #ifdef _FUZZMAP
    half fuzzMap = SAMPLE_TEXTURE2D(_FuzzMap, sampler_FuzzMap, uv * _FuzzMap_ST.xy + _FuzzMap_ST.zw).r * _FuzzStrength;
    outSurfaceData.albedo += fuzzMap * _FuzzColor.rgb;
    #endif
}

inline void InitializeStandardLitSurfaceData(float2 uv, out SurfaceData outSurfaceData)
{
    outSurfaceData = (SurfaceData)0;
    half4 albedoAlpha = SampleAlbedoAlpha(uv.xy, TEXTURE2D_ARGS(_BaseMap, sampler_BaseMap));
    outSurfaceData.alpha = Alpha(albedoAlpha.a, _Cutoff);

    outSurfaceData.albedo = albedoAlpha.rgb * _BaseColor.rgb;
    
    outSurfaceData.metallic = _Metallic;
    outSurfaceData.specular = half3(0.0h, 0.0h, 0.0h);//half3(0.5h, 0.5h, 0.5h);

    outSurfaceData.smoothness = saturate( _Smoothness);
    outSurfaceData.normalTS = SampleNormal(uv.xy, TEXTURE2D_ARGS(_BumpMap, sampler_BumpMap), _BumpScale);
    outSurfaceData.occlusion = _Occlusion;
    // #if defined (_EMISSION_DYNAMIC)
    //     float emissionMask = SAMPLE_TEXTURE2D(_WaveMap,sampler_WaveMap,uv.zw).r;
    //     outSurfaceData.emission = SampleEmission(uv.xy, _EmissionColor.rgb * emissionMask, TEXTURE2D_ARGS(_EmissionMap, sampler_EmissionMap));
    // #else
    //     outSurfaceData.emission = SampleEmission(uv.xy, _EmissionColor.rgb, TEXTURE2D_ARGS(_EmissionMap, sampler_EmissionMap));
    // #endif

    #if defined(_CLEARCOAT) || defined(_CLEARCOATMAP)
        half2 clearCoat = SampleClearCoat(uv.xy);
        outSurfaceData.clearCoatMask       = clearCoat.r;
        outSurfaceData.clearCoatSmoothness = clearCoat.g;
    #else
        outSurfaceData.clearCoatMask       = 0.0h;
        outSurfaceData.clearCoatSmoothness = 0.0h;
    #endif

    #ifdef _DETAIL
        float2 detailUV = uv * _DetailNormal_ST.xy + _DetailNormal_ST.zw;
        float3 BlendNormal = ApplyDetailNormal(detailUV ,outSurfaceData.normalTS);
        outSurfaceData.normalTS = BlendNormal;
    #endif
}

float US_D_GGX(float a2, float NoH)
{
    float d = (NoH * a2 - NoH) * NoH + 1;	// 2 mad
    return a2 / (PI*d*d);					// 4 mul, 1 rcp
}

// Appoximation of joint Smith term for GGX
// [Heitz 2014, "Understanding the Masking-Shadowing Function in Microfacet-Based BRDFs"]
float US_Vis_SmithJointApprox(float a2, float NoV, float NoL)
{
    float a = sqrt(a2);
    float Vis_SmithV = NoL * (NoV * (1 - a) + a);
    float Vis_SmithL = NoV * (NoL * (1 - a) + a);
    return 0.5 * rcp(Vis_SmithV + Vis_SmithL);
}

// [Schlick 1994, "An Inexpensive BRDF Model for Physically-Based Rendering"]
float3 US_F_Schlick(float3 SpecularColor, float VoH)
{
    float Fc = Pow5(1 - VoH);					// 1 sub, 3 mul
    //return Fc + (1 - Fc) * SpecularColor;		// 1 add, 3 mad
    // Anything less than 2% is physically impossible and is instead considered to be shadowing
    return saturate(50.0 * SpecularColor.g) * Fc + (1 - Fc) * SpecularColor;
}

float3 US_SpecularGGX(float Roughness, float3 SpecularColor, BxDFContext Context, half NoL, half3 N)
{
    float a2 = Pow4(Roughness);
    // Generalized microfacet specular
    float D = US_D_GGX(a2, Context.NoH);
    float Vis = US_Vis_SmithJointApprox(a2, Context.NoV, NoL);
    float3 F = US_F_Schlick(SpecularColor, Context.VoH);
    return (D * Vis) * F;
}

half3 US_DefaultLitBxDFSpecular(BRDFData brdfData, half3 N, half3 V, half3 L)
{
    BxDFContext Context;
    half NoV, VoH, NoH;
    Init(Context, N, V, L);
    NoV = Context.NoV;
    VoH = Context.VoH;
    NoH = Context.NoH;
    half NoL = saturate(Context.NoL);
    Context.NoV = saturate(abs(Context.NoV) + 1e-5);
    half3 Direct_Specular = US_SpecularGGX(max(brdfData.perceptualRoughness, 0.05), brdfData.specular, Context, NoL, N);
    return Direct_Specular;
}

float CalcuateRamp(float lambert)
{
    float diffR = 0.0;
    for(int i = 0; i < (int)_ShadowStep; i++)
    {
        float x = i / _ShadowStep * (1.0 - _ShadowOffset);
        diffR += smoothstep(x, x + _ShadowFalloff ,lambert);
    }
    diffR = diffR / _ShadowStep;
    return pow(diffR, _StepShadowStrenth);
}

half3 LightingPhysicallyBased_BxDF(BRDFData brdfData, Light light, 
    half3 normalWS, half3 viewDirectionWS)
{
    half3 lightColor = light.color;
    half3 lightDirectionWS = light.direction;
    half lightAttenuation = light.distanceAttenuation * light.shadowAttenuation;
    half NdotL = saturate(dot(normalWS, lightDirectionWS));
    half3 radiance = lightColor * (lightAttenuation * NdotL);
    
    half3 SpecularLighting = brdfData.specular * US_DefaultLitBxDFSpecular(brdfData, normalWS, lightDirectionWS, viewDirectionWS) * radiance;
    half3 DiffuseLighting = brdfData.diffuse  * radiance * _DirectBright;

    return DiffuseLighting + SpecularLighting;
}

half3 LightingPhysicallyBased_ToonHair(BRDFData brdfData, Light light, 
    half3 normalWS, half3 viewDirectionWS)
{
    half3 lightColor = light.color;
    half3 lightDirectionWS = light.direction;
    half lightAttenuation = light.distanceAttenuation * light.shadowAttenuation;
    half NdotL = dot(normalWS, lightDirectionWS);
    half3 radiance = lightColor * (NdotL);
    
    half3 SpecularLighting = brdfData.specular * US_DefaultLitBxDFSpecular(brdfData, normalWS, lightDirectionWS, viewDirectionWS) * radiance;
    half ShadowMask = smoothstep(_ShadowOffset, _ShadowOffset + _ShadowFalloff, NdotL * 0.5 + 0.5);
    half3 DiffuseLighting = brdfData.diffuse * _BaseColorDensity * lightColor * RemapFloatValue(0, 1, _ShadowColorDensity, 1, ShadowMask);
    
    return (DiffuseLighting + SpecularLighting) * RemapFloatValue(0, 1, 0.2, 1, lightAttenuation);
}
half3 LightingPhysicallyBased_ToonHair_LocalLight(BRDFData brdfData, Light light, 
    half3 normalWS, half3 viewDirectionWS)
{
    half3 lightColor = light.color;
    half3 lightDirectionWS = light.direction;
    half lightAttenuation = light.distanceAttenuation * light.shadowAttenuation;
    half NdotL = dot(normalWS, lightDirectionWS);

    half ShadowMask = smoothstep(_ShadowOffset, _ShadowOffset + _ShadowFalloff, NdotL * 0.5 + 0.5);
    half3 radiance = lightColor * (lightAttenuation * ShadowMask);
    
    half3 SpecularLighting = brdfData.specular * US_DefaultLitBxDFSpecular(brdfData, normalWS, lightDirectionWS, viewDirectionWS) * radiance;
    half3 DiffuseLighting = brdfData.diffuse * _BaseColorDensity * radiance;
    
    return DiffuseLighting + SpecularLighting;
}

half3 LightingPhysicallyBased_ToonLit(
    BRDFData brdfData,
    Light light, 
    half3 normalWS,
    half3 viewDirectionWS
    )
{
    half3 LightColor = light.color;
    half3 L = light.direction;
    half ShadowMask = light.distanceAttenuation * light.shadowAttenuation;
    half NoL = dot(normalWS, L);
    half WrapNoL = NoL * 0.5 + 0.5;
    
    half selfshadow = smoothstep(_ShadowOffset, _ShadowOffset + _ShadowFalloff, WrapNoL);
    
    half3 SpecularLighting = brdfData.specular * US_DefaultLitBxDFSpecular(brdfData, normalWS, L, viewDirectionWS) * LightColor * saturate(NoL) * ShadowMask;
    half3 DiffuseLighting = brdfData.diffuse * LightColor * selfshadow * ShadowMask;
    
    return DiffuseLighting + SpecularLighting;
}

void GetTBByN(float3  normalTS, half3x3 tangentToWorld, half normalAniso, inout half3 t, inout half3 b)
{
    half3 tangentTS = normalize(normalTS.x * half3(0, 0, 1) * normalAniso + half3(1, 0, 0));
    t = TransformTangentToWorld(tangentTS, tangentToWorld);
    t = NormalizeNormalPerPixel(t);

    half3 bitangentTS = normalize(normalTS.y * half3(0, 0, 1) * normalAniso + half3(0, 1, 0));
    b = TransformTangentToWorld(bitangentTS, tangentToWorld);
    b = NormalizeNormalPerPixel(b);
}

float RoughnessToBlinnPhongSpecularExponent(float roughness)
{
    return clamp(2 * rcp(roughness * roughness) - 2, FLT_EPS, rcp(FLT_EPS));
}

half3 LightingPhysicallyBased_Hair(
    BRDFData brdfData,
    Light light,
    float2 uv,
    float4 tangentWS,
    float3 normalTS,
    half3 normalWS,
    half3 V,
    bool specularHighlightsOff = false
    )
{
    half3 lightColor = light.color;
    half3 L = light.direction;
    half lightAttenuation = light.distanceAttenuation * light.shadowAttenuation;

    float3 H = normalize(V + L);
    float LoH = dot(L, H);
    float NoL = dot(normalWS, L);
    float NoV = max(saturate(dot(normalWS, V)), 0.00001);
    float VoH = max(saturate(dot(H, V)), 0.00001);
    float3 B = tangentWS.w * cross(tangentWS.xyz ,normalWS);
    GetTBByN(normalTS, float3x3(tangentWS.xyz, B, normalWS), _NormalAniso, tangentWS.xyz, B);
    
    half3 radiance = lightColor * (lightAttenuation * saturate(NoL));
    
    float2 shiftUV = uv * _ShiftMap_ST.xy + _ShiftMap_ST.zw;
    half shiftMap = SAMPLE_TEXTURE2D(_ShiftMap, sampler_ShiftMap, shiftUV).r;
    
    half specularExponent = RoughnessToBlinnPhongSpecularExponent(brdfData.perceptualRoughness * brdfData.perceptualRoughness);
    float3 t1 = ShiftTangent(B, normalWS, _Shift);
    half3 hairSpec1 = _SpecularTint.rgb * shiftMap * D_KajiyaKay(t1, H, specularExponent) * _SpecularMultiplyer;
    
    half secondarySpecularExponent = RoughnessToBlinnPhongSpecularExponent((1 - _SecondarySmoothness) * (1 - _SecondarySmoothness));
    float3 t2 = ShiftTangent(B, normalWS, _SecondaryShift);
    half3 hairSpec2 = _SecondarySpecularTint.rgb * shiftMap * D_KajiyaKay(t2, H, secondarySpecularExponent) * _SecondarySpecularMultiplyer;
    float3 D = hairSpec1 + hairSpec2;
    
    float3 F = F_Schlick(brdfData.specular, LoH);
    
    //float3 ST = lerp(0, smoothstep(0, 0.1, dot(normalWS, lightDirectionWS) * 0.5 + 0.5), pow(1 - VoH, 4));
    //specularLighting += ST * normalize(brdfData.diffuse) * _TransColor.rgb * _TransColor.a * 10 * step(0.9, lightAttenuation);
    //half3 scatterLight = saturate(_SactterColor.rgb + NdotL) * saturate((NdotL + _ScatterOffset) / (1 + _ScatterOffset));
    //specularLighting = specularLighting * scatterLight;
    
    half3 DiffuseLighting = brdfData.diffuse * lightColor * lightAttenuation * CalcuateRamp(NoL * 0.5 + 0.5);
    half3 SpecularLighting = 0.25 * F * D * saturate(NoV * FLT_MAX) * radiance;
    
    return DiffuseLighting + SpecularLighting;
}

/**
 * \brief Skin
 */
half3 LightingPhysicallyBased_Skin(
    BRDFData brdfData,
    half3 lightColor,
    half3 lightDirectionWS,
    half lightAttenuation,
    half3 normalWS,
    half3 viewDirectionWS,
    float2 UV
    )
{
    half NoL = dot(normalWS, lightDirectionWS);
    half WrapNoL = NoL * 0.5 + 0.5;
    half VdotL = saturate(dot( viewDirectionWS, -lightDirectionWS ) * 0.5 + 0.5);
    half NoV = saturate(dot(normalWS, viewDirectionWS));
    half3 radiance = lightColor * lightAttenuation;

    half CustomShadow = SAMPLE_TEXTURE2D(_CustomShadowMap, sampler_CustomShadowMap, UV).r;
    
    half selfshadow = smoothstep(_ShadowOffset, _ShadowOffset + _ShadowFalloff, WrapNoL);
    half3 Diffuse = brdfData.diffuse;// * RemapFloatValue(0, 1, _ShadowColorDensity, 1.0, selfshadow * CustomShadow);
    half3 F = smoothstep(0.1, 0.8, 1 - NoV) * lightAttenuation * saturate(NoL) * _FrenelColor * 10 * brdfData.diffuse;
    half3 Specular = brdfData.specular * US_DefaultLitBxDFSpecular(brdfData, normalWS, lightDirectionWS, viewDirectionWS);
    Specular += F;
    Specular *= selfshadow * CustomShadow;
    
    float ShadowMask = selfshadow * CustomShadow * lightAttenuation;
    half SSSUV = float2(ShadowMask, 1.0);
    half3 SSS = SAMPLE_TEXTURE2D(_3SRampMap, sampler_3SRampMap, SSSUV);
    SSS = RemapFloat3Value(float3(0, 0, 0), float3(1, 1, 1), _ShadowColorDensity, 1, SSS);
    
    return (Diffuse * SSS * _BaseColorDensity + Specular) * lightColor;
}
half3 LightingPhysicallyBased_Skin_LocalLight(
    BRDFData brdfData,
    half3 lightColor,
    half3 lightDirectionWS,
    half lightAttenuation,
    half3 normalWS,
    half3 viewDirectionWS,
    float2 UV
    )
{
    half NoL = dot(normalWS, lightDirectionWS);
    half WrapNoL = NoL * 0.5 + 0.5;
    half VdotL = saturate(dot( viewDirectionWS, -lightDirectionWS ) * 0.5 + 0.5);
    half NoV = saturate(dot(normalWS, viewDirectionWS));
    half3 radiance = lightColor * (lightAttenuation * saturate(NoL));

    half CustomShadow = SAMPLE_TEXTURE2D(_CustomShadowMap, sampler_CustomShadowMap, UV).r;
    
    half selfshadow = smoothstep(0.5 + _ShadowOffset, 0.5 + _ShadowOffset + _ShadowFalloff, WrapNoL);
    half3 Diffuse = brdfData.diffuse * lightAttenuation * selfshadow * CustomShadow;
    half3 F = smoothstep(0.1, 0.8, 1 - NoV) * lightAttenuation * saturate(NoL) * _FrenelColor * 10 * brdfData.diffuse;
    half3 Specular = brdfData.specular * US_DefaultLitBxDFSpecular(brdfData, normalWS, lightDirectionWS, viewDirectionWS) * lightAttenuation * saturate(NoL) * CustomShadow;
    //Specular += F;
    
    float ShadowMask = saturate(lightAttenuation) * selfshadow * CustomShadow;
    half SSSUV = float2(ShadowMask, 1.0);
    half3 SSS = SAMPLE_TEXTURE2D(_3SRampMap, sampler_3SRampMap, SSSUV);
    SSS = RemapFloat3Value(float3(0,0,0), float3(1,1,1), _ShadowColorDensity, 1, SSS);
    
    return (Diffuse + Specular) * lightColor * lightAttenuation * selfshadow;
}

half3 LightingPhysicallyBased_Skin(BRDFData brdfData,  Light light, half3 normalWS, half3 viewDirectionWS, float2 UV)
{
    return LightingPhysicallyBased_Skin(brdfData, light.color, light.direction, light.distanceAttenuation * light.shadowAttenuation, normalWS, viewDirectionWS, UV);
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

CBSDF EvaluateFabricBRDF(InputData inputData, BRDFData brdfData, Light light,AnisotropicData anisotropicData )
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

    half RampDiffuse = RemapFloatValue(0, 1, _ShadowColorDensity, 1, CalcuateRamp(NdotL * 0.5 + 0.5));
    cbsdf.diffR = RampDiffuse; //smoothstep(0.7, 0.7 + _ShadowFalloff, NdotL * 0.5 + 0.5) * diffTerm;
    cbsdf.specR = specTerm * clampNdotL;
    cbsdf.diffT = 0;
    cbsdf.specT = 0;
    
    return cbsdf;
}


half3  PhysicallyBaseDirectLighting(InputData inputData, BRDFData brdfData, Light light ,AnisotropicData anisotropicData)
{
    half ShadowMask = light.distanceAttenuation * light.shadowAttenuation;
    half3 lighting = light.color * RemapFloatValue(0, 1, _ShadowColorDensity, 1, ShadowMask);
    CBSDF cbrdf = EvaluateFabricBRDF(inputData, brdfData, light,  anisotropicData);
  
    half3 diffuseLighting = cbrdf.diffR * brdfData.diffuse * _BaseColorDensity * lighting;
    half3 specularLighting = cbrdf.specR * lighting;
    return diffuseLighting + specularLighting;
}

/**
 * \brief Skin
 */
half3 GetAdditional_Lights(InputData inputData, BRDFData brdfData ,float2 uv , float4 tangentWS ,float3 normalTS, AnisotropicData anisotropicData)
{                
    #if USE_LIGHT_GRID
        uint gridIndex = ComputeLightGridCellIndex((uint2)inputData.positionCS.xy, inputData.positionCS.w);
        CulledLightsGridData lightGridData = GetCulledLightsGrid(gridIndex);
        uint pixelLightCount = lightGridData.NumUnityLocalLights;
    #else
        uint pixelLightCount = GetAdditionalLightsCount();
    #endif

    half3 add_lit_color = 0;
    [loop]
    for (uint lightIndex = 0u; lightIndex < pixelLightCount; ++lightIndex)
    {
        #if USE_LIGHT_GRID
        int gpuLightIndex = GetGPULightData(lightGridData.DataStartIndex + lightIndex).index;
        Light light = GetAdditionalLight(gpuLightIndex, inputData.positionWS);
        #else
        Light light = GetAdditionalLight(lightIndex, inputData.positionWS);
        #endif

        // #if defined(_SCREEN_SPACE_OCCLUSION)
        // light.color *= aoFactor.directAmbientOcclusion;
        // #endif
        #ifdef _SKIN
            #ifdef _POINTLIGHT_ON
                add_lit_color += LightingPhysicallyBased_Skin_LocalLight(brdfData, light.color, light.direction, light.distanceAttenuation * light.shadowAttenuation, inputData.normalWS, inputData.viewDirectionWS, uv);
            #endif
        #elif defined(_HAIR)
            add_lit_color += LightingPhysicallyBased_Hair(brdfData,light,uv,tangentWS, normalTS, inputData.normalWS, inputData.viewDirectionWS );
        #elif defined(_TOONHAIR)
            add_lit_color += LightingPhysicallyBased_ToonHair_LocalLight(brdfData, light,inputData.normalWS, inputData.viewDirectionWS);
        #elif defined(_FABRIC)
            add_lit_color += PhysicallyBaseDirectLighting(inputData, brdfData, light, anisotropicData);
        #else
            add_lit_color +=  LightingPhysicallyBased_BxDF(brdfData, light, inputData.normalWS, inputData.viewDirectionWS);
        #endif
    }
    return add_lit_color;
}

float Hash21(float2 uv)
{
    uv = frac(uv * float2(123.34,456.21));
    uv += dot(uv , uv + 45.32);
    return frac(uv.x *uv.y);
}

half3 CustomGI(
    BRDFData brdfData,
    InputData inputData,
    Light light,
    half3 bakedGI,
    half occlusion,
    half3 normalWS,
    half3 viewDirectionWS
    )
{
    half3 reflectVector = reflect(-viewDirectionWS, normalWS);
    half NoV = saturate(dot(normalWS, viewDirectionWS));
    half fresnelTerm = Pow4(1.0 - NoV);
    half3 indirectDiffuse = bakedGI;//bakedGI * occlusion;

    float3 L = light.direction;
    half NoL = dot(normalWS, L);
    
    // #ifdef _UE4_IBL_ON
    //     half3 indirectSpecular = GetSkyLightReflection(viewDirectionWS , normalWS ,brdfData.perceptualRoughness) ;
    // #else
    //     half3 indirectSpecular = GlossyEnvironmentReflection(reflectVector,inputData.positionWS, brdfData.perceptualRoughness, 1.0);
    // #endif
    
    float3 Up = mul(UNITY_MATRIX_I_V, float3(0, 1, 0));
    float3 V = inputData.viewDirectionWS * -1;
    float3 X = normalize(cross(V, Up));
    float3 Y = normalize(cross(V, X));
    float3 N = inputData.normalWS;
    float3x3 M;
    M[0][0] = X.x;
    M[1][0] = X.y;
    M[2][0] = X.z;
    M[0][1] = Y.x;
    M[1][1] = Y.y;
    M[2][1] = Y.z;
    M[0][2] = V.x;
    M[1][2] = V.y;
    M[2][2] = V.z;
    float2 matcapuv = (mul(N, M) * 0.5 + 0.5).xy * float2(1, -1);
    
    float3 StylizedReflection = _StylizedReflectionMap.Sample(sampler_StylizedReflectionMap, matcapuv) * _StylizedReflectionDensity * brdfData.diffuse;
    StylizedReflection *= RemapFloatValue(0, 1, 0.2, 1, saturate(NoL));
    
    half3 indirectDiffuseColor = indirectDiffuse * brdfData.diffuse;
    
    indirectDiffuseColor = indirectDiffuseColor * _IndirectBright;
    
    half3 indirectSpecular = GetSkyLightReflection(viewDirectionWS , normalWS ,brdfData.perceptualRoughness) ;
    half3 indirectSpecularColor = indirectSpecular * EnvBRDFApprox(brdfData.specular , brdfData.perceptualRoughness , NoV) * _EnvReflectionScale;

    indirectSpecularColor = lerp(indirectSpecularColor, StylizedReflection, _StylizedReflectionWeight);
    
    return ( indirectDiffuseColor + indirectSpecularColor) * occlusion;  
}

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

half3 ImageBaseInDirectLighting(InputData inputData, BRDFData brdfData, Light light,AnisotropicData anisotropicData , float occlusion)
{
    float NdotV = max(saturate(dot(inputData.normalWS, inputData.viewDirectionWS)), 0.00001);
    half3 iblNormalWS = inputData.normalWS;
    half iblPerceptualRoughness = brdfData.perceptualRoughness;

    half fresnelTerm = Pow4(1.0 - NdotV);
    
    #ifdef _ANISOTROPIC
        GetGGXAnisotropicModifiedNormalAndRoughness(
            anisotropicData.bitangentWS,
            anisotropicData.tangentWS,
            inputData.normalWS,
            inputData.viewDirectionWS,
            anisotropicData.anisotropic,
            brdfData.perceptualRoughness,
            iblNormalWS,
            iblPerceptualRoughness
            );
    #endif
    
    float3 reflectDirectionWS = reflect(-inputData.viewDirectionWS, iblNormalWS);

    half3 diffuseGI = inputData.bakedGI;
    //half3 specularGI =  // IBL_EnvironmentReflection(inputData.viewDirectionWS, iblNormalWS, iblPerceptualRoughness);
    half3 specularGI = GlossyEnvironmentReflection(reflectDirectionWS , inputData.positionWS ,iblPerceptualRoughness, 1.0) ;
    
    half3 diffuseFGD;
    half3 specularFGD;
    GetPreIntegratedGGX(NdotV, brdfData.perceptualRoughness, brdfData.specular, specularFGD, diffuseFGD);
    half3 diffuseLighting = diffuseGI * brdfData.diffuse * diffuseFGD;
    half3 specularLighting = specularGI * specularFGD * EnvironmentBRDFSpecular(brdfData,fresnelTerm);
    
    return (diffuseLighting + specularLighting) * occlusion ;
}

half3 PhysicallyBaseDirectAdditionalLighting(InputData inputData, BRDFData brdfData, AnisotropicData anisotropicData)
{
    #if USE_LIGHT_GRID
        uint gridIndex = ComputeLightGridCellIndex((uint2)inputData.positionCS.xy, inputData.positionCS.w);
        CulledLightsGridData lightGridData = GetCulledLightsGrid(gridIndex);
        uint pixelLightCount = lightGridData.NumUnityLocalLights;
    #else
        uint pixelLightCount = GetAdditionalLightsCount();
    #endif

    float3 N = inputData.normalWS;
    
    half3 add_lit_color = 0;
    for (uint lightIndex = 0u; lightIndex < pixelLightCount; ++lightIndex)
    {
        #if USE_LIGHT_GRID
            int gpuLightIndex = GetGPULightData(lightGridData.DataStartIndex + lightIndex).index;
            Light light = GetAdditionalLight(gpuLightIndex, inputData.positionWS,inputData.shadowMask);
        #else
            Light light = GetAdditionalLight(lightIndex, inputData.positionWS,inputData.shadowMask);
        #endif

        float3 L = light.direction;
        float NoL = saturate(dot(N, L));
        add_lit_color += PhysicallyBaseDirectLighting(inputData, brdfData, light,anisotropicData) * smoothstep(0.5, 0.55, NoL); 
    }
    return add_lit_color;
}

float3 AdjustSaturation(float3 color)
{
    float3 gray = 0.2125 * color.r + 0.7154 *color.g +0.0721 *color.b;
    float3 finalColor = lerp(gray , color ,_Saturation);
    return finalColor;
}
