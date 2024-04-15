#ifndef ZHOUSHUURP_KAJIYA
#define ZHOUSHUURP_KAJIYA


    half4 _ShiftMap_ST;
    half4 _SpecularTint;
    half _SpecularMultiplyer;
    half _Smoothness;
    half _Shift;
    half4 _SecondarySpecularTint;
    half _SecondarySpecularMultiplyer;
    half _SecondarySmoothness;
    half _SecondaryShift;


    TEXTURE2D(_ShiftMap);                                   SAMPLER(sampler_ShiftMap);
#endif