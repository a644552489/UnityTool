#ifndef STANDARD_CHARACTER_HAIR_ALPHATEST_PASS
#define STANDARD_CHARACTER_HAIR_ALPHATEST_PASS

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

struct Attributes
{
    float4 positionOS : POSITION;
    float2 uv : TEXCOORD0;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct Varyings
{
    float4 positionCS : SV_POSITION;
    float3 positionVS : VAR_POSITIONVS;
    float3 positionWS : VAR_POSITION;
    float2 uv : VAR_UV;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

Varyings LitVertex(Attributes input)
{
    Varyings output = (Varyings)0;
    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_TRANSFER_INSTANCE_ID(input, output);

    VertexPositionInputs positionInputs = GetVertexPositionInputs(input.positionOS.xyz);
    output.positionWS = positionInputs.positionWS;
    output.positionVS = positionInputs.positionVS;
    output.positionCS = positionInputs.positionCS;
    output.uv = input.uv * _MainTex_ST.xy + _MainTex_ST.zw;
    return output;
}
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
float4 LitFragment(Varyings input) : SV_TARGET
{
    UNITY_SETUP_INSTANCE_ID(input);
    float2 uv = input.uv;
//  Base Texture ---------------------------------------------------------------------------------------------------
    SurfaceData surfaceData;
    half4 albedoAlpha = SampleAlbedoAlpha(uv, _MainTex, sampler_MainTex) * _BaseColor;

    surfaceData.albedo = albedoAlpha.rgb;
    surfaceData.alpha = CustomAlpha(albedoAlpha.r, _BaseColor, _Cutoff);
    return half4(surfaceData.albedo, surfaceData.alpha);
}
#endif