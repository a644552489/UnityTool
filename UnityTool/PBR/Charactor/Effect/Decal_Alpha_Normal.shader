Shader "TADemo/Decal_Alpha_Normal"
{
   Properties
    {
        
		[StyledTextureSingleLine]_MainTex("MainTex", 2D) = "white" {}
        _MainTex_ST("_MainTex_ST",vector) = (1,1,0,0)
        [Space]
        [StyledKeywordTextureSingleLine(_NORMALMAP)]_BumpMap("Normal Map", 2D) = "bump" {}
        _BumpMap_ST ("BumpMap_ST", vector) = (1,1,0,0)
        _BumpIntensity("_BumpIntensity" , Range(0,2)) =1
        _Alpha("Alpha", Range(0,1)) = 1
      
        // _Height("纹理拉伸", Range(0,5)) = 1

        [MainColor] _BaseColor("Base Color", Color) = (1,1,1,1) 
        // [Header(Option)]
        // [Space(5)]
        // [Enum(UnityEngine.Rendering.BlendOp)] _BlendOp("_BlendOp", Float) = 0
        // [Enum(UnityEngine.Rendering.BlendMode)] _SrcBlend("_SrcBlend", Float) = 1
        // [Enum(UnityEngine.Rendering.BlendMode)] _DstBlend("_DstBlend", Float) = 0
        // [Enum(UnityEngine.Rendering.CullMode)] _Cull("_Cull", Float) = 0
        // [Enum(UnityEngine.Rendering.CompareFunction)] _ZTest("_ZTest", Float) = 0
        // [Enum(UnityEngine.Rendering.ColoWriteMask)] _AlphaColorMask("_AlphaColorMask", Float) = 15
        // //控制深度写入的比较特殊，可以用 Toggle 或者自定义的 Enum
        // [Enum(off, 0, On, 1)] _ZWriteMode("ZWriteMode", Float) = 1


        // [Header(Stencil)]
        // [Enum(UnityEngine.Rendering.CompareFunction)] _StencilComp ("Stencil Comparison",         Float) = 8
        // [IntRange] _StencilWriteMask ("Stencil Write Mask", Range(0,255)) = 255
        // [IntRange] _StencilReadMask ("Stencil Read Mask", Range(0,255)) = 255
        // [IntRange] _Stencil ("Stencil ID", Range(0,255)) = 0
        // [Enum(UnityEngine.Rendering.StencilOp)] _StencilPass ("Stencil Pass", Float) = 0
        // [Enum(UnityEngine.Rendering.StencilOp)] _StencilFail ("Stencil Fail", Float) = 0
        // [Enum(UnityEngine.Rendering.StencilOp)] _StencilZFail ("Stencil ZFail", Float) = 0

    }
    
    SubShader
    {
        Tags{"RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" "PreviewType"="Plane" "Queue"="Geometry-20" }

        HLSLINCLUDE
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

         
        CBUFFER_START(UnityPerMaterial)

            half4 _MainTex_ST;
            half4 _BumpMap_ST;
            half3 _BaseColor;
            half _Alpha;
            half _Height;
            half _BumpIntensity;
        CBUFFER_END
 
        sampler2D _MainTex;
        TEXTURE2D_X_FLOAT(_CameraDepthTexture);
        SAMPLER(sampler_CameraDepthTexture);
        TEXTURE2D(_BumpMap); SAMPLER(sampler_BumpMap);
        ENDHLSL

   
         Pass
        {
            Name "Forward"
       
            Tags 
            { 
                "LightMode" = "UniversalForward"
            }
			
			Blend SrcAlpha OneMinusSrcAlpha
			ZWrite Off
			ZTest Greater
			Offset 0,0
            Cull Front
			ColorMask RGB
            // Cull Off
            
            HLSLPROGRAM

            //#pragma enable_d3d11_debug_symbols
            #pragma exclude_renderers gles glcore
            #pragma target 4.5

            #pragma shader_feature_local _NORMALMAP

          
            #pragma vertex vert
            #pragma fragment frag

            struct Attributes
            {
                float3 positionOS : POSITION;
                float3 normalOS : NORMAL;
            };
            struct Varings
            {
                float4 positionCS : SV_POSITION;
                float3 viewDirectionWS : TEXCOORD2;
                float4 screenPosition  : TEXCOORD3;
            };
            Varings vert(Attributes input)
            {
                Varings output = (Varings)0;
                output.positionCS = TransformObjectToHClip(input.positionOS.xyz);
                output.screenPosition = ComputeScreenPos(output.positionCS);
                
                return output;
            }
            half4 frag(Varings input) : SV_Target
            {

                float2 positionSS = input.screenPosition.xy / input.screenPosition.w;
                half depth = LOAD_TEXTURE2D_X(_CameraDepthTexture ,input.positionCS.xy);

                float3 positionWS = ComputeWorldSpacePosition(positionSS, depth, UNITY_MATRIX_I_VP);
                float3 positionOS = TransformWorldToObject(positionWS);
              
                positionOS = positionOS * half3(1, -1, 1);
                half2 uv = positionOS.xz + 0.5 ;
         
            
                half clipValue = 0.5 - Max3(abs(positionOS.x), abs(positionOS.y), abs(positionOS.z));
                clip(clipValue);

                half2 uv_MainTex = (uv.xy)* _MainTex_ST.xy + _MainTex_ST.zw;
                half2 uv_Bump = TRANSFORM_TEX(uv ,_BumpMap );

                #ifdef _NORMALMAP
                half3 normal = UnpackNormalScale(SAMPLE_TEXTURE2D(_BumpMap , sampler_BumpMap , uv_Bump),_BumpIntensity);

                half4 mainTex = tex2D( _MainTex, uv_MainTex - normal.xy*0.1);                
                #else
                half4 mainTex = tex2D(_MainTex , uv_MainTex);
          
                #endif
                
                half3 color = mainTex.rgb * _BaseColor.rgb;

        

                return half4(color,mainTex.a*_Alpha);
            }
            
            ENDHLSL  
        }

    
    }
    // CustomEditor "UnityEditor.Rendering.Universal.ShaderGUI.UCParticlesUnlitShader"
    FallBack "Hidden/Universal Render Pipeline/FallbackError"
}


