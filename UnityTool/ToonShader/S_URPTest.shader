Shader "Universal Render Pipeline/TestShader"
{
    Properties
    {
        _BaseMap ("Base Texture",2D) = "white"{}
        _ToonBRDFTexture ("Toon BRDF Texture",2D) = "white"{}
        _NormalTexture("Normal", 2D) = "bump"{}
        _BaseColor("Base Color",Color) = (1,1,1,1)
        _SpecularColor("SpecularColor",Color)=(1,1,1,1)
        _Smoothness("Smoothness",float)=10
        _Cutoff("Cutoff",float) = 0.5
        
        _ShadowFalloff("ShadowFalloff",Range(0, 1)) = 0.2
        _ShadowPosition("ShadowPosition",Range(0, 1)) = 0.2
        _SkinDetailShadowMin("SkinDetailShadowMin",Range(0, 1)) = 0.2
        _SkinDetailShadowMax("SkinDetailShadowMax",Range(0, 1)) = 0.4
        _BaseColorPower("BaseColorPower",Range(0, 16)) = 1.0
        _SelfShadowDensity("SelfShadowDensity",Range(0, 1)) = 0.3
        _SpecularDensity("SpecularDensity",Range(0, 1)) = 0.3
        _SpecularSize("SpecularSize",Range(0, 64)) = 32
    }
    SubShader
    {
        Tags
        {
            "RenderPipeline"="UniversalPipeline"
            "Queue"="Geometry"
            "RenderType"="Opaque"
        }

        HLSLINCLUDE
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        CBUFFER_START(UnityPerMaterial)
        float4 _BaseMap_ST;
        float4 _BaseColor;
        float4 _SpecularColor;
        float _Smoothness;
        float _Cutoff;

        float _ShadowPosition;
        float _ShadowFalloff;
        float _SkinDetailShadowMax;
        float _SkinDetailShadowMin;
        float _BaseColorPower;
        float _SelfShadowDensity;
        float _SpecularDensity;
        float _SpecularSize;
        
        CBUFFER_END
        
        ENDHLSL
    

        Pass
        {
            Name "URPSimpleLit" 
            Tags{"LightMode"="UniversalForward"}

            HLSLPROGRAM            
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            #pragma vertex vert
            #pragma fragment frag

            struct Attributes
            {
                float4 positionOS : POSITION;
                float4 normalOS : NORMAL;
                float2 uv : TEXCOORD0;
            };
            struct Varings
            {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 positionWS : TEXCOORD1;
                float3 viewDirWS : TEXCOORD2;
                float3 normalWS : TEXCOORD3;
                float3 tangentWS : TEXCOORD4;
            };
            
            TEXTURE2D(_BaseMap);
            SAMPLER(sampler_BaseMap);
            TEXTURE2D(_ToonBRDFTexture);
            SAMPLER(sampler_ToonBRDFTexture);    
            TEXTURE2D(_NormalTexture);
            SAMPLER(sampler_NormalTexture);  
            
            float RemapFloatValue(float oldLow, float oldHigh, float newLow, float newHigh, float invalue)
            {
	            return newLow + (invalue - oldLow) * (newHigh - newLow) / (oldHigh - oldLow);
            }

            half3 ComputeTextureSpaceNormal(float2 uv,half3 vertex_nor,half3 vertex_tangent)
            {
                half4 var_NMTex = SAMPLE_TEXTURE2D(_NormalTexture, sampler_NormalTexture, uv);
            
                float4 n = var_NMTex;
                float3 normalTS =  UnpackNormalScale(n,1);// 法线图
            
                half3 vertex_normal = vertex_nor;
                half3 bitangent = cross(vertex_nor.xyz, vertex_tangent.xyz);
            
                float3 norWS = mul(normalTS,half3x3(vertex_tangent.xyz,bitangent.xyz,vertex_normal));   
                // return TransformTangentToWorld(normalTS, half3x3(vertex_tangent.xyz, bitangent.xyz,vertex_normal));
                
                return norWS;//
                
            }
            
            Varings vert(Attributes IN)
            {
                Varings OUT;
                VertexPositionInputs positionInputs = GetVertexPositionInputs(IN.positionOS.xyz);
                VertexNormalInputs normalInputs = GetVertexNormalInputs(IN.normalOS.xyz);
                OUT.positionCS = positionInputs.positionCS;
                OUT.positionWS = positionInputs.positionWS;
                OUT.viewDirWS = GetCameraPositionWS() - positionInputs.positionWS;
                OUT.normalWS = normalInputs.normalWS;
                OUT.tangentWS = normalInputs.tangentWS;
                OUT.uv = IN.uv;
                #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
                    OUT.shadowCoord = GetShadowCoord(vertexInput);
                #endif
                return OUT;
            }
            
            float4 frag(Varings IN):SV_Target
            {
                Light light = GetMainLight();

                float3 VertexNormal = IN.normalWS;
                half3 N = ComputeTextureSpaceNormal(IN.uv, IN.normalWS, IN.tangentWS);
                
                half4 OutColor = half4(1,1,1,1);
				float3 worldpos = IN.positionWS;
				float3 V = normalize(IN.viewDirWS);
				half3 L = light.direction;
				half3 H = normalize(L + V);
				half3 R = -reflect(V, N);
				half3 NR = -reflect(V, N);
				half RoL = saturate(dot(R, L));
				half NoL = dot(N, L);
				half NoV = saturate(dot(N, V));
				half NoH = saturate(dot(N, H));
				half VoH = saturate(dot(V, H));
				half VoL = saturate(dot(V, L));

                half4 baseMap = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, IN.uv);
                half4 ToonBRDF = SAMPLE_TEXTURE2D(_ToonBRDFTexture, sampler_ToonBRDFTexture, float2(NoH * 0.5 + 0.5, 0));
                //计算主光
                
                half3 diffuse = LightingLambert(light.color, light.direction, IN.normalWS);
                half3 specular = LightingSpecular(light.color, light.direction, normalize(IN.normalWS), normalize(IN.viewDirWS), _SpecularColor, _Smoothness);
                //计算附加光照
                uint pixelLightCount = GetAdditionalLightsCount();
                for (uint lightIndex = 0; lightIndex < pixelLightCount; ++lightIndex)
                {
                    Light light = GetAdditionalLight(lightIndex, IN.positionWS);
                    diffuse += LightingLambert(light.color, light.direction, IN.normalWS);
                    specular += LightingSpecular(light.color, light.direction, normalize(IN.normalWS), normalize(IN.viewDirWS), _SpecularColor, _Smoothness);
                }
                float ToonSelfShadow = smoothstep(_ShadowPosition, _ShadowPosition + _ShadowFalloff, NoL * 0.5 + 0.5);
                ToonSelfShadow = RemapFloatValue(0, 1, _SelfShadowDensity, 1, ToonSelfShadow);
                OutColor.rgb = RemapFloatValue(0, 1, _SkinDetailShadowMin, _SkinDetailShadowMax, saturate(NoL)) / _SkinDetailShadowMax * ToonSelfShadow;

                OutColor.rgb *= pow(baseMap, _BaseColorPower) * _BaseColor.rgb;

                OutColor.rgb += (pow(NoH, _SpecularSize) + ToonBRDF.r) * _SpecularDensity;
                
                clip(baseMap.a-_Cutoff);
                return OutColor;
            }
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
            // Required to compile gles 2.0 with standard srp library
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            #pragma target 2.0

            // -------------------------------------
            // Material Keywords
            #pragma shader_feature _ALPHATEST_ON
            #pragma shader_feature _GLOSSINESS_FROM_BASE_ALPHA

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing

            #pragma vertex ShadowPassVertex
            #pragma fragment ShadowPassFragment
            
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Shaders/ShadowCasterPass.hlsl"
            ENDHLSL
        }

    }
}
