Shader "TADemo/Combine/Skin"
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
        
        [StyledTextureSingleLine] _BaseMap("Albedo", 2D) = "white" {}
        [MainColor] _BaseColor("Color", Color) = (1,1,1,1)
        
        [StyledKeywordTextureSingleLine(_NORMALMAP)]_BumpMap("Normal Map", 2D) = "bump" {}
        _BumpScale("_BumpScale" , Range(0,2))=1
        [Space(20)]
        
        [StyledKeywordTextureSingleLine(_MSA)] _MSAMap("Metallic_Smooth_AO",2D)="white"{}
        _Metallic("Metallic", Range(0.0, 1.0)) = 0.0
        _Smoothness("Smoothness", Range(0.0, 1.0)) = 0.5
        _Occlusion("_Occlusion", Range(0.0, 1.0)) = 1.0
        _BaseColorDensity("_BaseColorDensity", Range(0.0, 10.0)) = 1.0
        _ShadowColorDensity("_ShadowColorDensity", Range(0.0, 10)) = 0.2
        _IndirectBright("_IndirectBright" ,Range(1, 5)) = 1
        _EnvReflectionScale("EnvReflectionScale" ,Range(0, 10)) = 1
        
        _ShadowOffset("ShadowOffset",Range(-1,1))=0
        _ShadowFalloff("ShadowFalloff", range(0, 0.99)) = 0
        [StyledTextureSingleLine] _CustomShadowMap("CustomShadowMap", 2D) = "white" {}
        
        [Space(30)]
        [StyledKeywordTextureSingleLine(_DETAILNORMAL)] _DetailNormal("_DetailNormal", 2D)="bump"{}
        _NormalIntensity("_NormalIntensity",Range(0,2)) =1
        [StyledTexST(_DetailNormal)] _DetailNormal_ST("DetailNormalTiling" ,vector)= (1,1,0,0)
        [Space(30)]
      	[StyledKeywordTextureSingleLine(_SSSRamp)]	_3SRampMap("3SRampMap", 2D) = "white" {}
        
        _FrenelColor("_FrenelColor" , color )= (1,1,1,1)

        [Space]
        [Header(OUTLINE)]
        [Space]
        [Toggle]_ScreenOutlineOn("屏幕描边测试", Float) = 1
        _OutlineColor("_OutlineColor" ,color) = (1,1,1,1)
        _OutlineBaseThicknessMul("描边厚度",Range(0,1)) = 0.2
        
        [Space(30)]
        [Toggle] _RIM("边缘光",Float)= 0
        _FresnelAddPow("菲涅尔强度",Range(0,5)) = 1
        _FresnelAddColor("菲涅尔颜色" ,Color) = (1,1,1,1)
        _FresnelAddSmooth("菲涅尔平滑",Range(0,1)) = 0
        _FresnelMixL("颜色衰减",Range(0,1)) = 0.5
        _FresnelMulPointLight("菲尼尔点光强度",Range(0,1)) =1
        _FresnelFalloffValue("菲涅尔衰减",Range(0,1)) = 1
        
        [Toggle(_POINTLIGHT_ON)] _POINTLIGHT_ON("是否接收点光", Float) = 1
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
            #pragma enable_d3d11_debug_symbols

            // -------------------------------------
            // Material Keywords
            //#pragma shader_feature_local _NORMALMAP
            #pragma shader_feature _DETAILNORMAL
            #pragma shader_feature_local _RIM_ON
            #pragma shader_feature_local _POINTLIGHT_ON
            #pragma shader_feature _MSA
            #pragma shader_feature_local _NORMALMAP
            #pragma shader_feature_local_fragment _ALPHATEST_ON
            #pragma shader_feature_local_fragment _ALPHAPREMULTIPLY_ON
      
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
             #pragma multi_compile _ _RAMP_FOG
            #pragma multi_compile _ _PEROBJECT_SHADOW_ON
            #pragma multi_compile_fog
    
   
            #pragma multi_compile_fragment _ _ADDITIONAL_LIGHTS
            #define _SKIN
            // #define _RECEIVE_SHADOWS_OFF
            #define _NORMALMAP
         
            
            #pragma vertex LitPassVertex
            #pragma fragment LitPassFragment

        
            #include "../Actor-Input.hlsl"
            #include "../Actor-Pass.hlsl"
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

            #include "../Actor-Input.hlsl"
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
   CustomEditor "YLib.StyledEditor.StyledMaterial.MaterialCoreGUI"
}
