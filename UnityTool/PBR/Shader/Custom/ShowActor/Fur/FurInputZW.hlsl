#ifndef FUR_INPUT_ZW_INCLUDED
#define FUR_INPUT_ZW_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"


    #include "../../../ShaderLibrary/CustomLighting.hlsl"

sampler2D _LayerTex;
sampler2D _BumpMap;
sampler2D _FlowMap;
sampler2D _MainTex;
sampler2D _MSAMap;
sampler2D _OcclusionMap;
sampler2D _EmissionMap;
sampler2D _WaveMap;

//CBUFFER_START(UnityPerMaterial)
    half _UVOffset;
    half3 _FabricScatterColor;
    half _FabricScatterScale;
    float4 _MainTex_ST;
    float4 _LayerTex_ST;
    float4 _WaveMap_ST;
    half _MetaStrength;
    half _SmoothnessStrength;
    half _AOStrength;
    half _FurLength;
    half _GravityStrength;
    half4 _Color;
    half4 _EmissionColor;
    half4 _FurColor;
    half3 _Gravity;
    half _CutoffEnd;
    half _BumpScale;
    half _WaveSpeed;
    half _BreatheSpeed;
    half _FresnelBias;
    half _FresnelScale;
    half _FrenelPower;
    half4 _SpecColor1;
    half4 _SpecColor2;
    half4 _SpecInfo;
    half _AddLightScale;

    float4 _ShadowColor;
    half _ShadowLerp;



            float _LightmapStrength;
        float _EmissionStrength;
        float _ShadowGIStrength;
        float _ShadowStrength;

    //#if defined(INSTANCING_ON)
    // UNITY_INSTANCING_BUFFER_START(Props)

    //UNITY_DEFINE_INSTANCED_PROP(float , _FUR_OFFSET)
    //UNITY_DEFINE_INSTANCED_PROP(float4 , LightmapST_Morning)
    //UNITY_DEFINE_INSTANCED_PROP(float4 , LightmapST_Evening)


    //UNITY_INSTANCING_BUFFER_END(Props)

    //#define _FUR_OFFSET   UNITY_ACCESS_INSTANCED_PROP(Props , _FUR_OFFSET)
    //#define LightmapST_Morning      UNITY_ACCESS_INSTANCED_PROP(Props , LightmapST_Morning)
    //#define LightmapST_Evening      UNITY_ACCESS_INSTANCED_PROP(Props , LightmapST_Evening)
    //#else
    
    float4 LightmapST_Morning;
    float4 LightmapST_Evening;
    float _FUR_OFFSET;

  //  #endif
//CBUFFER_END


TEXTURE2D(Lightmap_Morning);    SAMPLER(sampler_Lightmap_Morning);
    TEXTURE2D(LightmapInd_Morning);  SAMPLER(sampler_LightmapInd_Morning);
    TEXTURE2D(ShadowMask_Morning);    SAMPLER(sampler_ShadowMask_Morning);
    

    TEXTURE2D(Lightmap_Evening);    SAMPLER(sampler_Lightmap_Evening);
    TEXTURE2D(LightmapInd_Evening); SAMPLER(sampler_LightmapInd_Evening);
    TEXTURE2D(ShadowMask_Evening);  SAMPLER(sampler_ShadowMask_Evening);


   //half _FUR_OFFSET;
   //float4 LightmapST_Morning;
   //float4  LightmapST_Evening;
#endif