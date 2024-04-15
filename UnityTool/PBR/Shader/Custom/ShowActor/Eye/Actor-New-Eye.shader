Shader "SLG_Custom/ShowActor/Actor-New-Eye"
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
        [Toggle(_ALPHATEST_ON)]_AlphaClip("AlphaClip", Float) = 0.0
        [StyledIndentLevelAdd]
        [StyledIfShow(_AlphaClip)][StyledField]_Cutoff("Alpha Cutoff", Range(0.0, 1.0)) = 0.5
    
          _Metallic("Metallic", Range(0.0, 1.0)) = 0.0
          _Smoothness("Smoothness", Range(0.0, 1.0)) = 0.5
        _Occlusion("AO Strength", Range(0.0, 1.0)) = 1.0
        
        [Space(20)]
    _IrisRadius("Iris Radius" , Range(0.01 , 1)) = 0.225
        _ScaleByCenter("_ScaleByCenter",Range(0,1))= 0.5
        _LimbusUVWidth("_LimbusUVWidth" , Range(0 ,1))= 0

_LimbusUVWidthShading("DepthOffset" , Range(0,1))=0
            _DepthScale("_DepthScale" , Range(0,1 )) = 1
        _PosOffset("_PosOffset" , Range( 0,1))=0

        _IrisTex("Iris Texture" , 2D)= "white"{}
        _IrisMask("Iris Mask" , 2D) = "white"{}



        _IOR("IOR of Eye" ,Range(1,2)) = 1.33

        _PupilRadius("Pupil Radius" , Range(0.01,5)) =0.3

        _EyeDepth("_EyeDepth" , 2D) = "Black"{}
    

        _EyeNormal("EyeNormal" ,2D) ="Bump"{}
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

            // -------------------------------------
            // Material Keywords
            #pragma shader_feature_local _NORMALMAP
            #pragma shader_feature_local_fragment _ALPHATEST_ON
            #pragma shader_feature_local_fragment _ALPHAPREMULTIPLY_ON
            #pragma shader_feature_local_fragment _EMISSION
            #pragma shader_feature_local_fragment _EMISSION_DYNAMIC
            #pragma shader_feature_local_fragment _METALLICSPECGLOSSMAP
            #pragma shader_feature_local_fragment _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
            #pragma shader_feature_local_fragment _OCCLUSIONMAP

            #pragma shader_feature_local_fragment _SPECULARHIGHLIGHTS_OFF
            #pragma shader_feature_local_fragment _ENVIRONMENTREFLECTIONS_OFF

            //#pragma shader_feature_local_fragment _SPECULAR_SETUP
            #pragma shader_feature_local_fragment _RECEIVE_SHADOWS_OFF

            #pragma shader_feature_local_fragment _CUSTOM_REFLECT_ON
            #pragma shader_feature_local_fragment _EDGE_LIGHT_ON

            // -------------------------------------
            // Universal Pipeline keywords
            //#pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile_fragment _ _SHADOWS_SOFT

            #define _ADDITIONAL_LIGHTS
            // #define _RECEIVE_SHADOWS_OFF
            
            #pragma vertex LitPassVertex
            #pragma fragment LitPassFragment
        
            #include "Actor-New-EyeInput.hlsl"
                #include "./Eye.hlsl"
            #include "Actor-New-EyePass.hlsl"
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

            #include "Actor-New-EyeInput.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Shaders/ShadowCasterPass.hlsl"
            ENDHLSL
        }
        
    }

  

    FallBack "SLG_Custom/CommonShader/MaterialError"
   CustomEditor "YLib.StyledEditor.StyledMaterial.MaterialCoreGUI"
}
