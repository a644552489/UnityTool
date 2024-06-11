#ifndef OUTLINE_INPUT
#define OUTLINE_INPUT

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
     

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"


float _ScreenOutlineOn;

float4 _OutlineColor;
float _OutlineBaseThicknessMul;


//TEXTURE2D(_BaseMap ); SAMPLER(sampler_BaseMap);

float3 CalcOutlineOffset(half3 normalOS, half4 color, float depth)
{
    half lineWidthDepthRatio = 0.5;
    float t = unity_CameraProjection._m11;
    float fakeFov = atan(1.0f / t) * 4.0h;
    depth = lerp(1.0F, depth, lineWidthDepthRatio);
    depth *= fakeFov;

    half outlineExpand = 0.002 * depth *color.g;
    normalOS.y *= (_ScreenParams.x / _ScreenParams.y);
    return normalOS.xyz * outlineExpand  * _OutlineBaseThicknessMul * _ScreenOutlineOn;
}

#endif