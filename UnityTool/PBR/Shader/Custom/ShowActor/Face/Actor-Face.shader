Shader "SLG_Custom/ShowActor/Actor-Face"
{
    Properties
    {
        // Specular vs Metallic workflow
        [HideInInspector] _WorkflowMode("WorkflowMode", Float) = 1.0

        [MainTexture] _BaseMap("Albedo", 2D) = "white" {}
        [MainColor] _BaseColor("Color", Color) = (1,1,1,1)

        _Cutoff("Alpha Cutoff", Range(0.0, 1.0)) = 0.5



        [ToggleOff] _SpecularHighlights("Specular Highlights", Float) = 1.0
        [ToggleOff] _EnvironmentReflections("Environment Reflections", Float) = 1.0

        _BumpScale("_BumpMapScale", Float) = 1.0
        _BumpMap("Normal Map", 2D) = "bump" {}
        

        [Space]
        _BrightPart("BrightPart" , Color) = (1,1,1,1)
        _ShadePart("ShadePart",Color ) = (0,0,0,0)
        _RampThreshold("_RampThreshold" , Range(0,1))=0
        _RampSmooth("_RampSmooth" ,Range(0,1)) =0
        [Space]

      //  _OcclusionStrength("_OcclusionStrength", Range(0.0, 1.0)) = 1.0
      //  _OcclusionMap("Occlusion", 2D) = "white" {}

    //    [HDR] _EmissionColor("Color", Color) = (0,0,0)
    //    _EmissionMap("Emission", 2D) = "white" {}

        [NoScaleOffset]_MSAMap("M_S_A",2D) = "white" {}



        _MetaStrength("Meta Strength", Range(0.0, 1.0)) =0
        _SmoothnessStrength("Smoothness Strength", Range(0.0, 1.0)) = 1.0
        _AOStrength("AO Strength", Range(0.0, 2.0)) = 1.0

        _3SFrontMask("3S-Front-Mask", Range( 0 , 2)) = 1
        _3SBackMask("3S-Back-Mask", Range( 0 , 2)) = 1
        _3SColor("3S-Color", Color) = (0,0,0,0)
        _3SStrength("3S-Strength", Range( 0 , 50)) = 1
		_3SRampMap("3SRampMap", 2D) = "white" {}
	
        _DetailNormalMapScale("Detail Scale", Range(0.0, 2.0)) = 1.0
        [Normal] _DetailNormalMap("Detail Normal Map", 2D) = "bump" {}


    

        // Blending state
        [HideInInspector] _Surface("__surface", Float) = 0.0
        [HideInInspector] _Blend("__blend", Float) = 0.0
        [HideInInspector] _AlphaClip("__clip", Float) = 0.0
        [HideInInspector] _SrcBlend("__src", Float) = 1.0
        [HideInInspector] _DstBlend("__dst", Float) = 0.0
        [HideInInspector] _ZWrite("__zw", Float) = 1.0
        [HideInInspector] _Cull("__cull", Float) = 2.0


        // Editmode props
        [HideInInspector] _QueueOffset("Queue offset", Float) = 0.0

        // ObsoleteProperties
        [HideInInspector] _MainTex("BaseMap", 2D) = "white" {}
        [HideInInspector] _Color("Base Color", Color) = (1, 1, 1, 1)
        [HideInInspector] _GlossMapScale("Smoothness", Float) = 0.0
        [HideInInspector] _Glossiness("Smoothness", Float) = 0.0
        [HideInInspector] _GlossyReflections("EnvironmentReflections", Float) = 0.0


                	[Space]
                [Header(OUTLINE)]
                [Space]
           
                [Toggle]_ScreenOutlineOn("屏幕描边测试", Float) = 1
                _OutlineColor("描边颜色", Color) = (0, 0, 0, 1)
           
     
                _OutLineScale ("屏幕描边缩放", Range(0.0,0.03)) = 0.001 //0.0015s
                _ScreenOutlineDeW("屏幕描边假透视",Range(0.0,1)) = 0.6
        _OutlineBaseThicknessMul("描边厚度",Range(0,1))=0.2
    }

    SubShader
    {
        Tags{"RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" "UniversalMaterialType" = "Lit" "IgnoreProjector" = "True" }
        LOD 800

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
            //#pragma shader_feature_local _NORMALMAP
            #pragma shader_feature_local_fragment _ALPHATEST_ON
            #pragma shader_feature_local_fragment _ALPHAPREMULTIPLY_ON
            #pragma shader_feature_local_fragment _EMISSION
            #pragma shader_feature_local_fragment _METALLICSPECGLOSSMAP
            #pragma shader_feature_local_fragment _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
            #pragma shader_feature_local_fragment _OCCLUSIONMAP

            #pragma shader_feature_local_fragment _SPECULARHIGHLIGHTS_OFF
            #pragma shader_feature_local_fragment _ENVIRONMENTREFLECTIONS_OFF
            //#pragma shader_feature_local_fragment _SPECULAR_SETUP
            #pragma shader_feature_local_fragment _RECEIVE_SHADOWS_OFF
            // -------------------------------------
            // Universal Pipeline keywords
            //#pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile_fragment _ _SHADOWS_SOFT

            #define _ADDITIONAL_LIGHTS
            // #define _RECEIVE_SHADOWS_OFF
            #define _NORMALMAP
            #define _DETAIL
            #define _FACE
            
            #pragma vertex LitPassVertex
            #pragma fragment LitPassFragment

            #include "Actor-Face-Input.hlsl"
            #include "Actor-Face-Pass.hlsl"
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

            #include "Actor-Face-Input.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Shaders/ShadowCasterPass.hlsl"
            ENDHLSL
        }
            
            Pass
        {
            Name "Outline"
            Tags
            {
                "LightMode" = "Outline"
            }
            Cull Front

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "../Outline_Input.hlsl"
            #include "../Outline_Pass.hlsl"
            ENDHLSL
        }
    }

    FallBack "SLG_Custom/CommonShader/MaterialError"

}
