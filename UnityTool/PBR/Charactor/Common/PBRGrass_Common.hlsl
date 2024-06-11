
#include "../Actor-Input.hlsl"
float _ColorGridOffset;
float _ColorGridSmooth;
float4 _ColorGridTop;
float4 _ColorGridBottom;

float _SubsurfaceSaturation;
float4 _SubsurfaceColor;

float _BackSubsurfaceDistortion;
float _SSSPower;
float _SSSIntensity;

float4 _ColorBright;
float4 _ColorDark;

float _WindFrequency;
float _WindSpeed;
float _WindStrength;

float _DiffuseMax;
float _DiffuseMin;
float _DiffusePow;


float _AORampMin;
float3 _AO_Dark;


float _FresnelPow;
float _FresnelSmooth;
float3 _FresnelColor;

TEXTURE2D(_RampMap); SAMPLER(sampler_RampMap);
TEXTURE2D(_RampMask) ; SAMPLER(sampler_RampMask); float4 _RampMask_ST;


float2 GrassAnim(float3 positionWS , float3 positionOS)
{
    float rand = dot( positionWS.xz   ,half2(1,0));
    
    float2 offset=  sin(_Time.y *_WindFrequency  - rand)  * _WindSpeed *  smoothstep(_WindStrength,1 ,max(0,positionOS.y) ) ;
    return offset;
   
}

VertexPositionInputs WindAnim(float3 positionWS ,float3 positionOS , VertexPositionInputs vertexInput)
{

    float2 offset = 0;
    float rand = positionWS.x * 2 + positionWS.z *0.25;

        
    float Y = positionOS.y * _WindStrength+1 ;
    Y = Y*Y;
    Y =Y*Y -Y;
        
    offset = RemapFloatValue(-1,1,0,1 ,sin(_Time.y* _WindFrequency + rand ) * _WindSpeed  )* Y *half2(-0.1,-0.35);
    #ifdef _GRASS
       
         offset = GrassAnim(positionWS , positionOS);
         positionWS.xz += offset;
         positionOS = TransformWorldToObject(positionWS);
         vertexInput = GetVertexPositionInputs(positionOS);
    #else


        positionOS.xz += offset;
        vertexInput = GetVertexPositionInputs(positionOS.xyz );
    #endif
    
   
 
    return vertexInput;
}

float2 WindAnim(float3 positionWS ,float3 positionOS )
{

   float2 offset = GrassAnim(positionWS , positionOS);
 
    return offset;
}


float3 Desaturation(float3 color ,float desaturation)
{
    float3 output =  desaturation * color;
    return output;
}




float3 GrassColorGrid(float3 albedo , float pos_Y , float ao  , float3 W)
{
    float3 color = 0;
    #ifdef _GRASS
     color  =lerp(albedo*  _ColorGridBottom , albedo*  _ColorGridTop ,smoothstep(  _ColorGridOffset ,_ColorGridOffset+_ColorGridSmooth ,pos_Y));
     
    float mask = SAMPLE_TEXTURE2D(_RampMask , sampler_RampMask , ( W.xz*0.02  * _RampMask_ST.xy + _RampMask_ST.zw)  + _Time.yy *0.1  *float2(_DiffuseMin ,_DiffuseMax)).r;
    mask = RemapFloatValue(0,1,_FresnelPow , _FresnelSmooth , mask );
    float3 ramp  = SAMPLE_TEXTURE2D(_RampMap, sampler_RampMap , float2(mask ,0));
  //  ramp = lerp(_ColorGridTop , ramp , mask);
    color = ramp *color;
    #else
     color = albedo;
    float AmbientOcclusion =RemapFloatValue(0,1,_AORampMin , 1 , ao);
    float3 AOcolor = lerp(_AO_Dark , 1 , AmbientOcclusion);
    color = color * AOcolor;
    #endif



    return color ;
}

half3 LightingPhysicallyBased_TwoSideBxDF(
    BRDFData brdfData,
    Light light, 
    half3 normalWS,
    half3 viewDirectionWS
 
    )
{
    half3 lightColor = light.color;
    half3 lightDirectionWS = light.direction;
    half lightAttenuation =light.distanceAttenuation * light.shadowAttenuation;
    half NoL = dot(normalWS, lightDirectionWS);
    half NdotL = NoL * 0.5 + 0.5;
    
    float3 col = brdfData.diffuse;//Desaturation( , _SubsurfaceSaturation);
    
    half3 brdf = 0;
    #ifdef _FOLIAGE
        half RemapNdotL = RemapFloatValue(-1, 1, _DiffuseMin,_DiffuseMax,min(NoL, lightAttenuation));
        #ifdef _SHRUB
            RemapNdotL = min(NdotL, lightAttenuation);
        #endif
        brdf += lerp(_ColorDark  , _ColorBright , pow(RemapNdotL, _DiffusePow)) * brdfData.diffuse * lightColor  *_DirectBright  ;//brdfData.diffuse * radiance  ;
    
        float NoV = smoothstep(_FresnelPow, _FresnelPow + _FresnelSmooth , 1.0 - saturate(dot(normalWS , viewDirectionWS)));
        float3 NoVColor = NoV * _FresnelColor.rgb;

        brdf += NoVColor;
    
        float3 backLitDir = (normalWS * _BackSubsurfaceDistortion + lightDirectionWS);
        float backSSS = saturate(dot(viewDirectionWS , - backLitDir));
        backSSS = saturate(pow( backSSS, _SSSPower ) );
        
        float3 SSS = backSSS  * col  * lightAttenuation * lightColor;

        brdf += SSS;

        NdotL = RemapNdotL;
    #else

        
      //  half Ramp = RemapFloatValue(-1,1,_DiffuseMin ,_DiffuseMax , NoL );
       // half3 RampColor = lerp( _ColorDark,_ColorBright , Ramp);
       
        brdf += brdfData.diffuse  *lightColor  *NdotL *_DirectBright * lightAttenuation;
    
    
    #endif
    ///========================================================================================================
    
    half3 radiance = lightColor * lightAttenuation * NdotL;
      brdf += brdfData.specular * DirectBRDFSpecular(brdfData, normalWS, lightDirectionWS, viewDirectionWS) *radiance;
   // brdf += brdfData.specular * US_DefaultLitBxDFSpecular(brdfData, normalWS, lightDirectionWS, viewDirectionWS)  *radiance;

    half Wrap = 0.5;
    half WrapNoL = saturate(-dot(normalWS , lightDirectionWS ) / Pow2(1 + Wrap));
    half VoL = dot(viewDirectionWS ,lightDirectionWS);
    float Scatter = US_D_GGX(0.6*0.6 , saturate(-VoL));
    float3 Tranmission = Scatter *col * _SubsurfaceColor.rgb * _SubsurfaceSaturation * WrapNoL *lightColor * lightAttenuation ;

    brdf += Tranmission;
 
    return brdf;
}