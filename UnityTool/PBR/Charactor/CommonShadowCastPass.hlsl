#ifndef COMMON_SHADOW_CASTER_PASS_INCLUDED
#define COMMON_SHADOW_CASTER_PASS_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
#if defined(LOD_FADE_CROSSFADE)
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LODCrossFade.hlsl"
#endif
float3 _LightDirection;

struct Attributes
{
    float4 positionOS   : POSITION;
    float3 normalOS     : NORMAL;
    #if defined(_ALPHATEST_ON)
    float2 texcoord     : TEXCOORD0;
    #endif
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct Varyings
{
    #if defined(_ALPHATEST_ON)
    float2 uv           : TEXCOORD0;
    #endif
    float4 positionCS   : SV_POSITION;
};

float4 GetShadowPositionHClip(Attributes input)
{
    float3 positionWS = TransformObjectToWorld(input.positionOS.xyz);
    float3 normalWS = TransformObjectToWorldNormal(input.normalOS);

    #if _NONORMALBIAS_ON
    float4 positionCS = TransformWorldToHClip(ApplyShadowBiasNoNormal(positionWS, normalWS, _LightDirection));
    #else
    float4 positionCS = TransformWorldToHClip(ApplyShadowBias(positionWS, normalWS, _LightDirection));
    #endif
    

    #if UNITY_REVERSED_Z
    positionCS.z = min(positionCS.z, positionCS.w * UNITY_NEAR_CLIP_VALUE);
    #else
    positionCS.z = max(positionCS.z, positionCS.w * UNITY_NEAR_CLIP_VALUE);
    #endif

    return positionCS;
}

Varyings ShadowPassVertex(Attributes input)
{
    #if defined(_USING_VERTEX_SCALE)
    input.positionOS.xyz *= _VertexScale.xyz; 
    #endif
    Varyings output;
    UNITY_SETUP_INSTANCE_ID(input);

    #if defined(_ALPHATEST_ON)
    output.uv = TRANSFORM_TEX(input.texcoord, _BaseMap);
    #endif

    #if defined(_WINDANIM_ON)
    float3 posWS = TransformObjectToWorld(input.positionOS);
    input.positionOS.xz += WindAnim(posWS , input.positionOS.xyz);
    #endif
 
    
    
    output.positionCS = GetShadowPositionHClip(input);



    return output;
}

half4 ShadowPassFragment(Varyings input) : SV_TARGET
{
    float alpha = 1;
    #if defined(_ALPHATEST_ON)
    alpha = Alpha(SampleAlbedoAlpha(input.uv, TEXTURE2D_ARGS(_BaseMap, sampler_BaseMap)).a, _Cutoff);
    #endif

    #ifdef LOD_FADE_CROSSFADE
    LODFadeCrossFade(input.positionCS ,alpha);
    #endif

    return 0;
}

#endif
