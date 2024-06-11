Shader "TADemo/Combine/Fabric"
{
    Properties
    {
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
        [StyledIndentLevelSub]

        [StyledCategory(Surface Type, true)]_Category_Colapsable_SurfaceType("[ Surface Type ]", Float) = 1
        [KeywordEnum(WOOL_MATERIAL, SILK_MATERIAL)] _FABRIC("Fabric Type", int) = 0
        [StyledTextureSingleLine]_PreIntegratedFGD("PreIntegratedFGD", 2D) = "black"{}
        [StyledIfShow(_FABRIC, 1)][StyledField] _Anisotropic("Anisotropic", range(-1.0, 1.0)) = 0

        [StyledCategory(Surface Settings,true)]_Category_Colapsable_Surface("[ Surface Cat ]", Float) = 1
        [HideInInspector]_MainTex("_MainTex",2D) ="white"{}
        [StyledTextureSingleLine(_BaseColor)][MainTexture] _BaseMap("BaseMap", 2D) = "white"{}
        [HideInInspector][MainColor] _BaseColor("BaseColor", color) = (1.0, 1.0, 1.0, 1.0)

        [StyledTexST(_BaseMap)] _BaseMap_ST("Tiling And Offset", vector) = (1, 1, 0, 0)
        
        [StyledKeywordTextureSingleLine(_NORMALMAP)]_BumpMap("Normal Map", 2D) = "bump" {}
        _BumpScale("_BumpScale" , Range(0,2))=1
        
        [StyledKeywordTextureSingleLine(_MSA)] _MSAMap("Metallic_Smooth_AO",2D)="white"{}
        
        // [StyledKeywordTextureSingleLine(_NORMAL_SMOOTH_AO)] _ThreadMap("Thread Map(R:AO, G:normalY, B:Smooth, A:normalX)", 2D) = "white"{}
        //[StyledKeywordTextureSingleLine(_SPECCUBE)] _SpecCUBE("SpecCUBE" ,Cube) = "cube"{}

        _Metallic("_Metallic" ,Range(0,1)) = 0
        _Occlusion("Occlusion", range(0, 1)) = 0
        _Smoothness("Smoothness", range(0, 0.99)) = 0
        _BaseColorDensity("_BaseColorDensity", Range(0.0, 10.0)) = 1.0
        _ShadowColorDensity("_ShadowColorDensity", Range(0.0, 10)) = 0.2
        _IndirectBright("_IndirectBright" ,Range(1, 5)) = 1
        _EnvReflectionScale("EnvReflectionScale" ,Range(0, 10)) = 1
        
        [Space(30)]
        _ShadowStep("ShadowStep" , int )=1
        _ShadowOffset("ShadowOffset",Range(-1,1))=0
        _ShadowFalloff("ShadowFalloff", range(0, 0.99)) = 0
        _StepShadowStrenth("StepShadowStrenth", range(0, 32)) = 8

        [Space(30)]
        [StyledKeywordTextureSingleLine(_DETAIL)] _DetailNormal("_DetailNormal", 2D)="bump"{}
        _NormalIntensity("_NormalIntensity",Range(0,2)) =1
        [StyledTexST(_DetailNormal)] _DetailNormal_ST("DetailNormalTiling" ,vector)= (1,1,0,0)
        
        [StyledCategory(Fuzz Settings, true)]_Category_Colapsable_Fuzz("[ Fuzz Cat ]", Float) = 1
        [StyledKeywordTextureSingleLineST(_FUZZMAP)]_FuzzMap("Fuzz Map", 2D) = "black"{}
        _FuzzColor("Fuzz Color", color) = (1, 1, 1, 1)
        _FuzzStrength("Fuzz Strength", range(0, 10)) = 0
        
        [Space]
        [Header(OUTLINE)]
        [Space]
        [Toggle]_ScreenOutlineOn("屏幕描边测试", Float) = 1
        _OutlineColor("描边颜色", Color) = (0, 0, 0, 1)
        _OutlineBaseThicknessMul("描边厚度",Range(0,1))=0.2
        
        [Space(30)]
        [Toggle] _RIM("边缘光",Float)= 0
        _FresnelAddPow("菲涅尔强度",Range(0,5)) = 1
        _FresnelAddColor("菲涅尔颜色" ,Color) = (1,1,1,1)
        _FresnelAddSmooth("菲涅尔平滑",Range(0,1)) = 0
        _FresnelMixL("颜色衰减",Range(0,1)) = 0.5
        _FresnelMulPointLight("菲尼尔点光强度",Range(0,1)) =1
        _FresnelFalloffValue("菲涅尔衰减",Range(0,1)) = 1
    }

    SubShader
    {
        Tags 
        {
            "RenderPipeline" = "UniversalRenderPipeline"
        }
        
        Pass
        {
            Blend [_SrcBlend][_DstBlend]
            Cull [_Cull]
            ZWrite [_ZWrite]
            ZTest [_ZTest]

            HLSLPROGRAM
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            // #pragma exclude_renderers gles gles3 glcore
            // #pragma target 4.5

            #pragma  shader_feature_local _RIM_ON

            #define _FABRIC
            //#define _SPECULAR_SETUP
            #pragma shader_feature _ALPHATEST_ON
            //#pragma shader_feature _NORMAL_SMOOTH_AO
            #pragma shader_feature _SPECULARMAP

            #pragma shader_feature _MSA
            #pragma shader_feature _NORMALMAP
            #pragma shader_feature _DETAIL

            #pragma shader_feature _ANISOTROPIC
            #pragma shader_feature _FUZZMAP

            #pragma shader_feature _FABRIC_SILK_MATERIAL
            #pragma multi_compile _ LIGHTMAP_ON
            #pragma multi_compile _ _RAMP_FOG
            #pragma multi_compile_fog
            //#pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
            //  主光源阴影 以及避免 Cascade Count 产生 Bug 的 _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile_fragment _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile_fragment _ _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile_fragment _ _SHADOWS_SOFT

            //片源多光源，无需逐顶点的附加光源, 无需附加灯阴影
            #pragma multi_compile_fragment _ _ADDITIONAL_LIGHTS
            //#pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX
            //#pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS

            #pragma multi_compile_fragment _ DIRLIGHTMAP_COMBINED
            #pragma multi_compile_fragment _ LIGHTMAP_SHADOW_MIXING
            #pragma multi_compile_fragment _ SHADOWS_SHADOWMASK
            #pragma multi_compile _ _UC_STANDALONE
            #pragma multi_compile _ _PEROBJECT_SHADOW_ON
            #pragma multi_compile_instancing

            #include "../Actor-Input.hlsl"
            #include "../Actor-Pass.hlsl"
            #pragma vertex LitPassVertex
            #pragma fragment LitPassFragment
            ENDHLSL
        }
        Pass
        {
            Name "ShadowCaster"
            Tags{"LightMode" = "ShadowCaster"}

            ZWrite On
            ZTest LEqual
            Cull[_Cull]

            HLSLPROGRAM
            #pragma shader_feature _ALPHATEST_ON

            #pragma multi_compile_instancing
            
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
        // Pass
        // {
        //     Tags{"LightMode" = "DepthOnly"}

        //     ZWrite On
        //     ColorMask 0
        //     Cull[_Cull]

        //     HLSLPROGRAM
        //     #pragma shader_feature _ALPHATEST_ON

        //     #pragma multi_compile_instancing
        //     #pragma vertex DepthOnlyVertex
        //     #pragma fragment DepthOnlyFragment
        //     #include "../../../Shader/UniversalPass/DepthOnlyPass.hlsl"
        //     ENDHLSL
        // }

        // Pass
        // {
        //     Tags{"LightMode" = "Meta"}
        //     Cull Off

        //     HLSLPROGRAM
        //     #pragma shader_feature _ALBEDOMAP
        //     #pragma shader_feature _ALPHATEST_ON
        //     #pragma shader_feature _MAODSMAP
        //     #pragma shader_feature _EMISSION

        //     #pragma vertex UniversalVertexMeta
        //     #pragma fragment UniversalFragmentMeta
        //     #include "../../../Shader/UniversalPass/LitMetaPass.hlsl"
        //     ENDHLSL
        // }ENDHLSL
    }
    CustomEditor "YLib.StyledEditor.StyledMaterial.MaterialCoreGUI"
}
