#version 330

in vec2 fragTexCoord;
in vec4 fragColor;
out vec4 finalColor;

uniform sampler2D texture0;

uniform vec2  viewAngle;     // tilt in X and Y, range roughly -1.0 to 1.0
uniform float depthScale;    // parallax displacement strength (e.g. 0.06)
uniform int   layerCount;    // number of depth layers (e.g. 8)
uniform float depthFalloff;  // how quickly deeper layers dim (e.g. 1.5)

void main() {
    vec2 uv = fragTexCoord;
    vec2 parallaxDir = viewAngle * depthScale;

    vec4  color  = vec4(0.0);
    float totalW = 0.0;

    int count = clamp(layerCount, 1, 16);

    for (int i = 0; i < 16; i++) {
        if (i >= count) break;

        float t      = float(i) / float(count);
        vec2 layerUV = clamp(uv - parallaxDir * t, 0.0, 1.0);
        float weight = exp(-depthFalloff * t);

        color  += texture(texture0, layerUV) * weight;
        totalW += weight;
    }

    finalColor = (color / totalW) * fragColor;
}