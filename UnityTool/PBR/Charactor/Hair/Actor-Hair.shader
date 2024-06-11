Shader "TADemo/Combine/Hair"
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

        [StyledCategory(Surface Settings,true)]_Category_Colapsable_Surface("[ Surface Cat ]", Float) = 1
           [StyledTextureSingleLine] _BaseMap("Albedo", 2D) = "white" {}
        [MainColor] _BaseColor("Color", Color) = (1,1,1,1)
        [Space(30)]
            _Metallic("Metallic", Range(0.0, 1.0)) = 0.0
          _Smoothness("Smoothness", Range(0.0, 1.0)) = 0.5
        _Occlusion("_Occlusion", Range(0.0, 1.0)) = 1.0
        
  
        _SactterColor("Sactter Color", color) = (1, 1, 1, 1)
        _ScatterOffset("Scatter Offset", range(0, 1)) = 0
        _LightingMultiplyer("Lighting Multiplyer", range(0, 5)) = 1

         [StyledKeywordTextureSingleLine(_NORMALMAP)]_BumpMap("Normal Map", 2D) = "bump" {}
          _BumpScale("_BumpScale" , Range(0,2))=1
        _NormalAniso("NormalAniso", range(0, 1)) = 1
        [StyledTextureSingleLineST]_NoiseMap("Noise Map", 2D) = "white"{}
  
        [StyledCategory(HighLight Settings,true)]_Category_Colapsable_HighLight("[ High Light ]", Float) = 1
     
        [StyledTextureSingleLineST]_ShiftMap("ShiftMap", 2D) = "white"{}
        _SpecularTint("SpecularTint", color) = (1, 1, 1, 1)
        _SpecularMultiplyer("SpecularMultiplyer", range(0, 1)) = 1
        
        _Shift("Shift", range(-5, 5)) = 1
        _SecondarySpecularTint("SecondarySpecularTint", color) = (1, 1, 1, 1)
        _SecondarySpecularMultiplyer("SecondarySpecularMultiplyer", range(0, 1)) = 1
        _SecondarySmoothness("SecondarySmoothness", range(0, 1)) = 0.8
        _SecondaryShift("SecondaryShift", range(-5, 5)) = 1
        
        _TransColor("TransColor", color) = (1, 1, 1, 1)
        
        // [StyledCategory(Indirect Lighting,true)]_Category_Colapsable_Indirect("[ Indirect Lighting ]", Float) = 1
        // _IndirectDiffuseLighting("IndirectDiffuseLighting", color) = (0.5, 0.5, 0.5, 1)
        // [StyledKeywordTextureSingleLine(_MATCAP, _MatCapColor)]_MatCapMap("MatCapMap", 2D) = "white"{}
        // [HideInInspector] _MatCapColor("MatCapColor", color) = (1, 1, 1, 1)
        // _MatCapIntensity("MatCapIntensity", range(0, 10)) = 0
        // _ZOffset("ZOffset", range(0, 3)) = 0
        
        [Space]
        _ShadowStep("ShadowStep" , int )=1
        _ShadowOffset("ShadowOffset",Range(-1,1))=0
        _ShadowFalloff("ShadowFalloff", range(0, 0.99)) = 0
        _StepShadowStrenth("StepShadowStrenth", range(0, 32)) = 8
        
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
        
        
        [StyledCategory(Other, true)]_Category_Colapsable_Other("[ Other ]", Float) = 1
    }

    //  LOD 1500
    //  效果全开
    SubShader
    {
        LOD 1500
   
        Pass
        {
            Name "alphaTest"
            ColorMask 0
            Blend One Zero
            Cull Front
            ZWrite On
            ZTest LEqual
            //Blend SrcAlpha OneMinusSrcAlpha
            //Cull Front
            //ZWrite Off
            //ZTest LEqual
            Tags
            {
                "LightMode" = "HairAlphaTest"
                "Queue" = "Geometry"
            }

            HLSLPROGRAM
            #define _ALPHATEST_ON
            #pragma multi_compile_instancing
             #include "../Actor-Input.hlsl"
            #include "../Actor-Pass.hlsl"
            #pragma vertex LitPassVertex
            #pragma fragment LitFragment
            ENDHLSL
        }

        Pass
        {
            Name "Color"
            Blend [_SrcBlend][_DstBlend]
            Cull [_Cull]
            ZWrite [_ZWrite]
            ZTest [_ZTest]

            Tags
            {
                "LightMode" = "UniversalForward"
                "Queue" = "Transparent"
            }

            HLSLPROGRAM
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            // #pragma exclude_renderers gles gles3 glcore
            // #pragma target 4.5

            #pragma shader_feature _NORMALMAP

            #pragma multi_compile_fragment _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile_fragment _ _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile_fragment _ _SHADOWS_SOFT

            #pragma multi_compile_fragment _ _ADDITIONAL_LIGHTS
            #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
        

            #pragma multi_compile_fragment _ DIRLIGHTMAP_COMBINED
            #pragma multi_compile_fragment _ LIGHTMAP_SHADOW_MIXING
            #pragma multi_compile_fragment _ SHADOWS_SHADOWMASK
             #pragma multi_compile _ _RAMP_FOG
            #pragma multi_compile _ _PEROBJECT_SHADOW_ON
            #pragma multi_compile_instancing
            #pragma  shader_feature_local _RIM_ON
            #define _HAIR 
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
            ColorMask 0
            Cull[_Cull]

            HLSLPROGRAM
            #pragma target 3.0
            
            //--------------------------------------W
            // GPU Instancing
            #pragma multi_compile_instancing
            #pragma enable_d3d11_debug_symbols
            
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

    //  LOD 1100
    //  关闭 Noise 采样
    //  关闭 附加灯
    //  关闭第二层高光
//    SubShader
//    {
//        LOD 1100
//        HLSLINCLUDE
//        #include "../Hair/Standard-CharacterHair-Input.hlsl"
//        ENDHLSL
//
//        //Pass
//        //{
//        //    Name "alphaTest"
//        //    ColorMask 0
//        //    Blend One Zero
//        //    Cull off
//        //    ZWrite on
//        //    ZTest Less
//        //    Tags
//        //    {
//        //        "LightMode" = "HairAlphaTest"
//        //        "Queue" = "Geometry"
//        //    }
//
//        //    HLSLPROGRAM
//        //    #define _ALPHATEST_ON
//        //    #pragma multi_compile_instancing
//        //    #include "../Hair/Standard-CharacterHair-AlphaClipPass.hlsl"
//        //    #pragma vertex LitVertex
//        //    #pragma fragment LitFragment
//        //    ENDHLSL
//        //}
//
//        Pass
//        {
//            Name "Color"
//            Blend [_SrcBlend][_DstBlend]
//            Cull [_Cull]
//            ZWrite [_ZWrite]
//            ZTest [_ZTest]
//
//            Tags
//            {
//                "LightMode" = "UniversalForward"
//            }
//
//            HLSLPROGRAM
//            #pragma prefer_hlslcc gles
//            #pragma exclude_renderers d3d11_9x
//            // #pragma exclude_renderers gles gles3 glcore
//            // #pragma target 4.5
//
//            #pragma shader_feature _NORMALMAP
//
//            #define _DISABLED_NOISE_COLOR
//            #define _DISABLED_SECONDARY_SPECULAR
//            #define _DISABLED_ADDITIONAL_LIGHTING
//
//            #pragma multi_compile_fragment _ _MAIN_LIGHT_SHADOWS
//            #pragma multi_compile_fragment _ _MAIN_LIGHT_SHADOWS_CASCADE
//            #pragma multi_compile_fragment _ _SHADOWS_SOFT
//
//            #pragma multi_compile_fragment _ _ADDITIONAL_LIGHTS
//            #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
//
//            #pragma multi_compile_fragment _ DIRLIGHTMAP_COMBINED
//            #pragma multi_compile_fragment _ LIGHTMAP_SHADOW_MIXING
//            #pragma multi_compile_fragment _ SHADOWS_SHADOWMASK
//
//            #pragma multi_compile_instancing
//            #include "../Hair/Standard-CharacterHair-Pass.hlsl"
//            #pragma vertex LitVertex
//            #pragma fragment LitFragment
//            ENDHLSL
//        }
//
//        Pass
//        {
//            Tags{"LightMode" = "ShadowCaster"}
//
//            ZWrite On
//            ZTest LEqual
//            Cull[_Cull]
//
//            HLSLPROGRAM
//            #pragma exclude_renderers gles gles3 glcore
//            #pragma target 4.5
//            #pragma shader_feature _ALPHATEST_ON
//            #pragma multi_compile_instancing
//            #pragma vertex ShadowPassVertex
//            #pragma fragment ShadowPassFragment
//            #include "../Hair/ShadowCasterPass.hlsl"
//            ENDHLSL
//        }
//
//        Pass
//        {
//            Tags{"LightMode" = "DepthOnly"}
//
//            ZWrite On
//            ColorMask 0
//            Cull[_Cull]
//
//            HLSLPROGRAM
//            #pragma shader_feature _ALPHATEST_ON
//
//            #pragma multi_compile_instancing
//            #pragma vertex DepthOnlyVertex
//            #pragma fragment DepthOnlyFragment
//            #include "../Hair/DepthOnlyPass.hlsl"
//            ENDHLSL
//        }
//    }
    CustomEditor "YLib.StyledEditor.StyledMaterial.MaterialCoreGUI"
}
