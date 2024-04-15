#ifndef Fur_INCLUDE
#define Fur_INCLUDE

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

struct FragmentCommonData
{
    half3 diffColor, specColor;
    // Note: smoothness & oneMinusReflectivity for optimization purposes, mostly for DX9 SM2.0 level.
    // Most of the math is being done on these (1-x) values, and that saves a few precious ALU slots.
    half oneMinusReflectivity, smoothness;
    float3 normalWorld, normalWorld_clearcoat;
    float3 tangentWorld;
    float3 eyeVec;
    half alpha;
    float3 posWorld;



#if UNITY_STANDARD_SIMPLE
    half3 reflUVW;
#endif

#if UNITY_STANDARD_SIMPLE
    half3 tangentSpaceNormal;
#endif
};

half3 NormalizePerVertexNormal (float3 n) // takes float to avoid overflow
{
    #if (SHADER_TARGET < 30) || UNITY_STANDARD_SIMPLE
        return normalize(n);
    #else
        return n; // will normalize per-pixel instead
    #endif
}

half3x3 CreateTangentToWorldPerVertex(half3 normal, half3 tangent, half tangentSign)
{
    // For odd-negative scale transforms we need to flip the sign
    half sign = tangentSign * unity_WorldTransformParams.w;
    half3 binormal = cross(normal, tangent) * sign;
    return half3x3(tangent, binormal, normal);
}

inline half4 VertexGIForward(Attributes v, float3 posWorld, half3 normalWorld)
{
    half4 ambientOrLightmapUV = 0;
    // Static lightmaps
    #ifdef LIGHTMAP_ON
        ambientOrLightmapUV.xy = v.uv.xy * unity_LightmapST.xy + unity_LightmapST.zw;
        ambientOrLightmapUV.zw = 0;
    // Sample light probe for Dynamic objects only (no static or dynamic lightmaps)
    #elif UNITY_SHOULD_SAMPLE_SH
        #ifdef VERTEXLIGHT_ON
            // Approximated illumination from non-important point lights
            ambientOrLightmapUV.rgb = Shade4PointLights (
                unity_4LightPosX0, unity_4LightPosY0, unity_4LightPosZ0,
                unity_LightColor[0].rgb, unity_LightColor[1].rgb, unity_LightColor[2].rgb, unity_LightColor[3].rgb,
                unity_4LightAtten0, posWorld, normalWorld);
        #endif

        ambientOrLightmapUV.rgb = ShadeSHPerVertex (normalWorld, ambientOrLightmapUV.rgb);
    #endif

    #ifdef DYNAMICLIGHTMAP_ON
        ambientOrLightmapUV.zw = v.uv2.xy * unity_DynamicLightmapST.xy + unity_DynamicLightmapST.zw;
    #endif

    return ambientOrLightmapUV;
}

half Alpha(float2 uv)
{
    return tex2D(_MainTex, uv).a * _Color.a;
}

half3 UnpackScaleNormalRGorAG(half4 packednormal, half bumpScale)
{
    #if defined(UNITY_NO_DXT5nm)
        half3 normal = packednormal.xyz * 2 - 1;
        //#if (SHADER_TARGET >= 30)
        //    // SM2.0: instruction count limitation
        //    // SM2.0: normal scaler is not supported
        //    
        //#endif
        normal.xy *= bumpScale;
        return normal;
    #else
        // This do the trick
        packednormal.x *= packednormal.w;

        half3 normal;
        normal.xy = (packednormal.xy * 2 - 1);
        //#if (SHADER_TARGET >= 30)
        //    // SM2.0: instruction count limitation
        //    // SM2.0: normal scaler is not supported
        //    
        //#endif
        normal.xy *= bumpScale;
        normal.z = sqrt(1.0 - saturate(dot(normal.xy, normal.xy)));
        return normal;
    #endif
}

half3 UnpackScaleNormal(half4 packednormal, half bumpScale)
{
    return UnpackScaleNormalRGorAG(packednormal, bumpScale);
}


float3 NormalizePerPixelNormal (float3 n)
{
    #if (SHADER_TARGET < 30) || UNITY_STANDARD_SIMPLE
        return n;
    #else
        return normalize(n);
    #endif
}


inline half3 PreMultiplyAlpha (half3 diffColor, half alpha, half oneMinusReflectivity, out half outModifiedAlpha)
{
    #if defined(_ALPHAPREMULTIPLY_ON)
        // NOTE: shader relies on pre-multiply alpha-blend (_SrcBlend = One, _DstBlend = OneMinusSrcAlpha)

        // Transparency 'removes' from Diffuse component
        diffColor *= alpha;

        #if (SHADER_TARGET < 30)
            // SM2.0: instruction count limitation
            // Instead will sacrifice part of physically based transparency where amount Reflectivity is affecting Transparency
            // SM2.0: uses unmodified alpha
            outModifiedAlpha = alpha;
        #else
            // Reflectivity 'removes' from the rest of components, including Transparency
            // outAlpha = 1-(1-alpha)*(1-reflectivity) = 1-(oneMinusReflectivity - alpha*oneMinusReflectivity) =
            //          = 1-oneMinusReflectivity + alpha*oneMinusReflectivity
            outModifiedAlpha = 1-oneMinusReflectivity + alpha*oneMinusReflectivity;
        #endif
    #else
        outModifiedAlpha = alpha;
    #endif
    return diffColor;
}



#if UNITY_REQUIRE_FRAG_WORLDPOS
    #if UNITY_PACK_WORLDPOS_WITH_TANGENT
        #define IN_WORLDPOS(i) half3(i.tangentToWorldAndPackedData[0].w,i.tangentToWorldAndPackedData[1].w,i.tangentToWorldAndPackedData[2].w)
    #else
        #define IN_WORLDPOS(i) i.posWorld
    #endif
    #define IN_WORLDPOS_FWDADD(i) i.posWorld
#else
    #define IN_WORLDPOS(i) half3(0,0,0)
    #define IN_WORLDPOS_FWDADD(i) half3(0,0,0)
#endif


inline void InitializeStandardLitSurfaceData(float2 uv, out SurfaceData outSurfaceData)
    {
        half3 msa = tex2D(_MSAMap,uv.xy).rgb;

        half4 albedoAlpha = tex2D(_MainTex,uv.xy);
        outSurfaceData.alpha = albedoAlpha.a * _Color.a;

        outSurfaceData.albedo =albedoAlpha.rgb * _Color.rgb;

        outSurfaceData.metallic = msa.r * _MetaStrength;
        outSurfaceData.specular = half3(0.h, 0.h, 0.h);//half3(0.5h, 0.5h, 0.5h);

        outSurfaceData.smoothness = saturate((1-msa.g) * _SmoothnessStrength);
        outSurfaceData.normalTS = UnpackScaleNormal(tex2D(_BumpMap, uv.xy), _BumpScale);
        outSurfaceData.occlusion =LerpWhiteTo(msa.b , _AOStrength);// msa.b * _AOStrength;

        #if defined (_EMISSION_DYNAMIC)
            float emissionMask = tex2D(_WaveMap,TRANSFORM_TEX(uv.xy, _WaveMap)).r;
            outSurfaceData.emission = tex2D(_EmissionMap,uv.xy).rgb *_EmissionColor.rgb * emissionMask;
        #else
            outSurfaceData.emission = tex2D(_EmissionMap,uv.xy).rgb *_EmissionColor.rgb;
        #endif

        outSurfaceData.clearCoatMask       = 0.0h;
        outSurfaceData.clearCoatSmoothness = 0.0h;

    }

    half3 CustomGI(BRDFData brdfData, 
    half3 bakedGI, half occlusion,
    half3 normalWS, half3 viewDirectionWS)
    {
        half3 reflectVector = reflect(-viewDirectionWS, normalWS);
        half NoV = saturate(dot(normalWS, viewDirectionWS));
        half fresnelTerm = Pow4(1.0 - NoV);

        half3 indirectDiffuse = bakedGI * occlusion;
        half3 indirectSpecular = GlossyEnvironmentReflection(reflectVector, brdfData.perceptualRoughness, occlusion);

        half3 indirectDiffuseColor = indirectDiffuse * brdfData.diffuse;
        half3 indirectSpecularColor = indirectSpecular * EnvironmentBRDFSpecular(brdfData, fresnelTerm);

        return  indirectDiffuseColor+indirectSpecularColor;  
        // return  bakedGI;  
    }

    half4 CustomActerPBR(InputData inputData, SurfaceData surfaceData)
    {
        BRDFData brdfData;

        InitializeBRDFData(surfaceData.albedo, surfaceData.metallic, surfaceData.specular, surfaceData.smoothness, surfaceData.alpha, brdfData);
        
        Light mainLight = GetMainLight(inputData.shadowCoord);

        half3 indirectColor = CustomGI(brdfData, 
        inputData.bakedGI, surfaceData.occlusion,
        inputData.normalWS, inputData.viewDirectionWS);
        
        half3 directColor = LightingPhysicallyBased(brdfData,
        mainLight, inputData.normalWS, inputData.viewDirectionWS
        );
        
        #ifndef _ADDITIONAL_LIGHTS_OFF
            uint pixelLightCount = GetAdditionalLightsCount();
            for (uint lightIndex = 0u; lightIndex < pixelLightCount; ++lightIndex)
            {
                Light light = GetAdditionalLight(lightIndex, inputData.positionWS);
                #if defined(_SCREEN_SPACE_OCCLUSION)
                    light.color *= aoFactor.directAmbientOcclusion;
                #endif
                directColor += LightingPhysicallyBased(brdfData, 
                light,inputData.normalWS, inputData.viewDirectionWS);
            }
        #endif
        half3 color =0;
        #if !defined(_ONLY_REALTIME_SHADOW)
           color = directColor + indirectColor;
        #else
            color = indirectColor * mainLight.shadowAttenuation;
        #endif
        //顶点光照
        //#ifdef _ADDITIONAL_LIGHTS_VERTEX
        //    directColor += inputData.vertexLighting * brdfData.diffuse;
        //#endif

        #if defined(_EMISSION_DYNAMIC)
            return half4(color + surfaceData.emission * max(0.4,(sin(_Time.z * _BreatheSpeed) + 1.25)), surfaceData.alpha);
        #else
            return half4(color + surfaceData.emission, surfaceData.alpha);  
        #endif
        // return half4(indirectColor , surfaceData.alpha);  
    }

    half EmpricialFresnel(half3 viewDirection, half3 normalDir)
    {
        viewDirection = normalize(viewDirection);
        normalDir = normalize(normalDir);
        
        return max(0,min(1,_FresnelBias + _FresnelScale *pow(abs(1-dot(viewDirection,normalDir)),_FrenelPower)));        
    }

    float StrandSpecular(float3 T, float3 V, float3 L,float exponent)
    {
       float3 H = normalize(L+V);
       float dotTH = dot(T,H);
       float sinTH = sqrt(1-dotTH*dotTH);
       float dirAtten = smoothstep(-1,0,dotTH);
       return dirAtten * pow(sinTH,exponent);
    }

    float LightSpecular(float3 P, float3 T, float3 V,float3 N, float exponent)
    {
        float lightSpec = 0;
        Light mainLight = GetMainLight();
        lightSpec += StrandSpecular(T,V,mainLight.direction,exponent) *saturate(dot(N,mainLight.direction));

        #ifdef _ADDITIONAL_LIGHTS_ALL
            uint lightsCount = GetAdditionalLightsCount();
            for (uint lightIndex = 0u; lightIndex < lightsCount; ++lightIndex)
                {
                    Light light = GetAdditionalLight(lightIndex, P);
                    lightSpec += StrandSpecular(T,V,light.direction,exponent) *saturate(dot(N,light.direction));
                }
        #endif
    return lightSpec;     
    }

    real3 MShiftTangent(real3 T, real3 N, real shift)
    {
        #ifdef _USE_BITANGENT
            real3 B = normalize(cross(N,T));
            return normalize(B + N * shift);
        #else
            return normalize(T + N * shift);
        #endif
    }


    
 void InitializeInputData(Varyings input, half3 normalTS, out InputData inputData)
    {
        inputData = (InputData)0;

        #if defined(REQUIRES_WORLD_SPACE_POS_INTERPOLATOR)
            inputData.positionWS = input.posWS;
        #endif

        half3 viewDirWS = SafeNormalize(input.viewWS);
        #if defined(_NORMALMAP) || defined(_DETAIL)
            float sgn = input.tangentWS.w;      // should be either +1 or -1
            float3 bitangent = sgn * cross(input.normalWS.xyz, input.tangentWS.xyz);
            inputData.normalWS = TransformTangentToWorld(normalTS, half3x3(input.tangentWS.xyz, bitangent.xyz, input.normalWS.xyz));
        #else
            inputData.normalWS = input.normalWS;
        #endif

        inputData.normalWS = NormalizeNormalPerPixel(inputData.normalWS);
        inputData.viewDirectionWS = viewDirWS;

        #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            inputData.shadowCoord = input.shadowCoord;
        #elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
            inputData.shadowCoord = TransformWorldToShadowCoord(inputData.positionWS);
        #else
            inputData.shadowCoord = float4(0, 0, 0, 0);
        #endif


        inputData.fogCoord = input.fogFactorAndVertexLight.x;
        inputData.vertexLighting = input.fogFactorAndVertexLight.yzw;

        half3 bakeGI_Morning = SAMPLE_GI_CUSTOM(input.lightmapUV_Morning, input.vertexSH, inputData.normalWS ,
           Lightmap_Morning , sampler_Lightmap_Morning ,LightmapInd_Morning );
        half3 bakeGI_Evening = SAMPLE_GI_CUSTOM(input.lightmapUV_Evening, input.vertexSH, inputData.normalWS ,
           Lightmap_Evening , sampler_Lightmap_Evening ,LightmapInd_Evening );

        inputData.bakedGI = lerp(bakeGI_Morning , bakeGI_Evening , _LightmapStrength);
        //SAMPLE_GI(input.lightmapUV_Morning, input.vertexSH, inputData.normalWS) * _LightmapStrength;

        inputData.normalizedScreenSpaceUV = GetNormalizedScreenSpaceUV(input.positionHCS);
        half4 shadowmask_Morning = SAMPLE_SHADOWMASK_CUSTOM(ShadowMask_Morning ,sampler_ShadowMask_Morning , input.lightmapUV_Morning);
        half4 shadowmask_Evening = SAMPLE_SHADOWMASK_CUSTOM(ShadowMask_Evening ,sampler_ShadowMask_Evening , input.lightmapUV_Evening);
        inputData.shadowMask = lerp(shadowmask_Morning , shadowmask_Evening , _LightmapStrength);
    }

#endif