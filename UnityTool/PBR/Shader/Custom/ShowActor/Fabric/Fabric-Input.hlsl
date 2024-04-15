#ifndef COMMON_L_FABRIC_LIT_INPUT_INCLUDE
#define COMMON_L_FABRIC_LIT_INPUT_INCLUDE

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/CommonMaterial.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"

TEXTURE2D(_FuzzMap);            SAMPLER(sampler_FuzzMap);
TEXTURE2D(_SpecularMap);        SAMPLER(sampler_SpecularMap);
//TEXTURE2D(_ThreadMap);          SAMPLER(sampler_ThreadMap);
TEXTURE2D(_MSAMap);             SAMPLER(sampler_MSAMap);
TEXTURE2D(_DetailNormal);       SAMPLER(sampler_DetailNormal);

TEXTURECUBE(_SpecCUBE); SAMPLER(sampler_SpecCUBE);

CBUFFER_START(UnityPerMaterial)
    half4 _BaseColor;
    half4 _BaseMap_ST;
    half4 _DetailNormal_ST;
    half _Cutoff;

    half4 _SpecularColor;
    half _FuzzStrength;
    half4 _FuzzColor;
    half4 _FuzzMap_ST;
    half _Smoothness;
    half _Occlusion;
    half _NormalIntensity;
    half _BumpScale;
    half _Metallic;

#ifdef _FABRIC_SILK_MATERIAL
    #define _ANISOTROPIC
    half _Anisotropic;
#endif
CBUFFER_END
#endif