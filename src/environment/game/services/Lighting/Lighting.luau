local Instance = require("@Instance")
local Vector3 = require("@Vector3")
local adapter = require("@RaylibAdapter")
local zembed = require("@zembed")
local const = adapter.const
local lib = adapter.lib
local Lighting = Instance.new("Lighting")
local Color3 = require("@Color3")
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

local function setAllEnvironmentEffects()
	local environment: FFIPointer = rlib.R3D_GetEnvironment()
	rlib.R3D_SetEnvironment(environment)
end

Lighting.InitRenderer = function(renderer, renderer_signal, datamodel)
	if _G.IsHeadless then
		return
	end

	Lighting:SetProperties({
		Ambient = Color3.fromRGB(105, 120, 145),
		Brightness = 2.0,

		ColorShift_Top = Color3.fromRGB(235, 245, 255),
		ColorShift_Bottom = Color3.fromRGB(180, 205, 235),

		OutdoorAmbient = Color3.fromRGB(125, 140, 165),

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

	local FilamentContext = renderer.FilamentContext
	local Filament = renderer.Filament

	local function UpdateLighting()
		local ambientR, ambientG, ambientB = Lighting.Ambient:ToRGB()

		local outdoorR, outdoorG, outdoorB = Lighting.OutdoorAmbient:ToRGB()

		local topR, topG, topB = Lighting.ColorShift_Top:ToRGB()

		local bottomR, bottomG, bottomB = Lighting.ColorShift_Bottom:ToRGB()

		local daylight = Lighting:GetDaylight()

		local sunAngle = math.rad((Lighting.ClockTime - 12) * 15)

		local latitude = math.rad(Lighting.GeographicLatitude)

		local sunDirX = math.cos(sunAngle)
		local sunDirY = math.sin(latitude)
		local sunDirZ = math.sin(sunAngle)

		local length = math.sqrt(sunDirX * sunDirX + sunDirY * sunDirY + sunDirZ * sunDirZ)

		sunDirX /= length
		sunDirY /= length
		sunDirZ /= length

		local sunIntensity = Lighting.Brightness * 50000

		local skyR = math.clamp(topR * daylight + outdoorR * (1 - daylight), 0, 1)
		local skyG = math.clamp(topG * daylight + outdoorG * (1 - daylight), 0, 1)
		local skyB = math.clamp(topB * daylight + outdoorB * (1 - daylight), 0, 1)

		local horizonR = math.clamp(bottomR * daylight + ambientR * (1 - daylight), 0, 1)
		local horizonG = math.clamp(bottomG * daylight + ambientG * (1 - daylight), 0, 1)
		local horizonB = math.clamp(bottomB * daylight + ambientB * (1 - daylight), 0, 1)

		Filament.lib.Kine_Filament_SetSkyAtmosphere(
			FilamentContext,

			-- sun direction
			sunDirX,
			sunDirY,
			sunDirZ,

			-- sky
			skyR,
			skyG,
			skyB,

			-- horizon
			horizonR,
			horizonG,
			horizonB,

			-- ground
			ambientR,
			ambientG,
			ambientB,

			-- sun intensity
			sunIntensity
		)
	end

	--renderer.Hook.new("Renderstep", UpdateLighting)

	-- default
	Filament.lib.Kine_Filament_SetSkyAtmosphere(
		FilamentContext,
		0.35,
		0.75,
		0.55, -- sunDirX, Y, Z

		0.18,
		0.42,
		0.90, -- sky zenith color

		0.55,
		0.78,
		1.00, -- horizon color

		0.25,
		0.30,
		0.32, -- ground color

		100000.0 -- sun light intensity (lux)
	)
end

return Lighting
