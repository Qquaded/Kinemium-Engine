// outline.fs
#version 330

in vec2 fragTexCoord;
out vec4 finalColor;

uniform sampler2D texture0;   // the texture
uniform vec2 resolution;      // texture size in pixels
uniform float thickness;      // outline thickness in pixels
uniform vec4 outlineColor;    // RGBA outline color

void main()
{
    vec4 color = texture(texture0, fragTexCoord);

    if (color.a > 0.01) {
        finalColor = color;
        return;
    }

    vec2 uv = fragTexCoord * resolution;

    bool nearOpaque = false;
    for (int y = -int(thickness); y <= int(thickness); y++) {
        for (int x = -int(thickness); x <= int(thickness); x++) {
            vec2 offset = uv + vec2(x, y);
            vec2 texUV = offset / resolution;

            texUV = clamp(texUV, vec2(0.0, 0.0), vec2(1.0, 1.0));

            vec4 sample = texture(texture0, texUV);
            if (sample.a > 0.01) {
                nearOpaque = true;
            }
        }
    }

    if (nearOpaque) {
        finalColor = outlineColor; // draw outline
    } else {
        finalColor = vec4(0.0, 0.0, 0.0, 0.0); // transparent
    }
}