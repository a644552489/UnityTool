Shader "SLG_Custom/ShowActor/Actor-Hair"
{
    Properties
    {
        // Specular vs Metallic workflow
        [HideInInspector] _WorkflowMode("WorkflowMode", Float) = 1.0

        [MainTexture] _BaseMap("Albedo", 2D) = "white" {}
        [MainColor] _BaseColor("Color", Color) = (1,1,1,1)

        _Cutoff("Alpha Cutoff", Range(0.0, 1.0)) = 0.5

        _Smoothness("Smoothness", Range(0.0, 1.0)) = 0.5
        _GlossMapScale("Smoothness Scale", Range(0.0, 1.0)) = 1.0
        _SmoothnessTextureChannel("Smoothness texture channel", Float) = 0

        _Metallic("Metallic", Range(0.0, 1.0)) = 0.0
        _MetallicGlossMap("Metallic", 2D) = "white" {}

        _SpecColor("Specular", Color) = (0.2, 0.2, 0.2)
        _SpecGlossMap("Specular", 2D) = "white" {}

        [ToggleOff] _SpecularHighlights("Specular Highlights", Float) = 1.0
        [ToggleOff] _EnvironmentReflections("Environment Reflections", Float) = 1.0

        _BumpScale("Scale", Float) = 1.0
        _BumpMap("Normal Map", 2D) = "bump" {}

        // _Parallax("Scale", Range(0.005, 0.08)) = 0.005
        // _ParallaxMap("Height Map", 2D) = "black" {}

        _OcclusionStrength("Strength", Range(0.0, 1.0)) = 1.0
        _OcclusionMap("Occlusion", 2D) = "white" {}

        [HDR] _EmissionColor("Color", Color) = (0,0,0)
        _EmissionMap("Emission", 2D) = "white" {}

        [NoScaleOffset]_MSAMap("M_S_A",2D) = "white" {}
        _MetaStrength("Meta Strength", Range(0.0, 2.0)) = 1.0
        _SmoothnessStrength("Smoothness Strength", Range(0.0, 2.0)) = 1.0
        _AOStrength("AO Strength", Range(0.0, 2.0)) = 1.0

        [NoScaleOffset]_ShiftMap("ShiftMap",2D) = "white" {}

        _PrimaryColor ("Primary Color", Color) = (1,1,1,1)
        _PrimaryGloss ("Primary Range", Range(0.0, 10.0)) = 4.0
        _PrimaryShift ("Primary Pos", float) = 0.0

        _SecondaryColor ("Secondary Color", Color) = (1,1,1,1)
        _SecondaryGloss ("Secondary Range", Range(0.0, 10.0)) = 4.0
        _SecondaryShift ("Secondary Pos", float) = 0.0

        _TestAlphaStrength("AlphaTest Alpha Strength", Range(0.01, 3.0)) = 1.0
        _BlenderAlphaStrength("AlphaBlender Alpha Strength", Range(0.01, 3.0)) = 1.0

        _FresnelPow("Fresnel Pow", Range(0.0, 5.0)) = 1.0

        // Blending state
        [HideInInspector] _Surface("__surface", Float) = 0.0
        [HideInInspector] _Blend("__blend", Float) = 0.0
        [HideInInspector] _AlphaClip("__clip", Float) = 0.0
        [HideInInspector] _SrcBlend("__src", Float) = 1.0
        [HideInInspector] _DstBlend("__dst", Float) = 0.0
        [HideInInspector] _ZWrite("__zw", Float) = 1.0
        [HideInInspector] _Cull("__cull", Float) = 2.0

        _ReceiveShadows("Receive Shadows", Float) = 1.0
        // Editmode props
        [HideInInspector] _QueueOffset("Queue offset", Float) = 0.0

        // ObsoleteProperties
        [HideInInspector] _MainTex("BaseMap", 2D) = "white" {}
        [HideInInspector] _Color("Base Color", Color) = (1, 1, 1, 1)
        [HideInInspector] _GlossMapScale("Smoothness", Float) = 0.0
        [HideInInspector] _Glossiness("Smoothness", Float) = 0.0
        [HideInInspector] _GlossyReflections("EnvironmentReflections", Float) = 0.0

        [HideInInspector][NoScaleOffset]unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}

        [HideInInspector]_DisableShadowCaster("Disable Shadow Caster",Float) = 1.0
    }


    SubShader
    {
        Tags {"RenderType" = "Transparent" "Queue"="Transparent" "IgnoreProjector"="True" "RenderPipeline"="UniversalPipeline"}
        LOD 1500

        Pass 
        {
            Name "HairDepth"
            Tags{"LightMode" = "HairDepth"}

            Blend One Zero
            ZWrite On
            Cull[_Cull]
            ZTest LEqual
            ColorMask 0

            HLSLPROGRAM

            #pragma target 3.0

            //Debug
            // #pragma enable_d3d11_debug_symbols

            // GPU Instancing
            #pragma multi_compile_instancing

            #define _ALPHATEST_ON

            #pragma vertex LitPassVertexDepth
            #pragma fragment LitPassFragmentDepth

            #include "Actor-Hair-Input.hlsl"
            #include "Actor-Hair-Pass.hlsl"
            ENDHLSL
        }

        Pass 
        {
            Name "HairBase"
            Tags{"LightMode" = "HairBase"}

            Blend One Zero
            ZWrite off
            Cull[_Cull]
            ZTest Equal
            // Cull front


            HLSLPROGRAM

            #pragma target 3.0

            //Debug
            // #pragma enable_d3d11_debug_symbols

            // GPU Instancing
            #pragma multi_compile_instancing

            // -------------------------------------
            // Material Keywords
            #pragma shader_feature_local _NORMALMAP
            //#pragma shader_feature_local_fragment _ALPHATEST_ON
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
            // #define _ALPHATEST_ON

            #pragma vertex LitPassVertex
            #pragma fragment LitPassFragment

            #include "Actor-Hair-Input.hlsl"
            #include "Actor-Hair-Pass.hlsl"
            ENDHLSL
        }

        Pass
        {
            Name "HairTransparent"
            Tags{"LightMode" = "HairTransparent"}

			Blend SrcAlpha OneMinusSrcAlpha
            ZWrite off
            ZTest Less
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
            //#pragma shader_feature_local_fragment _ALPHATEST_ON
            // #pragma shader_feature_local_fragment _ALPHAPREMULTIPLY_ON
            #pragma shader_feature_local_fragment _EMISSION
            #pragma shader_feature_local_fragment _METALLICSPECGLOSSMAP
            #pragma shader_feature_local_fragment _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
            #pragma shader_feature_local_fragment _OCCLUSIONMAP

            #pragma shader_feature_local_fragment _SPECULARHIGHLIGHTS_OFF
            #pragma shader_feature_local_fragment _ENVIRONMENTREFLECTIONS_OFF
            //#pragma shader_feature_local_fragment _SPECULAR_SETUP
            // #pragma shader_feature_local_fragment _RECEIVE_SHADOWS_OFF
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

            #include "Actor-Hair-Input.hlsl"
            #include "Actor-Hair-Pass.hlsl"
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

            #include "Actor-Hair-Input.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Shaders/ShadowCasterPass.hlsl"
            ENDHLSL
        }
        
    }

    //1100
    //关闭透明pass
    //关闭接受阴影
    //球谐函数关闭
    SubShader
    {
        Tags {"RenderType" = "Transparent" "Queue"="Transparent" "IgnoreProjector"="True" "RenderPipeline"="UniversalPipeline"}
        LOD 1100

        Pass 
        {
            Name "HairDepth"
            Tags{"LightMode" = "HairDepth"}

            Blend One Zero
            ZWrite On
            Cull[_Cull]
            ZTest LEqual
            ColorMask 0

            HLSLPROGRAM

            #pragma target 3.0

            //Debug
            // #pragma enable_d3d11_debug_symbols

            // GPU Instancing
            #pragma multi_compile_instancing

            #define _ALPHATEST_ON

            #pragma vertex LitPassVertexDepth
            #pragma fragment LitPassFragmentDepth

            #include "Actor-Hair-Input.hlsl"
            #include "Actor-Hair-Pass.hlsl"
            ENDHLSL
        }

        Pass 
        {
            Name "HairBase"
            Tags{"LightMode" = "HairBase"}

            Blend One Zero
            ZWrite On
            Cull[_Cull]
            ZTest Equal
            // Cull front


            HLSLPROGRAM

            #pragma target 3.0

            //Debug
            // #pragma enable_d3d11_debug_symbols

            // GPU Instancing
            #pragma multi_compile_instancing

            // -------------------------------------
            // Material Keywords
            #pragma shader_feature_local _NORMALMAP
            //#pragma shader_feature_local_fragment _ALPHATEST_ON
            #pragma shader_feature_local_fragment _ALPHAPREMULTIPLY_ON
            #pragma shader_feature_local_fragment _EMISSION
            #pragma shader_feature_local_fragment _METALLICSPECGLOSSMAP
            #pragma shader_feature_local_fragment _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
            #pragma shader_feature_local_fragment _OCCLUSIONMAP

            #pragma shader_feature_local_fragment _SPECULARHIGHLIGHTS_OFF
            #pragma shader_feature_local_fragment _ENVIRONMENTREFLECTIONS_OFF
            //#pragma shader_feature_local_fragment _SPECULAR_SETUP
            // #pragma shader_feature_local_fragment _RECEIVE_SHADOWS_OFF
            // -------------------------------------
            // Universal Pipeline keywords
            //#pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            // #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            // #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
            // #pragma multi_compile_fragment _ _SHADOWS_SOFT

            #define _ADDITIONAL_LIGHTS
            #define _RECEIVE_SHADOWS_OFF
            // #define _ALPHATEST_ON
            #define _SH_OFF

            #pragma vertex LitPassVertex
            #pragma fragment LitPassFragment

            #include "Actor-Hair-Input.hlsl"
            #include "Actor-Hair-Pass.hlsl"
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

            #include "Actor-Hair-Input.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Shaders/ShadowCasterPass.hlsl"
            ENDHLSL
        }
        
    }


    FallBack "SLG_Custom/CommonShader/MaterialError"
   // CustomEditor "Custom.ActorHairShader"
}
