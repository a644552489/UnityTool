Shader "SLG_Custom/ShowActor/MultiPassFurModified_ZW"
{
    Properties
    {
        //-------------------------------------------------
        //               Render Settings 
        //-------------------------------------------------
        [StyledCategory(Render Settings,true)]_Category_Colapsable_Render("[ Rendering Cat ]", Float) = 1

        [Enum(UnityEngine.Rendering.BlendMode)] _SrcBlend ("Src Blend Mode", Float) = 1
        [Enum(UnityEngine.Rendering.BlendMode)] _DstBlend ("Dst Blend Mode", Float) = 0
        [Enum(Off, 0, On, 1)]_ZWrite ("ZWrite", Float) = 0.0
        //[Toggle(_ALPHATEST_ON)]_ALPHATEST_ON ("_ALPHATEST_ON", Float) = 0

        //-------------------------------------------------
        //               Lighting Settings 
        //-------------------------------------------------
        [StyledCategory(Lighting Settings,true)]_Category_Colapsable_Lighting("[ Lighting Cat ]", Float) = 1

        [Toggle(_GI_ON)] _GI_ON ("GIOn(SH_ON)", Float) = 1
        [Toggle(_RECEIVE_SHADOWS)] _RECEIVE_SHADOWS ("Receive Shadow", Float) = 1
        [KeywordEnum(OFF,ONLY,ALL)] _ADDITIONAL_LIGHTS("ADDITIONAL LIGHTS", Float) = 1
        [KeywordEnum(VERTEX,FRAG)] _ADDITIONAL_LIGHTS_MODE("ADDITIONAL_LIGHTS MODE",float) = 0
   
        //-------------------------------------------------
        //               Surface Settings 
        //------------------------------------------------- 
        [StyledCategory(Surface Settings,true)]_Category_Colapsable_Surface("[ Surface Cat ]", Float) = 1
        [StyledTexST(_MainTex)] _Temp_ST_1("_Temp_ST_1",Float) = 0
        [StyledTextureSingleLine(_Color)][MainTexture] _MainTex ("Albedo", 2D) = "white" { }
        [HideInInspector][MainColor]_Color ("Color", Color) = (1, 1, 1, 1)

        [StyledKeywordTextureSingleLine(_NORMALMAP,_BumpScale)]_BumpMap("Normal Map", 2D) = "bump" {}
        [HideInInspector]_BumpScale("Scale", Range(0, 1)) = 1.0
        
        [StyledTextureTriProp(_MetaStrength,_SmoothnessStrength,_AOStrength)]_MSAMap("M_S_A",2D) = "white" {}//[NoScaleOffset]
        [HideInInspector]_MetaStrength("Meta Strength", Range(0.0, 2.0)) = 1.0
        [HideInInspector]_SmoothnessStrength("Smoothness Strength", Range(0.0, 2.0)) = 1.0
        [HideInInspector]_AOStrength("AO Strength", Range(0.0, 2.0)) = 1.0

        //[Toggle(_EMISSION_DYNAMIC)] _EMISSION_DYNAMIC("Emission Dynamic", Float) = 0
        [StyledTextureSingleLine(_EmissionColor)]_EmissionMap("Emission", 2D) = "black" {}
        [HideInInspector] _EmissionColor("Color", Color) = (0,0,0)
        
        [StyledKeywordTextureSingleLine(_EMISSION_DYNAMIC,_BreatheSpeed)]_WaveMap("WaveMap",2D) = "white" {}
        [HideInInspector]_WaveSpeed("Wave Speed", Range(0.0, 2.0)) = 1.0
        [HideInInspector]_BreatheSpeed("Breathe Speed", Range(0.0, 2.0)) = 1.0

        
        //-------------------------------------------------
        //               Fur Settings 
        //-------------------------------------------------
        [StyledCategory(Fur Settings,true)]_Category_Colapsable_Fur("[ Fur Cat ]", Float) = 1

        [KeywordEnum(UV0,UV1)] _UVSEC ("UVSet for Fur textures", Float) = 1
        [HideInInspector]_FurColor ("FurColor",Color) = (0.0,0.0,0.0,0.0)
        _LayerTex ("Layer", 2D) = "white" { }
        [StyledSlideExplain(Control the length of hair growth)]_FurLength ("Fur Length", Range(.0002, 10)) = .03
        [StyledSlideExplain(Control the terminal thickness of hair)]_CutoffEnd ("Alpha Cutoff end", Range(0, 1)) = 1.0 // how thick they are at the end
        _Gravity ("Gravity Direction", Vector) = (0, 0, -1, 0)
        [StyledSlideExplain(Controls how strongly fur is affected by gravity)]_GravityStrength ("Gravity Strength", Range(0, 1)) = 0.25
        [StyledKeywordTextureSingleLine(_FLOWMAP_USE,_UVOffset)]_FlowMap ("Flow Map", 2D) = "gray" { }
        [HideInInspector]_UVOffset ("UVOffset", Range(0, 1)) = 0

        [Space(20)]
        [Header(Shadow)]
        _ShadowColor ("Shadow Color", Color) = (0, 0, 0, 0)
        [StyledSlideExplain(Control fur AO shadow intensity)]_ShadowLerp ("AO Shadow Strength", Range(0, 1)) = 0.5

        [Space(20)]
        [StyledSlideExplain(Adjust the overall intensity of fur contour lights and highlight)]_AddLightScale("AddLightScale",Range(0.0,1.0)) = 1
        [Header(AddLight_ContourLight)]
        [StyledSlideExplain(Global offset value of Fresnel function)]_FresnelBias("FresnelBias",Range(0.0,10.0)) = 0.0
        [StyledSlideExplain(The Strength of Fresnel Function)]_FresnelScale("FresnelScale",Range(0.0,10.0)) = 1.0
        [StyledSlideExplain(Pow value of fresnel function)]_FrenelPower("FrenelPower",Range(1,32)) = 2
        _FabricScatterColor ("Fabric Scatter Color", Color) = (1, 1, 1, 1)
        [StyledSlideExplain(Adjust the final intensity of contour light)]_FabricScatterScale ("Fabric Scatter Scale", Range(0.0, 1.0)) = 1
        [Header(AddLight_Highlights)]
        [Toggle(_USE_BITANGENT)] _USE_BITANGENT("USE BITANGENT",Float) = 0
        _SpecColor1("_SpecColor1",color) = (0,0,0,1)
        _SpecColor2("_SpecColor1",color) = (0,0,0,1)
        _SpecInfo("x:T1Scale y:T1Shift z:T2Scale w:T2Shift" , vector) = (8,0,1,0)

                [Toggle(_ONLY_REALTIME_SHADOW)]_OnlyRealtimeShadow("Only Realtime Shadow None Lighting",Float) = 1

        //-------------------------------------------------
        //               Advanced Settings 
        //-------------------------------------------------
        [StyledCategory(Advanced Settings,true)]_Category_Colapsable_Advanced("[ Advanced Cat ]", Float) = 1
        
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque"  "PerformanceChecks" = "False" }
        //Tags { "RenderType" = "Transparent"  "PerformanceChecks" = "False"  "Queue" = "Transparent"}

        LOD 1100

		//FurDepth
        Pass
        {
            Name "FurDepth"
            Tags { "LightMode" = "FurDepth" }
        
            Blend One Zero
            ZWrite On
            Cull Back
            ZTest LEqual
            ColorMask 0
        
            HLSLPROGRAM
        
            #pragma target 3.0
        
            //Debug
            // #pragma enable_d3d11_debug_symbols
        
            // GPU Instancing
             #pragma multi_compile_instancing
            #pragma shader_feature _FLOWMAP_USE
            #define _ALPHATEST_ON
        
            #pragma vertex LitPassVertexDepth
            #pragma fragment LitPassFragmentDepth
            #pragma shader_feature _UVSEC_UV0 _UVSEC_UV1 
        
            #include "FurInputZW.hlsl"
            #include "FurPass.hlsl"
        
            ENDHLSL
        }

		//FurRendererBase
        Pass
        {
            Name "FurRender"
            Tags { "LightMode" = "FurRendererBase" }
            
            Blend[_SrcBlend][_DstBlend]
            ZWrite[_ZWrite]
            Cull Back
            ZTest Equal



            HLSLPROGRAM
            // make fog work
               #pragma multi_compile_instancing
            #pragma multi_compile_fog
            #pragma shader_feature _ _GI_ON
   
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma shader_feature _ADDITIONAL_LIGHTS_ALL _ADDITIONAL_LIGHTS_OFF _ADDITIONAL_LIGHTS_ONLY
            #pragma shader_feature _ADDITIONAL_LIGHTS_MODE_VERTEX _ADDITIONAL_LIGHTS_MODE_FRAG
            #pragma shader_feature _USE_BITANGENT
            #pragma shader_feature _NORMALMAP
            #pragma shader_feature _FLOWMAP_USE
            #pragma shader_feature _UVSEC_UV0 _UVSEC_UV1 
            #pragma shader_feature _ _RECEIVE_SHADOWS
            //#pragma shader_feature _ _ALPHATEST_ON _ALPHABLEND_ON _ALPHAPREMULTIPLY_ON
            #pragma shader_feature_local_fragment _EMISSION_DYNAMIC
            #pragma shader_feature _METALLICGLOSSMAP
            #pragma shader_feature ___ _DETAIL_MULX2
            #pragma shader_feature _ _SPECULARHIGHLIGHTS_OFF
            #pragma shader_feature _ _GLOSSYREFLECTIONS_OFF

       #pragma multi_compile _ SHADOWS_SHADOWMASK
             #pragma shader_feature_local _ONLY_REALTIME_SHADOW        
            #define LIGHTMAP_ON

            #define LIGHTMAP_SHADOW_MIXING
    
            
            #pragma vertex vert_LayerBase
            #pragma fragment frag_LayerBase

			#include "FurInputZW.hlsl"
            #include "FurPass.hlsl"

            ENDHLSL
        }

		//FurRendererLayer
        Pass
        {
            Name "FurRender"
            Tags { "LightMode" = "FurRendererLayer" }
            
            Blend[_SrcBlend][_DstBlend]
            ZWrite[_ZWrite]
            Cull Back
            ZTest Equal
            
            HLSLPROGRAM
            // make fog work

            #pragma multi_compile_instancing
            #pragma multi_compile_fog
            #pragma shader_feature _ _GI_ON

            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma shader_feature _ADDITIONAL_LIGHTS_ALL _ADDITIONAL_LIGHTS_OFF _ADDITIONAL_LIGHTS_ONLY
            #pragma shader_feature _ADDITIONAL_LIGHTS_MODE_VERTEX _ADDITIONAL_LIGHTS_MODE_FRAG
            #pragma shader_feature _USE_BITANGENT
            #pragma shader_feature _NORMALMAP
            #pragma shader_feature _FLOWMAP_USE
            #pragma shader_feature _UVSEC_UV0 _UVSEC_UV1 
            #pragma shader_feature _ _RECEIVE_SHADOWS
            #pragma shader_feature_local_fragment _EMISSION_DYNAMIC
            #pragma shader_feature _METALLICGLOSSMAP
            #pragma shader_feature ___ _DETAIL_MULX2
            #pragma shader_feature _ _SPECULARHIGHLIGHTS_OFF
            #pragma shader_feature _ _GLOSSYREFLECTIONS_OFF

             #pragma multi_compile _ SHADOWS_SHADOWMASK
             
           #pragma shader_feature_local _ONLY_REALTIME_SHADOW

            #define LIGHTMAP_ON

            #define LIGHTMAP_SHADOW_MIXING

            
            #pragma vertex vert_LayerBase
            #pragma fragment frag_Layer

			#include "FurInputZW.hlsl"
            #include "FurPass.hlsl"

            ENDHLSL
        }

	

    }

   
    FallBack "SLG_Custom/CommonShader/MaterialError"
    CustomEditor "YLib.StyledEditor.StyledMaterial.MaterialCoreGUI"
}
