#ifndef COMMON_L_FABRIC_LIT_PASS_INCLUDE
#define COMMON_L_FABRIC_LIT_PASS_INCLUDE

#include "./FabricLighting.hlsl"

struct Attributes
{
    float4 positionOS : POSITION;
    float3 normalOS : NORMAL;
    float4 tangentOS : TANGENT;
    float2 uv : TEXCOORD0;
#ifdef LIGHTMAP_ON
    float2 lightmapUV : TEXCOORD1;
#endif
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
#ifdef LIGHTMAP_ON
    float2 lightmapUV : VAR_LIGHTMAPUV;
#endif
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
    output.uv = input.uv;
#ifdef LIGHTMAP_ON
    output.lightmapUV = input.lightmapUV * unity_LightmapST.xy + unity_LightmapST.zw;
#endif
    return output;
}

float4 LitFragment(Varyings input) : SV_TARGET
{
    UNITY_SETUP_INSTANCE_ID(input);


    float2 uv = input.uv * _BaseMap_ST.xy + _BaseMap_ST.zw;
#ifdef LIGHTMAP_ON
    float2 lightmapUV = input.lightmapUV;
#else
    float2 lightmapUV = float2(0, 0);
#endif
//  Base Texture ----------------------------------------------------------------------------------
    half4 albedoAlpha = SampleAlbedoAlpha(uv, _BaseMap, sampler_BaseMap);

    half4 MSA = half4(0, 1, 1, 0);
    half3 normalTS = half3(0, 0, 1);
    half3 normalMap = half3(0,0,1);

#ifdef _NORMALMAP
    normalMap  =SampleNormal(uv, TEXTURE2D_ARGS(_BumpMap, sampler_BumpMap), _BumpScale);
#endif

#ifdef _MSA
     MSA = SAMPLE_TEXTURE2D(_MSAMap ,sampler_MSAMap , uv);
#endif

#ifdef _DETAILNORMAL
    half2 detailUV = input.uv  * _DetailNormal_ST.xy + _DetailNormal_ST.zw;
    normalTS =UnpackNormalScale( SAMPLE_TEXTURE2D(_DetailNormal, sampler_DetailNormal , detailUV) , _NormalIntensity);

#endif


//#ifdef _NORMAL_SMOOTH_AO
//    threadMap = SAMPLE_TEXTURE2D(_ThreadMap, sampler_ThreadMap, uv);
//    normalTS = half3(threadMap.a, threadMap.g, 1);
//    normalTS.xy = (normalTS.xy * 2 - 1) * _NormalIntensity;
//    normalTS.z = sqrt(1.0 - saturate(dot(normalTS.xy, normalTS.xy)));
//#endif



    normalTS = normalize(float3(normalMap.xy + normalTS.xy , normalMap.b * normalTS.b));

#ifdef _SPECULARMAP
    half3 specular = SAMPLE_TEXTURE2D(_SpecularMap, sampler_SpecularMap, uv).rgb * _SpecularColor.rgb;
#else
    half3 specular = _SpecularColor.rgb;
#endif

    half3 normal = NormalizeNormalPerPixel(TransformTangentToWorld(normalTS, float3x3(input.tangentWS, input.bitangentWS, input.normalWS)));


    SurfaceData surface;
    surface.albedo = albedoAlpha.rgb * _BaseColor.rgb;
    surface.specular = specular;
    surface.metallic = MSA.r * _Metallic;
    surface.smoothness = MSA.g * _Smoothness;
    surface.normalTS = normal;
    surface.emission = 0;
    surface.occlusion =lerp(0,1,_Occlusion);// LerpWhiteTo(MSA.b, _Occlusion);
    surface.alpha = Alpha(albedoAlpha.a, _BaseColor, _Cutoff);
//  -----------------------------------------------------------------------------------------------
//  InputData -------------------------------------------------------------------------------------
    InputData inputData;
    inputData.positionWS = input.positionWS;
    inputData.viewDirectionWS = input.viewDirWS;
    inputData.normalWS = surface.normalTS;
    inputData.shadowMask = SAMPLE_SHADOWMASK(lightmapUV);
    inputData.normalizedScreenSpaceUV = GetNormalizedScreenSpaceUV(input.positionCS);
    //inputData.tangentToWorld[0] = inputData.normalWS;
    //inputData.tangentToWorld[1] = input.tangentWS;
    //inputData.tangentToWorld[2] = input.bitangentWS;

#ifdef LIGHTMAP_ON
    inputData.bakedGI = SampleLightmap(lightmapUV, inputData.normalWS);
#else
    inputData.bakedGI = SampleSH(inputData.normalWS);
#endif


#if defined(MAIN_LIGHT_CALCULATE_SHADOWS) || !defined(_MAIN_LIGHT_SHADOWS_CASCADE)
    inputData.shadowCoord = TransformWorldToShadowCoord(input.positionWS);
#else
    inputData.shadowCoord = float4(0, 0, 0, 0);
#endif
//  -----------------------------------------------------------------------------------------------
//  Fuzz Map --------------------------------------------------------------------------------------
#ifdef _FUZZMAP
    half fuzzMap = SAMPLE_TEXTURE2D(_FuzzMap, sampler_FuzzMap, input.uv * _FuzzMap_ST.xy + _FuzzMap_ST.zw).r * _FuzzStrength;
    surface.albedo += fuzzMap * _FuzzColor.rgb;
#endif
//  -----------------------------------------------------------------------------------------------

    float4 color = FabricLit(inputData, surface, input.tangentWS );

    return color.xyzz;
}
#endif