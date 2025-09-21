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

// Credit to https://www.ronja-tutorials.com/post/024-white-noise/
float random3x1(vec3 pos, vec3 seedVector) {
    vec3 smallValue = sin(pos);
    float value = dot(smallValue, seedVector);
    value = fract(sin(value) * 143758.5453);
    // Remap from [-1, 1] to [0, 1]
    value = (value + 1.f)/2.f;
    return value;
}

vec3 random3x3(vec3 pos){
    return vec3(
        random3x1(pos, vec3(12.989, 78.233, 37.719)),
        random3x1(pos, vec3(39.346, 11.135, 83.155)),
        random3x1(pos, vec3(73.156, 52.235, 09.151))
    );
}

float noise(vec3 pos, float scale) {
    vec3 scaledPos = pos/scale;
    vec3 originalCell = floor(scaledPos);

    float minDistance = 100.f;
    for(int dx = -1; dx < 2; dx++) {
        for(int dy = -1; dy < 2; dy++) {
            for(int dz = -1; dz < 2; dz++) {
                vec3 dCell = vec3(float(dx), float(dy), float(dz));
                vec3 currentCell = originalCell + dCell;

                vec3 currentCellVoronoiCenter = currentCell + random3x3(currentCell);
                minDistance = min(minDistance, distance(currentCellVoronoiCenter, scaledPos));
            }
        }
    }

    return minDistance;
}

float noiseFBM(vec3 pos, float initialScale, float persistence, float lacunarity, int levels, vec3 displacementDirection, float )
{
    float noiseValue = 0.f;
    float amplitude = 1.f;
    float scale = initialScale;

    for(int i = 0; i<levels; i++){
        vec3 shiftedPosition = pos + displacementDirection * u_Time * 0.005 * float(i + 1);
        noiseValue += amplitude * noise(shiftedPosition, scale);
        scale *= lacunarity;
        amplitude *= persistence;
    }

    noiseValue = smoothstep(0.f, 1.f, 1.f - noiseValue);
    return noiseValue;
}

vec3 displaceVertex(vec3 inVertex, vec3 inNormal)
{
    float amplitude = 1.f + 0.1 * sin(u_Time * 0.05);

    vec3 outVertex = inVertex;

    outVertex.y += (3.f + amplitude) * cos(inVertex.x * 0.5) * cos(inVertex.y * 0.5);

    outVertex.x -= 0.5 * (inVertex.y + 1.f);
    //vec3 noiseShift = vec3(0.f, -1.f, 0.5f) * u_Time * 0.01;
    float noiseMultiplier = 1.f;
    float noiseValue = noiseMultiplier * (noiseFBM(inVertex, 2.f, 0.25f, 0.5f, 2, vec3(0.f, -1.f, 0.5f)) - 0.5f);
    outVertex += inNormal * noiseValue;

    return outVertex;
}

void main()
{
    mat3 invTranspose = mat3(u_ModelInvTr);
    fs_Nor = vec4(invTranspose * vec3(vs_Nor), 0);

    fs_Pos = u_Model * vec4(displaceVertex(vs_Pos.xyz, vs_Nor.xyz), vs_Pos.w);

    gl_Position = u_ViewProj * fs_Pos;
}
