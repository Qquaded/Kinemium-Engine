-- description: "Creates a sky shader for custom rendering, Parented under lighting."
local Color3 = require("@Color3")
local Shader = require("@ShaderDatatype")
local Vector3 = require("@Vector3")

local function calculateSunDirection(time, latitude)
	latitude = math.rad(latitude)
	local declination = math.rad(23.45 * math.sin(math.rad(360 * (284 + time * 15) / 365)))
	local hourAngle = math.rad(15 * (time - 12))

	local elevation = math.asin(
		math.sin(latitude) * math.sin(declination) + math.cos(latitude) * math.cos(declination) * math.cos(hourAngle)
	)
	local azimuth = math.atan2(
		math.sin(hourAngle),
		math.cos(hourAngle) * math.sin(latitude) - math.tan(declination) * math.cos(latitude)
	)

	return Vector3.new(
		math.cos(azimuth) * math.cos(elevation),
		math.sin(elevation),
		math.sin(azimuth) * math.cos(elevation)
	)
end

local defaultGLSL = [[
// Sky
uniform vec3  u_ZenithColor;
uniform vec4  u_HorizonParams; // xyz = horizon color, w = horizon exponent

// Haze + Ground packed: xyz = haze color, w = haze strength
uniform vec4  u_HazeColorStrength;
uniform vec3  u_GroundColor;

// Sun (5 uniforms)
uniform vec4  u_SunParams; // xyz = direction, w = sharpness
uniform vec3  u_SunDiskColor;
uniform vec4  u_CoronaParams;   // xyz = corona color, w = corona power
uniform float u_CoronaStrength;
uniform vec4  u_ScatterParams;  // xyz = scatter color, w = scatter power
uniform float u_ScatterStrength;

// Stars: x = count, y = brightness, z = sharpness, w = twinkle amount
uniform vec4  u_StarParams;
// Twinkle speed separate (needed in expression)
uniform float u_StarTwinkleSpeed;

// Clouds: x = coverage, y = sharpness, z = speed, w = altitude
uniform vec4  u_CloudParams;
// Cloud colors + opacity: cloudColor rgb + opacity in alpha
uniform vec4  u_CloudColor;
uniform vec4  u_CloudShadowColor; // xyz = shadow color, w = shadow depth

// Total: 16 uniforms exactly

float hash(vec2 p) {
    p = fract(p * vec2(127.1, 311.7));
    p += dot(p, p + 19.19);
    return fract(p.x * p.y);
}

float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    vec2 u = f * f * (3.0 - 2.0 * f);
    return mix(
        mix(hash(i),                  hash(i + vec2(1.0, 0.0)), u.x),
        mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), u.x),
        u.y
    );
}

float fbm(vec2 p) {
    float v = 0.0;
    float a = 0.5;
    for (int i = 0; i < 4; i++) {
        v += a * noise(p);
        p  = p * 2.1 + vec2(1.7, 9.2);
        a *= 0.5;
    }
    return v;
}

float starField(vec3 rd) {
    float phi   = atan(rd.z, rd.x);
    float theta = acos(clamp(rd.y, -1.0, 1.0));
    vec2  uv    = vec2(phi / 6.28318, theta / 3.14159);

    float scale = u_StarParams.x * 0.05;
    vec2  cell  = floor(uv * scale);
    vec2  lc    = fract(uv * scale) - 0.5;

    float rnd  = hash(cell);
    vec2  pos  = (vec2(hash(cell + 13.7), hash(cell + 7.3)) - 0.5) * 0.9;
    float dist = length(lc - pos);

    float twinkle = 1.0 - u_StarParams.w *
                    (0.5 + 0.5 * sin(TIME * u_StarTwinkleSpeed + rnd * 6.28318));

    float star = smoothstep(1.0 - u_StarParams.z, 1.0, 1.0 - dist * 2.0) * twinkle;

    float threshold = 1.0 - (u_StarParams.x / 200000.0);
    return (rnd > threshold) ? star * u_StarParams.y : 0.0;
}

float cloudDensity(vec3 rd) {
    if (rd.y < 0.001) return 0.0;

    float t  = u_CloudParams.w / max(rd.y, 0.001);
    vec2  uv = rd.xz * t;

    uv += vec2(TIME * u_CloudParams.z, TIME * u_CloudParams.z * 0.4);

    float n = fbm(uv * 2.5);
    return clamp((n - (1.0 - u_CloudParams.x)) * u_CloudParams.y, 0.0, 1.0);
}

void fragment() {
    vec3  rd     = normalize(EYEDIR);
    vec3  sunDir = normalize(u_SunParams.xyz);
    float sunDot = dot(rd, sunDir);
    float t      = max(rd.y, 0.0);

    // Sky gradient
    vec3 sky = mix(u_HorizonParams.xyz, u_ZenithColor, pow(t, u_HorizonParams.w));

    // Haze
    float haze = pow(1.0 - abs(rd.y), 5.0);
    sky += u_HazeColorStrength.rgb * haze * u_HazeColorStrength.a;

    // Sun disk
    float sunDisk = smoothstep(u_SunParams.w, u_SunParams.w + 0.0003, sunDot);
    sky = mix(sky, u_SunDiskColor, sunDisk);

    // Corona
    float corona = pow(max(sunDot, 0.0), u_CoronaParams.w);
    sky += u_CoronaParams.rgb * corona * u_CoronaStrength;

    // Scatter
    float scatter = pow(max(sunDot, 0.0), u_ScatterParams.w) * (1.0 - t);
    sky += u_ScatterParams.rgb * scatter * u_ScatterStrength;

    // Ground
    if (rd.y < 0.0) {
        float below = pow(max(-rd.y, 0.0), 0.3);
        sky = mix(sky, u_GroundColor, below);
    }

    // Stars (fade out during day and near sun)
    float nightMask = 1.0 - clamp(u_SunParams.y * 2.0, 0.0, 1.0);
    float starVis   = max(rd.y, 0.0) * nightMask * (1.0 - smoothstep(0.95, 1.0, sunDot));
    sky += vec3(starField(rd) * starVis);

    // Clouds
    float cloudD = cloudDensity(rd) * u_CloudColor.a;
    if (cloudD > 0.0) {
        float sunLit   = clamp(dot(vec3(0.0, 1.0, 0.0), sunDir) * 0.5 + 0.5, 0.0, 1.0);
        vec3  cloudCol = mix(u_CloudShadowColor.rgb, u_CloudColor.rgb,
                             sunLit * u_CloudShadowColor.a + (1.0 - u_CloudShadowColor.a));
        sky = mix(sky, cloudCol, cloudD);
    }

    COLOR = sky;
}
]]

return {
	class = "Sky",
	callback = function(instance, renderer, datamodel)
		if IsServer then
			return
		end
		local default_shader = Shader.fromMemorySky(defaultGLSL)
		local pastShader = nil
		local kinemiumShaderService = datamodel:GetService("KinemiumShaderService")
		local lighting = datamodel.Lighting

		local propTable = {
			CelestialBodiesShown = true,
			StarCount = 3000,
			SunAngularSize = 21,
			MoonAngularSize = 21,
			Shader = default_shader,

			-- Time of day
			ClockTime = 14.0,
			GeographicLatitude = 0.0,

			-- Sky (day presets, blended automatically by ClockTime)
			ZenithColor = Color3.new(0.08, 0.18, 0.55),
			HorizonColor = Color3.new(0.60, 0.75, 0.90),
			HorizonExponent = 0.45,
			HazeColor = Color3.new(0.25, 0.22, 0.15),
			HazeStrength = 1.0,
			GroundColor = Color3.new(0.15, 0.12, 0.10),
			SunDiskColor = Color3.new(1.5, 1.3, 0.9),
			SunDiskSharpness = 0.9994,
			CoronaColor = Color3.new(0.9, 0.7, 0.35),
			CoronaPower = 128.0,
			CoronaStrength = 0.6,
			ScatterColor = Color3.new(0.8, 0.4, 0.1),
			ScatterPower = 6.0,
			ScatterStrength = 0.5,

			-- Stars
			StarDensity = 3000.0,
			StarBrightness = 1.0,
			StarSharpness = 0.995,
			StarTwinkleSpeed = 3.0,
			StarTwinkleAmount = 0.4,

			-- Clouds
			CloudCoverage = 0.45,
			CloudSharpness = 2.5,
			CloudSpeed = 0.02,
			CloudColor = Color3.new(1.0, 0.98, 0.96),
			CloudShadowColor = Color3.new(0.55, 0.60, 0.72),
			CloudShadowDepth = 0.6,
			CloudAltitude = 0.08,
			CloudOpacity = 1.0,
		}
		instance:SetProperties(propTable)

		if IsServer then
			print("is server")
			return instance
		end

		local function pushUniforms(shader)
			local i = instance

			-- Compute sun direction from ClockTime
			local sunDir = calculateSunDirection(i.ClockTime, i.GeographicLatitude)
			local sunElevation = sunDir.Y -- -1 to 1, positive = above horizon

			-- Day/night blend factor: 1 = full day, 0 = full night
			-- Smooth transition around sunrise/sunset (sun elevation ~0)
			local dayFactor = math.clamp(sunElevation * 5.0 + 0.5, 0.0, 1.0)

			-- Night sky presets
			local nightZenith = { 0.01, 0.01, 0.04 }
			local nightHorizon = { 0.02, 0.03, 0.08 }
			local nightHaze = { 0.02, 0.02, 0.05 }

			-- Sunrise/sunset tint (warm colors near horizon when sun is low)
			local sunsetFactor = math.clamp(1.0 - math.abs(sunElevation) * 4.0, 0.0, 1.0) * 0.6
			local sunsetR = sunsetFactor * 0.4
			local sunsetG = sunsetFactor * 0.15

			-- Blend zenith color
			local zR = nightZenith[1] + (i.ZenithColor.R - nightZenith[1]) * dayFactor
			local zG = nightZenith[2] + (i.ZenithColor.G - nightZenith[2]) * dayFactor
			local zB = nightZenith[3] + (i.ZenithColor.B - nightZenith[3]) * dayFactor
			shader:SetUniform("u_ZenithColor", { zR, zG, zB })

			-- Blend horizon color + add sunset tint
			local hR = nightHorizon[1] + (i.HorizonColor.R - nightHorizon[1]) * dayFactor + sunsetR
			local hG = nightHorizon[2] + (i.HorizonColor.G - nightHorizon[2]) * dayFactor + sunsetG
			local hB = nightHorizon[3] + (i.HorizonColor.B - nightHorizon[3]) * dayFactor
			shader:SetUniform("u_HorizonParams", { hR, hG, hB, i.HorizonExponent })

			-- Blend haze
			local haR = nightHaze[1] + (i.HazeColor.R - nightHaze[1]) * dayFactor + sunsetR * 0.5
			local haG = nightHaze[2] + (i.HazeColor.G - nightHaze[2]) * dayFactor + sunsetG * 0.5
			local haB = nightHaze[3] + (i.HazeColor.B - nightHaze[3]) * dayFactor
			shader:SetUniform("u_HazeColorStrength", { haR, haG, haB, i.HazeStrength })

			shader:SetUniform("u_GroundColor", i.GroundColor)

			-- Pack sun direction + sharpness
			shader:SetUniform("u_SunParams", { sunDir.X, sunDir.Y, sunDir.Z, i.SunDiskSharpness })
			shader:SetUniform("u_SunDiskColor", i.SunDiskColor)
			-- Pack corona color + power into vec4
			shader:SetUniform("u_CoronaParams", { i.CoronaColor.R, i.CoronaColor.G, i.CoronaColor.B, i.CoronaPower })
			shader:SetUniform("u_CoronaStrength", i.CoronaStrength)
			-- Pack scatter color + power into vec4
			shader:SetUniform(
				"u_ScatterParams",
				{ i.ScatterColor.R, i.ScatterColor.G, i.ScatterColor.B, i.ScatterPower }
			)
			shader:SetUniform("u_ScatterStrength", i.ScatterStrength)
			-- Pack star params: count, brightness, sharpness, twinkle amount
			shader:SetUniform("u_StarParams", { i.StarDensity, i.StarBrightness, i.StarSharpness, i.StarTwinkleAmount })
			shader:SetUniform("u_StarTwinkleSpeed", i.StarTwinkleSpeed)
			-- Pack cloud params: coverage, sharpness, speed, altitude
			shader:SetUniform("u_CloudParams", { i.CloudCoverage, i.CloudSharpness, i.CloudSpeed, i.CloudAltitude })
			-- Pack cloud color + opacity
			shader:SetUniform("u_CloudColor", { i.CloudColor.R, i.CloudColor.G, i.CloudColor.B, i.CloudOpacity })
			-- Pack cloud shadow color + shadow depth
			shader:SetUniform(
				"u_CloudShadowColor",
				{ i.CloudShadowColor.R, i.CloudShadowColor.G, i.CloudShadowColor.B, i.CloudShadowDepth }
			)
		end

		local skyInitialized = false
		local skyDirty = true

		instance.Changed:Connect(function(property)
			if property == "Shader" then
				if pastShader and pastShader ~= instance.Shader then
					kinemiumShaderService.UnloadShader(pastShader)
				end
				skyInitialized = false
				pastShader = instance.Shader
			end
			skyDirty = true
		end)

		task.spawn(function()
			while task.wait(0.1) do
				if instance.Parent == lighting and instance.Shader then
					if skyDirty or not skyInitialized then
						pushUniforms(instance.Shader)
						skyDirty = false
					end
					kinemiumShaderService.LoadShader(instance.Shader)
					if not skyInitialized then
						skyInitialized = true
						pastShader = instance.Shader
					end
				end
			end
		end)

		return instance
	end,
}
