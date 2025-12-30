#version 330

// Input vertex attributes (from vertex shader)
in vec3 fragPosition;
in vec2 fragTexCoord;
in vec4 fragColor;
in vec3 fragNormal;

// Input uniform values
uniform sampler2D texture0;
uniform vec4 colDiffuse;

// Output fragment color
out vec4 finalColor;

// Lighting constants
#define MAX_LIGHTS 64
#define LIGHT_DIRECTIONAL 0
#define LIGHT_POINT 1

// Uniform arrays matching the Lua module
uniform int lightEnabled[MAX_LIGHTS];
uniform int lightType[MAX_LIGHTS];
uniform vec3 lightPosition[MAX_LIGHTS];
uniform vec3 lightTarget[MAX_LIGHTS];
uniform vec4 lightColor[MAX_LIGHTS];
uniform float lightAttenuation[MAX_LIGHTS];

uniform vec4 ambient;
uniform vec3 viewPos;

void main()
{
    vec4 texelColor = texture(texture0, fragTexCoord);
    vec4 tint = colDiffuse;
    vec3 normal = normalize(fragNormal);
    vec3 viewDir = normalize(viewPos - fragPosition);

    vec3 lightAccum = vec3(0.0);
    vec3 specularAccum = vec3(0.0);

    for (int i = 0; i < MAX_LIGHTS; i++)
    {
        if (lightEnabled[i] == 1)
        {
            vec3 lightDir = vec3(0.0);
            float attenuation = 1.0;

            if (lightType[i] == LIGHT_DIRECTIONAL)
            {
                lightDir = -normalize(lightTarget[i] - lightPosition[i]);
            }
            else if (lightType[i] == LIGHT_POINT)
            {
                lightDir = normalize(lightPosition[i] - fragPosition);
                float distance = length(lightPosition[i] - fragPosition);
                attenuation = 1.0 / (1.0 + lightAttenuation[i] * distance * distance);
            }

            float NdotL = max(dot(normal, lightDir), 0.0);
            lightAccum += lightColor[i].rgb * NdotL * attenuation;

            float spec = 0.0;
            if (NdotL > 0.0)
            {
                spec = pow(max(dot(viewDir, reflect(-lightDir, normal)), 0.0), 16.0);
            }
            specularAccum += spec * lightColor[i].rgb * attenuation;
        }
    }

    // Combine results
    vec3 diffuseSpec = (lightAccum + specularAccum) * tint.rgb;
    vec3 finalAmbient = ambient.rgb * tint.rgb;
    
    vec3 color = texelColor.rgb * (diffuseSpec + finalAmbient);
    finalColor = vec4(color, texelColor.a * tint.a);

    // Gamma correction
    finalColor.rgb = pow(finalColor.rgb, vec3(1.0 / 2.2));
}

