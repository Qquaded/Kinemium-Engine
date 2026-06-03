#version 330
in vec2 fragTexCoord;
out vec4 finalColor;

uniform sampler2D texture0;
uniform float radius; // in UV space, e.g. 0.05

void main() {
    vec2 uv = fragTexCoord;
    vec4 color = texture(texture0, uv);

    vec2 corner = min(uv, 1.0 - uv); // distance to nearest edge in each axis

    if (corner.x < radius && corner.y < radius) {
        vec2 d = vec2(radius) - corner;
        if (length(d) > radius) color.a = 0.0;
    }

    finalColor = color;
}