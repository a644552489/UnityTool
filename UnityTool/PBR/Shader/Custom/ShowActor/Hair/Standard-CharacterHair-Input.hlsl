#ifndef STANDARD_CHARACTER_HAIR_INPUT
#define STANDARD_CHARACTER_HAIR_INPUT

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"

TEXTURE2D(_NormalMap);                                  SAMPLER(sampler_NormalMap);
TEXTURE2D(_NoiseMap);                                   SAMPLER(sampler_NoiseMap);
TEXTURE2D(_ShiftMap);                                   SAMPLER(sampler_ShiftMap);
TEXTURE2D(_MainTex);                                    SAMPLER(sampler_MainTex);

CBUFFER_START(UnityPerMaterial)
    half4 _BaseColor;
    half4 _MainTex_ST;
    half _Cutoff;
    half _TransparentWeight;
    half4 _FresnelColor;
    half4 _ShadowColor;
    half4 _SactterColor;
    half _ScatterOffset;
    half _LightingMultiplyer;

    half4 _NoiseMap_ST;

    half _Metallic;
    half4 _ShiftMap_ST;
    half4 _SpecularTint;
    half _SpecularMultiplyer;
    half _Smoothness;
    half _Shift;
    half4 _SecondarySpecularTint;
    half _SecondarySpecularMultiplyer;
    half _SecondarySmoothness;
    half _SecondaryShift;

    half _NormalIntensity;
    half _NormalAniso;

    // half4 _IndirectDiffuseLighting;
    // half4 _IndirectSpecularLighting;

    // half4 _MatCapColor;
    // half _MatCapIntensity;
    // half _ZOffset;

CBUFFER_END
#endif