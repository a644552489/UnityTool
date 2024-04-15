#ifndef FUR_SHELL_LIT_HLSL
#define FUR_SHELL_LIT_HLSL

#include "Packages/com.unity.render-pipelines.universal/Shaders/LitInput.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"
#include "./Param.hlsl"
#include "./Common.hlsl"

struct Attributes
{
    float4 positionOS : POSITION;
    float3 normalOS : NORMAL;
    float4 tangentOS : TANGENT;
    float2 texcoord : TEXCOORD0;
    float2 lightmapUV : TEXCOORD1;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct Varyings
{
    float4 positionCS : SV_POSITION;
    float3 positionWS : TEXCOORD0;
    float3 normalWS : TEXCOORD1;
    float3 tangentWS : TEXCOORD2;
    float2 uv : TEXCOORD4;
    DECLARE_LIGHTMAP_OR_SH(lightmapUV, vertexSH, 5);
    float4 fogFactorAndVertexLight : TEXCOORD6; // x: fogFactor, yzw: vertex light
    float  layer : TEXCOORD7;
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
    float3 shellDir = SafeNormalize(normalInput.normalWS + move + windMove);
    float3 viewDirWS = GetCameraPositionWS() - vertexInput.positionWS;
    
    output.positionWS = vertexInput.positionWS + shellDir * (_ShellLayerDistance * index);
    output.positionCS = TransformWorldToHClip(output.positionWS);
    output.uv = TRANSFORM_TEX(input.texcoord, _BaseMap);
    output.normalWS = normalInput.normalWS;
    output.tangentWS = normalInput.tangentWS;
    output.layer = (float)index / _ShellLayers;

    float3 vertexLight = VertexLighting(vertexInput.positionWS, normalInput.normalWS);
    float fogFactor = ComputeFogFactor(vertexInput.positionCS.z);
    output.fogFactorAndVertexLight = float4(fogFactor, vertexLight);

    OUTPUT_LIGHTMAP_UV(input.lightmapUV, unity_LightmapST, output.lightmapUV);
    OUTPUT_SH(output.normalWS.xyz, output.vertexSH);

    stream.Append(output);
}

[maxvertexcount(42)]
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

inline float3 TransformHClipToWorld(float4 positionCS)
{
    return mul(UNITY_MATRIX_I_VP, positionCS).xyz;
}

float4 frag(Varyings input) : SV_Target
{
    half3 Furmask = SAMPLE_TEXTURE2D(_Furmask, sampler_Furmask,input.uv).rgb;


    // float2 furUv = input.uv /( _Furmask_R_Scale * Furmask.r * _BaseMap_ST.xy * _FurScale + _Furmask_G_Scale *Furmask.g * _BaseMap_ST.xy * _FurScale + _Furmask_B_Scale *Furmask.b * _BaseMap_ST.xy * _FurScale );
    // float2 furUv = input.uv /_BaseMap_ST.xy * _FurScale;
    
      
    

    float2 furUv = input.uv /( _Furmask_R_Scale * Furmask.r * _BaseMap_ST.xy * _FurScale + _Furmask_G_Scale *Furmask.g * _BaseMap_ST.xy * _FurScale + _Furmask_B_Scale *Furmask.b * _BaseMap_ST.xy * _FurScale );

    float4 furColor =  SAMPLE_TEXTURE2D(_FurTerture, sampler_FurTerture, furUv);

    //float alpha = _Furmask_R_Scale * Furmask.r * furColor.r * (1.0 - input.layer) + _Furmask_G_Scale * Furmask.g * furColor.r * (1.0 - input.layer) + _Furmask_B_Scale * Furmask.b * furColor.r * (1.0 - input.layer);
    // float alpha = _Furmask_R_Scale * Furmask.r * furColor.r * (1.0 - input.layer) + _Furmask_G_Scale * Furmask.g * furColor.r * (1.0 - input.layer) + _Furmask_B_Scale * Furmask.b * furColor.r * (1.0 - input.layer);
    // float alpha =  furColor.r * (1.0 - input.layer);
  
    float alpha = saturate(_Furmask_R_Scale *(Furmask.r * furColor.r * _Furmask_R_Height)  + _Furmask_G_Scale * (Furmask.g * furColor.g* _Furmask_G_Height)  + _Furmask_B_Scale * ( Furmask.b * furColor.b * _Furmask_B_Height) ) * (1.0 - input.layer);
   
    if (input.layer > 0.0 && alpha < _AlphaCutout) discard;

    float3 viewDirWS = SafeNormalize(GetCameraPositionWS() - input.positionWS);
    float3 normalTS = UnpackNormalScale(
        SAMPLE_TEXTURE2D(_Normal, sampler_Normal, furUv), 
        _NormalScale);
    float3 bitangent = SafeNormalize(viewDirWS.y * cross(input.normalWS, input.tangentWS));
    float3 normalWS = SafeNormalize(TransformTangentToWorld(
        normalTS, 
        float3x3(input.tangentWS, bitangent, input.normalWS)));

    SurfaceData surfaceData = (SurfaceData)0;
    InitializeStandardLitSurfaceData(input.uv, surfaceData);
    surfaceData.occlusion = lerp(1.0 - _Occ, 1.0, input.layer);
    surfaceData.albedo *= surfaceData.occlusion;

    InputData inputData = (InputData)0;
    inputData.positionWS = input.positionWS;
    inputData.normalWS = normalWS;
    inputData.viewDirectionWS = viewDirWS;
#if defined(_MAIN_LIGHT_SHADOWS) && !defined(_RECEIVE_SHADOWS_OFF)
    inputData.shadowCoord = TransformWorldToShadowCoord(input.positionWS);
#else
    inputData.shadowCoord = float4(0, 0, 0, 0);
#endif
    inputData.fogCoord = input.fogFactorAndVertexLight.x;
    inputData.vertexLighting = input.fogFactorAndVertexLight.yzw;
    inputData.bakedGI = SAMPLE_GI(input.lightmapUV, input.vertexSH, normalWS);

    float4 color = UniversalFragmentPBR(inputData, surfaceData);

    ApplyRimLight(color.rgb, input.positionWS, viewDirWS, normalWS);
    color.rgb += _AmbientColor;
    color.rgb = MixFog(color.rgb, inputData.fogCoord);

    return color;
}

#endif