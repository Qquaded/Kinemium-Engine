local Instance = require("@Instance")
local Vector3 = require("@Vector3")
local Workspace = Instance.new("Workspace")
local Enum = require("@EnumMap")

local mesh = require("@Kinemium.3d/mesh")
local skybox = require("@Kinemium.3d/skybox")

Workspace._Intents = Enum.PluginIntents.Graphics

local pool = {}
local renderablePool = {}
local RaycastResult = require("@RaycastResult")

local adapter = require("@RaylibAdapter")

local CHUNK_SIZE = 32
local TERRAIN_CHUNK_SIZE = 16
local meshMap = mesh.PreloadStandardMeshes()
local TRANSPARENCY_EPSILON = 0.001

print(meshMap)

local activeMaterialShader = nil

local function isPartOpaque(part)
	return (part.Transparency or 0) <= TRANSPARENCY_EPSILON
end

local function worldToChunk(pos)
	if not pos then
		return 0, 0, 0
	end
	return math.floor(pos.X / CHUNK_SIZE), math.floor(pos.Y / CHUNK_SIZE), math.floor(pos.Z / CHUNK_SIZE)
end

local function profileBegin(name)
	if ENGINE_PROFILER then
		ENGINE_PROFILER:Begin(name)
	end
end

local function profileSetCounter(name, value)
	if ENGINE_PROFILER then
		ENGINE_PROFILER:SetCounter(name, value)
	end
end

local function profileNextFrame()
	if ENGINE_PROFILER then
		ENGINE_PROFILER:NextFrame()
	end
end

local function profileEnd()
	if ENGINE_PROFILER then
		ENGINE_PROFILER:End()
	end
end

Workspace.InitRenderer = function(renderer, signal, game)
	Workspace:SetProperties({
		Test = 1,
	})

	--local sky = skybox.Load("./src/assets/sky/test/images/sky.png")
	local defMaterial = adapter.lib.LoadMaterialDefault()

	renderer.Hook.new("Renderstep", function()
		for _, object in pairs(Workspace:GetDescendants()) do
			if object:IsA("BasePart") then
				local matrix = object.CFrame:ToRaylibMatrixScale(object.Size, adapter.structs)
				local mesh = meshMap[object.Shape.Name] and meshMap[object.Shape.Name][1] or meshMap["block"][1]
				local material = defMaterial
				--skybox.Draw(vector.create(0, 0, 0), 1)
				renderer.MeshPool.DrawMesh(mesh, material, matrix)
			end
		end
	end)
end

return Workspace
