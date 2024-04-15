
Shader "UC/Actor/Protagonist/High/ToonFace"
{
    Properties
    {

                _MainTex ("漫反射贴图 A:阴影矫正", 2D) = "white" {}
                // [HDR]_BaseColor ("漫反射叠加色" ,Color) = (1,1,1,1)
        		_IlluminationTex("R:高光偏移 G:高光强度 B:阴影矫正+第二层阴影 A:边缘光遮罩 ", 2D) = "white" {}
                _NMTex("法线", 2D) = "bump"{}
                _NormalInt("法线强度",Range(0.0,1.0)) = 1.0

    			/*[Toggle] _CameraDirOn("开摄像机控制", Float) = 0
                _celRatioShift("手动伽马矫正", Range(-1, 1)) = 0.0*/
                //_LightProbeIntensity ("LightProbe Intensity", Float) = 30.0

/*        		[Space]
                [Header(Border)]
                [Space]
                [Toggle]_RAMPMAP("开启光照控制图", Float) = 0
                _RampTex ("光照控制图", 2D) = "white" {}*/

                

                [Space]
                [Header(Ramp)]
                [Space]
                _RampSmooth("Ramp羽化,默认0", Range(0,1.0)) = 0
                [HideInInspector] _ShadowOffset("Ramp偏移,默认0", Range(-1,1.0)) = 0    
                _RampMap ("_RampMap",2D) = "white"{}
                [Space]
                _ShadowOffsetInt("阴影矫正强度", Range(0,1.0)) = 1.0

                
                [Space]
                [Header(Shade)]
                [Space]
                [HideInInspector] _RatioHardness("阴影羽化", Range(0,0.5)) = 0
                [HideInInspector] _ShadowOffset("一阶阴影偏移", Range(-0.5,0.5)) = 0
                _ShadowOffset2 ("阴影矫正叠色出现", Range(0.0,1.2)) = -1.0
                _RatioHardness2("阴影矫正叠色羽化", Range(0,0.5)) = 0
                [HDR]_ShadowColor2 ("阴影矫正叠色颜色" , Color) = (1.0,1.0,1.0,1.0)
                _ShadePow("阴影矫正叠原本颜色",Range(0.0,4.0)) = 0.2
                

                [Space]
                [Header(Specular)]
                [Space]
                [HDR]_SpecularColor("高光颜色",Color)=(1,1,1,1)
                // _Smooth("高光大小",Range(-1,1)) = 30.0
                _SpecularSmooth("高光羽化度",Range(0.001,0.5)) = 0.3

                // [Header(MulCol)]
                // [Space]
                // [HDR]_MulColor ("叠加颜色" , Color) = (0.0,0.0,0.0,1.0) 
                // _MulColorRange("叠加位置", Range(-1.0, 1.0)) = -1.0
                // _MulColorPow("叠加软化",Range(0.00001, 2.0)) = 0.01

                [Space]
                [Header(ShadowCol)]
                [Space]
                [Toggle]_ShadowCol("暗部叠色开关", Float) = 0
                [HDR]_ShadowColor02_Range ("上下叠色偏移", Range(-1.0, 2.0)) = 0.5
                _ShadowColor02_UpOffset ("上下叠色遮罩", Range(-2.0, 1.0)) = -1
                _ShadowColor02_Offset ("灯光方向叠色遮罩", Range(-1.0, 1.0)) = -1
                _ShadowColor02_Power ("叠色颜色强度", Range(1.0, 3.0)) = 1

                _ShadowColor02_01("上叠色" , Color) = (1,0,0,1)
                _ShadowColor02_02("下叠色" , Color) = (0,0,1,1)

                // [Header(DarkLine)]
                // _Darkline_Offset("手绘褶皱范围", Range(-1.0,1.0)) = 0.0
                // _DarklineColor("手绘褶皱颜色" , Color) = (1.0,1.0,1.0,1.0)


/*              [Space]
                [Header(Border)]
                [Space]
                [Toggle]_BORDER("明暗交界线溢色", Float) = 0
                _BorderRange("明暗交界线溢色范围", Range(0,10)) = 2
                _BorderInt("明暗交界线溢色强度", Range(0,1)) = 0.1
                _BorderWeaken("贴图暗部的溢色保留",Range(0.00001,5.0)) = 2.0
                [HDR]_BorderSurfaceCol("亮部溢色",Color) = (1.0,1.0,1.0,0.0)
                [HDR]_BorderDarkCol("暗部溢色",Color) = (1.0,1.0,1.0,0.2)*/

                
        		//描边相关
        		[Space]
                [Header(OUTLINE)]
                [Space]
                // _OutLineScale ("描边宽度缩放", Range(0.1, 1)) = 0.6 //0.0015
                
                // _OutlineRectify ("描边矫正", Range(-0.01, 2.5)) = 0.0
                _OutlineColor("描边颜色", Color) = (0, 0, 0, 1)
                _OutlineZOffset("OutlineZOffset",Range(0.0,0.01)) = 0.0
                // _OutlineMax("描边矫正限制",Range(0.0,1.0)) = 0.5
                [HideInInspector] _OutlineBaseThickness ("OutlineBaseThickness", Range(0,0.08)) = 0.05 //0.0015
                [HideInInspector] _OutlineBaseThicknessMul("描边宽度乘数,用于修型",Range(0.0,0.01)) = 1.0
                [HideInInspector] [HDR]_OutlineColorAdd("描边颜色增加,用于敌人标记", Color) = (0, 0, 0, 1)
                // [KeywordEnum(Off, On)] _CustomOutlineNormal ("法线外扩矫正", Float) = 0 
                // _OutlineDistance_0("最近距离",Range(0.0,5.0)) = 0.0
                // _OutlineRectify ("描边矫正", Range(-0.01, 2.5)) = 0.0
                // _OutlineDistance_1("标准距离",Float) = 10.0
                // _OutlineDistance_2("最远距离",Float) = 20.0

                // _OutlineWidth_0("最近描边宽度",Float) = 0.05
                // // _OutlineWidth_1("标准描边宽度",Float) = 0.1
                // _OutlineWidth_2("最远描边宽度",Float) = 0.2

                // [Space]
                // _RimMulSH("边缘环境光叠加",Range(0.0,3.0)) = 1.0
                // [Space]

                // 屏幕描边
                [Space]
                [Header(OUTLINE)]
                [Space]
                [Toggle]_ScreenOutlineOn("屏幕描边测试", Float) = 0
                _OutLineScale ("屏幕描边缩放", Range(0.0,0.03)) = 0.001 //0.0015
                _ScreenOutlineDeW("屏幕描边假透视",Range(0.0,1)) = 0.6

                [Header(Fresnel)]
                [Space]
                [HideInInspector] [Toggle]_FresnelOn("简单边缘光", Float) = 0
                // [HDR]_FresnelColor("压暗边缘光颜色",Color) = (0.6,0.6,0.6,0)
        		[HideInInspector]_FresnelPow("压暗边缘光范围衰减",Range(0,5)) = 0.65
        		[HideInInspector]_FresnelSmooth("压暗边缘光羽化度",Range(0,0.5)) = 0
                // _FresnelMixPOW("边缘光叠加自身颜色",Range(0,2)) = 1

                [Header(FresnelAdd)]
                [Space]
                [HideInInspector][HDR]_FresnelAddColor ("叠亮边缘光颜色",Color) = (0,0,0,1)
                [HideInInspector]_FresnelAddPow ("叠亮边缘光范围衰减", Range(0,5)) = 0.65       
                [HideInInspector]_FresnelAddSmooth ("叠亮边缘光羽化度", Range(0, 0.5)) = 0
                [HideInInspector]_FresnelMulSH("烘焙光混合",Range(0.0,5)) = 1
                // _FresnelMulSHMax("边缘光受环境亮度限制",Range(0.0,5)) = 5
                [Header(FresnelAdd)]
                _FresnelMulPointLight("菲涅尔实时光混合",Range(0.0,20.0)) = 1.0
                // // _FresnelMulPointLightMax("边缘光受点光亮度限制",Range(0.0,10)) = 10
                
                // [Space]
                // [Header(FresnelAddMix)]
                // [Space]
                // //[Toggle]_FresnelFlip("融合方向反向",Float) = 0.0
                // _FresnelMixL("叠亮边缘光:暗部遮罩(默认0)",Range(0,1)) = 0
                // // _FresnelMixLPow("光方向羽化度",Range(0,0.5)) = 0.25
                // _FresnelFalloffValue("叠亮边缘光:上下衰减(默认-1)",Range(-1,1)) = -1
                // // _FresnelFalloffPow("叠亮边缘光上下羽化",Range(0.00001,1)) = 1.0

                // [HideInInspector]_ActorEnvSet_("环境光参数",Vector) = (1,0.06,0.04,0.2)
                // [HideInInspector]_ActorEnvSet2_("环境光参数2",Vector) = (1,2,1,1)

                
                // [Space]
                // [Header(FresnelAddMix)]
                // [Space]
                // //[Toggle]_FresnelFlip("融合方向反向",Float) = 0.0
                // _FresnelMixL("叠亮边缘光:暗部遮罩(默认0)",Range(0,1)) = 0
                // // _FresnelMixLPow("光方向羽化度",Range(0,0.5)) = 0.25
                // _FresnelFalloffValue("叠亮边缘光:上下衰减(默认-1)",Range(-1,1)) = -1
                // // _FresnelFalloffPow("叠亮边缘光上下羽化",Range(0.00001,1)) = 1.0
        
        // [Space]
        // [Header(Env)]
        // [Space]
        // _SH_Hue("环境光色相",Range(0.0,2.0)) = 1.0
        // _SH_Saturation("环境光饱和度",Range(0.0,2.0)) = 1.0
        // _SH_SaturationMax("饱和度限制",Range(0.0,2.0)) = 2.0
        // // [Space]
        // // _SH_Exposure_Shade("暗部最暗限制",Range(0.0,1)) = 1
        // // _SH_Exposure("亮部最暗限制",Range(0.0,1)) = 1
        // // _SH_ValueMax("最亮限制",Range(0.0,5.0)) = 3.0
        // [Space]
        // _SH_ValueMin("混合度限制",Range(0.0,1.0)) = 0.6
        // // _ProjectorCol("硬投影颜色",Color) = (1.0,1.0,1.0,1.0)
        // [HideInInspector] _SHCol("_SHCol", Color) = (0,0,0,0)
        [HideInInspector] _ProjectorTexture("",2D) = "white" {}
        [HideInInspector]_OutlineVRange("_OutlineVRange", Vector) = (0,1,0,1)
        [HideInInspector]_OutlineSpeedDir("_OutlineSpeedDir", Vector) = (0,0,0,0)
        [HideInInspector]_OutlineVOffset("_OutlineVOffset", Float) = 1.0
        [HideInInspector]_OutlineVDifference("_OutlineVDifference", Float) = 1.0
        [HideInInspector]_OutlineVNoiseScale("_OutlineVNoiseScale", Float) = 1.0

        // // 外边缘光 拜拜啦兄弟~
        // [Space]
        // [Header(Rim)]
        // [Space]
        // [Toggle]_RIM("轮廓光", Float) = 0
        // // _RimWidth("轮廓光整体宽度",Range(0.0,100)) = 10
        // _RimDepthOffSet("轮廓光方向",Vector) = (4.0,6.0,0.0,0.0)
        // [HDR]_RimColor2 ("轮廓光颜色", Color) = (1, 1, 1, 1)
        // // [HDR]_RimColor3 ("轮廓光颜色2", Color) = (1, 1, 1, 1)
        // // _RimDepthStpe("轮廓光精度",Range(0.0,1.0)) = 0.5 
        // // [Space]
        // // [Space]
        // _RimMixCol("轮廓光透明度",Range(0.0,9.0)) = 0.0
                
        // // _RimMixLambert("轮廓光衰减，1是只留亮部，-1是只留暗部，2和-2是全亮",Range(-2.0,2.0)) = 1.0
        // // _RimMixFresnel("轮廓光软化强度",Range(0.0,1.0)) = 1.0
        // // _RimMixFresnelPow("轮廓光软化大小",Range(1.0, 30.0)) = 2.0
        // // _RimMixFresnelSmooth("轮廓光软化过渡", Range(0.001, 1.0)) = 1
        // [Space]
        // [Space]
        // // _RimSHPow("轮廓光受环境光影响程度", Range(0.001, 90.0)) = 10
        // _FalloffValue("轮廓光衰减范围,值越大轮廓光的范围越大",Range(-1.0,2.0)) = 2.0
        // _FalloffPow("轮廓光衰减过渡",Range(0.00001,30)) = 1.0

        /*[Space]
        [Header(Light)]
        [Space]
        [Toggle]_LIGHT("主角变亮", Float) = 0
        _LightInt("变亮程度",Range(0.0,1.0)) = 0.5*/
        /*
        [Space]
        [Header(CustomShadow)]
        [Space]
        [Toggle]_CUSTOMSHADOW("自投影", Float) = 0
        _CustomShadowOffset ("自投影宽度", Float) = 1
        _CustomShadowDir("自投影方向",Vector) = (1.0,1.0,1.0,1.0)
        _CustomShadowCol("自投影颜色",Color) = (1.0,1.0,1.0,1.0)
        */

                
        [Space]
        [Space]
        [Header(Effect)]
        [Space]
        // s[Toggle]_SH_Value("环境光开关(更改权重联系TA开拉条", Float) = 1
        //_SH_Value("环境光拉条",Range(0.0,2.0)) = 0.6
        [HideInInspector][HDR]_BaseColor ("漫反射叠加色" ,Color) = (1,1,1,1)
        [HideInInspector]_PureShadowColor("阴影无光照影响着色", Color) = (1,1,1,1)
        [HideInInspector]_DarkPointLightInt("暗部点光强度",Range(0.0,1.0)) = 1.0
        // [Space]
        // [Space]
        // [Header(EffectPast)]
        // [Toggle]_EFFECT("特效改色开关", Float) = 1
        [HideInInspector]_SpeedInt("拖尾强度",Range(0.0,1.0)) = 1.0
        [HideInInspector]_PointLightDark("直接点光压暗",Range(0,1)) = 1

        // [Space]
        // [Space]
        // [Header(OLD)]
        // [Space]
        // [Toggle]_PointLightAtt("新老点光切换",Float) = 0
        // _BadLightTex("老版光照放个Ill", 2D) = "white" {}
        // _LightColor ("Light Color" , Color) = (1.0,1.0,1.0,1.0)
        // _ShadowColor ("Shadow Color" , Color) = (0.7,0.7,0.7,1.0)
        [HideInInspector]_OutlineVertexCol("老版本无用值,为了不报错存在,已让美术删除K帧",Float) = 0
        [HideInInspector]_ActorEnvInt("_ActorEnvInt",Range(0,1)) = 1
        [HideInInspector]_StencilComp("Comp",Float) = 8// 本来想搞动态的
                
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
        Stencil
        {
            Ref 5
            Comp [_StencilComp]
            Pass Replace
        }
	    Tags {"RenderType" = "Opaque" }
	    
		
        Pass
        {
            Name "URPSimpleLit" 
            Tags{"LightMode"="UniversalForward"}

            HLSLPROGRAM            
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            #pragma vertex vert
            #pragma fragment frag

            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile_fragment _ _SHADOWS_SOFT
            
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
                float4 shadowCoord : TEXCOORD5;
            };

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
                OUT.shadowCoord = GetShadowCoord(positionInputs);
                return OUT;
            }
            
            float4 frag(Varings IN):SV_Target
            {
                Light light = GetMainLight(IN.shadowCoord);

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

                float ToonSelfShadow = smoothstep(_ShadowPosition, _ShadowPosition + _ShadowFalloff, NoL * 0.5 + 0.5);
                ToonSelfShadow = RemapFloatValue(0, 1, _SelfShadowDensity, 1, ToonSelfShadow);
                half3 diffuse = RemapFloatValue(0, 1, _SkinDetailShadowMin, _SkinDetailShadowMax, saturate(NoL)) / _SkinDetailShadowMax * ToonSelfShadow;
                diffuse.rgb *= pow(baseMap, _BaseColorPower) * _BaseColor.rgb * light.color;

                half3 specular = (pow(NoH, _SpecularSize) + ToonBRDF.r) * _SpecularDensity;

                float ShadowMask = light.shadowAttenuation * light.distanceAttenuation;
                
                //计算附加光照
                uint pixelLightCount = GetAdditionalLightsCount();
                for (uint lightIndex = 0; lightIndex < pixelLightCount; ++lightIndex)
                {
                    Light light = GetAdditionalLight(lightIndex, IN.positionWS);
                    diffuse += LightingLambert(light.color, light.direction, IN.normalWS);
                    specular += LightingSpecular(light.color, light.direction, normalize(IN.normalWS), normalize(IN.viewDirWS), _SpecularColor, _Smoothness);
                }

                OutColor.rgb = diffuse + specular;
                
                clip(baseMap.a-_Cutoff);
                return OutColor;
            }
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


            #include "../CharacterCommon_Inputs.hlsl"
            #include "../CharacterCommon_ForwardPass.hlsl"
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
