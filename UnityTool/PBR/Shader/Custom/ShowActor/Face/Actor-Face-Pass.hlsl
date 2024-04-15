#ifndef CUSTOM_FACE_PASS_INCLUDED
    #define CUSTOM_FACE_PASS_INCLUDED

    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

    // GLES2 has limited amount of interpolators
    #if defined(_PARALLAXMAP) && !defined(SHADER_API_GLES)
        #define REQUIRES_TANGENT_SPACE_VIEW_DIR_INTERPOLATOR
    #endif

    #if (defined(_NORMALMAP) || (defined(_PARALLAXMAP) && !defined(REQUIRES_TANGENT_SPACE_VIEW_DIR_INTERPOLATOR))) || defined(_DETAIL)
        #define REQUIRES_WORLD_SPACE_TANGENT_INTERPOLATOR
    #endif

    // keep this file in sync with LitGBufferPass.hlsl

    struct Attributes
    {
        float4 positionOS   : POSITION;
        float3 normalOS     : NORMAL;
        float4 tangentOS    : TANGENT;
        float2 texcoord     : TEXCOORD0;
        float2 lightmapUV   : TEXCOORD1;
        UNITY_VERTEX_INPUT_INSTANCE_ID
    };

    struct Varyings
    {
        float2 uv                       : TEXCOORD0;
        DECLARE_LIGHTMAP_OR_SH(lightmapUV, vertexSH, 1);

        #if defined(REQUIRES_WORLD_SPACE_POS_INTERPOLATOR)
            float3 positionWS               : TEXCOORD2;
        #endif

        float3 normalWS                 : TEXCOORD3;
        #if defined(REQUIRES_WORLD_SPACE_TANGENT_INTERPOLATOR)
            float4 tangentWS                : TEXCOORD4;    // xyz: tangent, w: sign
        #endif
        float3 viewDirWS                : TEXCOORD5;

        half4 fogFactorAndVertexLight   : TEXCOORD6; // x: fogFactor, yzw: vertex light

        #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            float4 shadowCoord              : TEXCOORD7;
        #endif

        #if defined(REQUIRES_TANGENT_SPACE_VIEW_DIR_INTERPOLATOR)
            float3 viewDirTS                : TEXCOORD8;
        #endif

        float4 positionCS               : SV_POSITION;
        UNITY_VERTEX_INPUT_INSTANCE_ID
        UNITY_VERTEX_OUTPUT_STEREO
    };

    void InitializeInputData(Varyings input, half3 normalTS, out InputData inputData)
    {
        inputData = (InputData)0;

        #if defined(REQUIRES_WORLD_SPACE_POS_INTERPOLATOR)
            inputData.positionWS = input.positionWS;
        #endif

        half3 viewDirWS = SafeNormalize(input.viewDirWS);
        #if defined(_NORMALMAP) || defined(_DETAIL)
            float sgn = input.tangentWS.w;      // should be either +1 or -1
            float3 bitangent = sgn * cross(input.normalWS.xyz, input.tangentWS.xyz);
            inputData.normalWS = TransformTangentToWorld(normalTS, half3x3(input.tangentWS.xyz, bitangent.xyz, input.normalWS.xyz));
        #else
            inputData.normalWS = input.normalWS;
        #endif

        inputData.normalWS = NormalizeNormalPerPixel(inputData.normalWS);
        inputData.viewDirectionWS = SafeNormalize(viewDirWS);

        #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            inputData.shadowCoord = input.shadowCoord;
        #elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
            inputData.shadowCoord = TransformWorldToShadowCoord(inputData.positionWS);
        #else
            inputData.shadowCoord = float4(0, 0, 0, 0);
        #endif

        inputData.fogCoord = input.fogFactorAndVertexLight.x;
        inputData.vertexLighting = input.fogFactorAndVertexLight.yzw;
        inputData.bakedGI = SAMPLE_GI(input.lightmapUV, input.vertexSH, inputData.normalWS);
        inputData.normalizedScreenSpaceUV = GetNormalizedScreenSpaceUV(input.positionCS);
        inputData.shadowMask = SAMPLE_SHADOWMASK(input.lightmapUV);
    }


    half3 CustomLightingPhysicallyBased(BRDFData brdfData, 
    half3 lightColor, half3 lightDirectionWS, half lightAttenuation,
    half3 normalWS, half3 viewDirectionWS)
    {
        half NdotL = dot(normalWS, lightDirectionWS)*0.5+0.5;
        
        ///
        ///���������oyql
        ///

       half ramp = smoothstep(_RampThreshold - _RampSmooth , _RampThreshold + _RampSmooth , NdotL);
        
       NdotL =lerp( _ShadePart,_BrightPart , ramp);

        ///
        ///
        ///
        #ifdef _FACE
            lightAttenuation = 1;
        #endif
            
        
   
       // half3 radiance = lightColor * (lightAttenuation * saturate(NdotL));
      half3 radiance = lightColor *(lightAttenuation * saturate(NdotL));
        half3 brdf = brdfData.diffuse;
        
        brdf += brdfData.specular * DirectBRDFSpecular(brdfData, normalWS, lightDirectionWS, viewDirectionWS);

        half front_uv = saturate(NdotL * _3SFrontMask + 0.5);
        half front_mask = SAMPLE_TEXTURE2D(_3SRampMap, sampler_3SRampMap,front_uv).r;
        half back_mask =   lightAttenuation * saturate(NdotL * _3SBackMask + 0.5);
        half VdotL = saturate(dot( viewDirectionWS, -lightDirectionWS )*0.5+0.5);
        half mask = saturate(front_mask * back_mask * VdotL * _3SStrength);
        half3 sssColor = lightColor * _3SColor.rgb *  brdfData.diffuse;
      
        return lerp(brdf * radiance,sssColor,mask);
        //  return mask;
    }

    half3 CustomLightingPhysicallyBased(BRDFData brdfData,  Light light, half3 normalWS, half3 viewDirectionWS)
    {
        return CustomLightingPhysicallyBased(brdfData, light.color, light.direction, light.distanceAttenuation * light.shadowAttenuation, normalWS, viewDirectionWS);
    }

    half3 CustomGlossyEnvironmentReflection(half3 reflectVector, half perceptualRoughness, half occlusion)
    {
        half mip = PerceptualRoughnessToMipmapLevel(perceptualRoughness);
        half4 irradiance = SAMPLE_TEXTURECUBE_LOD(unity_SpecCube0, samplerunity_SpecCube0, reflectVector, mip);
        irradiance *= occlusion;
        return irradiance.rgb;
    }

    // Computes the specular term for EnvironmentBRDF
    half3 CustomEnvironmentBRDFSpecular(BRDFData brdfData, half fresnelTerm)
    {
        float surfaceReduction = 1.0 / (brdfData.roughness2 + 1.0);
        return surfaceReduction * lerp(brdfData.specular, brdfData.grazingTerm, fresnelTerm);
    }

    half3 CustomGI(BRDFData brdfData, 
    half3 bakedGI, half occlusion,
    half3 normalWS, half3 viewDirectionWS)
    {
        half3 reflectVector = reflect(-viewDirectionWS, normalWS);
        half NoV = saturate(dot(normalWS, viewDirectionWS));
        half fresnelTerm = Pow4(1.0 - NoV);

        half3 indirectDiffuse = bakedGI * occlusion;
        half3 indirectSpecular =  CustomGlossyEnvironmentReflection(reflectVector, brdfData.perceptualRoughness, occlusion);

        half3 indirectDiffuseColor = indirectDiffuse * brdfData.diffuse;
        half3 indirectSpecularColor = indirectSpecular* CustomEnvironmentBRDFSpecular(brdfData, fresnelTerm); 

        return  indirectDiffuseColor+indirectSpecularColor;  
        // return  bakedGI;  
    }

    void CustomInitializeBRDFData(float3 albedo, float metallic, float3 specular, float smoothness,  out BRDFData outBRDFData)
    {
        outBRDFData = (BRDFData)0;
        float oneMinusReflectivity = OneMinusReflectivityMetallic(metallic);
        float reflectivity = 1.0 - oneMinusReflectivity;
        float3 brdfDiffuse = albedo * oneMinusReflectivity;
        float3 brdfSpecular = lerp(kDielectricSpec.rgb, albedo, metallic);

        //----------InitializeBRDFDataDirect-----------
        outBRDFData.diffuse = brdfDiffuse;
        outBRDFData.specular = brdfSpecular;
        outBRDFData.reflectivity = reflectivity;

        outBRDFData.perceptualRoughness = 1-smoothness;
        outBRDFData.roughness           = max(outBRDFData.perceptualRoughness * outBRDFData.perceptualRoughness,HALF_MIN_SQRT);
        outBRDFData.roughness2          = max(outBRDFData.roughness * outBRDFData.roughness,HALF_MIN);
        outBRDFData.grazingTerm         = clamp(smoothness + reflectivity,0,1);
        outBRDFData.normalizationTerm   = outBRDFData.roughness * 4.0 + 2.0;
        outBRDFData.roughness2MinusOne  = outBRDFData.roughness2 - 1.0;
    }

    half4 CustomActerPBR(InputData inputData, SurfaceData surfaceData)
    {
        BRDFData brdfData ;

        //CustomInitializeBRDFData(surfaceData.albedo, surfaceData.metallic, surfaceData.specular, surfaceData.smoothness, surfaceData.alpha, brdfData);
        CustomInitializeBRDFData(surfaceData.albedo, surfaceData.metallic, surfaceData.specular, surfaceData.smoothness, brdfData);
        
        Light mainLight = GetMainLight(inputData.shadowCoord);

        half3 indirectColor = CustomGI(brdfData, 
        inputData.bakedGI, surfaceData.occlusion,
        inputData.normalWS, inputData.viewDirectionWS);
        
        half3 directColor = CustomLightingPhysicallyBased(brdfData,
        mainLight, inputData.normalWS, inputData.viewDirectionWS
        );
     
        #ifdef _ADDITIONAL_LIGHTS
            uint pixelLightCount = GetAdditionalLightsCount();
            for (uint lightIndex = 0u; lightIndex < pixelLightCount; ++lightIndex)
            {
                Light light = GetAdditionalLight(lightIndex, inputData.positionWS);
                #if defined(_SCREEN_SPACE_OCCLUSION)
                    light.color *= aoFactor.directAmbientOcclusion;
                #endif
                directColor += CustomLightingPhysicallyBased(brdfData, 
                light,inputData.normalWS, inputData.viewDirectionWS);
            }
        #endif

        #ifdef _ADDITIONAL_LIGHTS_VERTEX
            color += inputData.vertexLighting * brdfData.diffuse;
        #endif

        return half4(directColor + indirectColor + surfaceData.emission, surfaceData.alpha);  
        // return half4(directColor , surfaceData.alpha);  
    }

    ///////////////////////////////////////////////////////////////////////////////
    //                  Vertex and Fragment functions                            //
    ///////////////////////////////////////////////////////////////////////////////

    // Used in Standard (Physically Based) shader
    Varyings LitPassVertex(Attributes input)
    {
        Varyings output = (Varyings)0;

        UNITY_SETUP_INSTANCE_ID(input);
        UNITY_TRANSFER_INSTANCE_ID(input, output);
        UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

        VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);

        // normalWS and tangentWS already normalize.
        // this is required to avoid skewing the direction during interpolation
        // also required for per-vertex lighting and SH evaluation
        VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);

        half3 viewDirWS = GetWorldSpaceViewDir(vertexInput.positionWS);
        half3 vertexLight = VertexLighting(vertexInput.positionWS, normalInput.normalWS);
        half fogFactor = ComputeFogFactor(vertexInput.positionCS.z);

        output.uv = TRANSFORM_TEX(input.texcoord, _BaseMap);

        // already normalized from normal transform to WS.
        output.normalWS = normalInput.normalWS;
        output.viewDirWS = viewDirWS;
        #if defined(REQUIRES_WORLD_SPACE_TANGENT_INTERPOLATOR) || defined(REQUIRES_TANGENT_SPACE_VIEW_DIR_INTERPOLATOR)
            real sign = input.tangentOS.w * GetOddNegativeScale();
            half4 tangentWS = half4(normalInput.tangentWS.xyz, sign);
        #endif
        #if defined(REQUIRES_WORLD_SPACE_TANGENT_INTERPOLATOR)
            output.tangentWS = tangentWS;
        #endif

        #if defined(REQUIRES_TANGENT_SPACE_VIEW_DIR_INTERPOLATOR)
            half3 viewDirTS = GetViewDirectionTangentSpace(tangentWS, output.normalWS, viewDirWS);
            output.viewDirTS = viewDirTS;
        #endif

        OUTPUT_LIGHTMAP_UV(input.lightmapUV, unity_LightmapST, output.lightmapUV);
        OUTPUT_SH(output.normalWS.xyz, output.vertexSH);

        output.fogFactorAndVertexLight = half4(fogFactor, vertexLight);

        #if defined(REQUIRES_WORLD_SPACE_POS_INTERPOLATOR)
            output.positionWS = vertexInput.positionWS;
        #endif

        #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.shadowCoord = GetShadowCoord(vertexInput);
        #endif

        output.positionCS = vertexInput.positionCS;

        return output;
    }

    // Used in Standard (Physically Based) shader
    half4 LitPassFragment(Varyings input) : SV_Target
    {
        UNITY_SETUP_INSTANCE_ID(input);
        UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

     
        half3 msa = SAMPLE_TEXTURE2D(_MSAMap, sampler_MSAMap,input.uv).rgb;

        SurfaceData surfaceData;
        InitializeStandardLitSurfaceData(input.uv, surfaceData,msa);
    
        InputData inputData;
        InitializeInputData(input, surfaceData.normalTS, inputData);
      

        half4 color = CustomActerPBR(inputData, surfaceData);

        color.rgb = MixFog(color.rgb, inputData.fogCoord);
        

        // half4 n = SAMPLE_TEXTURE2D(_BumpMap, sampler_BumpMap, input.uv);
        
        // color.rgb =UnpackNormalScale(n, 1);
        // color.rgb = inputData.normalWS;
        //color.rgb = SampleNormal(input.uv, TEXTURE2D_ARGS(_BumpMap, sampler_BumpMap), _BumpScale);


        // color.rgb = surfaceData.normalTS;
        //color.rgb = surfaceData.smoothness;

         //color.rgb = (1-surfaceData.smoothness)*(1-surfaceData.smoothness);
        // color.rgb = inputData.normalWS;
        return color;
    }

#endif

