#version 330 core
layout(location = 0) in vec3 vertexPosition;
layout(location = 1) in vec3 vertexNormal;

uniform mat4 mvp; // Model-View-Projection from light

void main()
{
    gl_Position = mvp * vec4(vertexPosition, 1.0);
}
