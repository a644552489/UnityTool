#ifndef FUR_SHELL_SHADOW_HLSL
#define FUR_SHELL_SHADOW_HLSL

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/CommonMaterial.hlsl"
#include "./Param.hlsl"
#include "./Common.hlsl"

struct Attributes
{
    float4 positionOS : POSITION;
    float3 normalOS : NORMAL;
    float4 tangentOS : TANGENT;
    float2 uv : TEXCOORD0;
};

struct Varyings
{
    float4 vertex : SV_POSITION;
    float2 uv : TEXCOORD0;
    float  fogCoord : TEXCOORD1;
    float  layer : TEXCOORD2;
};

Attributes vert(Attributes input)
{
    return input;
}

void AppendShellVertex(inout TriangleStream<Varyings> stream, Attributes input, int index)
{
    Varyings output = (Varyings)0;

    VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
    VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);

    float moveFactor = pow(abs((float)index / _ShellLayers), _FurBaseMove.w);
    float3 posOS = input.positionOS.xyz;
    float3 windAngle = _Time.w * _FurWindFreq.xyz;
    float3 windMove = moveFactor * _FurWindMove.xyz * sin(windAngle + posOS * _FurWindMove.w);
    float3 move = moveFactor * _FurBaseMove.xyz;

    float3 shellDir = normalize(normalInput.normalWS + move + windMove);
    float3 posWS = vertexInput.positionWS + shellDir * (_ShellLayerDistance * index);
    //float4 posCS = TransformWorldToHClip(posWS);
    float4 posCS = GetShadowPositionHClip(posWS, normalInput.normalWS);
    
    output.vertex = posCS;
    output.uv = TRANSFORM_TEX(input.uv, _FurTerture);
    output.fogCoord = ComputeFogFactor(posCS.z);
    output.layer = (float)index / _ShellLayers;

    stream.Append(output);
}

[maxvertexcount(128)]
void geom(triangle Attributes input[3], inout TriangleStream<Varyings> stream)
{
    [loop] for (float i = 0; i < _ShellLayers; ++i)
    {
        [unroll] for (float j = 0; j < 3; ++j)
        {
            AppendShellVertex(stream, input[j], i);
        }
        stream.RestartStrip();
    }
}

void frag(
    Varyings input, 
    out float4 outColor : SV_Target, 
    out float outDepth : SV_Depth)
{
    float4 furColor = SAMPLE_TEXTURE2D(_FurTerture, sampler_FurTerture, input.uv * _FurScale);
    float alpha = furColor.r * (1.0 - input.layer);
    if (input.layer > 0.0 && alpha < _AlphaCutout) discard;

    outColor = outDepth = input.vertex.z / input.vertex.w;
}

#endif