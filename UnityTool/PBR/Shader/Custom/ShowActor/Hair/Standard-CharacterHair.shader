Shader "TADemo/Standard/Character/Hair"
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

        [StyledCategory(Surface Settings,true)]_Category_Colapsable_Surface("[ Surface Cat ]", Float) = 1
        [StyledTextureSingleLine(_BaseColor)][MainTexture] _MainTex("BaseMap", 2D) = "white"{}
        [HideInInspector][MainColor] _BaseColor("BaseColor", color) = (1.0, 1.0, 1.0, 1.0)
        _TransparentWeight("TransparentWeight", range(0, 1)) = 0.5
        _FresnelColor("Fresnel Color", color) = (1, 1, 1, 1)
        _ShadowColor("Shadow Color", color) = (0, 0, 0, 0)
        _SactterColor("Sactter Color", color) = (1, 1, 1, 1)
        _ScatterOffset("Scatter Offset", range(0, 1)) = 0
        _LightingMultiplyer("Lighting Multiplyer", range(0, 5)) = 1

        [StyledKeywordTextureSingleLine(_NORMALMAP, _NormalIntensity)] _NormalMap("NormalMap", 2D) = "bump"{}
        [HideInInspector] _NormalIntensity("NormalIntensity", float) = 1
        _NormalAniso("NormalAniso", range(0, 1)) = 1
        [StyledTextureSingleLineST]_NoiseMap("Noise Map", 2D) = "white"{}
        [StyledTexST(, _MainTex)] _MainTex_ST("Tiling And Offset", vector) = (1, 1, 0, 0)

        [StyledCategory(HighLight Settings,true)]_Category_Colapsable_HighLight("[ High Light ]", Float) = 1
        _Metallic("Metallic", range(0, 1)) = 0
        [StyledTextureSingleLineST]_ShiftMap("ShiftMap", 2D) = "white"{}
        _SpecularTint("SpecularTint", color) = (1, 1, 1, 1)
        _SpecularMultiplyer("SpecularMultiplyer", range(0, 1)) = 1
        _Smoothness("Smoothness", range(0, 1)) = 0.8
        _Shift("Shift", range(-5, 5)) = 1
        _SecondarySpecularTint("SecondarySpecularTint", color) = (1, 1, 1, 1)
        _SecondarySpecularMultiplyer("SecondarySpecularMultiplyer", range(0, 1)) = 1
        _SecondarySmoothness("SecondarySmoothness", range(0, 1)) = 0.8
        _SecondaryShift("SecondaryShift", range(-5, 5)) = 1
        
        // [StyledCategory(Indirect Lighting,true)]_Category_Colapsable_Indirect("[ Indirect Lighting ]", Float) = 1
        // _IndirectDiffuseLighting("IndirectDiffuseLighting", color) = (0.5, 0.5, 0.5, 1)
        // [StyledKeywordTextureSingleLine(_MATCAP, _MatCapColor)]_MatCapMap("MatCapMap", 2D) = "white"{}
        // [HideInInspector] _MatCapColor("MatCapColor", color) = (1, 1, 1, 1)
        // _MatCapIntensity("MatCapIntensity", range(0, 10)) = 0
        // _ZOffset("ZOffset", range(0, 3)) = 0
        [StyledCategory(Other, true)]_Category_Colapsable_Other("[ Other ]", Float) = 1
    }

    //  LOD 1500
    //  效果全开
    SubShader
    {
        LOD 1500
        HLSLINCLUDE
  
        #include "../Hair/Standard-CharacterHair-Input.hlsl"
        ENDHLSL

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
            #include "../Hair/Standard-CharacterHair-AlphaClipPass.hlsl"
            #pragma vertex LitVertex
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

            #pragma multi_compile_instancing
            #include "../Hair/Standard-CharacterHair-Pass.hlsl"
            #pragma vertex LitVertex
            #pragma fragment LitFragment
            ENDHLSL
        }

        Pass
        {
            Tags{"LightMode" = "ShadowCaster"}

            ZWrite On
            ZTest LEqual
            Cull[_Cull]

            HLSLPROGRAM
            #pragma exclude_renderers gles gles3 glcore
            #pragma target 4.5
            #pragma shader_feature _ALPHATEST_ON
            #pragma multi_compile_instancing
            #pragma vertex ShadowPassVertex
            #pragma fragment ShadowPassFragment
            #include "../Hair/ShadowCasterPass.hlsl"
            ENDHLSL
        }

        Pass
        {
            Tags{"LightMode" = "DepthOnly"}

            ZWrite On
            ColorMask 0
            Cull[_Cull]

            HLSLPROGRAM
            #pragma shader_feature _ALPHATEST_ON

            #pragma multi_compile_instancing
            #pragma vertex DepthOnlyVertex
            #pragma fragment DepthOnlyFragment
            #include "../Hair/DepthOnlyPass.hlsl"
            ENDHLSL
        }
    }

    //  LOD 1100
    //  关闭 Noise 采样
    //  关闭 附加灯
    //  关闭第二层高光
    SubShader
    {
        LOD 1100
        HLSLINCLUDE
        #include "../Hair/Standard-CharacterHair-Input.hlsl"
        ENDHLSL

        //Pass
        //{
        //    Name "alphaTest"
        //    ColorMask 0
        //    Blend One Zero
        //    Cull off
        //    ZWrite on
        //    ZTest Less
        //    Tags
        //    {
        //        "LightMode" = "HairAlphaTest"
        //        "Queue" = "Geometry"
        //    }

        //    HLSLPROGRAM
        //    #define _ALPHATEST_ON
        //    #pragma multi_compile_instancing
        //    #include "../Hair/Standard-CharacterHair-AlphaClipPass.hlsl"
        //    #pragma vertex LitVertex
        //    #pragma fragment LitFragment
        //    ENDHLSL
        //}

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
            }

            HLSLPROGRAM
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            // #pragma exclude_renderers gles gles3 glcore
            // #pragma target 4.5

            #pragma shader_feature _NORMALMAP

            #define _DISABLED_NOISE_COLOR
            #define _DISABLED_SECONDARY_SPECULAR
            #define _DISABLED_ADDITIONAL_LIGHTING

            #pragma multi_compile_fragment _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile_fragment _ _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile_fragment _ _SHADOWS_SOFT

            #pragma multi_compile_fragment _ _ADDITIONAL_LIGHTS
            #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS

            #pragma multi_compile_fragment _ DIRLIGHTMAP_COMBINED
            #pragma multi_compile_fragment _ LIGHTMAP_SHADOW_MIXING
            #pragma multi_compile_fragment _ SHADOWS_SHADOWMASK

            #pragma multi_compile_instancing
            #include "../Hair/Standard-CharacterHair-Pass.hlsl"
            #pragma vertex LitVertex
            #pragma fragment LitFragment
            ENDHLSL
        }

        Pass
        {
            Tags{"LightMode" = "ShadowCaster"}

            ZWrite On
            ZTest LEqual
            Cull[_Cull]

            HLSLPROGRAM
            #pragma exclude_renderers gles gles3 glcore
            #pragma target 4.5
            #pragma shader_feature _ALPHATEST_ON
            #pragma multi_compile_instancing
            #pragma vertex ShadowPassVertex
            #pragma fragment ShadowPassFragment
            #include "../Hair/ShadowCasterPass.hlsl"
            ENDHLSL
        }

        Pass
        {
            Tags{"LightMode" = "DepthOnly"}

            ZWrite On
            ColorMask 0
            Cull[_Cull]

            HLSLPROGRAM
            #pragma shader_feature _ALPHATEST_ON

            #pragma multi_compile_instancing
            #pragma vertex DepthOnlyVertex
            #pragma fragment DepthOnlyFragment
            #include "../Hair/DepthOnlyPass.hlsl"
            ENDHLSL
        }
    }
    CustomEditor "YLib.StyledEditor.StyledMaterial.MaterialCoreGUI"
}
