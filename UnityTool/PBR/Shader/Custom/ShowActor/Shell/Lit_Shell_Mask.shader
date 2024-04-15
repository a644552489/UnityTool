Shader "SLG_Custom/ShowActor/Shell_Mask"
{

Properties
{
    [Header(Basic)][Space]
    [MainColor] [HDR]_BaseColor("Color", Color) = (0.5, 0.5, 0.5, 1)
    [HDR]_AmbientColor("Ambient Color", Color) = (0.0, 0.0, 0.0, 1)
    _BaseMap("Albedo", 2D) = "white" {}
    

   
   
    [Header(FurFurmask)][Space]

    [NoScaleOffset]_Furmask("Furmask",2D) = "white" {}

    _Furmask_R_Scale("Furmask_R_Scale", Range(0.0, 3.0)) = 1.0
    _Furmask_R_Height("Furmask_R_Height", Range(0.0, 2.0)) = 1.0

    _Furmask_G_Scale("Furmask_G_Scale", Range(0.0, 3.0)) = 1.0
    _Furmask_G_Height("Furmask_G_Height", Range(0.0, 2.0)) = 1.0

    _Furmask_B_Scale("Furmask_B_Scale", Range(0.0, 3.0)) = 1.0
    _Furmask_B_Height("Furmask_B_Height", Range(0.0, 2.0)) = 1.0


    [Header(Fur)][Space]
    [Gamma] _Metallic("Metallic", Range(0.0, 1.0)) = 0.5
    _Smoothness("Smoothness", Range(0.0, 1.0)) = 0.5
    //_Occ("Occlusion", Range(0.0, 1.0)) = 0.5
    _FurTerture("Fur", 2D) = "white" {}



    [Normal] _Normal("Normal", 2D) = "bump" {}
    _NormalScale("Normal Scale", Range(0.0, 2.0)) = 1.0
    [IntRange] _ShellLayers("Shell Amount", Range(1, 25)) = 14
    _ShellLayerDistance("Shell Step", Range(0.0, 0.01)) = 0.001
    _AlphaCutout("Alpha Cutout", Range(0.0, 1.0)) = 0.2
    _FurScale("Fur Scale", Range(0.0, 50.0)) = 1.0
    _Occ("Occlusion", Range(0.0, 1.0)) = 0.5
    


     [Header(FurWind)][Space]
    _FurBaseMove("Base Move", Vector) = (0.0, -0.0, 0.0, 3.0)
    _FurWindFreq("Wind Freq", Vector) = (0.5, 0.7, 0.9, 1.0)
    _FurWindMove("Wind Move", Vector) = (0.2, 0.3, 0.2, 1.0)

    [Header(Lighting)][Space]
    _RimLightPower("Rim Light Power", Range(1.0, 20.0)) = 6.0
    _RimLightIntensity("Rim Light Intensity", Range(0.0, 1.0)) = 0.5
    _ShadowExtraBias("Shadow Extra Bias", Range(-1.0, 1.0)) = 0.0
}

SubShader
{
    Tags 
    { 
        "RenderType" = "Opaque" 
        "RenderPipeline" = "UniversalPipeline" 
        "UniversalMaterialType" = "Lit"
        "IgnoreProjector" = "True"
    }

    LOD 100

    ZWrite On
    Cull Back

    Pass
    {
        Name "ForwardLit"
        Tags { "LightMode" = "UniversalForward" }

        HLSLPROGRAM
        
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
        #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
        #pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
        #pragma multi_compile _ _SHADOWS_SOFT
        #pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE

    
        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
        #pragma multi_compile _ LIGHTMAP_ON
        #pragma multi_compile_fog


        #pragma target 4.0
        #pragma vertex vert
        #pragma require geometry
        #pragma geometry geom 
        #pragma fragment frag
        // #include "./Lit.hlsl"
         #include "./Lit_Shell_Mask.hlsl"
        ENDHLSL
    }


    Pass
    {
        Name "ShadowCaster"
        Tags { "LightMode" = "ShadowCaster" }

        ZWrite On
        ZTest LEqual
        ColorMask 0

        HLSLPROGRAM
        #pragma exclude_renderers gles gles3 glcore
        #pragma vertex vert
        #pragma require geometry
        #pragma geometry geom 
        #pragma fragment frag
        #include "./Shadow.hlsl"
        ENDHLSL
    }



}

}
