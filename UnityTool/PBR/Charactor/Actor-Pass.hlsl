
#define CUSTOM_NEW_PASS_INCLUDED_EYE

// GLES2 has limited amount of interpolators
#if defined(_PARALLAXMAP) && !defined(SHADER_API_GLES)
    #define REQUIRES_TANGENT_SPACE_VIEW_DIR_INTERPOLATOR
#endif

#if (defined(_NORMALMAP) || (defined(_PARALLAXMAP) && !defined(REQUIRES_TANGENT_SPACE_VIEW_DIR_INTERPOLATOR))) || defined(_DETAIL)
    #define REQUIRES_WORLD_SPACE_TANGENT_INTERPOLATOR
#endif
#if defined(LOD_FADE_CROSSFADE)
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LODCrossFade.hlsl"
#endif
#include "Packages/com.unity.render-pipelines.universal/Runtime/USPipeline/PostProcessing/Shaders/GlobalVolumetricFog/GlobalVolumetricFogCommon.hlsl"

// keep this file in sync with LitGBufferPass.hlsl

struct Attributes
{
    float4 positionOS   : POSITION;
    float3 normalOS     : NORMAL;
    float4 tangentOS    : TANGENT;
    float2 texcoord     : TEXCOORD0;
    float2 lightmapUV   : TEXCOORD1;
    float4 color :COLOR0;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct Varyings
{
    float2 uv                       : TEXCOORD0;
    DECLARE_LIGHTMAP_OR_SH(lightmapUV, vertexSH, 1);

    #if defined(REQUIRES_WORLD_SPACE_POS_INTERPOLATOR)
    float3 positionWS               : TEXCOORD2;
    #endif

    float3 normalWS                 : TEXCOORD3;
    //#if defined(REQUIRES_WORLD_SPACE_TANGENT_INTERPOLATOR)
    float4 tangentWS                : TEXCOORD4;    // xyz: tangent, w: sign
    //#endif
    float3 viewDirWS                : TEXCOORD5;

    half4 fogFactorAndVertexLight   : TEXCOORD6; // x: fogFactor, yzw: vertex light

    #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
    float4 shadowCoord              : TEXCOORD7;
    #endif

    #if defined(REQUIRES_TANGENT_SPACE_VIEW_DIR_INTERPOLATOR)
    float3 viewDirTS                : TEXCOORD8;
    #endif
    float4 positionOS               :TEXCOORD9;

    float4 positionCS               : SV_POSITION;
    float2 fogCoord :TEXCOORD10;
    float4 color :TEXCOORD11;
    UNITY_VERTEX_INPUT_INSTANCE_ID
    UNITY_VERTEX_OUTPUT_STEREO
};

//Hair AlphaTest Clip
float4 LitFragment(Varyings input) : SV_TARGET
{
    UNITY_SETUP_INSTANCE_ID(input);
    float2 uv = input.uv;
    //  Base Texture ---------------------------------------------------------------------------------------------------
    SurfaceData surfaceData;
    half4 albedoAlpha = SampleAlbedoAlpha(uv, _BaseMap, sampler_BaseMap) * _BaseColor;

    surfaceData.albedo = albedoAlpha.rgb;
    surfaceData.alpha = CustomAlpha(albedoAlpha.r, _BaseColor, _Cutoff);
    return half4(surfaceData.albedo, surfaceData.alpha);
}

void InitializeInputData(Varyings input, half3 normalTS, out InputData inputData)
{
    inputData = (InputData)0;
    
    inputData.positionWS = input.positionWS;

    inputData.positionCS = input.positionCS;
    half3 viewDirWS = SafeNormalize(input.viewDirWS);
    #if defined(_NORMALMAP) || defined(_DETAIL)
        float sgn = input.tangentWS.w;      // should be either +1 or -1
        float3 bitangent = sgn * cross(input.normalWS.xyz, input.tangentWS.xyz);
        inputData.normalWS = TransformTangentToWorld(normalTS, half3x3(input.tangentWS.xyz, bitangent.xyz, input.normalWS.xyz));
    #else
        inputData.normalWS = input.normalWS;
    #endif

    inputData.normalWS = NormalizeNormalPerPixel(inputData.normalWS);
    inputData.viewDirectionWS = SafeNormalize(viewDirWS);

    #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
        inputData.shadowCoord = input.shadowCoord;
    #elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
        inputData.shadowCoord = TransformWorldToShadowCoord(inputData.positionWS);
    #else
        inputData.shadowCoord = float4(0, 0, 0, 0);
    #endif

    #if defined(_PEROBJECT_SHADOW_ON)
        inputData.PerObjshadowCoord = TransformWorldToPerObjShadowCoord(inputData.positionWS);
    #endif
    
    inputData.fogCoord = InitializeInputDataFog(float4 (input.positionWS ,1.0) , input.fogFactorAndVertexLight.x); //input.fogFactorAndVertexLight.x;
    inputData.vertexLighting = input.fogFactorAndVertexLight.yzw;
    inputData.bakedGI = SAMPLE_GI(input.lightmapUV, input.vertexSH, inputData.normalWS);
    inputData.normalizedScreenSpaceUV = GetNormalizedScreenSpaceUV(input.positionCS);
    inputData.shadowMask = SAMPLE_SHADOWMASK(input.lightmapUV);
}

half4 CustomActerPBR(InputData inputData, SurfaceData surfaceData,float4 tangentWS ,float2 uv)
{
    BRDFData brdfData;

    AnisotropicData anisotropicData = (AnisotropicData)0;
    #ifdef _FABRIC
        #ifdef _FABRIC_SILK_MATERIAL
            InitializationAnisotropicData(inputData.normalWS, tangentWS.xyz , 1.0 - surfaceData.smoothness, anisotropicData);
        #endif
    #endif

    InitializeBRDFData(surfaceData.albedo, surfaceData.metallic, surfaceData.specular, surfaceData.smoothness, surfaceData.alpha, brdfData);

    half4 shadowMask = CalculateShadowMask(inputData);
    AmbientOcclusionFactor aoFactor = CreateAmbientOcclusionFactor(inputData, surfaceData);
    Light mainLight = GetMainLight(inputData  , shadowMask ,aoFactor);
#if defined(_PEROBJECT_SHADOW_ON)
    if(_PerObjectShadow_Render == 1)
    {
      
            #ifdef _MAIN_LIGHT_SHADOWS_CASCADE
            half cascadeIndex = ComputeCascadeIndex(inputData.positionWS);
            #else
            half cascadeIndex = half(0.0);
            #endif
            if (_PerObjectMinMixed)
            {
                half perobjshadow=PerObjectShadow(inputData.PerObjshadowCoord);
                mainLight.shadowAttenuation = perobjshadow < mainLight.shadowAttenuation ? perobjshadow : mainLight.shadowAttenuation;
            }
            else
            {
                half shadowdepth=SAMPLE_TEXTURE2D_LOD(_MainLightShadowmapTexture,sampler_LinearClamp,inputData.shadowCoord.xy,cascadeIndex);
                float3 shadowCS=float3(inputData.shadowCoord.x,inputData.shadowCoord.y,shadowdepth);
                float3 shadowWS=TransformShadowCoordToWorld(shadowCS,cascadeIndex);
    
                half perobjectdepth=SAMPLE_TEXTURE2D(_PerObjectShadowAtlas,sampler_LinearClamp,inputData.PerObjshadowCoord.xy);
                float3 shadowPCS=float3(inputData.PerObjshadowCoord.x,inputData.PerObjshadowCoord.y,perobjectdepth);
                float3 shadowPWS=TransformPerShadowCoordToWorld(shadowPCS,inputData.PerObjshadowCoord.w);
                half csmshadowdepth=SAMPLE_TEXTURE2D_LOD(_MainLightShadowmapTexture,sampler_LinearClamp,inputData.shadowCoord.xy,cascadeIndex);
                bool selfshadow=ComparePerObjShadowToWorldCoord(shadowPWS, inputData.PerObjshadowCoord.w, csmshadowdepth, cascadeIndex, shadowWS);
                if (selfshadow)
                {
                    mainLight.shadowAttenuation = PerObjectShadow(inputData.PerObjshadowCoord)*_PerObjectShadowWeight;
                }
            }
        
    }

#endif
    MixRealtimeAndBakedGI(mainLight, inputData.normalWS, inputData.bakedGI);

    half3 indirectColor = CustomGI(brdfData, inputData, mainLight, inputData.bakedGI, surfaceData.occlusion, inputData.normalWS, inputData.viewDirectionWS);

    #ifdef _FABRIC
        half3 directColor = PhysicallyBaseDirectLighting(inputData, brdfData ,mainLight,anisotropicData );
    #elif defined(_SKIN)
        half3 directColor = LightingPhysicallyBased_Skin(brdfData, mainLight ,inputData.normalWS ,inputData.viewDirectionWS, uv);
    #elif defined(_HAIR)
        half3 directColor = LightingPhysicallyBased_Hair(brdfData, mainLight, uv, tangentWS, surfaceData.normalTS, inputData.normalWS, inputData.viewDirectionWS);
    #elif defined(_PLANT)
        half3 directColor = LightingPhysicallyBased_TwoSideBxDF(brdfData , mainLight , inputData.normalWS ,inputData.viewDirectionWS);
    #elif defined(_TOONHAIR)
        half3 directColor = LightingPhysicallyBased_ToonHair(brdfData, mainLight, inputData.normalWS, inputData.viewDirectionWS);
    #elif defined(_TOONLIT)
        half3 directColor = LightingPhysicallyBased_ToonLit(brdfData, mainLight, inputData.normalWS, inputData.viewDirectionWS);
    #else
        half3 directColor = LightingPhysicallyBased_BxDF(brdfData, mainLight, inputData.normalWS, inputData.viewDirectionWS);
    #endif

    #ifdef _ADDITIONAL_LIGHTS
        directColor += GetAdditional_Lights(inputData, brdfData ,uv , tangentWS , surfaceData.normalTS, anisotropicData);
       // return GetAdditional_Lights(inputData, brdfData ,uv , tangentWS , surfaceData.normalTS, anisotropicData).xyzz;
    #endif

    half3 color = directColor + indirectColor;


    #ifdef _ADDITIONAL_LIGHTS_VERTEX
        color += inputData.vertexLighting * brdfData.diffuse;
    #endif

    #ifdef _RIM_ON
        float WrapNoL = dot(inputData.normalWS , mainLight.direction ) * 0.5 + 0.5;
        float NoV = saturate(dot(inputData.normalWS , inputData.viewDirectionWS));
        float positionOS_Y = TransformWorldToObject(inputData.positionWS).y;//mul((float3x3)(unity_WorldToObject) , inputData.positionWS ).y;

        float3 rim = pow(1 - NoV, (1 - _FresnelFalloffValue) * 16) * _FresnelAddPow * _FresnelAddColor.rgb;
        color += rim * mainLight.distanceAttenuation * mainLight.shadowAttenuation;
    #endif
    
    return half4(color, surfaceData.alpha);
}

///////////////////////////////////////////////////////////////////////////////
//                  Vertex and Fragment functions                            //
///////////////////////////////////////////////////////////////////////////////

// Used in Standard (Physically Based) shader
Varyings LitPassVertex(Attributes input)
{
    Varyings output = (Varyings)0;

    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_TRANSFER_INSTANCE_ID(input, output);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);
    VertexPositionInputs vertexInput = (VertexPositionInputs)0;
    #if defined(_WINDANIM_ON)
        float3 posWS = TransformObjectToWorld(input.positionOS);
        vertexInput = WindAnim(  posWS , input.positionOS.xyz ,vertexInput);
    #else
        vertexInput = GetVertexPositionInputs(input.positionOS.xyz );
    #endif


 

    output.positionOS = input.positionOS;
    // normalWS and tangentWS already normalize.
    // this is required to avoid skewing the direction during interpolation
    // also required for per-vertex lighting and SH evaluation
    VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);

    half3 viewDirWS = GetWorldSpaceViewDir(vertexInput.positionWS);
    half3 vertexLight = VertexLighting(vertexInput.positionWS, normalInput.normalWS);
    half fogFactor = ComputeFogFactor(vertexInput.positionCS.z);
    output.uv = TRANSFORM_TEX(input.texcoord, _BaseMap);

    output.normalWS = normalInput.normalWS;
    output.viewDirWS = viewDirWS;
    #if defined(REQUIRES_WORLD_SPACE_TANGENT_INTERPOLATOR) || defined(REQUIRES_TANGENT_SPACE_VIEW_DIR_INTERPOLATOR)
    real sign = input.tangentOS.w * GetOddNegativeScale();
    half4 tangentWS = half4(normalInput.tangentWS.xyz, sign);
    #endif
    #if defined(REQUIRES_WORLD_SPACE_TANGENT_INTERPOLATOR)
    output.tangentWS = tangentWS;
    #endif

    #if defined(REQUIRES_TANGENT_SPACE_VIEW_DIR_INTERPOLATOR)
        half3 viewDirTS = GetViewDirectionTangentSpace(tangentWS, output.normalWS, viewDirWS);
        output.viewDirTS = viewDirTS;
    #endif

    OUTPUT_LIGHTMAP_UV(input.lightmapUV, unity_LightmapST, output.lightmapUV);
    OUTPUT_SH(output.normalWS.xyz, output.vertexSH);

    output.fogFactorAndVertexLight = half4(fogFactor, vertexLight);


    output.positionWS =vertexInput.positionWS;
   

    #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
        output.shadowCoord = GetShadowCoord(vertexInput);
    #endif

    output.positionCS = vertexInput.positionCS;


    output.fogCoord = ComputeFogUV(output.positionCS.z,vertexInput.positionWS.y);
    output.color = input.color;
    return output;
}

// Used in Standard (Physically Based) shader
half4 LitPassFragment(Varyings input) : SV_Target
{
    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

    half3 msa = SAMPLE_TEXTURE2D(_MSAMap, sampler_MSAMap,input.uv.xy).rgb;
    #ifdef _EYE
        float3 EyeDepth = SAMPLE_TEXTURE2D(_EyeDepth , sampler_EyeDepth , input.uv);
        float3 EyeNormal =UnpackNormal( SAMPLE_TEXTURE2D(_EyeNormal , sampler_EyeNormal , input.uv));

        float3 bitangentWS = input.tangentWS.w * cross(input.normalWS , input.tangentWS.xyz);
        float3x3 tbn = float3x3(input.tangentWS.xyz ,bitangentWS, input.normalWS);
        EyeNormal =( TransformTangentToWorld(EyeNormal ,tbn)); 

        float3 tangent =normalize( TransformTangentToWorld( float3(1,0,0) ,tbn));

        float3 Eye = EyeReflection(input.uv , _ScaleByCenter ,_IrisRadius, _LimbusUVWidth ,_IOR ,input.normalWS ,input.viewDirWS , EyeDepth , _DepthScale ,EyeNormal ,tangent ,_PupilRadius ,_LimbusUVWidthShading ,_PosOffset);

        float4 Iris = SAMPLE_TEXTURE2D(_IrisTex , sampler_IrisTex , Eye.xy);
        float4 IrisMask = SAMPLE_TEXTURE2D(_IrisMask ,sampler_IrisMask , input.uv);
    
        float3 eye = lerp(IrisMask.xyz ,Iris.xyz ,Eye.z);
    #endif
    
    SurfaceData surfaceData;
    #ifdef _CalcMaterialSurface
        CalcMaterialSurfaceData(input.uv, surfaceData, input.color);
    #else
        #ifdef _MSA
            InitializeStandardLitSurfaceData(input.uv, surfaceData ,msa);
        #else
            InitializeStandardLitSurfaceData(input.uv , surfaceData);
        #endif
    #endif

    #ifdef LOD_FADE_CROSSFADE
    LODFadeCrossFade(input.positionCS,surfaceData.alpha );
    #endif

    
    #ifdef _EYE
        surfaceData.albedo = eye *_Bright * _BaseColor;
    #endif



    #if defined(_PLANT) 
        surfaceData.albedo = GrassColorGrid(surfaceData.albedo ,input.positionOS.y  ,input.color.r , input.positionWS) ;
    #endif

    #ifdef _SCENE_COMMON
    surfaceData.albedo = AdjustSaturation(surfaceData.albedo);
    #endif
    
    InputData inputData;
    InitializeInputData(input, surfaceData.normalTS, inputData);
    half4 color = CustomActerPBR(inputData, surfaceData,input.tangentWS,input.uv);
    
   // color.rgb = MixFog(color.rgb , input.fogCoord);
  
    color.rgb = MixFog(color.rgb , inputData.fogCoord);

    if(ApplyVolumetricFog)
    {
        float3 volumeUV = ComputeVolumeUV(input.positionWS);
        float4 fogging = ComputeGlobalVolumetricFog(volumeUV, input.positionCS.w);
        color.rgb = color.rgb * fogging.a + fogging.rgb;
    }

    #ifdef _VERTEXCOLOR_ON
        color.rgb = input.color.rgb;
    #endif
    
    return color;
}
