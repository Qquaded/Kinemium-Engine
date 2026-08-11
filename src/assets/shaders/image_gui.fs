#version 330

in vec2 fragTexCoord;
in vec4 fragColor;
out vec4 finalColor;

uniform sampler2D texture0;    // the image texture

// Background fill
uniform vec4  bgColor;         // background color (r,g,b,a) 0..1
uniform float bgTransparency;  // 0 = fully visible, 1 = invisible

// UIStroke
uniform vec4  strokeColor;     // stroke color (r,g,b,a) 0..1
uniform float strokeThickness; // stroke thickness in UV space (0 = disabled)

// Corner rounding (UV space, 0 = no rounding)
uniform float cornerRadius;    // uniform corner radius in UV space

// Scale parameters
uniform int scaleType;         // 0: Stretch, 1: Slice
uniform vec2 elemSize;         // UI element dimensions
uniform vec2 texSize;          // Texture dimensions
uniform vec4 sliceCenter;      // x: minX, y: minY, z: maxX, w: maxY
uniform float sliceScale;      // scale multiplier for slice edges

// ------------------------------------------------------------------
// SDF helpers
// ------------------------------------------------------------------

// Signed distance to a rounded box centered at origin, half-size b, corner r
float sdRoundBox(vec2 p, vec2 b, float r) {
    r = min(r, min(b.x, b.y));
    vec2 q = abs(p) - b + vec2(r);
    return length(max(q, 0.0)) + min(max(q.x, q.y), 0.0) - r;
}

void main() {
    vec2 uv = fragTexCoord;
    vec2 txCoords = uv;

    if (scaleType == 1) { // Slice
        float marginLeft = sliceCenter.x;
        float marginTop = sliceCenter.y;
        float marginRight = max(texSize.x - sliceCenter.z, 0.0);
        float marginBottom = max(texSize.y - sliceCenter.w, 0.0);

        float screenMarginLeft = marginLeft * sliceScale;
        float screenMarginTop = marginTop * sliceScale;
        float screenMarginRight = marginRight * sliceScale;
        float screenMarginBottom = marginBottom * sliceScale;

        vec2 px = uv * elemSize;

        // X coordinate mapping
        if (px.x < screenMarginLeft) {
            txCoords.x = px.x / max(sliceScale, 0.001);
        } else if (px.x > elemSize.x - screenMarginRight) {
            txCoords.x = texSize.x - (elemSize.x - px.x) / max(sliceScale, 0.001);
        } else {
            float middleScreenW = max(elemSize.x - screenMarginLeft - screenMarginRight, 0.001);
            float middleTexW = max(texSize.x - marginLeft - marginRight, 0.001);
            txCoords.x = marginLeft + (px.x - screenMarginLeft) * (middleTexW / middleScreenW);
        }

        // Y coordinate mapping
        if (px.y < screenMarginTop) {
            txCoords.y = px.y / max(sliceScale, 0.001);
        } else if (px.y > elemSize.y - screenMarginBottom) {
            txCoords.y = texSize.y - (elemSize.y - px.y) / max(sliceScale, 0.001);
        } else {
            float middleScreenH = max(elemSize.y - screenMarginTop - screenMarginBottom, 0.001);
            float middleTexH = max(texSize.y - marginTop - marginBottom, 0.001);
            txCoords.y = marginTop + (px.y - screenMarginTop) * (middleTexH / middleScreenH);
        }

        txCoords.x /= max(texSize.x, 0.001);
        txCoords.y /= max(texSize.y, 0.001);
    }

    // Sample the image and apply fragColor (contains ImageColor and ImageTransparency)
    vec4 imgSample = texture(texture0, txCoords) * fragColor;

    // ---- Background colour (mixed behind the image) ----
    float bgAlpha = clamp(1.0 - bgTransparency, 0.0, 1.0);

    // Composite using straight alpha over operator
    float outA = imgSample.a + bgAlpha * (1.0 - imgSample.a);
    vec3 outRGB = vec3(0.0);
    if (outA > 0.0) {
        outRGB = (imgSample.rgb * imgSample.a + bgColor.rgb * bgAlpha * (1.0 - imgSample.a)) / outA;
    }
    vec4 composed = vec4(outRGB, outA);

    // ---- UIStroke ----
    if (strokeThickness > 0.0) {
        // Convert uv to a -0.5..0.5 space centred at the rect
        vec2 p = uv - 0.5;
        vec2 halfSize = vec2(0.5);

        float distOuter = sdRoundBox(p, halfSize, cornerRadius);
        float distInner = sdRoundBox(p, halfSize - vec2(strokeThickness), cornerRadius - strokeThickness);

        // Inside the stroke band: distOuter <= 0 and distInner >= 0
        bool inStroke = (distOuter <= 0.0) && (distInner >= 0.0);

        if (inStroke) {
            // Soft anti-aliased blend using fwidth
            float aaouter = 1.0 - smoothstep(-1.0, 0.0, distOuter);
            float aainner = smoothstep(-1.0, 0.0, distInner);
            float bandAlpha = aaouter * aainner;
            composed = mix(composed, strokeColor, strokeColor.a * bandAlpha);
        }
    }

    // ---- Corner rounding clip ----
    if (cornerRadius > 0.0) {
        vec2 p = uv - 0.5;
        float dist = sdRoundBox(p, vec2(0.5), cornerRadius);
        // Anti-aliased clip: smoothly discard outside the rounded box
        float alpha = 1.0 - smoothstep(-0.005, 0.005, dist);
        composed.a *= alpha;
    }

    finalColor = composed;
}
