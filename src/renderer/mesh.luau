local raylib = require("@raylib")
local structs = raylib.structs
local lib = raylib.lib
local r3dapi = require("@r3d")
local r3d = r3dapi.lib
local _r3dstructs = r3dapi.structs
local ffi = zune.ffi
local meshgen = require("./meshgen")
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
	local gpuMesh

	print(meshId)

	if meshId == "cube" then
		meshData = r3d.R3D_GenMeshDataCube(params.width or 1, params.height or 1, params.length or 1)
		gpuMesh = r3d.R3D_LoadMesh(4, meshData, ffi.null, 0) -- 4 = R3D_PRIMITIVE_TRIANGLES, 0 = Static usages
	elseif meshId == "sphere" then
		meshData = r3d.R3D_GenMeshDataSphere(params.radius or 1, params.rings or 16, params.slices or 16)
		gpuMesh = r3d.R3D_LoadMesh(4, meshData, ffi.null, 0)
	elseif meshId == "cylinder" then
		meshData = r3d.R3D_GenMeshDataCylinder(params.radius or 1, params.height or 2, params.slices or 16)
		gpuMesh = r3d.R3D_LoadMesh(4, meshData, ffi.null, 0)
	elseif meshId == "plane" then
		meshData = r3d.R3D_GenMeshDataPlane(params.width or 10, params.length or 10, params.resX or 1, params.resZ or 1)
		gpuMesh = r3d.R3D_LoadMesh(4, meshData, ffi.null, 0)
	elseif meshId == "torus" then
		meshData =
			r3d.R3D_GenMeshDataTorus(params.radius or 1, params.size or 0.3, params.radSeg or 16, params.sides or 16)
		gpuMesh = r3d.R3D_LoadMesh(4, meshData, ffi.null, 0)
	elseif meshId == "wedge" then
		meshData = r3d.R3D_GenMeshDataSlope(
			params.width or 1,
			params.height or 1,
			params.length or 1,
			params.slopeNormal or vector.create(1, 1, 0)
		)
		gpuMesh = r3d.R3D_LoadMesh(4, meshData, ffi.null, 0)
	elseif meshId == "cornerwedge" then
		local width = params.width or 1
		local height = params.height or 1
		local length = params.length or 1

		local hx = width * 0.5
		local hy = height * 0.5
		local hz = length * 0.5

		local a = { x = -hx, y = -hy, z = -hz } -- back-left
		local b = { x = hx, y = -hy, z = -hz } -- back-right
		local c = { x = hx, y = -hy, z = hz } -- front-right
		local d = { x = -hx, y = -hy, z = hz } -- front-left
		local e = { x = -hx, y = hy, z = -hz } -- top apex

		local triangles = {
			-- Bottom face (flipped)
			{ a, b, c },
			{ a, c, d },

			-- Back face (-Z)
			{ a, e, b },

			-- Left face (-X)
			{ a, d, e },

			-- Right slope
			{ b, e, c },

			-- Front slope
			{ d, c, e },
		}

		-- buildFromTriangles returns { cpuMeshData, gpuMesh }
		local custom = meshgen.buildFromTriangles(triangles, { usage = meshgen.Usage.Static })
		if not custom then
			return nil
		end
		return custom
	else
		warn(`Unknown mesh type: {meshId}`)
		return nil
	end

	log(`Generated mesh: {meshId} ({meshId})`)
	return { meshData, gpuMesh }
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
