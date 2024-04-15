Shader "TADemo/Fabric/CommonFabric"
{
    Properties
    {
        [StyledCategory(Render Settings,true)]_Category_Colapsable_Render("[ Rendering Cat ]", Float) = 1
        [Enum(UnityEngine.Rendering.BlendMode)]_SrcBlend("SrcBlend", Float) = 1.0
        [Enum(UnityEngine.Rendering.BlendMode)]_DstBlend("DstBlend", Float) = 0.0
        [Enum(Off, 0, On, 1)]_ZWrite("ZWrite", Float) = 1.0
        [Enum(UnityEngine.Rendering.CompareFunction)]_ZTest ("ZTest", Float) = 4
        [Enum(UnityEngine.Rendering.CullMode)]_Cull("Cull", Float) = 2.0
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

       [StyledKeywordTextureSingleLine(_NORMALMAP,_BumpScale)]_BumpMap("Normal Map", 2D) = "bump" {}
        [HideInInspector]_BumpScale("Scale", Float) = 1.0


        [StyledKeywordTextureSingleLine(_SPECULARMAP)] _SpecularMap("Specular Map", 2D) = "white"{}
                _SpecularColor("Specular", color) = (0.5, 0.5, 0.5, 1)

        [StyledKeywordTextureSingleLine(_MSA)] _MSAMap("Metallic_Smooth_AO",2D)="white"{}

       // [StyledKeywordTextureSingleLine(_NORMAL_SMOOTH_AO)] _ThreadMap("Thread Map(R:AO, G:normalY, B:Smooth, A:normalX)", 2D) = "white"{}

    //   [StyledKeywordTextureSingleLine(_SPECCUBE)] _SpecCUBE("SpecCUBE" ,Cube) = "cube"{}

        _Metallic("_Metallic" ,Range(0,1)) = 0
        _Occlusion("Occlusion", range(0, 1)) = 0
        _Smoothness("Smoothness", range(0, 0.99)) = 0

        [Space(30)]
        [StyledKeywordTextureSingleLine(_DETAILNORMAL ,_NormalIntensity)] _DetailNormal("_DetailNormal", 2D)="bump"{}
        [StyledTexST(_DetailNormal)] _DetailNormal_ST("DetailNormalTiling" ,vector)= (1,1,0,0)

        [HideInInspector] _NormalIntensity("NormalIntensity", float) = 1
        


        [StyledCategory(Fuzz Settings, true)]_Category_Colapsable_Fuzz("[ Fuzz Cat ]", Float) = 1
        [StyledKeywordTextureSingleLineST(_FUZZMAP)]_FuzzMap("Fuzz Map", 2D) = "black"{}
        _FuzzColor("Fuzz Color", color) = (1, 1, 1, 1)
        _FuzzStrength("Fuzz Strength", range(0, 10)) = 0
        
        
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
        Tags 
        {
            "RenderPipeline" = "UniversalRenderPipeline"
        }

        HLSLINCLUDE
        #include "./Fabric-Input.hlsl"
        ENDHLSL

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

           #define _SPECULAR_SETUP
            #pragma shader_feature _ALPHATEST_ON
       //     #pragma shader_feature _NORMAL_SMOOTH_AO
            #pragma shader_feature _SPECULARMAP

            #pragma shader_feature _MSA
            #pragma shader_feature _NORMALMAP
            #pragma shader_feature _DETAILNORMAL

            #pragma shader_feature _ANISOTROPIC
            #pragma shader_feature _FUZZMAP

            #pragma shader_feature _FABRIC_SILK_MATERIAL
            #pragma multi_compile _ LIGHTMAP_ON

            #pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION

            //  主光源阴影 以及避免 Cascade Count 产生 Bug 的 _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile_fragment _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile_fragment _ _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile_fragment _ _SHADOWS_SOFT

            //  片源多光源，无需逐顶点的附加光源, 无需附加灯阴影
            #pragma multi_compile_fragment _ _ADDITIONAL_LIGHTS
            //  #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX
            //  #pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS

            #pragma multi_compile_fragment _ DIRLIGHTMAP_COMBINED
            #pragma multi_compile_fragment _ LIGHTMAP_SHADOW_MIXING
            #pragma multi_compile_fragment _ SHADOWS_SHADOWMASK

            #pragma multi_compile_instancing
            #include "./Fabric-Pass.hlsl"
            #pragma vertex LitVertex
            #pragma fragment LitFragment
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

        Pass
        {
            Tags{"LightMode" = "ShadowCaster"}

            ZWrite On
            ZTest LEqual
            Cull[_Cull]

            HLSLPROGRAM
            #pragma shader_feature _ALPHATEST_ON

            #pragma multi_compile_instancing
            #pragma vertex ShadowPassVertex
            #pragma fragment ShadowPassFragment
            //#include "Packages/com.unity.render-pipelines.universal/Shaders/LitInput.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Shaders/ShadowCasterPass.hlsl"
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
