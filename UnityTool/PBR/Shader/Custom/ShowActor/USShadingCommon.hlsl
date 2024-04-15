
float RemapFloatValue(float oldLow, float oldHigh, float newLow, float newHigh, float invalue)
{
    return newLow + (invalue - oldLow) * (newHigh - newLow) / (oldHigh - oldLow);
}

float3 RemapFloat3Value(float oldLow, float oldHigh, float newLow, float newHigh, float3 invalue)
{
    float3 Ret = 0.0f;
    Ret.r = RemapFloatValue(oldLow, oldHigh, newLow, newHigh, invalue.r);
    Ret.g = RemapFloatValue(oldLow, oldHigh, newLow, newHigh, invalue.g);
    Ret.b = RemapFloatValue(oldLow, oldHigh, newLow, newHigh, invalue.b);
    return Ret;
}