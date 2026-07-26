local adapter = require("@RaylibAdapter")
local structs = adapter.structs
local lib = adapter.lib

local modelRegistry = {}
local meshDataRegistry = {} -- CPU-side R3D_MeshData for file-loaded models

local function LoadMesh(meshId: string, filePath: string)
	local model = lib.LoadModel(filePath)
	if lib.IsModelValid(model) == 1 then
		modelRegistry[filePath] = model
		log(`Loaded mesh: {meshId} from {filePath}`)
		return model
	else
		warn(`Failed to load mesh: {filePath}`)
		return nil
	end
end

local function UnloadMesh(meshId: string)
	local model = modelRegistry[meshId]
	if model then
		lib.UnloadModel(model)
		modelRegistry[meshId] = nil
		meshDataRegistry[meshId] = nil
		log(`Unloaded mesh: {meshId}`)
	end
end

local function GetMesh(meshId: string)
	return modelRegistry[meshId]
end

local function GenerateMesh(meshId: string, params: any)
	local meshData

	if meshId == "cube" then
		meshData = lib.GenMeshCube(params.width or 2, params.height or 2, params.length or 2)
	elseif meshId == "sphere" then
		meshData = lib.GetMeshSphere(params.radius or 1, params.rings or 16, params.slices or 16)
	elseif meshId == "cylinder" then
		meshData = lib.GenMeshCylinder(params.radius or 1, params.height or 2, params.slices or 16)
	elseif meshId == "plane" then
		meshData = lib.GenMeshPlane(params.width or 10, params.length or 10, params.resX or 1, params.resZ or 1)
	elseif meshId == "torus" then
		meshData = lib.GenMeshTorus(params.radius or 1, params.size or 0.3, params.radSeg or 16, params.sides or 16)
		warn(`Unknown mesh type: {meshId}`)
		return nil
	end

	log(`Generated mesh: {meshId} ({meshId})`)
	return { meshData }
end

local _preloadedMeshesCache = nil

local function PreloadStandardMeshes()
	local preloaded = {}
	preloaded["block"] = GenerateMesh("cube", { width = 1, height = 1, length = 1 })
	preloaded["sphere"] = GenerateMesh("sphere", { radius = 0.5, rings = 16, slices = 16 })
	preloaded["cylinder"] = GenerateMesh("cylinder", { radius = 0.5, height = 1, slices = 16 })
	preloaded["plane"] = GenerateMesh("plane", { width = 10, length = 10, resX = 1, resZ = 1 })
	preloaded["torus"] = GenerateMesh("torus", { radius = 1, size = 0.3, radSeg = 16, sides = 16 })
	preloaded["wedge"] =
		GenerateMesh("wedge", { width = 1, height = 1, length = 1, slopeNormal = vector.create(1, 1, 0) })
	preloaded["cornerwedge"] = GenerateMesh("cornerwedge", { width = 1, height = 1, length = 1 })

	_preloadedMeshesCache = preloaded
	return preloaded
end

local function GetModelRegistry()
	return modelRegistry
end

local function loadMaterialOnModel(model, texture, const)
	local materials = zune.ffi.ptrFromAddress(zune.mem.slice(model, structs.Model:offset("materials"), 8))

	-- Set texture
	local maps = materials:readptr(structs.Material:offset("maps"))
	maps:write(const or 0, texture, 0, structs.Texture:size())

	--		materials:write(structs.Material:offset("shader"), shader, 0, structs.Shader:size())
end

local function EulerToAxisAngleRad(euler: Vector3): (Vector3, number)
	local cx, sx = math.cos(euler.X / 2), math.sin(euler.X / 2)
	local cy, sy = math.cos(euler.Y / 2), math.sin(euler.Y / 2)
	local cz, sz = math.cos(euler.Z / 2), math.sin(euler.Z / 2)

	-- Quaternion multiplication: q = qz * qy * qx
	local qw = cz * cy * cx + sz * sy * sx
	local qx = cz * cy * sx - sz * sy * cx
	local qy = cz * sy * cx + sz * cy * sx
	local qz = sz * cy * cx - cz * sy * sx

	local angle = 2 * math.acos(math.clamp(qw, -1, 1))
	local s = math.sqrt(1 - qw * qw)
	if s < 0.0001 then
		-- If s is near zero, axis direction is arbitrary
		return vector.create(1, 0, 0), 0
	else
		return vector.create(qx / s, qy / s, qz / s), angle
	end
end

local function drawModel(model, part, loadedMaterials)
	local axis, angle = EulerToAxisAngleRad(part.Orientation or part.Rotation)

	-- Apply material texture
	if loadedMaterials[part.Material.Value] then
		local data = loadedMaterials[part.Material.Value]
		loadMaterialOnModel(model, data.texture)
	end

	lib.DrawModelEx(
		model,
		vector.create(part.Position.X, part.Position.Y, part.Position.Z),
		axis,
		angle,
		vector.create(part.Size.X, part.Size.Y, part.Size.Z),
		part.Color:ToRaylib(part.Transparency)
	)
end

return {
	LoadMesh = LoadMesh,
	UnloadMesh = UnloadMesh,
	GetMesh = GetMesh,
	GenerateMesh = GenerateMesh,
	PreloadStandardMeshes = PreloadStandardMeshes,
	GetModelRegistry = GetModelRegistry,
	drawModel = drawModel,
	loadMaterialOnModel = loadMaterialOnModel,
	-- Returns the map populated by PreloadStandardMeshes.
	-- Each entry is { cpuMeshData, gpuMesh } keyed by shape name.
	GetPreloadedMeshes = function()
		return _preloadedMeshesCache
	end,
}
