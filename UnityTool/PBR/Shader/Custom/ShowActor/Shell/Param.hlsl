#ifndef FUR_SHELL_PARAM_HLSL
#define FUR_SHELL_PARAM_HLSL

int _ShellLayers;
float _ShellLayerDistance;
float _AlphaCutout;
float _Occ;
float _FurScale;
float4 _FurBaseMove;
float4 _FurWindFreq;
float4 _FurWindMove;
float3 _AmbientColor;
float _FaceViewProdThresh;

half _Furmask_R_Scale;half _Furmask_G_Scale;half _Furmask_B_Scale;half _Furmask_R_Height;half _Furmask_G_Height;half _Furmask_B_Height;

TEXTURE2D(_FurTerture); 
SAMPLER(sampler_FurTerture);
float4 _FurTerture_ST;

TEXTURE2D(_Normal); 
SAMPLER(sampler_Normal);
float4 _Normal_ST;
float _NormalScale;

TEXTURE2D(_Furmask);            
SAMPLER(sampler_Furmask);
float4 _Furmask_ST;


#endif