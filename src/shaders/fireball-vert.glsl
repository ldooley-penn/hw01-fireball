#version 300 es

uniform mat4 u_Model;
uniform mat4 u_ModelInvTr;
uniform mat4 u_ViewProj;
uniform float u_Time;

in vec4 vs_Pos;
in vec4 vs_Nor;

out vec4 fs_Pos;
out vec4 fs_Nor;
out vec4 fs_Col;

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
    return abs(floor(mod(x, 2.f)));
}

float sawtoothWave(float x)
{
    return x - floor(x);
}

float triangleWave(float x)
{
    return 2.f * abs(x - floor(x + 0.5));
}

vec3 displaceVertex(vec3 inVertex)
{
    float amplitude = 1.f + 0.1 * sin(u_Time * 0.05);

    inVertex.y += (3.f + amplitude) * cos(inVertex.x * 0.5) * cos(inVertex.y * 0.5);

    //float earXOffset = ease(abs(inVertex.y), 0.f, 1.f, 1.f);

    inVertex.x -= 0.5 * (inVertex.y + 1.f);

    return inVertex;
}

void main()
{
    mat3 invTranspose = mat3(u_ModelInvTr);
    fs_Nor = vec4(invTranspose * vec3(vs_Nor), 0);

    fs_Pos = u_Model * vec4(displaceVertex(vs_Pos.xyz), vs_Pos.w);

    gl_Position = u_ViewProj * fs_Pos;
}
