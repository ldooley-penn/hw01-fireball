#version 300 es

precision highp float;

uniform vec4 u_Color;

uniform float u_Time;

in vec4 fs_Nor;

out vec4 out_Col; // This is the final output color that you will see on your
                  // screen for the pixel that is currently being processed.

void main()
{
    out_Col = vec4(abs(fs_Nor.xyz), 1.f);
}