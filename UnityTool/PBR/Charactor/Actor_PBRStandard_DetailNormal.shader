Shader "TADemo/PBRStandard_DetailNormal"
{
    Properties
    {
        // Specular vs Metallic workflow
        [StyledCategory(Render Settings,true)]_Category_Colapsable_Render("[ Rendering Cat ]", Float) = 1
        [Enum(UnityEngine.Rendering.BlendMode)]_SrcBlend("SrcBlend", Float) = 1.0
        [Enum(UnityEngine.Rendering.BlendMode)]_DstBlend("DstBlend", Float) = 0.0
        [Enum(Off, 0, On, 1)]_ZWrite("ZWrite", Float) = 1.0
        [Enum(UnityEngine.Rendering.CompareFunction)]_ZTest ("ZTest", Float) = 4
        [Enum(UnityEngine.Rendering.CullMode)]_Cull("Cull", Float) = 2.0
        [Toggle(_VERTEXCOLOR_ON)]_VertexColor("VertexColor", Float) = 0.0
        [Toggle(_ALPHATEST_ON)]_AlphaClip("AlphaClip", Float) = 0.0
        [StyledIndentLevelAdd]
        [StyledIfShow(_AlphaClip)][StyledField]_Cutoff("Alpha Cutoff", Range(0.0, 1.0)) = 0.5
        _DirectBright("_DirectBright" ,Range(1,5)) =1
        _IndirectBright("_IndirectBright" , Range(1,5)) =1
        _EnvReflectionScale("EnvReflectionScale" ,Range(0, 10)) = 1
        _Saturation("_Saturation" , Range(0,1)) =1
        
    
        [StyledCategory(Layer0, true)]_Category_BaseLayer("[ Rendering Cat ]", Float) = 1
        [StyledTextureSingleLine] _BaseMap("Albedo", 2D) = "white" {}
        [MainColor] _BaseColor("Color", Color) = (1,1,1,1)
        [StyledKeywordTextureSingleLine(_NORMALMAP)]_BumpMap("Normal Map", 2D) = "bump" {}
        _BumpScale("_BumpScale" , Range(0,2)) = 1
        
        [StyledCategory(Layer1, true)]_Category_Layer1("[ Rendering Cat ]", Float) = 1
        [StyledTextureSingleLine] _DetailBaseColorTexture("DetailBaseColor", 2D) = "white" {}
        _DetailBaseColorTexture_ST("DetailBaseColorST", Vector) = (1, 1, 0, 0)
        [StyledKeywordTextureSingleLine(_DetailNORMALMAP)]_DetailNormal("DetialNormal", 2D) = "bump" {}
        _DetailNormal_ST("DetialNormalTilling", Vector) = (1, 1, 0, 0)
        _DetailBlend("DetialBlend", Range(0, 1)) = 0.5
        
        [StyledCategory(Layer2, true)]_Category_Layer2("[ Rendering Cat ]", Float) = 1
        [StyledTextureSingleLine] _Layer2_BaseColorTexture("Layer2_BaseColor", 2D) = "white" {}
        _Layer2_BaseColorTexture_ST("Layer2BaseColorST", Vector) = (1, 1, 0, 0)
        [StyledKeywordTextureSingleLine(_Layer2_NormalTexture)]_Layer2Normal("DetialNormal", 2D) = "bump" {}
        _Layer2Normal_ST("Layer2NormalTilling", Vector) = (1, 1, 0, 0)
        _Layer2Blend("Layer2Blend", Range(0, 1)) = 0.5
        
        [Space(20)]
        [StyledKeywordTextureSingleLine(_MSA)] _MSAMap("Metallic_Smooth_AO",2D)="white"{}
        _Metallic("Metallic", Range(0.0, 1.0)) = 0.0
        _Smoothness("Smoothness", Range(0.0, 1.0)) = 0.5
        _Occlusion("_Occlusion", Range(0.0, 1.0)) = 1.0
        
        [StyledTextureSingleLine] _StylizedReflectionMap("StylizedReflect", 2D) = "black" {}
        _StylizedReflectionWeight("StylizedReflectionWeight", Range(0.0, 1.0)) = 0.0
        _StylizedReflectionDensity("StylizedDensity", Range(0.0, 10.0)) = 1.0
    }

    //1500
    SubShader
    {
        Tags{"RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" "UniversalMaterialType" = "Lit" "IgnoreProjector" = "True" }
        LOD 1500

        Pass
        {
            Name "ForwardLit"
            Tags{"LightMode" = "UniversalForward"}

            Blend[_SrcBlend][_DstBlend]
            ZWrite[_ZWrite]
            Cull[_Cull]

            HLSLPROGRAM

            #pragma target 3.0

            //Debug
            // #pragma enable_d3d11_debug_symbols

            // GPU Instancing
            #pragma multi_compile_instancing
            #pragma multi_compile_fog
            // -------------------------------------
            // Material Keywords
            #pragma shader_feature _DETAIL
            #pragma shader_feature_local _RIM_ON
            #pragma shader_feature_local _VERTEXCOLOR_ON
            #pragma shader_feature _MSA
            
            #pragma shader_feature_local _NORMALMAP
            #pragma shader_feature_local_fragment _ALPHATEST_ON
            #pragma shader_feature_local_fragment _ALPHAPREMULTIPLY_ON
          
            
            #pragma shader_feature_local_fragment _METALLICSPECGLOSSMAP
            #pragma shader_feature_local_fragment _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
            #pragma shader_feature_local_fragment _OCCLUSIONMAP
            
            //#pragma shader_feature_local_fragment _SPECULAR_SETUP
            // #pragma shader_feature_local_fragment _RECEIVE_SHADOWS_OFF
            
            #pragma multi_compile _ LIGHTMAP_ON
            #pragma multi_compile _ DIRLIGHTMAP_COMBINED
            // -------------------------------------
            // Universal Pipeline keywords
            #pragma multi_compile _ _RAMP_FOG
            //#pragma multi_compile _ _ADDITIONAL_LIGHTS
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile_fragment _ _SHADOWS_SOFT
            #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
            #pragma multi_compile _ SHADOWS_SHADOWMASK
            #pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
            #pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
            #define _ADDITIONAL_LIGHTS
            #define _CalcMaterialSurface
            #define _SCENE_COMMON
            
            #pragma vertex LitPassVertex
            #pragma fragment LitPassFragment
            
            #include "Actor-Input.hlsl"
            void CalcMaterialSurfaceData(float2 uv, out SurfaceData outSurfaceData, float4 VertexColor)
            {
                float B0 = _DetailBlend * VertexColor.r;
                float B1 = _Layer2Blend* VertexColor.g;
                outSurfaceData = (SurfaceData)0;
                half4 albedoAlpha = SampleAlbedoAlpha(uv.xy, TEXTURE2D_ARGS(_BaseMap, sampler_BaseMap));
                half4 DetialBaseColor = SampleAlbedoAlpha(uv.xy * _DetailBaseColorTexture_ST.xy, TEXTURE2D_ARGS(_DetailBaseColorTexture, sampler_DetailBaseColorTexture));
                half4 Layer2BaseColor = SampleAlbedoAlpha(uv.xy * _Layer2_BaseColorTexture_ST.xy, TEXTURE2D_ARGS(_Layer2_BaseColorTexture, sampler_Layer2_BaseColorTexture));
                outSurfaceData.alpha = Alpha(albedoAlpha.a, _Cutoff);
                outSurfaceData.albedo = lerp(albedoAlpha.rgb, DetialBaseColor.rgb, B0) * _BaseColor.rgb;
                outSurfaceData.albedo = lerp(outSurfaceData.albedo, Layer2BaseColor.rgb, B1) * _BaseColor.rgb;

                
                outSurfaceData.metallic = _Metallic;
                outSurfaceData.specular = half3(0.0h, 0.0h, 0.0h);//half3(0.5h, 0.5h, 0.5h);
                outSurfaceData.smoothness = saturate( _Smoothness);

                half3 BaseNormal = SampleNormal(uv.xy, TEXTURE2D_ARGS(_BumpMap, sampler_BumpMap), _BumpScale);
                half3 DetailNormal = SampleNormal(uv.xy * _DetailNormal_ST.xy, TEXTURE2D_ARGS(_DetailNormal, sampler_DetailNormal), _BumpScale);
                half3 Layer2_Normal = SampleNormal(uv.xy * _Layer2Normal_ST.xy, TEXTURE2D_ARGS(_Layer2_NormalTexture, sampler_Layer2_NormalTexture), _BumpScale);
                outSurfaceData.normalTS = normalize(lerp(BaseNormal, DetailNormal, B0));
                //outSurfaceData.normalTS = normalize(lerp(outSurfaceData.normalTS, Layer2_Normal, B1));
                outSurfaceData.occlusion = _Occlusion;
                // #if defined (_EMISSION_DYNAMIC)
                //     float emissionMask = SAMPLE_TEXTURE2D(_WaveMap,sampler_WaveMap,uv.zw).r;
                //     outSurfaceData.emission = SampleEmission(uv.xy, _EmissionColor.rgb * emissionMask, TEXTURE2D_ARGS(_EmissionMap, sampler_EmissionMap));
                // #else
                //     outSurfaceData.emission = SampleEmission(uv.xy, _EmissionColor.rgb, TEXTURE2D_ARGS(_EmissionMap, sampler_EmissionMap));
                // #endif
            
                #if defined(_CLEARCOAT) || defined(_CLEARCOATMAP)
                    half2 clearCoat = SampleClearCoat(uv.xy);
                    outSurfaceData.clearCoatMask       = clearCoat.r;
                    outSurfaceData.clearCoatSmoothness = clearCoat.g;
                #else
                    outSurfaceData.clearCoatMask       = 0.0h;
                    outSurfaceData.clearCoatSmoothness = 0.0h;
                #endif
            
                #ifdef _DETAIL
                    float2 detailUV = uv * _DetailNormal_ST.xy + _DetailNormal_ST.zw;
                    float3 BlendNormal = ApplyDetailNormal(detailUV ,outSurfaceData.normalTS);
                    outSurfaceData.normalTS = BlendNormal;
                #endif
       
            }
            #include "Actor-Pass.hlsl"
            ENDHLSL
        }

        Pass
        {
            Name "ShadowCaster"
            Tags{"LightMode" = "ShadowCaster"}

            ZWrite On
            ZTest LEqual
            ColorMask 0
            Cull[_Cull]

            HLSLPROGRAM
            
            #pragma target 3.0
            
            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing

            // -------------------------------------
            // Material Keywords
            #pragma shader_feature_local_fragment _ALPHATEST_ON
            #pragma shader_feature_local_fragment _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A

            #pragma vertex ShadowPassVertex
            #pragma fragment ShadowPassFragment

            #include "Actor-Input.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Shaders/ShadowCasterPass.hlsl"
            ENDHLSL
        }
 

              Pass
        {
            Name "DepthNormals"
            Tags
            {
                "LightMode" = "DepthNormals"
            }

            // -------------------------------------
            // Render State Commands
            ZWrite On
            Cull[_Cull]

            HLSLPROGRAM
            #pragma target 2.0

            // -------------------------------------
            // Shader Stages
            #pragma vertex DepthNormalsVertex
            #pragma fragment DepthNormalsFragment

            // -------------------------------------
            // Material Keywords
            #pragma shader_feature_local _NORMALMAP
            #pragma shader_feature_local _PARALLAXMAP
            #pragma shader_feature_local _ _DETAIL_MULX2 _DETAIL_SCALED
            #pragma shader_feature_local_fragment _ALPHATEST_ON
            #pragma shader_feature_local_fragment _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A

            // -------------------------------------
            // Unity defined keywords
            #pragma multi_compile_fragment _ LOD_FADE_CROSSFADE

            // -------------------------------------
            // Universal Pipeline keywords
            #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"

            // -------------------------------------
            // Includes
            #include "Packages/com.unity.render-pipelines.universal/Shaders/LitInput.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Shaders/LitDepthNormalsPass.hlsl"
            ENDHLSL
        }
    }
    
    FallBack "SLG_Custom/CommonShader/MaterialError"
    CustomEditor "YLib.StyledEditor.StyledMaterial.MaterialCoreGUI"
}
