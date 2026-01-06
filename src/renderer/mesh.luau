local raylib = require("@raylib")
local structs = raylib.structs
local const = raylib.const
local lib = raylib.lib
local r3d = raylib.r3d.lib

local function Color3ToRaylib(c, transparency)
	local r, g, b = c:ToRGB()
	return structs.Color:new({
		r = r,
		g = g,
		b = b,
		a = math.floor(255 * (1 - transparency)),
	})
end

local loadedMaterials = {}

local modelRegistry = {}

local function LoadMesh(meshId: string, filePath: string)
	local model = lib.LoadModel(filePath)
	if lib.IsModelValid(model) == 1 then
		modelRegistry[filePath] = model
		print(`Loaded mesh: {meshId} from {filePath}`)
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
		print(`Unloaded mesh: {meshId}`)
	end
end

local function GetMesh(meshId: string)
	return modelRegistry[meshId]
end

local function GenerateMesh(meshId: string, meshType: string, params: any)
	local mesh

	if meshType == "Cube" then
		--mesh = r3d.R3D_GenMeshCube(params.width or 1, params.height or 1, params.length or 1)
		mesh = lib.GenMeshCube(params.width or 1, params.height or 1, params.length or 1)
	elseif meshType == "Sphere" then
		--mesh = r3d.R3D_GenMeshSphere(params.radius or 1, params.rings or 16, params.slices or 16)
		mesh = lib.GenMeshSphere(params.radius or 1, params.rings or 16, params.slices or 16)
	elseif meshType == "Cylinder" then
		--mesh = r3d.R3D_GenMeshCylinder(params.radius or 1, params.height or 2, params.slices or 16)
		mesh = lib.GenMeshCylinder(params.radius or 1, params.height or 2, params.slices or 16)
	elseif meshType == "Plane" then
		--mesh = r3d.R3D_GenMeshPlane(params.width or 10, params.length or 10, params.resX or 1, params.resZ or 1)
		mesh = lib.GenMeshPlane(params.width or 10, params.length or 10, params.resX or 1, params.resZ or 1)
	elseif meshType == "Torus" then
		--mesh = r3d.R3D_GenMeshTorus(params.radius or 1, params.size or 0.3, params.radSeg or 16, params.sides or 16)
		mesh = lib.GenMeshTorus(params.radius or 1, params.size or 0.3, params.radSeg or 16, params.sides or 16)
	else
		warn(`Unknown mesh type: {meshType}`)
		return nil
	end

	print(`Generated mesh: {meshId} ({meshType})`)
	return { nil, mesh }
end

local function PreloadStandardMeshes()
	local preloaded = {}
	preloaded["block"] = GenerateMesh("cube", "Cube", { width = 1, height = 1, length = 1 })
	preloaded["sphere"] = GenerateMesh("sphere", "Sphere", { radius = 0.5, rings = 16, slices = 16 })
	preloaded["cylinder"] = GenerateMesh("cylinder", "Cylinder", { radius = 0.5, height = 1, slices = 16 })
	preloaded["plane"] = GenerateMesh("plane", "Plane", { width = 10, length = 10, resX = 1, resZ = 1 })
	preloaded["torus"] = GenerateMesh("torus", "Torus", { radius = 1, size = 0.3, radSeg = 16, sides = 16 })
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
		Color3ToRaylib(part.Color, part.Transparency)
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
}
