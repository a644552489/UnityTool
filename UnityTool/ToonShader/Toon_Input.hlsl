#ifndef TOON_INPUT
#define TOON_INPUT
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
     

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"
CBUFFER_START(UnityPerMaterial) 
        

     float _ToonSteps;
float _EnableFace;
float4 _BaseMap_ST;
float4 _BaseColor;

half _BumpItensity;
half _ShadowSmooth;
half _ShadowArea;

float _SkinDetailShadowMax;
float _SkinDetailShadowMin;

  
float4 _LightMap_ST;
   
float _RampThreshold;
float _RampChange;
half _ShapeShadowSmooth;
half  _ShapeShadowPow;

float _ShadowStrength;

uniform float4 _ShadowMultColor; //阴影颜色

uniform float4 _DarkShadowMultColor; //暗阴影颜色


        
float _EnableRim;
half4 _RimColor;
float _RimSmooth;
float _RimPow;

float _EnableSpecular;
float4 _SpecColor;

float _SpecMulti;
float _SpecSub;
float _MetalIntensity;

float _SelfShadowDensity;
      
//  half3 _EmissionColor;

      

uniform float4 _outlinecolor;
uniform float _outlinewidth;
        
float _BRDFDespity;

      
    
half _GIIndirDiffuse;
float _HairShadowDistace;

float _ReciveShadow;

float _Metalic;
float _Smooth;
float _Occlusion;

CBUFFER_END

TEXTURE2D(_MetalMap);
SAMPLER(sampler_MetalMap);
TEXTURE2D(_CameraDepthTexture);
SAMPLER(sampler_CameraDepthTexture);

TEXTURE2D(_ToonBRDFMap);
SAMPLER(sampler_ToonBRDFMap);


float2x2 RotMatrix(float axis)
{
    float s = sin(axis);
    float c = cos(axis);

    return float2x2(
        c , -s,
        s , c);
}

float2 MetalUV(float3 normalOS )
{
    
    float x = dot(normalize(UNITY_MATRIX_IT_MV[0].xyz) , normalize(normalOS));
    float y = dot(normalize(UNITY_MATRIX_IT_MV[1].xyz) , normalize(normalOS));
    float2 xy = mul(half2(x,y) , RotMatrix(_SpecSub));
    float2 uv =xy * 0.495+0.5;
    return uv;
}

float2 MetalUV(float3 normalOS ,float3 lightDir)
{

    float3 lightY = float3(0,0,1);
    float3 lightZ = cross(lightDir , lightY);
    lightY = cross(lightDir , lightZ);

    float3x3 lightpos= float3x3(lightDir ,lightY , lightZ);
    float x = dot(normalize(lightpos[0].xyz) , normalize(normalOS));
    float y = dot(normalize(lightpos[1].xyz) , normalize(normalOS));
    float2 xy = mul(half2(x,y) , RotMatrix(_SpecSub));
    float2 uv =xy * 0.495+0.5;
    return uv;
}

half CalculateRamp(half ndlWrapped)
{
    half bright = _ShapeShadowPow + ndlWrapped;
    half midDark = _ShapeShadowPow- ndlWrapped; //_ShapeShadowSmooth
                    
    half diff = smoothstep(midDark, bright, ndlWrapped);
    float step = floor(diff * _ToonSteps)/_ToonSteps;

    float interval = 1/ _ToonSteps;
    float level = round(diff  * _ToonSteps) / _ToonSteps;
   
    float ramp = interval * smoothstep(level - _ShapeShadowSmooth   ,
    level + _ShapeShadowSmooth  ,diff)+ level -interval;
    
    
    ramp = max(0 ,ramp);
    return ramp;
}

float ThreeRamp(float lambert)
{
    float base_1stShadow =saturate(1.0 - (lambert - (_ShapeShadowPow - _ShapeShadowSmooth)) / _ShapeShadowSmooth);
    float _1st_2ndShadow = saturate(1.0 - (lambert - (_SkinDetailShadowMin - _SkinDetailShadowMax)) / _SkinDetailShadowMax);
    float Ramp =lerp(lerp(1,0.25,_1st_2ndShadow), 0.05 ,base_1stShadow);
    return Ramp;
}

half EnvironmentBRDFSpecular(half roughness2, half fresnelTerm ,half grazingTerm )
{
    float surfaceReduction = 1.0 / (roughness2 + 1.0);
    return half(surfaceReduction * lerp(1.0, grazingTerm, fresnelTerm));
}
half DirectBRDFSpecular_Custom(float roughness2MinusOne , float roughness2 ,float normalizationTerm,float3 lightDirectionWS ,
    float3 viewDirectionWS , float3 normalWS)
{
    float3 lightDirectionWSFloat3 = float3(lightDirectionWS);
    float3 halfDir = SafeNormalize(lightDirectionWSFloat3 + float3(viewDirectionWS));

    float NoH = saturate(dot(float3(normalWS), halfDir));
    half LoH = half(saturate(dot(lightDirectionWSFloat3, halfDir)));

    // GGX Distribution multiplied by combined approximation of Visibility and Fresnel
    // BRDFspec = (D * V * F) / 4.0
    // D = roughness^2 / ( NoH^2 * (roughness^2 - 1) + 1 )^2
    // V * F = 1.0 / ( LoH^2 * (roughness + 0.5) )
    // See "Optimizing PBR for Mobile" from Siggraph 2015 moving mobile graphics course
    // https://community.arm.com/events/1155

    // Final BRDFspec = roughness^2 / ( NoH^2 * (roughness^2 - 1) + 1 )^2 * (LoH^2 * (roughness + 0.5) * 4.0)
    // We further optimize a few light invariant terms
    // brdfData.normalizationTerm = (roughness + 0.5) * 4.0 rewritten as roughness * 4.0 + 2.0 to a fit a MAD.
    float d = NoH * NoH * roughness2MinusOne + 1.00001f;

    half LoH2 = LoH * LoH;
    half specularTerm = roughness2 / ((d * d) * max(0.1h, LoH2) * normalizationTerm);

    // On platforms where half actually means something, the denominator has a risk of overflow
    // clamp below was added specifically to "fix" that, but dx compiler (we convert bytecode to metal/gles)
    // sees that specularTerm have only non-negative terms, so it skips max(0,..) in clamp (leaving only min(100,...))
    #if REAL_IS_HALF
    
    specularTerm = specularTerm - HALF_MIN;
    // Update: Conservative bump from 100.0 to 1000.0 to better match the full float specular look.
    // Roughly 65504.0 / 32*2 == 1023.5,
    // or HALF_MAX / ((mobile) MAX_VISIBLE_LIGHTS * 2),
    // to reserve half of the per light range for specular and half for diffuse + indirect + emissive.
    specularTerm = clamp(specularTerm, 0.0, 1000.0); // Prevent FP16 overflow on mobiles
    #endif

    return specularTerm;
}

float RemapFloatValue(float oldLow, float oldHigh, float newLow, float newHigh, float invalue)
{
    return newLow + (invalue - oldLow) * (newHigh - newLow) / (oldHigh - oldLow);
}


#endif