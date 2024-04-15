#ifndef FUR_PASS_INCLUDED
#define FUR_PASS_INCLUDED

struct Attributes
{
    float4 positionOS : POSITION;
    float3 color : COLOR;
    float2 uv : TEXCOORD0;
    float2 uv1 : TEXCOORD1;
    half2 lightmapUV : TEXCOORD2;
    float4 tangent : TANGENT;
    float3 normal : NORMAL;
            UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct Varyings
{
    float4 positionHCS : SV_POSITION;
    float4 uv : TEXCOORD0;
    float3 posWS : TEXCOORD1;

    float4 tangentWS : TEXCOORD3; 
    float3 color : TEXCOORD4; 
    half4 ambientOrLightmapUV : TEXCOORD5;
    float3 normalWS : TEXCOORD6;
    float4 shadowCoord : TEXCOORD7;
    DECLARE_LIGHTMAP_OR_SH(lightmapUV_Morning, vertexSH, 8); //lightmapUVOrVertexSH : TEXCOORD8;
    float4 lightmapUV_Evening: TEXCOORD2;
    float3 viewWS : TEXCOORD9;
    half4 fogFactorAndVertexLight : TEXCOORD10;
    float4 lightAdd : TEXCOORD12;
            UNITY_VERTEX_INPUT_INSTANCE_ID
        UNITY_VERTEX_OUTPUT_STEREO
    //TODO
    //     UNITY_SHADOW_COORDS(6)
    //     UNITY_FOG_COORDS(7)
    // #else
    //     UNITY_LIGHTING_COORDS(6,7)
    //     UNITY_FOG_COORDS(8)

};

#include "FurInclude.hlsl"

Varyings vert(Attributes IN, half FUR_OFFSET = 0)
{
    Varyings OUT;
    OUT = (Varyings)0;
     UNITY_SETUP_INSTANCE_ID(IN);
        UNITY_TRANSFER_INSTANCE_ID(IN, OUT);
        UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(OUT);
    //顶点挤出
    //考虑重力方向和强度的顶点位移矢量
    half3 direction = lerp(IN.normal, _Gravity * _GravityStrength + IN.normal * (1 - _GravityStrength), _FUR_OFFSET) * IN.color;
    #ifndef _QUALITY_LOW
        IN.positionOS.xyz += direction * _FurLength * _FUR_OFFSET *0.1;
    #endif
    OUT.color = IN.color;
    OUT.posWS = TransformObjectToWorld(IN.positionOS.xyz);
    float3 positionWS = TransformObjectToWorld(IN.positionOS.xyz);
    float4 positionCS = TransformWorldToHClip(positionWS);

    
    OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
    OUT.uv.xy = TRANSFORM_TEX(IN.uv, _MainTex);
    OUT.uv.zw = IN.uv1;
    OUT.viewWS = normalize(_WorldSpaceCameraPos - OUT.posWS);
    VertexNormalInputs normalInput = GetVertexNormalInputs(IN.normal, IN.tangent);
    half3 vertexLight = VertexLighting(positionWS, normalInput.normalWS);
    half fogFactor = ComputeFogFactor(positionCS.z);
    OUT.fogFactorAndVertexLight = half4(fogFactor, vertexLight);

    half3 normalWS = TransformObjectToWorldNormal(IN.normal);
    OUT.normalWS = normalWS;

    real sign = IN.tangent.w * GetOddNegativeScale();
    OUT.tangentWS = half4(normalInput.tangentWS.xyz, sign);

    VertexPositionInputs vertexInput = (VertexPositionInputs)0;
    vertexInput.positionWS = positionWS;
    vertexInput.positionCS = positionCS;

        float4 Lightmap_Morning;
        float4 Lightmap_Evening;


             Lightmap_Morning = LightmapST_Morning;
             Lightmap_Evening = LightmapST_Evening;


        OUTPUT_LIGHTMAP_UV(IN.lightmapUV, Lightmap_Morning, OUT.lightmapUV_Morning);
        OUTPUT_LIGHTMAP_UV(IN.lightmapUV ,Lightmap_Evening , OUT.lightmapUV_Evening );
        OUTPUT_SH(OUT.normalWS.xyz, OUT.vertexSH);

    OUT.ambientOrLightmapUV = VertexGIForward(IN, OUT.posWS, normalWS);
    //TODO Fog
    //TODO Shadow
    OUT.shadowCoord = GetShadowCoord(vertexInput);
    OUT.shadowCoord = TransformWorldToShadowCoord(positionWS);

    OUT.lightAdd  = half4(0.0,0.0,0.0,0.0);
    #ifdef _ADDITIONAL_LIGHTS_MODE_VERTEX
        float3 T1 = MShiftTangent(OUT.tangentWS.xyz,OUT.normalWS,_SpecInfo.y * 0.1);
        float3 T2 = MShiftTangent(OUT.tangentWS.xyz,OUT.normalWS,_SpecInfo.w * 0.1);
        float spec1 = LightSpecular( OUT.posWS,T1,OUT.viewWS,OUT.normalWS,_SpecInfo.x * 16);
        float spec2 = LightSpecular( OUT.posWS,T2,OUT.viewWS,OUT.normalWS,_SpecInfo.z * 16);
        OUT.lightAdd.rgb = _SpecColor1.rgb * spec1 + _SpecColor2.rgb * spec2;
        OUT.lightAdd.a = EmpricialFresnel(OUT.viewWS,OUT.normalWS);
    #endif

    return OUT;
}

half4 frag(Varyings IN, half FUR_OFFSET = 0) : SV_Target
{
    UNITY_SETUP_INSTANCE_ID(IN);
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(IN);
    
    //flowMap 调整毛发走向
    float2 uvoffset = half2(0.0,0.0);
    #ifdef _FLOWMAP_USE
        #ifdef _UVSEC_UV1
        uvoffset = tex2D(_FlowMap, IN.uv.zw).rg * 2 - 1;
        #else
        uvoffset = tex2D(_FlowMap, IN.uv.xy).rg * 2 - 1;
        #endif
    #endif

    float2 newUV = IN.uv.xy + _UVOffset * uvoffset * _FUR_OFFSET / 60.0;

    SurfaceData surfaceData ;
    InitializeStandardLitSurfaceData(newUV, surfaceData);

    //InputData inputData;
    //inputData.positionWS = IN.posWS;
    //inputData.viewDirectionWS = IN.viewWS;
    //inputData.shadowCoord = IN.shadowCoord;
    //inputData.vertexLighting = IN.fogFactorAndVertexLight.yzw;
    //inputData.normalWS = IN.normalWS;
    //inputData.fogCoord = IN.fogFactorAndVertexLight.x;
    //inputData.bakedGI = 0.5;

    
 
    //#if defined(_NORMALMAP)
    //    float sgn = IN.tangentWS.w; 
    //    float3 bitangent = sgn * cross(IN.normalWS.xyz, IN.tangentWS.xyz);
    //    inputData.normalWS = TransformTangentToWorld(surfaceData.normalTS, half3x3(IN.tangentWS.xyz, bitangent.xyz, IN.normalWS.xyz));
    //#else
    //    inputData.normalWS = IN.normalWS;
    //#endif 

    //#ifdef _GI_ON
    //    inputData.bakedGI = SAMPLE_GI(IN.lightmapUVOrVertexSH.xy, IN.lightmapUVOrVertexSH.xyz, inputData.normalWS);
    //#endif    


       InputData inputData; 
        InitializeInputData(IN, surfaceData.normalTS, inputData);
  
    #ifdef _ADDITIONAL_LIGHTS_MODE_FRAG
    float3 T1 = MShiftTangent(IN.tangentWS.xyz,inputData.normalWS,_SpecInfo.y * 0.1);
    float3 T2 = MShiftTangent(IN.tangentWS.xyz,inputData.normalWS,_SpecInfo.w * 0.1);
    float spec1 = LightSpecular(inputData.positionWS,T1,inputData.viewDirectionWS,inputData.normalWS,_SpecInfo.x * 16);
    float spec2 = LightSpecular(inputData.positionWS,T2,inputData.viewDirectionWS,inputData.normalWS,_SpecInfo.z * 16);
    IN.lightAdd.rgb = _SpecColor1.rgb * spec1 + _SpecColor2.rgb * spec2;
    IN.lightAdd.a = EmpricialFresnel(inputData.viewDirectionWS,inputData.normalWS);
    #endif

    half3 fresnelCol = _FabricScatterColor * inputData.bakedGI * IN.lightAdd.a * _FabricScatterScale;




    half4 c = CustomActerPBR(inputData, surfaceData);
    
    c.rgb = MixFog(c.rgb, inputData.fogCoord);
    
    #ifndef _QUALITY_LOW
        //毛绒裁剪
        
        //uvOffset 调整毛发偏移
        half alpha = 1;
        #ifdef _UVSEC_UV1 
        alpha = tex2D(_LayerTex, TRANSFORM_TEX(IN.uv.zw, _LayerTex) + _UVOffset * uvoffset * _FUR_OFFSET).r;
        #else
        alpha = tex2D(_LayerTex, TRANSFORM_TEX(IN.uv.xy, _LayerTex) + _UVOffset * uvoffset * _FUR_OFFSET).r;
        #endif
        //_CutoffEnd 决定 毛发尾端粗细
        //alpha = step(lerp(0, _CutoffEnd, _FUR_OFFSET), alpha);
        //毛发裁剪
        //c.a = (alpha *2 -(_FUR_OFFSET * _FUR_OFFSET + _FUR_OFFSET));
        //c.a *=  (TODO)边缘剔除
        //生发mask
        //c.a = saturate(c.a) * surfaceData.alpha;

        //ao
        half3 tempCol = c.rgb;

        //c.rgb *= lerp(lerp(_ShadowColor.rgb, 1, _FUR_OFFSET), 1, _ShadowLerp);
        //c.rgb *= lerp(_ShadowColor.rgb, 1, _ShadowLerp *_FUR_OFFSET);
        c.rgb *= lerp(lerp(1, _ShadowColor.rgb, _ShadowLerp), 1,_FUR_OFFSET);
        // c.rgb += (fresnelCol+IN.lightAdd.rgb * alpha) * _FUR_OFFSET * _FUR_OFFSET *_AddLightScale;

        
        c.rgb = lerp(tempCol,c.rgb,IN.color);
    #endif
    //c.rgb = IN.color;
    c.rgb = saturate(c.rgb);
    return c;
}
Varyings vert_LayerBase(Attributes IN)
{
    return vert(IN, 0);
}
Varyings vert_Layer(Attributes IN)
{
    return vert(IN, .1);
}
half4 frag_LayerBase(Varyings IN) : SV_Target
{
    return frag(IN, .0);
}
half4 frag_Layer(Varyings IN) : SV_Target
{
    return frag(IN, .1);
}

struct AttributesDepth
{
    float4 positionOS : POSITION;
    float3 color : COLOR;
    float2 uv : TEXCOORD0;
    float2 uv1 : TEXCOORD1;
    float3 normal : NORMAL;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct VaryingsDepth
{
    float4 uv : TEXCOORD0;
    float4 positionCS : SV_POSITION;
    UNITY_VERTEX_INPUT_INSTANCE_ID
    UNITY_VERTEX_OUTPUT_STEREO
};


VaryingsDepth LitPassVertexDepth(AttributesDepth input)
{
    VaryingsDepth output = (VaryingsDepth)0;

    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_TRANSFER_INSTANCE_ID(input, output);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);
    
    //短绒毛
    half3 direction = lerp(input.normal, _Gravity * _GravityStrength + input.normal * (1 - _GravityStrength), _FUR_OFFSET) * input.color;
    input.positionOS.xyz += direction * _FurLength * _FUR_OFFSET *0.1;

    VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);

    output.uv.xy = TRANSFORM_TEX(input.uv, _MainTex);
    output.uv.zw = input.uv1;

    output.positionCS = vertexInput.positionCS;

    return output;
}

half4 LitPassFragmentDepth(VaryingsDepth input) : SV_Target
{
    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);


    float2 uvoffset = half2(0.0,0.0);
    #ifdef _FLOWMAP_USE
        #ifdef _UVSEC_UV1
        uvoffset = tex2D(_FlowMap, input.uv.zw).rg * 2 - 1;
        #else
        uvoffset = tex2D(_FlowMap, input.uv.xy).rg * 2 - 1;
        #endif
    #endif

    half alpha = 1;
    #ifdef _UVSEC_UV1 
    alpha = tex2D(_LayerTex, TRANSFORM_TEX(input.uv.zw, _LayerTex) + _UVOffset * uvoffset * _FUR_OFFSET).r;
    #else
    alpha = tex2D(_LayerTex, TRANSFORM_TEX(input.uv.xy, _LayerTex) + _UVOffset * uvoffset * _FUR_OFFSET).r;
    #endif
    //_CutoffEnd 决定 毛发尾端粗细
    half newOffset = lerp(0, _CutoffEnd, _FUR_OFFSET);
    //毛发裁剪
    //half alpha = alpha  - newOffset;
    alpha = (alpha *2 -(newOffset * newOffset + newOffset));
    //c.a *=  (TODO)边缘剔除
    //生发mask
    //c.a = saturate(c.a) * surfaceData.alpha;

    // AlphaDiscard(alpha, _Cutoff);
    clip(alpha);

    // half3 color = tex2D(_MainTex, input.uv.xy).rgb;
    // return half4(color, alpha);

    return half4(1,0,0, alpha);
}

#endif