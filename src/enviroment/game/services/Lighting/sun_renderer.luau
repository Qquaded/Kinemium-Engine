---@diagnostic disable: undefined-global
local sunRenderer = {}

local raylib = require("@raylib")
local lib = raylib.lib
local const = raylib.const
local structs = raylib.structs
local Vector3 = require("@Vector3")
local CFrame = require("@CFrame")

local sunShader
local sunTexture
local sunMesh
local sunMat

function sunRenderer.Init()
	sunShader = lib.LoadShader("./src/assets/shaders/sun.vert", "./src/assets/shaders/sun.frag")
	sunTexture = lib.LoadTexture("./src/assets/sky/default/sun.png")

	sunMesh = lib.GenMeshPlane(100, 100, 1, 1)

	sunMat = lib.LoadMaterialDefault()
	lib.SetMaterialTexture(sunMat, const.MaterialMapIndex.MATERIAL_MAP_ALBEDO, sunTexture)
end

function sunRenderer.Render(camera, sunDirection)
	if not sunShader or not sunMesh then
		return
	end

	lib.rlDisableDepthMask()
	lib.rlDisableDepthTest()

	lib.BeginShaderMode(sunShader)

	local camPos = zune.mem.toVector3(camera, 0)
	local distance = 500.0

	local pos = Vector3.new(camPos.X, camPos.Y, camPos.Z) + (sunDirection * distance)

	local targetPos = Vector3.new(camPos.X, camPos.Y, camPos.Z)
	local cf = CFrame.lookAt(pos, targetPos)

	local correction = CFrame.Angles(math.rad(90), 0, 0)
	cf = cf * correction

	local transform = cf:ToRaylibMatrix(structs)

	lib.DrawMesh(sunMesh, sunMat, transform)

	lib.EndShaderMode()

	lib.rlEnableDepthTest()
	lib.rlEnableDepthMask()
end

function sunRenderer.Unload()
	if sunShader then
		lib.UnloadShader(sunShader)
	end
	if sunTexture then
		lib.UnloadTexture(sunTexture)
	end
	if sunMesh then
		lib.UnloadMesh(sunMesh)
	end
end

return sunRenderer
