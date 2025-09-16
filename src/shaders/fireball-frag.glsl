#version 300 es

precision highp float;

uniform vec4 u_Color;

uniform float u_Time;

in vec4 fs_Nor;

out vec4 out_Col; // This is the final output color that you will see on your
                  // screen for the pixel that is currently being processed.

float ease(float time, float start, float end, float duration)
{
    if(time < 0.f){
        return start;
    }
    if(time > duration){
        return end;
    }
    return end * (time / duration) + start;
}

float inQuadratic(float time){
    return time * time;
}

float outQuadratic(float time)
{
    return 1.f - inQuadratic(1.f - time);
}

float inOutQuadratic(float time)
{
    if(time < 0.5){
        return inQuadratic(time * 2.f) / 2.f;
    }
    return 1.f - inQuadratic((1.f - time) * 2.f)/2.f;
}

float bias(float b, float time)
{
    if(time < 0.f)
    {
        return 0.f;
    }
    if(time > 1.f)
    {
        return 1.f;
    }
    return pow(time, log(b) / log(0.5f));
}

float gain(float g, float time)
{
    if(time < 0.5f)
    {
        return bias(1.f - g, 2.f * time) / 2.f;
    }
    return 1.f - bias(1.f - g, 2.f - 2.f * time) / 2.f;
}

float squareWave(float x)
{
    return fabs(floor(mod(x, 2.f));
}

float sawtoothWave(float x)
{
    return x - floor(x);
}

float triangleWave(float x)
{
    return 2.f * abs(x - floor(x + 0.5));
}

void main()
{
    out_Col = vec4(abs(fs_Nor.xyz), 1.f);
}