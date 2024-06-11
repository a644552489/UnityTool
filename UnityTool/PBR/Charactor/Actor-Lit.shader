Shader "TADemo/Combine/Lit"
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
        [Toggle(_PEROBJECT_SHADOW_ON)] _PEROBJECT_SHADOW("PerObject Shadow",Float)= 0.0
        [Toggle(_ALPHATEST_ON)]_AlphaClip("AlphaClip", Float) = 0.0
        [StyledIndentLevelAdd]
        [StyledIfShow(_AlphaClip)][StyledField]_Cutoff("Alpha Cutoff", Range(0.0, 1.0)) = 0.5
        _DirectBright("_DirectBright" ,Range(1,5)) =1
        _IndirectBright("_IndirectBright" , Range(1,5)) =1
        _EnvReflectionScale("EnvReflectionScale" ,Range(0, 10)) = 1
        _Saturation("_Saturation" , Range(0,1)) =1
        [Space(30)]
        [StyledTextureSingleLine] _BaseMap("Albedo", 2D) = "white" {}
        [MainColor] _BaseColor("Color", Color) = (1,1,1,1)
        
        [StyledKeywordTextureSingleLine(_NORMALMAP)]_BumpMap("Normal Map", 2D) = "bump" {}
        _BumpScale("_BumpScale" , Range(0,2))=1
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
             #pragma  shader_feature_local _RIM_ON
            #pragma shader_feature _MSA

            #pragma enable_d3d11_debug_symbols
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
            #pragma multi_compile _ _PEROBJECT_SHADOW_ON
            #pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
            #pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
            #define _ADDITIONAL_LIGHTS
            #define _SCENE_COMMON
            // #define _MAIN_LIGHT_SHADOWS
            //
            // #define _MAIN_LIGHT_SHADOWS_CASCADE
            //
            //
            // #define _SHADOWS_SOFT
            //
            // #define SHADOWS_SHADOWMASK

    
            // #define _RECEIVE_SHADOWS_OFF
            
            #pragma vertex LitPassVertex
            #pragma fragment LitPassFragment
  
            #include "Actor-Input.hlsl"
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
            #pragma enable_d3d11_debug_symbols
            #pragma vertex ShadowPassVertex
            #pragma fragment ShadowPassFragment

            #include "Actor-Input.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Shaders/ShadowCasterPass.hlsl"
            ENDHLSL
        }
        
        
    }

  

    FallBack "SLG_Custom/CommonShader/MaterialError"
   CustomEditor "YLib.StyledEditor.StyledMaterial.MaterialCoreGUI"
}
