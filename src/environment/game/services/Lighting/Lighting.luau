local Instance = require("@Instance")
local Vector3 = require("@Vector3")
local raylib = require("@raylib")
local zembed = require("@zembed")
local const = raylib.const
local lib = raylib.lib
local Lighting = Instance.new("Lighting")
local Color3 = require("@Color3")
local r3d = require("@r3d")
local rlib = r3d.lib
local Stars = {}
local Enum = require("@EnumMap")

local STAR_COUNT = 3000
local STAR_RADIUS = 1000

for i = 1, STAR_COUNT do
	local z = math.random() * 2 - 1
	local theta = math.random() * math.pi * 2
	local r = math.sqrt(1 - z * z)

	table.insert(Stars, {
		pos = Vector3.new(r * math.cos(theta) * STAR_RADIUS, z * STAR_RADIUS, r * math.sin(theta) * STAR_RADIUS),
		size = math.random(),
	})
end

local function getDayAlpha(clockTime)
	return (clockTime % 24) / 24
end

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

function Lighting:GetSunDirection()
	return calculateSunDirection(self.ClockTime, self.GeographicLatitude)
end

local function setSkyObject(r3d_sky)
	local environment: FFIPointer = rlib.R3D_GetEnvironment()

	local iden = lib.QuaternionIdentity()

	local envbackground = r3d.structs.R3D_EnvBackground:new({
		sky = r3d_sky,
		energy = 1.0,
		rotation = iden,
		skyBlur = 0,
	})

	local offset = r3d.structs.R3D_Environment:offset("background")
	environment:write(offset, envbackground, 0, r3d.structs.R3D_EnvBackground:size())

	rlib.R3D_SetEnvironment(environment)
end

local function loadSky(cubemapPath)
	cubemapPath = zembed.AssetPath(cubemapPath)
	local r3d_sky = rlib.R3D_LoadCubemap(cubemapPath, 5)
	setSkyObject(r3d_sky)
	return function()
		rlib.R3D_UnloadCubemap(r3d_sky)
	end
end

local function setAllEnvironmentEffects()
	local environment: FFIPointer = rlib.R3D_GetEnvironment()
	rlib.R3D_SetEnvironment(environment)
end

Lighting.InitRenderer = function(renderer, renderer_signal, datamodel)
	if _G.IsHeadless then
		return
	end

	Lighting:SetProperties({
		Ambient = Color3.new(1, 1, 1),
		Brightness = 2.0,
		ColorShift_Top = Color3.fromRGB(255, 255, 255),
		ColorShift_Bottom = Color3.fromRGB(0, 0, 0),
		OutdoorAmbient = Color3.fromRGB(128, 128, 128),
		GlobalShadows = true,
		ClockTime = 14.0,
		GeographicLatitude = 0.0,
		EnableDayCycle = false,

		GetDaylight = function()
			local t = getDayAlpha(Lighting.ClockTime)
			return t
		end,
	})

	Lighting._Intents = Enum.PluginIntents.Graphics

	local unload = loadSky("kineasset://sky/test/images/sky.png")
	setAllEnvironmentEffects()

	local light = rlib.R3D_CreateLight(0) -- R3D_LIGHT_DIR
	rlib.R3D_SetLightDirection(light, vector.create(-1, -1, -1))
	rlib.R3D_SetLightColor(light, raylib.const.WHITE)
	rlib.R3D_SetLightEnergy(light, 1.0)
	rlib.R3D_SetLightActive(light, true)
	rlib.R3D_SetShadowSoftness(light, 3)
	rlib.R3D_SetShadowDepthBias(light, 0.001)
	rlib.R3D_SetShadowSlopeBias(light, 0.01)
	rlib.R3D_EnableShadow(light)

	local effectToEnvMap = {
		SSAOEffect = { offset = "ssao", struct = r3d.structs.R3D_EnvSSAO },
		BloomEffect = { offset = "bloom", struct = r3d.structs.R3D_EnvBloom },
		SSGIEffect = { offset = "ssgi", struct = r3d.structs.R3D_EnvSSGI },
		SSILEffect = { offset = "ssil", struct = r3d.structs.R3D_EnvSSIL },
		SSREffect = { offset = "ssr", struct = r3d.structs.R3D_EnvSSR },
		DOFEffect = { offset = "dof", struct = r3d.structs.R3D_EnvDoF },
		FogEffect = { offset = "fog", struct = r3d.structs.R3D_EnvFog },
		TonemapEffect = { offset = "tonemap", struct = r3d.structs.R3D_EnvTonemap },
		ColorEffect = { offset = "color", struct = r3d.structs.R3D_EnvColor },
	}
	local highestBlur = 0
	local blurCacheDirty = true

	local function invalidateBlurCache()
		blurCacheDirty = true
	end

	local function refreshBlurCache()
		local maxBlur = 0
		for _, blur in pairs(Lighting:QueryDescendants(">BlurEffect")) do
			if blur.Enabled and (blur.Size or 0) > 0 then
				maxBlur = math.max(maxBlur, blur.Size)
			end
		end

		highestBlur = maxBlur
		blurCacheDirty = false
	end

	local function applyEffectToEnv(effect)
		local map = effectToEnvMap[effect.ClassName]
		if map and effect:GetMetadata("EffectObject") then
			local envType = r3d.structs.R3D_Environment
			local environment: FFIPointer = rlib.R3D_GetEnvironment()
			environment:write(envType:offset(map.offset), effect:GetMetadata("EffectObject"), 0, map.struct:size())
			rlib.R3D_SetEnvironment(environment)
		end
	end

	local function handleLightingChild(child)
		if child.ClassName == "BlurEffect" then
			invalidateBlurCache()
			child.Changed:Connect(function()
				invalidateBlurCache()
			end)
		end
		if effectToEnvMap[child.ClassName] then
			applyEffectToEnv(child)
			child.Changed:Connect(function()
				applyEffectToEnv(child)
			end)
		end
	end

	renderer.Pool.new("3d", function()
		if blurCacheDirty then
			refreshBlurCache()
		end

		if highestBlur > 0 then
			renderer.Blur.blurRadius = highestBlur
			renderer.Blur:DrawFullBlur(const.WHITE)
		end

		local colorShift_Top = Lighting.ColorShift_Top:ToRaylib()
		rlib.R3D_SetLightDirection(
			light,
			-calculateSunDirection((Lighting.ClockTime % 12) + 6, Lighting.GeographicLatitude):ToZuneVector()
		)
		rlib.R3D_SetLightColor(light, colorShift_Top)
		rlib.R3D_SetLightEnergy(light, Lighting.Brightness)
		rlib.R3D_SetLightActive(light, Lighting.GlobalShadows)
	end, -1048576) -- why is this number so big???

	for _, child in pairs(Lighting:GetChildren()) do
		handleLightingChild(child)
	end
	Lighting.ChildAdded:Connect(handleLightingChild)
	Lighting.DescendantRemoving:Connect(function(child)
		if child.ClassName == "BlurEffect" then
			invalidateBlurCache()
		end
	end)

	local currentCustomSky = nil

	function Lighting.SetSkyShader(shaderobject)
		if type(shaderobject) ~= "table" then
			return
		end
		if shaderobject._class ~= "shader" then
			return
		end
		local shader = shaderobject._shader

		if currentCustomSky then
			-- Update the existing cubemap instead of reallocating
			rlib.R3D_UpdateCustomSky(currentCustomSky, shader)
			return
		end

		local sky = rlib.R3D_GenCustomSky(512, shader)
		unload()
		unload = function()
			rlib.R3D_UnloadCubemap(sky)
		end
		setSkyObject(sky)
		currentCustomSky = sky
	end
end

return Lighting
