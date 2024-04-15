#ifndef CUSTOM_NEW_LIT_INPUT_INCLUDED_EYE
    #define CUSTOM_NEW_LIT_INPUT_INCLUDED_EYE

    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/CommonMaterial.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/ParallaxMapping.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

    #if defined(_DETAIL_MULX2) || defined(_DETAIL_SCALED)
        #define _DETAIL
    #endif

    // NOTE: Do not ifdef the properties here as SRP batcher can not handle different layouts.
    CBUFFER_START(UnityPerMaterial)
        float4 _BaseMap_ST;
 
        half4 _BaseColor;

        half _Cutoff;
        half _Smoothness;
        half _Metallic;
        half _BumpScale;
        // half _Parallax;
        half _Occlusion;
        // half _ClearCoatMask;
        // half _ClearCoatSmoothness;
        // half _DetailAlbedoMapScale;
        // half _DetailNormalMapScale;
        // half _Surface;
    


  


    CBUFFER_END


    // UNITY_INSTANCING_BUFFER_START(GpuInstanceInput)
    // UNITY_DEFINE_INSTANCED_PROP(float4, _BaseColor)
    // UNITY_DEFINE_INSTANCED_PROP(float4, _SpecColor)
    // UNITY_DEFINE_INSTANCED_PROP(float4, _EmissionColor)
    // UNITY_DEFINE_INSTANCED_PROP(float , _Cutoff)
    // UNITY_DEFINE_INSTANCED_PROP(float , _Smoothness)
    // UNITY_DEFINE_INSTANCED_PROP(float , _Metallic)
    // UNITY_DEFINE_INSTANCED_PROP(float , _BumpScale)
    // UNITY_DEFINE_INSTANCED_PROP(float , _Parallax)
    // UNITY_DEFINE_INSTANCED_PROP(float , _OcclusionStrength)
    // UNITY_DEFINE_INSTANCED_PROP(float , _ClearCoatMask)
    // UNITY_DEFINE_INSTANCED_PROP(float , _ClearCoatSmoothness)
    // UNITY_DEFINE_INSTANCED_PROP(float , _DetailAlbedoMapScale)
    // UNITY_DEFINE_INSTANCED_PROP(float , _DetailNormalMapScale)
    // UNITY_DEFINE_INSTANCED_PROP(float , _Surface)
    // UNITY_DEFINE_INSTANCED_PROP(half ,_IsEdgeLight)
    // UNITY_DEFINE_INSTANCED_PROP(half ,_EdgePower)
    // UNITY_DEFINE_INSTANCED_PROP(half4 ,_EdgeColor)
    // UNITY_INSTANCING_BUFFER_END(GpuInstanceInput)

    // #define _BaseColor              UNITY_ACCESS_INSTANCED_PROP(GpuInstanceInput, _BaseColor)
    // #define _SpecColor              UNITY_ACCESS_INSTANCED_PROP(GpuInstanceInput, _SpecColor)
    // #define _EmissionColor          UNITY_ACCESS_INSTANCED_PROP(GpuInstanceInput, _EmissionColor)
    // #define _Cutoff                 UNITY_ACCESS_INSTANCED_PROP(GpuInstanceInput, _Cutoff)
    // #define _Smoothness             UNITY_ACCESS_INSTANCED_PROP(GpuInstanceInput, _Smoothness)
    // #define _Metallic               UNITY_ACCESS_INSTANCED_PROP(GpuInstanceInput, _Metallic)
    // #define _BumpScale              UNITY_ACCESS_INSTANCED_PROP(GpuInstanceInput, _BumpScale)
    // #define _Parallax               UNITY_ACCESS_INSTANCED_PROP(GpuInstanceInput, _Parallax)
    // #define _OcclusionStrength      UNITY_ACCESS_INSTANCED_PROP(GpuInstanceInput, _OcclusionStrength)
    // #define _ClearCoatMask          UNITY_ACCESS_INSTANCED_PROP(GpuInstanceInput, _ClearCoatMask)
    // #define _ClearCoatSmoothness    UNITY_ACCESS_INSTANCED_PROP(GpuInstanceInput, _ClearCoatSmoothness)
    // #define _DetailAlbedoMapScale   UNITY_ACCESS_INSTANCED_PROP(GpuInstanceInput, _DetailAlbedoMapScale)
    // #define _DetailNormalMapScale   UNITY_ACCESS_INSTANCED_PROP(GpuInstanceInput, _DetailNormalMapScale)
    // #define _Surface                UNITY_ACCESS_INSTANCED_PROP(GpuInstanceInput, _Surface)
    // #define _IsEdgeLight            UNITY_ACCESS_INSTANCED_PROP(GpuInstanceInput, _IsEdgeLight)
    // #define _EdgePower              UNITY_ACCESS_INSTANCED_PROP(GpuInstanceInput, _EdgePower)
    // #define _EdgeColor               UNITY_ACCESS_INSTANCED_PROP(GpuInstanceInput, _EdgeColor)



    // TEXTURE2D(_ParallaxMap);        SAMPLER(sampler_ParallaxMap);
    // TEXTURE2D(_OcclusionMap);       SAMPLER(sampler_OcclusionMap);
    // TEXTURE2D(_DetailMask);         SAMPLER(sampler_DetailMask);
    // TEXTURE2D(_DetailAlbedoMap);    SAMPLER(sampler_DetailAlbedoMap);
    // TEXTURE2D(_DetailNormalMap);    SAMPLER(sampler_DetailNormalMap);
    // TEXTURE2D(_MetallicGlossMap);   SAMPLER(sampler_MetallicGlossMap);
    // TEXTURE2D(_SpecGlossMap);       SAMPLER(sampler_SpecGlossMap);
    // TEXTURE2D(_ClearCoatMap);       SAMPLER(sampler_ClearCoatMap);
    // TEXTURE2D(_WaveMap);            SAMPLER(sampler_WaveMap);
    // TEXTURE2D(_BubbleMap);          SAMPLER(sampler_BubbleMap);

//Eye
TEXTURE2D(_IrisTex);    SAMPLER(sampler_IrisTex);

TEXTURE2D(_IrisMask); SAMPLER(sampler_IrisMask);
TEXTURE2D(_EyeDepth) ; SAMPLER(sampler_EyeDepth);
TEXTURE2D(_EyeNormal) ; SAMPLER(sampler_EyeNormal);

    #ifdef _SPECULAR_SETUP
        #define SAMPLE_METALLICSPECULAR(uv) SAMPLE_TEXTURE2D(_SpecGlossMap, sampler_SpecGlossMap, uv)
    #else
        #define SAMPLE_METALLICSPECULAR(uv) SAMPLE_TEXTURE2D(_MetallicGlossMap, sampler_MetallicGlossMap, uv)
    #endif

    half4 SampleMetallicSpecGloss(float2 uv, half albedoAlpha)
    {
        half4 specGloss;

        #ifdef _METALLICSPECGLOSSMAP
            specGloss = SAMPLE_METALLICSPECULAR(uv);
            #ifdef _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
                specGloss.a = albedoAlpha * _Smoothness;
            #else
                specGloss.a *= _Smoothness;
            #endif
        #else // _METALLICSPECGLOSSMAP
            #if _SPECULAR_SETUP
                specGloss.rgb = _SpecColor.rgb;
            #else
                specGloss.rgb = _Metallic.rrr;
            #endif

            #ifdef _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
                specGloss.a = albedoAlpha * _Smoothness;
            #else
                specGloss.a = _Smoothness;
            #endif
        #endif

        return specGloss;
    }

    half SampleOcclusion(float2 uv)
    {
        #ifdef _OCCLUSIONMAP
            // TODO: Controls things like these by exposing SHADER_QUALITY levels (low, medium, high)
            #if defined(SHADER_API_GLES)
                return SAMPLE_TEXTURE2D(_OcclusionMap, sampler_OcclusionMap, uv).g;
            #else
                half occ = SAMPLE_TEXTURE2D(_OcclusionMap, sampler_OcclusionMap, uv).g;
                return LerpWhiteTo(occ, _OcclusionStrength);
            #endif
        #else
            return 1.0;
        #endif
    }


    // Returns clear coat parameters
    // .x/.r == mask
    // .y/.g == smoothness
    half2 SampleClearCoat(float2 uv)
    {
        #if defined(_CLEARCOAT) || defined(_CLEARCOATMAP)
            half2 clearCoatMaskSmoothness = half2(_ClearCoatMask, _ClearCoatSmoothness);

            #if defined(_CLEARCOATMAP)
                clearCoatMaskSmoothness *= SAMPLE_TEXTURE2D(_ClearCoatMap, sampler_ClearCoatMap, uv).rg;
            #endif

            return clearCoatMaskSmoothness;
        #else
            return half2(0.0, 1.0);
        #endif  // _CLEARCOAT
    }

    void ApplyPerPixelDisplacement(half3 viewDirTS, inout float2 uv)
    {
        #if defined(_PARALLAXMAP)
            uv += ParallaxMapping(TEXTURE2D_ARGS(_ParallaxMap, sampler_ParallaxMap), viewDirTS, _Parallax, uv);
        #endif
    }

    // Used for scaling detail albedo. Main features:
    // - Depending if detailAlbedo brightens or darkens, scale magnifies effect.
    // - No effect is applied if detailAlbedo is 0.5.
    half3 ScaleDetailAlbedo(half3 detailAlbedo, half scale)
    {
        // detailAlbedo = detailAlbedo * 2.0h - 1.0h;
        // detailAlbedo *= _DetailAlbedoMapScale;
        // detailAlbedo = detailAlbedo * 0.5h + 0.5h;
        // return detailAlbedo * 2.0f;

        // A bit more optimized
        return 2.0h * detailAlbedo * scale - scale + 1.0h;
    }

    half3 ApplyDetailAlbedo(float2 detailUv, half3 albedo, half detailMask)
    {
        #if defined(_DETAIL)
            half3 detailAlbedo = SAMPLE_TEXTURE2D(_DetailAlbedoMap, sampler_DetailAlbedoMap, detailUv).rgb;

            // In order to have same performance as builtin, we do scaling only if scale is not 1.0 (Scaled version has 6 additional instructions)
            #if defined(_DETAIL_SCALED)
                detailAlbedo = ScaleDetailAlbedo(detailAlbedo, _DetailAlbedoMapScale);
            #else
                detailAlbedo = 2.0h * detailAlbedo;
            #endif

            return albedo * LerpWhiteTo(detailAlbedo, detailMask);
        #else
            return albedo;
        #endif
    }

    half3 ApplyDetailNormal(float2 detailUv, half3 normalTS, half detailMask)
    {
        #if defined(_DETAIL)
            #if BUMP_SCALE_NOT_SUPPORTED
                half3 detailNormalTS = UnpackNormal(SAMPLE_TEXTURE2D(_DetailNormalMap, sampler_DetailNormalMap, detailUv));
            #else
                half3 detailNormalTS = UnpackNormalScale(SAMPLE_TEXTURE2D(_DetailNormalMap, sampler_DetailNormalMap, detailUv), _DetailNormalMapScale);
            #endif

            // With UNITY_NO_DXT5nm unpacked vector is not normalized for BlendNormalRNM
            // For visual consistancy we going to do in all cases
            detailNormalTS = normalize(detailNormalTS);

            return lerp(normalTS, BlendNormalRNM(normalTS, detailNormalTS), detailMask); // todo: detailMask should lerp the angle of the quaternion rotation, not the normals
        #else
            return normalTS;
        #endif
    }

    half3 BlendPinLight(float3 blendOpSrc,float3 blendOpDest,float a)
    {
        return lerp(blendOpDest,(( blendOpSrc > 0.5 ) ? max( blendOpDest, 2.0 * ( blendOpSrc - 0.5 ) ) : min( blendOpDest, 2.0 * blendOpSrc ) ),a);
    }

    inline void InitializeStandardLitSurfaceData(float2 uv, out SurfaceData outSurfaceData,half3 eye)
    {
        outSurfaceData = (SurfaceData)0;
        half4 albedoAlpha = SampleAlbedoAlpha(uv.xy, TEXTURE2D_ARGS(_BaseMap, sampler_BaseMap));
        outSurfaceData.alpha = Alpha(albedoAlpha.a, _BaseColor, _Cutoff);


        outSurfaceData.albedo =eye; //albedoAlpha.rgb * _BaseColor.rgb;

        outSurfaceData.metallic = _Metallic;
        outSurfaceData.specular = half3(0.h, 0.h, 0.h);//half3(0.5h, 0.5h, 0.5h);

        outSurfaceData.smoothness = saturate( _Smoothness);
        outSurfaceData.normalTS = SampleNormal(uv.xy, TEXTURE2D_ARGS(_BumpMap, sampler_BumpMap), _BumpScale);
        outSurfaceData.occlusion = _Occlusion;
        // #if defined (_EMISSION_DYNAMIC)
        //     float emissionMask = SAMPLE_TEXTURE2D(_WaveMap,sampler_WaveMap,uv.zw).r;
        //     outSurfaceData.emission = SampleEmission(uv.xy, _EmissionColor.rgb * emissionMask, TEXTURE2D_ARGS(_EmissionMap, sampler_EmissionMap));
        // #else
        //     outSurfaceData.emission = SampleEmission(uv.xy, _EmissionColor.rgb, TEXTURE2D_ARGS(_EmissionMap, sampler_EmissionMap));
        // #endif

        #if defined(_CLEARCOAT) || defined(_CLEARCOATMAP)
            half2 clearCoat = SampleClearCoat(uv.xy);
            outSurfaceData.clearCoatMask       = clearCoat.r;
            outSurfaceData.clearCoatSmoothness = clearCoat.g;
        #else
            outSurfaceData.clearCoatMask       = 0.0h;
            outSurfaceData.clearCoatSmoothness = 0.0h;
        #endif

        #if defined(_DETAIL)
            half detailMask = SAMPLE_TEXTURE2D(_DetailMask, sampler_DetailMask, uv.xy).a;
            float2 detailUv = uv.xy * _DetailAlbedoMap_ST.xy + _DetailAlbedoMap_ST.zw;
            outSurfaceData.albedo = ApplyDetailAlbedo(detailUv, outSurfaceData.albedo, detailMask);
            outSurfaceData.normalTS = ApplyDetailNormal(detailUv, outSurfaceData.normalTS, detailMask);

        #endif
    }



float Hash21(float2 uv)
{
    uv = frac(uv * float2(123.34,456.21));
    uv += dot(uv , uv + 45.32);
    return frac(uv.x *uv.y);
}
inline float2 ParallaxOffset( half h, half height, half3 viewDir )
    {
        h = h * height - height/2.0;
        float3 v = normalize(viewDir);
        v.z += 0.42;
        return h * (v.xy / v.z);
    }



#endif
