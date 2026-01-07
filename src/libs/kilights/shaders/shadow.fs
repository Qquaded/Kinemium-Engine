#version 330 core
in vec4 fragPosLightSpace;
out vec4 fragColor;

uniform sampler2D shadowMap;
uniform vec3 objectColor;
uniform vec3 lightColor;

float ShadowCalculation(vec4 fragPosLight)
{
    // Perform perspective divide
    vec3 projCoords = fragPosLight.xyz / fragPosLight.w;
    projCoords = projCoords * 0.5 + 0.5; // map to [0,1]

    // Get closest depth from shadow map
    float closestDepth = texture(shadowMap, projCoords.xy).r;

    // Current fragment depth
    float currentDepth = projCoords.z;

    // Shadow factor (1 = lit, 0 = in shadow)
    float shadow = currentDepth - 0.005 > closestDepth ? 0.3 : 1.0; // 0.005 = bias to avoid acne

    return shadow;
}

void main()
{
    float shadow = ShadowCalculation(fragPosLightSpace);
    vec3 color = objectColor * lightColor * shadow;
    fragColor = vec4(color, 1.0);
}
