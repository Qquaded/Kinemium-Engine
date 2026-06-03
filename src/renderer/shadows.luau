--!optimize 2
--!native

local raylib = require("@raylib")
local zembed = require("@zembed")
local lib = raylib.lib
local const = raylib.const
local structs = raylib.structs
local bufferUtils = require("@bufferUtils")

local Shadows = {}

local depthShader
local depthMaterial
local shadowRT
local lightSpaceMatrix
local shadowSize

local OFF_SHADER_LOCS = structs.Shader:offset("locs")
local OFF_MATERIAL_SHADER = structs.Material:offset("shader")
local SIZE_SHADER = structs.Shader:size()

local function setShaderLoc(shaderBuf, locIndex, locValue)
	if not shaderBuf then
		return
	end
	local locsPtr = zune.ffi.ptrFromAddress(zune.mem.slice(shaderBuf, OFF_SHADER_LOCS, 8))
	locsPtr:writei32(locIndex * 4, locValue)
end

local function chooseShadowSize(freeMemOverride)
	local freeMem = freeMemOverride or 0
	if not freeMemOverride and zune.platform and zune.platform.getFreeMemory then
		freeMem = zune.platform.getFreeMemory() or 0
	end

	-- bytes thresholds
	if freeMem > 0 and freeMem < 1024 * 1024 * 1024 then
		return 512
	end
	if freeMem > 0 and freeMem < 2 * 1024 * 1024 * 1024 then
		return 1024
	end
	return 2048
end

local function ensureResources()
	if shadowRT then
		return
	end

	shadowSize = chooseShadowSize()

	depthShader = lib.LoadShader(
		zembed.AssetPath("kineasset://shaders/depth.vs"),
		zembed.AssetPath("kineasset://shaders/depth.fs")
	)
	if lib.IsShaderValid(depthShader) == 0 then
		warn("depth shader invalid")
	end

	local locMatModel = lib.GetShaderLocation(depthShader, "matModel")
	if locMatModel ~= -1 then
		setShaderLoc(depthShader, const.ShaderLocationIndex.SHADER_LOC_MATRIX_MODEL, locMatModel)
	end

	shadowRT = lib.LoadRenderTexture(shadowSize, shadowSize)

	depthMaterial = lib.LoadMaterialDefault()
	buffer.copy(depthMaterial, OFF_MATERIAL_SHADER, depthShader, SIZE_SHADER)
end

function Shadows.chooseShadowSize(freeMemOverride)
	return chooseShadowSize(freeMemOverride)
end

function Shadows.GetShadowSize()
	return shadowSize or 0
end

function Shadows.GetShadowTexture()
	if not shadowRT then
		return nil
	end
	return bufferUtils.extract.texture(shadowRT)
end

function Shadows.GetLightSpaceMatrix()
	return lightSpaceMatrix
end

function Shadows.GetDepthMaterial()
	return depthMaterial
end

function Shadows.Render(lightDir, center, casters)
	if not lightDir or not center then
		return
	end

	ensureResources()

	local dist = 200.0
	local orthoSize = 120.0

	local eye = vector.create(center.X - lightDir.X * dist, center.Y - lightDir.Y * dist, center.Z - lightDir.Z * dist)
	local target = vector.create(center.X, center.Y, center.Z)
	local up = vector.create(0, 1, 0)

	local lightView = lib.MatrixLookAt(eye, target, up)
	local lightProj = lib.MatrixOrtho(-orthoSize, orthoSize, -orthoSize, orthoSize, 1.0, 500.0)
	lightSpaceMatrix = lib.MatrixMultiply(lightProj, lightView)

	local locLightSpace = lib.GetShaderLocation(depthShader, "lightSpaceMatrix")
	if locLightSpace ~= -1 then
		lib.SetShaderValueMatrix(depthShader, locLightSpace, lightSpaceMatrix)
	end

	lib.BeginTextureMode(shadowRT)
	lib.ClearBackground(const.WHITE)
	lib.rlEnableDepthTest()

	lib.BeginShaderMode(depthShader)
	if casters then
		for i = 1, #casters do
			casters[i](depthMaterial)
		end
	end
	lib.EndShaderMode()

	lib.rlDisableDepthTest()
	lib.EndTextureMode()
end

return Shadows
