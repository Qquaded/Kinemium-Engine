#version 330 core

out vec4 fragColor;

uniform vec3 cameraPos;
uniform vec3 sunDir;
uniform vec3 sunColor;
uniform float time;
uniform vec2 iResolution;

uniform sampler2D cloudShadowMap; // Currently unused or empty
uniform mat4 lightSpaceMatrix;

// Constants
const float CLOUD_HEIGHT_MIN = 300.0;
const float CLOUD_HEIGHT_MAX = 800.0;
const int MARCH_STEPS = 64;
const float MARCH_STEP_SIZE = 15.0;

// Noise generation
float hash(float n) { return fract(sin(n) * 753.5453123); }

float noise(vec3 x) {
    vec3 p = floor(x);
    vec3 f = fract(x);
    f = f * f * (3.0 - 2.0 * f);
    float n = p.x + p.y * 157.0 + 113.0 * p.z;
    return mix(mix(mix(hash(n + 0.0), hash(n + 1.0), f.x),
                   mix(hash(n + 157.0), hash(n + 158.0), f.x), f.y),
               mix(mix(hash(n + 113.0), hash(n + 114.0), f.x),
                   mix(hash(n + 270.0), hash(n + 271.0), f.x), f.y), f.z);
}

float fbm(vec3 p) {
    float f = 0.0;
    float m = 0.5;
    for (int i = 0; i < 5; i++) {
        f += m * noise(p);
        p *= 2.0;
        m *= 0.5;
    }
    return f;
}

// Density function
float getDensity(vec3 p) {
    // Height gradient
    float h = p.y;
    if (h < CLOUD_HEIGHT_MIN || h > CLOUD_HEIGHT_MAX) return 0.0;
    
    float heightCoeff = 1.0 - smoothstep(0.0, 100.0, abs(h - (CLOUD_HEIGHT_MIN + CLOUD_HEIGHT_MAX) * 0.5) - 100.0);
    
    // Movement
    vec3 moves = vec3(time * 10.0, 0.0, time * 5.0);
    p += moves;
    
    // Noise
    float n = fbm(p * 0.003);
    
    // Threshold
    float dens = smoothstep(0.4, 0.8, n) * heightCoeff;
    return dens;
}

// Lighting (Beer's Law + Henyey-Greenstein)
float getLight(vec3 p) {
    vec3 dir = normalize(sunDir); // Ensure normalized
    float dist = 0.0;
    float dens = 0.0;
    float stepL = 20.0; 
    
    // Short march towards sun
    for(int i = 0; i < 5; i++) {
        vec3 lp = p + dir * dist;
        float d = getDensity(lp);
        dens += d;
        dist += stepL;
    }
    
    float transmittance = exp(-dens * 1.5); // Beer's law
    return transmittance;
}

// Raymarching
vec4 raymarch(vec3 ro, vec3 rd) {
    // Intersect with cloud layer (planar slab)
    // Plane y = CLOUD_HEIGHT_MIN
    float tMin = (CLOUD_HEIGHT_MIN - ro.y) / rd.y;
    float tMax = (CLOUD_HEIGHT_MAX - ro.y) / rd.y;
    
    if (rd.y < 0.0) {
        // Looking down
        // If above clouds, we hit MAX first, then MIN
        float tmp = tMin; tMin = tMax; tMax = tmp;
    }
    
    if (tMax < 0.0) return vec4(0.0); // Behind us
    
    float t = max(0.0, tMin);
    float limit = tMax;
    
    if (t > limit) return vec4(0.0);
    
    vec4 sum = vec4(0.0);
    
    for(int i=0; i<MARCH_STEPS; i++) {
        if (t > limit) break;
        
        vec3 p = ro + rd * t;
        float dens = getDensity(p);
        
        if(dens > 0.01) {
            float light = getLight(p);
            vec4 col = vec4(mix(vec3(1.0), sunColor, 0.5) * light, dens);
            
            // Premultiplied alpha accumulation
            col.a *= 0.4; // Absorption coeff per step
            col.rgb *= col.a;
            
            sum += col * (1.0 - sum.a);
        }
        
        if (sum.a > 0.99) break;
        t += MARCH_STEP_SIZE;
    }
    
    return clamp(sum, 0.0, 1.0);
}

uniform vec3 camRight;
uniform vec3 camUp;
uniform vec3 camForward;

void main() {
    float ar = iResolution.x / iResolution.y;
    vec2 uv = (gl_FragCoord.xy / iResolution) * 2.0 - 1.0;
    uv.x *= ar;
    
    // Reconstruct Camera Ray using passed basis vectors
    vec3 ro = cameraPos;
    // Assuming standard perspective projection with FOV ~60-70 degrees (focal length ~1.0-1.5)
    // Ray = Right * x + Up * y + Forward * focal_dist
    vec3 rd = normalize(uv.x * camRight + uv.y * camUp + camForward * 1.5);

    fragColor = raymarch(ro, rd);
}
