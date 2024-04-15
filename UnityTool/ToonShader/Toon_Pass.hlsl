#ifndef TOON_PASS
#define TOON_PASS

struct VertexInput //输入结构
        {
    float4 posOS : POSITION; // 顶点信息 Get✔
    half4 color: COLOR0;
    float2 uv0 : TEXCOORD0; // UV信息 Get✔
    float3 normalOS : NORMAL; // 法线信息 Get✔
    float4 tangentOS : TANGENT; // 切线信息 Get✔
 
        };

struct VertexOutput //输出结构
            {
    float4 posCS : POSITION; // 屏幕顶点位置
    float4 color: COLOR0;
    float2 uv0 : TEXCOORD1; // UV0
    float3 posWS : TEXCOORD2; // 世界空间顶点位置
    float3 viewDirWS: TEXCOORD3;
    float3 nDirWS : TEXCOORD4; // 世界空间法线方向
    float3 nDirVS :TEXCOORD5;
    float4 posNDC :TEXCOORD6;
    float4 posSS:TEXCOORD7;
    float3 posOS :TEXCOORD8;
    float4 tangentWS :TEXCOORD9;
           
    float3 normalOS :TEXCOORD10;
    half fogFactor :TEXCOORD11;
         
    DECLARE_LIGHTMAP_OR_SH(lightmapUV , vertexSH , 12);

    half2 matcapUV :TEXCOORD13;
            };


VertexOutput vert(VertexInput v) //顶点shader
         {
    VertexOutput o = (VertexOutput)0; // 新建输出结构
    o.color = v.color;
                 
   
            
    VertexPositionInputs  vertexInput = GetVertexPositionInputs(v.posOS);
    VertexNormalInputs normalInput = GetVertexNormalInputs(v.normalOS, v.tangentOS);
              
    //   o.tangentWS = TransformObjectToWorld(v.tangentOS);
    o.nDirWS = TransformObjectToWorldNormal(v.normalOS);
         
    real sign =v.tangentOS.w * GetOddNegativeScale();
    o.tangentWS = half4(normalInput.tangentWS.xyz , sign);
             
    o.posWS = TransformObjectToWorld(v.posOS);
    o.viewDirWS =  normalize(_WorldSpaceCameraPos.xyz - o.posWS.xyz);
    o.posNDC = vertexInput.positionNDC;
    o.posCS = TransformWorldToHClip(o.posWS);
    o.nDirVS = TransformWorldToViewDir(o.nDirWS);
    o.posSS = ComputeScreenPos(o.posCS);
    o.posOS = v.posOS;
              
    o.uv0 = v.uv0; // 传递UV

    o.fogFactor = ComputeFogFactor(vertexInput.positionCS.z);

    o.matcapUV = MetalUV(v.normalOS);
             o.normalOS = v.normalOS;

    return o; // 返回输出结构
         }



           float4 frag(VertexOutput i) : COLOR //像素shader
            {
            
                
          
                
                half3 BumpTex = UnpackNormalScale(SAMPLE_TEXTURE2D(_BumpMap , sampler_BumpMap ,i.uv0), _BumpItensity); //SampleNormal( i.uv0,TEXTURE2D_ARGS(_BumpMap, sampler_BumpMap) ,_BumpItensity  );
                
          
                 float3 bitangentWS = i.tangentWS.w * cross(i.nDirWS , i.tangentWS.xyz);
                float3  nDir = TransformTangentToWorld(BumpTex , float3x3(i.tangentWS.xyz, bitangentWS.xyz, i.nDirWS.xyz));
                nDir = NormalizeNormalPerPixel(nDir);
              
     

               float4 shadowCoord = TransformWorldToShadowCoord(i.posWS.xyz);

                  Light mainLight = GetMainLight(shadowCoord);

            
              
                float3 lDir = normalize(mainLight.direction);
                //由于面部阴影受光照角度影响极易产生难看的阴影，因此可以虑将光照固定成水平方向，再微调面部法线即可得到比较舒适的面部阴影。
                //_FixLightY=0 即可将光照方向固定至水平。
        //      lDir = normalize(float3(lDir.x ,_RampThreshold ,lDir.z ));
                // 准备点积结果
                float nDotl = dot(nDir, lDir);
                float lambert =  nDotl * 0.5f + 0.5f; // 截断负值




                //采样BaseMap和LightMap，确定最初的阴影颜色ShadowColor和DarkShadowColor 。
                half4 baseMap = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, i.uv0) * _BaseColor;
          //      half4 LightMapColor = SAMPLE_TEXTURE2D(_LightMap, sampler_LightMap, TRANSFORM_TEX(i.uv0 ,_LightMap) );
                float2 matcap  =0;
#ifdef _LIGHTPOS_ON
             matcap = MetalUV(i.normalOS ,mainLight.direction);
#else
                matcap  = i.matcapUV;
  #endif
                float3 mapCap = SAMPLE_TEXTURE2D(_MetalMap , sampler_MetalMap ,matcap );
                
                float3 mapCapColor = smoothstep(   _SpecMulti - mapCap ,_SpecMulti + mapCap , mapCap) * _SpecColor;

            
              
             
                half4 FinalColor =0;
          
     
             
                half Ramp = ThreeRamp(lambert);//CalculateRamp(lambert);

        

  

//===========================================================================================================
          half perceptualRoughness = 1.0- _Smooth;
                
          half oneMinusReflectivity = OneMinusReflectivityMetallic(_Metalic);
         half3 brdfSpecular = lerp(kDieletricSpec.rgb, baseMap.xyz, _Metalic);
                
            float roughness = max(PerceptualRoughnessToRoughness(perceptualRoughness), HALF_MIN_SQRT);
            float roughness2   =  max(roughness * roughness, HALF_MIN);
            float normalizationTerm  = roughness * half(4.0) + half(2.0);
             float   roughness2MinusOne  = roughness2 - half(1.0);
                
            half3 bakeGI = SampleSH(nDir);
            half3  diffse= baseMap.xyzz * oneMinusReflectivity;
            half3 indirectDiffuse = bakeGI ;
              
            half3 reflectVector = reflect(-i.viewDirWS, nDir);
     
     
            half3 indirectSpecular = GlossyEnvironmentReflection(reflectVector, perceptualRoughness, _Occlusion);
                
                float3 indirect = (indirectDiffuse + indirectSpecular) *_GIIndirDiffuse;
                FinalColor.rgb += indirect;

              
    
           //     half3 diffuse = RemapFloatValue(0, 1, _SkinDetailShadowMin, _SkinDetailShadowMax, saturate(NoL)) / _SkinDetailShadowMax * ToonSelfShadow;
            

    // Specular-----------------------------------------------------------------------------------
                        //灰

             
        
                half3 diffseColor = diffse * Ramp * mainLight.color * _BRDFDespity ; 

               float3 Spec =brdfSpecular * DirectBRDFSpecular_Custom(roughness2MinusOne ,roughness2 , normalizationTerm ,mainLight.direction ,i.viewDirWS ,nDir);
            
                   half3 specularColor = _EnableSpecular   *  mapCapColor  + Spec    ;
       
      //-------------------------------------------------------------------------------------   
        
               half shadow = mainLight.shadowAttenuation * mainLight.distanceAttenuation;
                 shadow = lerp (1, shadow, _ReciveShadow);

                uint pixelLightCount = GetAdditionalLightsCount();
                for (uint lightIndex = 0; lightIndex < pixelLightCount; ++lightIndex)
                {
                    Light light = GetAdditionalLight(lightIndex, i.posWS);
                    diffseColor += LightingLambert(light.color, light.direction, nDir);
                    specularColor += brdfSpecular * DirectBRDFSpecular_Custom(roughness2MinusOne ,roughness2 , normalizationTerm ,mainLight.direction ,i.viewDirWS ,nDir);
                }
 
                FinalColor.rgb +=  (specularColor + diffseColor) *shadow;//  + Emission   ;// + SpecRimEmission.a * SpecRimEmission;

             
               
  
                
            float alpha = baseMap.a *_BaseColor.a;
               FinalColor.rgb = saturate(FinalColor.rgb);
                return half4(FinalColor.rgb ,alpha);
            }

#endif