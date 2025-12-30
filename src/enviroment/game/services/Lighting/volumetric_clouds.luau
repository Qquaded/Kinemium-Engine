---@diagnostic disable: undefined-global
local volumetricClouds = {}

local raylib = require("@raylib")
local lib = raylib.lib
local const = raylib.const
local utils = require("@bufferutils")

-- CLOUD DATA
local cloudShader
local cloudUniforms
local screenQuad
local quadMaterial

-- SETTINGS
local _settings = {
	CloudHeight = 3,
	CloudThickness = 3,
	CloudSize = 3,
	Steps = 3,
}

function volumetricClouds.Init()
	cloudShader = lib.LoadShader("./src/assets/shaders/clouds.vert", "./src/assets/shaders/clouds.frag")

	cloudUniforms = {
		cameraPos = lib.GetShaderLocation(cloudShader, "cameraPos"),
		sunDir = lib.GetShaderLocation(cloudShader, "sunDir"),
		sunColor = lib.GetShaderLocation(cloudShader, "sunColor"),
		time = lib.GetShaderLocation(cloudShader, "time"),
		iResolution = lib.GetShaderLocation(cloudShader, "iResolution"),
		camRight = lib.GetShaderLocation(cloudShader, "camRight"),
		camUp = lib.GetShaderLocation(cloudShader, "camUp"),
		camForward = lib.GetShaderLocation(cloudShader, "camForward"),
	}

	screenQuad = lib.GenMeshPlane(2, 2, 1, 1) -- Optimized quad
	quadMaterial = lib.LoadMaterialDefault()
end

function volumetricClouds.UpdateUniforms(camera, cameraPosV3, sunDir, lighting)
	local len = math.sqrt(sunDir.X ^ 2 + sunDir.Y ^ 2 + sunDir.Z ^ 2)
	local sun = { sunDir.X / len, sunDir.Y / len, sunDir.Z / len }

	local posV3 = cameraPosV3
	local targetV3 = zune.mem.toVector3(camera, 12)
	local upV3 = zune.mem.toVector3(camera, 24)

	-- Calculate Basis Vectors
	local fwd = { X = targetV3.X - posV3.X, Y = targetV3.Y - posV3.Y, Z = targetV3.Z - posV3.Z }
	local fwdLen = math.sqrt(fwd.X * fwd.X + fwd.Y * fwd.Y + fwd.Z * fwd.Z)
	fwd.X = fwd.X / fwdLen
	fwd.Y = fwd.Y / fwdLen
	fwd.Z = fwd.Z / fwdLen

	local rgt = {
		X = fwd.Y * upV3.Z - fwd.Z * upV3.Y,
		Y = fwd.Z * upV3.X - fwd.X * upV3.Z,
		Z = fwd.X * upV3.Y - fwd.Y * upV3.X,
	}
	local rgtLen = math.sqrt(rgt.X * rgt.X + rgt.Y * rgt.Y + rgt.Z * rgt.Z)
	if rgtLen < 0.0001 then
		rgt = { X = 1, Y = 0, Z = 0 }
	else
		rgt.X = rgt.X / rgtLen
		rgt.Y = rgt.Y / rgtLen
		rgt.Z = rgt.Z / rgtLen
	end

	local realUp = {
		X = rgt.Y * fwd.Z - rgt.Z * fwd.Y,
		Y = rgt.Z * fwd.X - rgt.X * fwd.Z,
		Z = rgt.X * fwd.Y - rgt.Y * fwd.X,
	}

	local cameraPos = vector.create(posV3.X, posV3.Y, posV3.Z)
	lib.SetShaderValue(cloudShader, cloudUniforms.cameraPos, cameraPos, const.ShaderUniformDataType.SHADER_UNIFORM_VEC3)

	lib.SetShaderValue(
		cloudShader,
		cloudUniforms.camRight,
		vector.create(rgt.X, rgt.Y, rgt.Z),
		const.ShaderUniformDataType.SHADER_UNIFORM_VEC3
	)
	lib.SetShaderValue(
		cloudShader,
		cloudUniforms.camUp,
		vector.create(realUp.X, realUp.Y, realUp.Z),
		const.ShaderUniformDataType.SHADER_UNIFORM_VEC3
	)
	lib.SetShaderValue(
		cloudShader,
		cloudUniforms.camForward,
		vector.create(fwd.X, fwd.Y, fwd.Z),
		const.ShaderUniformDataType.SHADER_UNIFORM_VEC3
	)

	lib.SetShaderValue(
		cloudShader,
		cloudUniforms.sunDir,
		vector.create(sun[1], sun[2], sun[3]),
		const.ShaderUniformDataType.SHADER_UNIFORM_VEC3
	)
	lib.SetShaderValue(
		cloudShader,
		cloudUniforms.sunColor,
		vector.create(1.0, 0.95, 0.9),
		const.ShaderUniformDataType.SHADER_UNIFORM_VEC3
	)
	lib.SetShaderValue(
		cloudShader,
		cloudUniforms.time,
		utils:float(os.clock()),
		const.ShaderUniformDataType.SHADER_UNIFORM_FLOAT
	)

	local screenW = lib.GetScreenWidth()
	local screenH = lib.GetScreenHeight()

	local resBuf = buffer.create(8)
	buffer.writef32(resBuf, 0, screenW)
	buffer.writef32(resBuf, 4, screenH)

	lib.SetShaderValue(cloudShader, cloudUniforms.iResolution, resBuf, const.ShaderUniformDataType.SHADER_UNIFORM_VEC2)
end

function volumetricClouds.Render()
	lib.rlDisableDepthTest()
	lib.rlDisableDepthMask()
	lib.rlDisableBackfaceCulling()

	lib.BeginShaderMode(cloudShader)
	lib.BeginBlendMode(const.BlendMode.BLEND_ALPHA)
	lib.DrawMesh(screenQuad, quadMaterial, raylib.lib.MatrixIdentity() or nil)
	lib.DrawMesh(screenQuad, quadMaterial, buffer.create(64))

	lib.EndBlendMode()
	lib.EndShaderMode()

	lib.rlEnableBackfaceCulling()
	lib.rlEnableDepthTest()
	lib.rlEnableDepthMask()
end

function volumetricClouds.Unload()
	if cloudShader then
		lib.UnloadShader(cloudShader)
	end
	if screenQuad then
		lib.UnloadMesh(screenQuad)
	end
end

return volumetricClouds
