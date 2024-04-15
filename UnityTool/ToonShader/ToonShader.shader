
Shader "UC/Actor/Protagonist/ToonShader"
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
         [MainColor] _BaseColor("主颜色", Color) = (1, 1, 1, 1)

    _BRDFDespity("_BRDFDespity" ,Range(0,10)) =1
     
        _BaseMap ("漫反射贴图", 2D) = "white" {}
        _BumpMap("法线贴图" , 2D) = "bump"{}
        _BumpItensity("法线强度",Range(0,1)) =1
        
               _Metalic("_Metalic" , Range(0,1)) = 0
        _Smooth("_Smooth" , Range(0.001,1)) = 0
        _Occlusion("Occlusion" , Range(0,1)) =1
        
        
          [Header(Shadow Setting)]
        [Space(5)]
      
        _ToonSteps("_ToneSteps" ,int ) =3
         _ShapeShadowSmooth("固定阴影平滑" , Range(0,1)) =0
          _ShapeShadowPow("固定阴影强度" , Range(0,1))=0
        
        _SkinDetailShadowMin("_SecondPow" , Range(0,1)) = 0
        _SkinDetailShadowMax("_SecondSmooth",Range(0,1)) =1
        _SelfShadowDensity("_SelfShadowDensity" , Range(0,1))=0

         _RampThreshold("灯光Y方向" , Range(0,1  )) =  0
        
        
         _GIIndirDiffuse("GI强度" , Range(0,1))= 1

           [Header(Specular Setting)]
        [Space(5)]
        [Toggle]_LIGHTPOS("_LIGHTPOS" ,Float) = 0
        [Toggle]_EnableSpecular ("Enable Specular", Float) = 0

            _MetalMap("MetalMap" , 2D)  ="white"{}
    //    _SpecularShift("shift",2D) = "white"{}
       _SpecColor ("Specular Color", color) = (0.8, 0.8, 0.8, 1)

        _SpecMulti ("Multiple Factor", range(0.001, 1.0)) = 1
        _SpecSub("MetalSub",Range(0,10)) = 0

        [Toggle]_ReciveShadow("_RecvieShadow" , Float)  = 1
        
        
        	[Space]
                [Header(OUTLINE)]
                [Space]
           
                [Toggle]_ScreenOutlineOn("屏幕描边测试", Float) = 1
                _OutlineColor("描边颜色", Color) = (0, 0, 0, 1)
           
     
                _OutLineScale ("屏幕描边缩放", Range(0.0,0.03)) = 0.001 //0.0015s
                _ScreenOutlineDeW("屏幕描边假透视",Range(0.0,1)) = 0.6
      
         
    }
    SubShader
    {
        Stencil
        {
            Ref 5
            Comp [_StencilComp]
            Pass Replace
        }
	    Tags {"RenderType" = "Opaque" }
		Pass
        {
           
            Name "MoreCel"
			Tags{
				"RenderPipeline" = "UniversalPipeline"
				"LightMode" = "UniversalForward"
			}

            Cull Back

            HLSLPROGRAM
			#pragma exclude_renderers gles glcore
            #pragma target 4.5
            
            #pragma vertex vert
            #pragma fragment frag

            // -------------------------------------
  
         #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile _ _SHADOWS_SOFT//柔化阴影，得到软阴影
   #pragma shader_feature_local ENABLE_FACE_SHADOW_MAP
               #pragma shader_feature_local _LIGHTPOS_ON
            #include "../Toon_Input.hlsl"
            #include "../Toon_Pass.hlsl"
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
            #pragma vertex MoreCelVertex
            #pragma fragment MoreCelFragment


           // #pragma shader_feature __ _CUSTOMOUTLINENORMAL_ON
            //#pragma shader_feature __ _NORMALIZENORMAL_ON
            //#pragma multi_compile_local _ _SCREEN_DOOR
            #pragma multi_compile_vertex __ _STRENCH_ON
            #pragma multi_compile _ _RAMP_FOG
            #pragma multi_compile_local _ _CLIPMASK_ON
            #pragma multi_compile_local _ _PROJECTOR_ON
            #define _ACTOR_RENDER
            #define _PASS_OUTLINE 1


            #include "./CharacterCommon_Inputs.hlsl"
            #include "./CharacterCommon_ForwardPass.hlsl"
            ENDHLSL
        }
    	
    	
	           Pass
        {
            Name "DepthOnly"
            Tags{"LightMode" = "DepthOnly"}

            ZWrite On
            ColorMask 0
            Cull Off

            HLSLPROGRAM
            #pragma exclude_renderers gles glcore
            #pragma target 4.5

            #pragma vertex MoreCelVertex
            #pragma fragment MoreCelFragment

            #pragma multi_compile_vertex __ _STRENCH_ON
            #pragma multi_compile _ _RAMP_FOG
            #pragma multi_compile_local _ _CLIPMASK_ON
            #define _ACTOR_RENDER
            #define _PASS_DEPTH 1

            #include "../CharacterCommon_Inputs.hlsl"
            #include "../CharacterCommon_ForwardPass.hlsl"

            ENDHLSL
        }



    	Pass
    	{
    		Name "ShadowCaster"
            Tags
            {
                "LightMode" = "ShadowCaster"
            }

            ZWrite On
            ZTest LEqual
            ColorMask 0
    		
    		HLSLPROGRAM
    		#pragma exclude_renderers gles glcore
            #pragma target 4.5

    		
            // -------------------------------------
            // Material Keywords
            #pragma shader_feature_local_fragment _ALPHATEST_ON
            #pragma shader_feature_local_fragment _GLOSSINESS_FROM_BASE_ALPHA

            #pragma vertex MoreCel_ShadowPassVertex
            #pragma fragment MoreCel_ShadowPassFragment
            #define _ACTOR_RENDER

            #include "../CharacterCommon_Inputs.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"

			float3 _LightDirection;

			struct Attributes
			{
			    float4 positionOS   : POSITION;
			    float3 normalOS     : NORMAL;
			    float2 texcoord     : TEXCOORD0;
			    UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct Varyings
			{
			    float2 uv           : TEXCOORD0;
			    float4 positionCS   : SV_POSITION;
			};

			float4 GetShadowPositionHClip(Attributes input)
			{
			    float3 positionWS = TransformObjectToWorld(input.positionOS.xyz);
			    float3 normalWS = TransformObjectToWorldNormal(input.normalOS);

			    float4 positionCS = TransformWorldToHClip(ApplyShadowBias(positionWS, normalWS, _LightDirection));

			#if UNITY_REVERSED_Z
			    positionCS.z = min(positionCS.z, positionCS.w * UNITY_NEAR_CLIP_VALUE);
			#else
			    positionCS.z = max(positionCS.z, positionCS.w * UNITY_NEAR_CLIP_VALUE);
			#endif

			    return positionCS;
			}

			Varyings MoreCel_ShadowPassVertex(Attributes input)
			{
			    Varyings output;
			    UNITY_SETUP_INSTANCE_ID(input);

			    output.uv = TRANSFORM_TEX(input.texcoord, _MainTex);
			    output.positionCS = GetShadowPositionHClip(input);
			    return output;
			}

			half4 MoreCel_ShadowPassFragment(Varyings input) : SV_TARGET
			{
				//Alpha(SampleAlbedoAlpha(input.uv, TEXTURE2D_ARGS(_BaseMap, sampler_BaseMap)).a, 1.0, 0.5);
			    return 0;
			}

            ENDHLSL
    		
		} 
    	
    	Pass
    	{
    		Name "UCMotionBlur"
    		Tags
    		{
    			"LightMode" = "UCMotionBlur" 
    		}	
            Cull Back
    		ZWrite Off
//    		ZTest Always
    		HLSLPROGRAM
    		#pragma exclude_renderers gles glcore
            #pragma target 4.5
    		#pragma vertex vert 
            #pragma fragment frag
    		#pragma multi_compile_vertex __ _STRENCH_ON
            #pragma multi_compile_local __ _CLIPMASK_ON
            #define _ACTOR_RENDER

    		#include "../CharacterCommon_Inputs.hlsl"
			#include "../CharacterCommon_MotionBlur.hlsl"

    		
    		ENDHLSL
    	}

        Pass
        {
            Name "MotionVectors"
            Tags {"LightMode" = "MotionVectors"}
            
            ZWrite On
            Cull Back
            
            HLSLPROGRAM
            #pragma exclude_renderers gles glcore
            #pragma target 4.5

            #pragma vertex Vert
            #pragma fragment Frag

            //#define _NORMALMAP   
            //#define _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            #pragma multi_compile _ WRITE_NORMAL_BUFFER
            
            #include "../CharacterCommon_Inputs.hlsl"
            #include "../CharacterCommon_MotionVector.hlsl"
            ENDHLSL
            
        }
    	
    	 Pass
        {
            Name "EditorProfiler"
        	Tags
    		{
    			"LightMode" = "EditorProfiler" 
    		}
            Cull Back
            HLSLPROGRAM
            #pragma target 2.0

            #pragma multi_compile _ SHADER_COMPLEXITY
            #define _ACTOR_RENDER

            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/UCProfiler.hlsl"
            ENDHLSL
        }
    }
    FallBack "Hidden/Universal Render Pipeline/FallbackError"
}
