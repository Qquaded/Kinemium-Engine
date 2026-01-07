#version 330 core
out float fragDepth;

void main()
{
    // gl_FragCoord.z is depth in [0,1] after projection
    fragDepth = gl_FragCoord.z;
}
