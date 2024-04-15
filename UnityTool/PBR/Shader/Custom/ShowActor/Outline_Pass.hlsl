

struct VertexInput
{
    float4 positionOS : POSITION;
    float3 normalOS : NORMAL;
 
    float2 texcoord : TEXCOORD0; // UV信息 Get✔
    float4 color :COLOR0;
};

struct VertexOutput
{
    float4 positionCS : SV_POSITION;
    float2 uv : TEXCOORD0; // UV0
    float3 normalWS:TEXCOORD1;
};


VertexOutput vert(VertexInput input)
{
    float4 positionOS = input.positionOS;
    VertexOutput output = (VertexOutput)0;
    VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
    VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS.rgb);// 没得用的


    output.uv = input.texcoord;
    half3 worldNormal = normalInput.normalWS;// 没得用的
    // 计算描边相关参数
    half lineColorOffset = 0.8;
        
    //_OutLineScale = 0.4;
    //_OutlineBaseThickness = 1.1;

    //_OutlineBaseThickness *= 0.03;// 历史问题,很坑

      
    half4 clipPos = TransformObjectToHClip(input.positionOS.xyz);// 屏幕描边测试
    // _OutLineScale = 0.4;
    // _OutlineBaseThickness = 0.7;
    // _OutlineBaseThickness *= 0.03;// 歷史問題
    // _OutlineBaseThickness *= _OutlineBaseThicknessMul;// 修行脚本临时解决
        
    // float rectify = 0.24 * max(TransformObjectToHClip(input.positionOS.xyz).w*_OutLineScale,0.5);

    // _OutlineBaseThickness = min(rectify * _OutlineBaseThickness,_OutlineBaseThickness);//0.01;
    // input.positionOS.xyz += input.normalOS * input.color.g  * _OutlineBaseThickness;//* depth;
    // output.positionCS = TransformObjectToHClip(input.positionOS.xyz);
    // outlineExpand = min(outlineExpand,0.8);
    // input.positionOS.xyz = input.positionOS.xyz + CalcOutlineOffset(input.normalOS.xyz, input.color,vertexInput.positionCS.w);
    // output.positionCS = TransformObjectToHClip(input.positionOS.xyz);

    // 屏幕描边测试
    output.normalWS = normalInput.normalWS;
    half3 normalVS = TransformWorldToViewDir(normalInput.normalWS, true);
    float2 outlineDir = normalize(normalVS.xy);
    outlineDir *= float2(1,-1);
    outlineDir.y *= (_ScreenParams.x/_ScreenParams.y);
            
    clipPos.xy += outlineDir * _OutLineScale  * input.color.g * lerp(clipPos.w,1,_ScreenOutlineDeW);
    output.positionCS = lerp(output.positionCS,clipPos,_ScreenOutlineOn);
    return output;
}

float4 frag(VertexOutput input ):SV_TARGET
{
 
float4 adobleColor= SAMPLE_TEXTURE2D(_BaseMap , sampler_BaseMap ,input.uv);
   float4 final = adobleColor * _OutlineColor ;
  return final;


}

