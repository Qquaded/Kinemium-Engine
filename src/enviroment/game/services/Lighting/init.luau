local Instance = require("@Instance")
local Color3 = require("@Color3")
local Vector3 = require("@Vector3")
local raylib = require("@raylib")
local const = raylib.const
local structs = raylib.structs
local Lighting = Instance.new("Lighting")

local volumetricClouds = require("./Lighting/volumetric_clouds")
local sunRenderer = require("./Lighting/sun_renderer")
local _ssao = require("./Lighting/ssao")
local Kilights = require("@Kilights")

local default_shader
local lightPool = {}

function Lighting:GetSunDirection()
	local time = self.ClockTime
	local latitude = math.rad(self.GeographicLatitude)
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

local function handleSky(skyObject, renderer)
	if skyObject.ClassName == "Sky" then
		local skybox = renderer.skybox
		local cubemapPaths

		if skyObject.Cubemap ~= "" then
			skybox.Load(skyObject.Cubemap)
		else
			cubemapPaths = {
				skyObject.SkyboxRt, -- +X
				skyObject.SkyboxLf, -- -X
				skyObject.SkyboxUp, -- +Y
				skyObject.SkyboxDn, -- -Y
				skyObject.SkyboxFt, -- +Z
				skyObject.SkyboxBk, -- -Z
			}

			local cubemap = skybox.FromCubemap(cubemapPaths)
			if not cubemap then
				return
			end
			skybox.Unload()
			skybox.Load(cubemap)
		end

		print("Reinitialized sky with new Skybox skyObject")
	end
end

Lighting.InitRenderer = function(renderer, renderer_signal, datamodel)
	if _G.IsHeadless then
		return
	end
	renderer.skybox.Load()

	default_shader = Kilights.getDefaultShader()

	Lighting:SetProperties({
		Ambient = Color3.fromRGB(128, 128, 128),
		Brightness = 2.0,
		ColorShift_Top = Color3.fromRGB(255, 255, 255),
		ColorShift_Bottom = Color3.fromRGB(0, 0, 0),
		OutdoorAmbient = Color3.fromRGB(128, 128, 128),
		GlobalShadows = true,
		ClockTime = 14.0,
		GeographicLatitude = 0.0,
		VolumetricCloudsEnabled = true,
		CloudHeight = 1000.0,
		CloudThickness = 200.0,
		CloudDensity = 0.5,
		CloudSpeed = 0.01,
		CloudCoverage = 0.7,
		SSAOEnabled = true,
		SSAORadius = 0.5,
		SSAOBias = 0.025,
		SSAOIntensity = 1.0,

		-- internals
		kilight = Kilights,
		AddLight = function(id, ...)
			lightPool[id] = Kilights.CreateLight(...)
			return id
		end,

		RemoveLight = function(id)
			lightPool[id] = nil
		end,

		kilight_shader_def = default_shader,
	})

	volumetricClouds.Init()
	sunRenderer.Init()
	--ssao.Init()

	Kilights.SetAmbientColor({
		r = 0.5,
		g = 0.5,
		b = 0.5,
		a = 1.0,
	}, default_shader)

	Lighting.AddLight(
		"Sun",
		Kilights.LIGHT_POINT,
		vector.create(0.1, 5.0, 0.1),
		vector.create(0, 0, 0),
		{ r = 255, g = 255, b = 255, a = 255 },
		default_shader
	)

	local applied = false
	renderer_signal:Connect(function(route, dt)
		if route == "RenderStepped" then
			local workspace = datamodel.Workspace

			if workspace and workspace.materials and not applied then
				for _, data in pairs(workspace.materials) do
					buffer.copy(
						data.material,
						structs.Material:offset("shader"),
						default_shader,
						0,
						structs.Shader:size()
					)
				end
				applied = true
			end

			local ambient = Lighting.Ambient
			local brightness = Lighting.Brightness

			Kilights.SetAmbientColor({
				r = ambient.R / 255,
				g = ambient.G / 255,
				b = ambient.B / 255,
				a = 1.0,
			}, default_shader)

			renderer.shader.SetShaderUniform(
				"Kinemium",
				"globalAmbient",
				{ ambient.R / 255, ambient.G / 255, ambient.B / 255 },
				4
			)
			renderer.shader.SetShaderUniform("Kinemium", "brightness", brightness, 0)

			local sunDir = Lighting:GetSunDirection()
			renderer.shader.SetShaderUniform("Kinemium", "sunDirection", { sunDir.X, sunDir.Y, sunDir.Z }, 3)

			if Lighting.VolumetricCloudsEnabled then
				--local _cameraPos = zune.mem.toVector3(renderer.camera, 0)
			end
		elseif route == "WorkspaceStart" then
			if not _G.IsHeadless then
				Kilights:Begin(default_shader)
				for _, light in pairs(lightPool) do
					Kilights.UpdateLightValues(default_shader, light)
				end
				Kilights.SetCameraPos(default_shader, renderer.camera)
			end
		elseif route == "WorkspaceFinish" then
			if not _G.IsHeadless then
				Kilights:End()
			end
		elseif route == "RenderClouds" then
			if Lighting.VolumetricCloudsEnabled then
				--volumetricClouds.Render()
			end
		elseif route == "PreGuiRender" then
			local blurEffect = Lighting:FindFirstChildOfClass("BlurEffect")

			if blurEffect then
				renderer.blur.blurRadius = blurEffect.Size
				renderer.blur:DrawFullBlur(const.WHITE)
			end
		end
	end)

	Lighting.ChildAdded:Connect(function(child)
		handleSky(child, renderer)
	end)

	renderer.Add3DStack(function()
		local camera = renderer.camera

		renderer.skybox.Draw(camera, 50)
		sunRenderer.Render(camera, Lighting:GetSunDirection())
	end)
end

return Lighting
