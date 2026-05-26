local Instance = require("@Instance")
local Vector3 = require("@Vector3")
local Workspace = Instance.new("Workspace")
local Enum = require("@EnumMap")
local pool = {}
local renderablePool = {}
local RaycastResult = require("@RaycastResult")

local raylib = require("@raylib")
local structs = raylib.structs
local r3d = require("@r3d")
local const = r3d.constants
local rlib = r3d.lib

local material_shader_manager = require("./materialShaders/_main")

local CHUNK_SIZE = 32
local TERRAIN_CHUNK_SIZE = 16
local chunks = {}
local chunkList = {}
local largeParts = {}
local TRANSPARENCY_EPSILON = 0.001

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

Workspace.InitRenderer = function(renderer, signal, game)
	table.clear(chunks)
	table.clear(chunkList)
	table.clear(largeParts)
	table.clear(pool)
	table.clear(renderablePool)

	local IdPool = {}
	local visibleChunks = {}
	local visibleChunkCacheDirty = true
	local lastVisibleChunkSettingsKey = nil
	local lastVisibilityCameraPos = nil
	local lastVisibilityCameraLook = nil
	local lastVisibilityMaxDistance = nil

	local mtsh_sh = material_shader_manager:AddFilters()

	local proptable = {
		Gravity = -9.81,
		GlobalWind = Vector3.new(0, 0, 0),
		FallenPartsDestroyHeight = 90,
		AirTurbulenceIntensity = 0,
		AirDensity = 0,
		StreamingEnabled = false,
		UseFixedSimulation = true,
		PlayerScriptsUseInputActionSystem = true,
		NextGenerationReplication = true,
		ServerAuthority = {
			AuthorityMode = Enum.AuthorityMode.Client,
		},
		PhysicsEngine = Enum.PhysicsEngine.Default, -- jolt

		-- rendering
		MAX_VIEW_DISTANCE = 2000,
		UseGpuInstancing = true,
		MinInstancesPerBatch = 2,
		EnableViewFrustumCulling = true,
		ViewFrustumPadding = 12,
		VisibilityRefreshDistance = 16,
		VisibilityRefreshDotThreshold = 0.9925,
		EnableDefaultPlayerMenu = true,

		ChunkRebuildTimeLimit = 0.012,

		LODEnabled = true,
		LOD1Distance = 60,
		LOD2Distance = 150,
		LOD3Distance = 400,
		LOD1MinSize = 2,
		LOD2MinSize = 6,
		LOD3MinSize = 16,

		ApplyGlobalSurfaceShader = function(shaderObject)
			if activeMaterialShader then
				activeMaterialShader = nil
			end

			if typeof(shaderObject) == "table" then
				if shaderObject._class == "shader" then
					if shaderObject._type == "surface" then
						activeMaterialShader = shaderObject._shader
						return true
					end
				end
			end
			return false
		end,

		IsInPool = function(part)
			return pool[part.UniqueId] ~= nil
		end,

		GetPoolCount = function()
			return #pool
		end,

		Get3DObjects = function()
			return renderablePool
		end,

		Pool = {
			GetAllUniqueIds = function()
				local result = {}
				for _, part in pairs(Workspace:GetDescendants()) do
					result[part.UniqueId] = part
				end
				return result
			end,

			GetIdPool = function()
				return IdPool
			end,

			GetPartByUniqueId = function(uniqueId)
				return IdPool[uniqueId]
			end,
		},
	}

	local function markVisibleChunkCacheDirty()
		visibleChunkCacheDirty = true
	end

	local function makeChunk(cx, cy, cz, key)
		local min = Vector3.new(cx * CHUNK_SIZE, cy * CHUNK_SIZE, cz * CHUNK_SIZE)
		local max = Vector3.new((cx + 1) * CHUNK_SIZE, (cy + 1) * CHUNK_SIZE, (cz + 1) * CHUNK_SIZE)
		local center = Vector3.new((min.X + max.X) * 0.5, (min.Y + max.Y) * 0.5, (min.Z + max.Z) * 0.5)
		local halfExtentX = (max.X - min.X) * 0.5
		local halfExtentY = (max.Y - min.Y) * 0.5
		local halfExtentZ = (max.Z - min.Z) * 0.5
		local chunk = {
			key = key,
			parts = {},
			aabbMin = min,
			aabbMax = max,
			center = center,
			boundsRadius = math.sqrt(halfExtentX * halfExtentX + halfExtentY * halfExtentY + halfExtentZ * halfExtentZ),
			dirty = true,
			instanceDataDirty = true,
			batches = {},
			batchList = {},
			singleParts = {},
			-- Largest max(X,Y,Z) among all non-duplicate parts in this chunk.
			-- Used by drawChunks for a fast whole-chunk LOD skip: if even the
			-- biggest part is below the LOD threshold the chunk is skipped without
			-- entering any inner loop.
			maxPartSize = 0,
			r3dAABB = structs.BoundingBox:new({
				min = vector.create(min.X, min.Y, min.Z),
				max = vector.create(max.X, max.Y, max.Z),
			}),
		}

		chunk.listIndex = #chunkList + 1
		chunkList[chunk.listIndex] = chunk
		chunks[key] = chunk
		markVisibleChunkCacheDirty()

		return chunk
	end

	local function updateLargePartChunkSpan(part)
		if not part or not part.CFrame or not part.Size then
			return
		end

		local cf = part.CFrame
		local center = cf.Position
		local half = part.Size * 0.5
		local right = cf:GetRightVector()
		local up = cf:GetUpVector()
		local look = cf:GetLookVector()
		local extent = Vector3.new(
			math.abs(right.X) * half.X + math.abs(up.X) * half.Y + math.abs(look.X) * half.Z,
			math.abs(right.Y) * half.X + math.abs(up.Y) * half.Y + math.abs(look.Y) * half.Z,
			math.abs(right.Z) * half.X + math.abs(up.Z) * half.Y + math.abs(look.Z) * half.Z
		)
		local min = center - extent
		local max = center + extent
		rawset(part, "__workspaceLargeMinChunk", Vector3.new(worldToChunk(min)))
		rawset(part, "__workspaceLargeMaxChunk", Vector3.new(worldToChunk(max)))
	end

	local function addPart(part)
		local pos = part.CFrame and part.CFrame.Position or part.Position
		local cx, cy, cz = worldToChunk(pos)
		local key = string.format("%d,%d,%d", cx, cy, cz)

		local chunk = chunks[key]
		if not chunk then
			chunk = makeChunk(cx, cy, cz, key)
		end

		chunk.parts[#chunk.parts + 1] = part
		chunk.dirty = true
		chunk.instanceDataDirty = true
		rawset(part, "__workspaceChunk", chunk)
		rawset(part, "__workspaceChunkKey", key)
		rawset(part, "__workspaceChunkIndex", #chunk.parts)
		rawset(part, "__workspaceOpaque", isPartOpaque(part))

		if part.Size and math.max(part.Size.X, part.Size.Y, part.Size.Z) > CHUNK_SIZE then
			largeParts[#largeParts + 1] = part
			rawset(part, "__workspaceLargeIndex", #largeParts)
			updateLargePartChunkSpan(part)
		end
	end

	local function markChunkDirty(chunk, structureChanged)
		if chunk then
			if structureChanged == true then
				chunk.dirty = true
			end
			chunk.instanceDataDirty = true
		end
	end

	local function unloadChunkBatches(chunk)
		if not chunk or not chunk.batches then
			return
		end
		for _, batch in pairs(chunk.batches) do
			if batch.instanceBuffer then
				pcall(rlib.R3D_UnloadInstanceBuffer, batch.instanceBuffer)
				batch.instanceBuffer = nil
			end
		end
	end

	local function removePart(part)
		local chunk = rawget(part, "__workspaceChunk")
		local key = rawget(part, "__workspaceChunkKey")
		local index = rawget(part, "__workspaceChunkIndex")
		if not chunk then
			return
		end

		if index then
			local lastIndex = #chunk.parts
			local lastPart = chunk.parts[lastIndex]
			chunk.parts[index] = lastPart
			chunk.parts[lastIndex] = nil
			if lastPart and lastPart ~= part then
				rawset(lastPart, "__workspaceChunkIndex", index)
			end
		end
		chunk.dirty = true
		chunk.instanceDataDirty = true

		rawset(part, "__workspaceChunk", nil)
		rawset(part, "__workspaceChunkKey", nil)
		rawset(part, "__workspaceChunkIndex", nil)
		rawset(part, "__workspaceOpaque", nil)
		rawset(part, "__workspaceLargeMinChunk", nil)
		rawset(part, "__workspaceLargeMaxChunk", nil)

		local largeIdx = rawget(part, "__workspaceLargeIndex")
		if largeIdx then
			local lastIdx = #largeParts
			local lastPart = largeParts[lastIdx]
			largeParts[largeIdx] = lastPart
			largeParts[lastIdx] = nil
			if lastPart and lastPart ~= part then
				rawset(lastPart, "__workspaceLargeIndex", largeIdx)
			end
			rawset(part, "__workspaceLargeIndex", nil)
		end

		if #chunk.parts <= 0 and key then
			unloadChunkBatches(chunk)
			local listIndex = chunk.listIndex
			local lastChunk = chunkList[#chunkList]
			chunkList[listIndex] = lastChunk
			chunkList[#chunkList] = nil
			if lastChunk and lastChunk ~= chunk then
				lastChunk.listIndex = listIndex
			end
			chunks[key] = nil
			markVisibleChunkCacheDirty()
		end
	end

	local function updatePartChunk(part)
		local oldChunk = rawget(part, "__workspaceChunk")
		local oldKey = rawget(part, "__workspaceChunkKey")
		local pos = part.CFrame and part.CFrame.Position or part.Position
		local cx, cy, cz = worldToChunk(pos)
		local newKey = string.format("%d,%d,%d", cx, cy, cz)

		if oldKey == newKey then
			markChunkDirty(oldChunk, false)
			return
		end

		removePart(part)
		addPart(part)
	end

	local function watchRenderablePart(part)
		if rawget(part, "__workspaceRenderConn") ~= nil then
			return
		end

		local conn = part.Changed:Connect(function(prop)
			if prop == "Position" or prop == "CFrame" then
				updatePartChunk(part)
				updateLargePartChunkSpan(part)
				rawset(part, "__matrixDirty", true)
				rawset(part, "__partAABB", nil)
				local batch = rawget(part, "__workspaceBatch")
				if batch then
					batch.instancesDirty = true
				end
				return
			end

			if prop == "Size" then
				updateLargePartChunkSpan(part)
				rawset(part, "__materialDirty", true)
				rawset(part, "__matrixDirty", true)
				rawset(part, "__partAABB", nil)
				local batch = rawget(part, "__workspaceBatch")
				if batch then
					batch.instancesDirty = true
					local chunk = rawget(part, "__workspaceChunk")
					if chunk then
						chunk.instanceDataDirty = true
					end
				end
			elseif prop == "Color" or prop == "Transparency" then
				rawset(part, "__materialDirty", true)
				if prop == "Transparency" then
					local chunk = rawget(part, "__workspaceChunk")
					local wasOpaque = rawget(part, "__workspaceOpaque")
					local isOpaqueNow = isPartOpaque(part)
					rawset(part, "__workspaceOpaque", isOpaqueNow)
					if wasOpaque ~= isOpaqueNow then
						markChunkDirty(chunk, true)
						return
					end
				end
				-- Same: only GPU update needed for batched parts.
				local batch = rawget(part, "__workspaceBatch")
				if batch then
					batch.instancesDirty = true
					local chunk = rawget(part, "__workspaceChunk")
					if chunk then
						chunk.instanceDataDirty = true
					end
				end
			elseif prop == "Material" or prop == "Shape" or prop == "MeshObject" or prop == "Destroyed" then
				markChunkDirty(rawget(part, "__workspaceChunk"), true)
				rawset(part, "__materialDirty", true)
				rawset(part, "__matrixDirty", true)
			end
		end)

		rawset(part, "__workspaceRenderConn", conn)
	end

	-- chunkVisible uses a precomputed `frustum` table built once per frame in
	-- drawChunks, eliminating per-chunk trig (atan2, asin, cos) and repeated
	-- camera-vector extraction.  The frustum stores four inward-facing plane
	-- normals derived from the camera FOV:
	--
	--   For a half-angle θ (horizontal or vertical):
	--     nRight  = forward*sin(θ) - right*cos(θ)   (right wall, inward)
	--     nLeft   = forward*sin(θ) + right*cos(θ)   (left  wall, inward)
	--     nTop    = forward*sin(θ) - up*cos(θ)      (top   wall, inward)
	--     nBottom = forward*sin(θ) + up*cos(θ)      (bottom wall, inward)
	--
	-- A sphere (center C, radius r) is OUTSIDE a plane n when:
	--   dot(C - camPos, n) < -r
	--
	-- No trig at all inside the per-chunk loop; only five dot products.
	local function chunkVisible(chunk, camPos, maxDist, frustum)
		local dx = chunk.center.X - camPos.X
		local dy = chunk.center.Y - camPos.Y
		local dz = chunk.center.Z - camPos.Z
		local distSq = dx * dx + dy * dy + dz * dz
		local r = chunk.boundsRadius + (chunk.maxPartSize or 0) * 0.866
		local maxReach = maxDist + r
		if distSq > maxReach * maxReach then
			return false
		end

		if not frustum then
			-- Frustum culling disabled or frustum not yet built.
			return true
		end

		-- Camera is inside the chunk sphere: always visible.
		if distSq <= r * r then
			return true
		end

		-- Behind-camera rejection (no trig).
		if (frustum.forward.X * dx + frustum.forward.Y * dy + frustum.forward.Z * dz) < -r then
			return false
		end

		-- Four frustum-plane tests using precomputed inward normals.
		if (frustum.nRight.X * dx + frustum.nRight.Y * dy + frustum.nRight.Z * dz) < -r then
			return false
		end
		if (frustum.nLeft.X * dx + frustum.nLeft.Y * dy + frustum.nLeft.Z * dz) < -r then
			return false
		end
		if (frustum.nTop.X * dx + frustum.nTop.Y * dy + frustum.nTop.Z * dz) < -r then
			return false
		end
		if (frustum.nBottom.X * dx + frustum.nBottom.Y * dy + frustum.nBottom.Z * dz) < -r then
			return false
		end

		return true
	end

	local meshlib = renderer.Mesh
	local materialList = renderer.Texture.GetMaterials()
	local loadedMaterials = {}
	local availableMaterials = {}
	local INSTANCE_POSITION_STRIDE = 12 -- vec3 (f32 x3)
	local INSTANCE_ROTATION_STRIDE = 16 -- quat (f32 x4)
	local INSTANCE_SCALE_STRIDE = 12 -- vec3 (f32 x3)
	local INSTANCE_COLOR_STRIDE = 4 -- rgba8
	local R3D_CULL_BACK = 1
	local OFF_MATERIAL_ALBEDO = r3d.structs.R3D_Material:offset("albedo")
	local OFF_MATERIAL_TRANSPARENCY_MODE = r3d.structs.R3D_Material:offset("transparencyMode")
	local OFF_MATERIAL_CULL_MODE = r3d.structs.R3D_Material:offset("cullMode")
	local OFF_MATERIAL_UVSCALE = r3d.structs.R3D_Material:offset("uvScale")
	local OFF_MATERIAL_SHADER = r3d.structs.R3D_Material:offset("shader")
	local OFF_ALBEDO_COLOR = r3d.structs.R3D_AlbedoMap:offset("color")
	local SIZE_MATERIAL = r3d.structs.R3D_Material:size()
	local SIZE_ALBEDO = r3d.structs.R3D_AlbedoMap:size()
	local INSTANCE_FLAGS = bit32.bor(
		const.R3D_INSTANCE_POSITION,
		const.R3D_INSTANCE_ROTATION,
		const.R3D_INSTANCE_SCALE,
		const.R3D_INSTANCE_COLOR
	)
	local instancedMaterialCache = {}
	local lastUseGpuInstancing = true
	local lastMinInstancesPerBatch = 1

	local fallbackMaterial = {
		index = -1,
		material = rlib.R3D_GetDefaultMaterial(),
	}

	local preloadedMeshes
	if not IsHeadless then
		local stdMeshPreloadStart = os.clock()
		preloadedMeshes = meshlib.PreloadStandardMeshes()
		iodebug(string.format("Preloaded standard meshes in %.3fms", (os.clock() - stdMeshPreloadStart) * 1000))

		local default = rlib.R3D_GetDefaultMaterial()

		local material_index = 0
		for material_name, material_path in pairs(materialList) do
			local material = buffer.create(buffer.len(default))
			buffer.copy(material, 0, default)

			availableMaterials[material_name] = {
				index = material_index,
				material = material,
				path = material_path,
			}

			if mtsh_sh[material_name] then
				mtsh_sh[material_name].Apply(material)
			end

			material_index += 1
		end
	end

	proptable.materials = availableMaterials

	signal:Connect(function(route, data) end)

	local function isRenderable(obj)
		return obj.BaseClass == "BasePart"
	end

	local function visitSubtree(root, callback)
		local stack = { root }
		local top = 1
		while top > 0 do
			local node = stack[top]
			stack[top] = nil
			top -= 1
			callback(node)
			local children = node:GetChildren()
			for i = 1, #children do
				top += 1
				stack[top] = children[i]
			end
		end
	end

	local function registerWorkspaceObject(v)
		pool[v.UniqueId] = v
		IdPool[v.UniqueId] = v
		if isRenderable(v) and rawget(v, "__workspaceRenderableIndex") == nil then
			addPart(v)
			watchRenderablePart(v)
			signal:Fire("UpdatePart", v)
			pool[v.UniqueId]._renderable = true
			renderablePool[#renderablePool + 1] = v
			rawset(v, "__workspaceRenderableIndex", #renderablePool)
		end
	end

	local function unregisterWorkspaceObject(v)
		if isRenderable(v) then
			local conn = rawget(v, "__workspaceRenderConn")
			if conn and conn.Disconnect then
				conn:Disconnect()
			end
			rawset(v, "__workspaceRenderConn", nil)
			removePart(v)
		end
		pool[v.UniqueId] = nil
		IdPool[v.UniqueId] = nil
		local idx = rawget(v, "__workspaceRenderableIndex")
		if idx then
			local lastIndex = #renderablePool
			local lastRenderable = renderablePool[lastIndex]
			renderablePool[idx] = lastRenderable
			renderablePool[lastIndex] = nil
			if lastRenderable and lastRenderable ~= v then
				rawset(lastRenderable, "__workspaceRenderableIndex", idx)
			end
			rawset(v, "__workspaceRenderableIndex", nil)
		end
	end

	Workspace.DescendantAdded:Connect(function(v)
		local startTime = os.clock()
		local count = 0
		visitSubtree(v, function(child)
			count += 1
			registerWorkspaceObject(child)
		end)
		if count > 50 then
			print(
				string.format(
					"[Workspace] Registered %d descendants in %.2f ms",
					count,
					(os.clock() - startTime) * 1000
				)
			)
		end
	end)

	Workspace.DescendantRemoving:Connect(function(v)
		visitSubtree(v, unregisterWorkspaceObject)
	end)

	for _, child in pairs(Workspace:GetDescendants()) do
		registerWorkspaceObject(child)
	end

	local function loadMaterial(materialName, sync)
		if loadedMaterials[materialName] then
			return loadedMaterials[materialName]
		end

		local mtl_info = availableMaterials[materialName]
		if not mtl_info then
			return nil
		end
		if mtl_info.loading then
			return nil
		end

		local function processLoad()
			local material = mtl_info.material
			mtl_info.loading = true

			local function read(path): (buffer?, string?)
				if not path then
					return nil, nil
				end
				local success, result = pcall(zune.fs.readFileSync, path, true)
				if success then
					return result, raylib.lib.GetFileExtension(path)
				else
					return nil, nil
				end
			end

			iodebug(string.format("Loading custom material %s", materialName))
			local materialLoadStart = os.clock()
			local data_albedo, data_albedo_ext = read(mtl_info.path.albedo)
			local data_normal, data_normal_ext = read(mtl_info.path.normal)
			local data_orm, data_orm_ext = read(mtl_info.path.orm)
			iodebug(
				string.format(
					"Loaded custom material %s in %.3fms",
					materialName,
					(os.clock() - materialLoadStart) * 1000
				)
			)

			local materialProcessStart = os.clock()
			if data_albedo then
				iodebug(string.format("Found albedo map, processing"))
				local map = rlib.R3D_LoadAlbedoMapFromMemory(
					data_albedo_ext,
					data_albedo,
					buffer.len(data_albedo),
					raylib.const.WHITE
				)
				buffer.copy(
					material,
					r3d.structs.R3D_Material:offset("albedo"),
					map,
					0,
					r3d.structs.R3D_AlbedoMap:size()
				)
			end
			if data_normal then
				iodebug(string.format("Found normal map, processing"))
				local map = rlib.R3D_LoadNormalMapFromMemory(data_normal_ext, data_normal, buffer.len(data_normal), 1)
				buffer.copy(
					material,
					r3d.structs.R3D_Material:offset("normal"),
					map,
					0,
					r3d.structs.R3D_NormalMap:size()
				)
			end
			if data_orm then
				iodebug(string.format("Found ORM map, processing"))
				local map = rlib.R3D_LoadOrmMapFromMemory(data_orm_ext, data_orm, buffer.len(data_orm), 1, 1, 0)
				buffer.copy(material, r3d.structs.R3D_Material:offset("orm"), map, 0, r3d.structs.R3D_OrmMap:size())
			end
			if mtsh_sh[materialName] then
				mtsh_sh[materialName].Apply(material)
			end

			mtl_info.loading = false
			loadedMaterials[materialName] = mtl_info

			iodebug(
				string.format(
					"Processed custom material %s in %.3fms",
					materialName,
					(os.clock() - materialProcessStart) * 1000
				)
			)
			return mtl_info
		end

		if sync then
			return processLoad()
		end

		zune.task.spawn(processLoad)
		return nil
	end

	local function getInstancedMaterial(materialName, isOpaque)
		local matData = loadedMaterials[materialName] or loadMaterial(materialName) or fallbackMaterial
		if not matData then
			return nil
		end

		local matKey = materialName .. (isOpaque and "_opaque" or "_transparent")
		if not instancedMaterialCache[matKey] then
			local materialBuffer = buffer.create(SIZE_MATERIAL)
			buffer.copy(materialBuffer, 0, matData.material, 0, SIZE_MATERIAL)
			buffer.writei32(
				materialBuffer,
				OFF_MATERIAL_TRANSPARENCY_MODE,
				isOpaque and const.R3D_TRANSPARENCY_DISABLED or const.R3D_TRANSPARENCY_PREPASS
			)
			buffer.writei32(materialBuffer, OFF_MATERIAL_CULL_MODE, R3D_CULL_BACK)
			instancedMaterialCache[matKey] = materialBuffer
		end

		return instancedMaterialCache[matKey]
	end

	local reusableCustomMatData = { material = nil }
	local function queueSinglePartDraw(part, r3dAABB)
		local cf = part and part.CFrame
		local size = part and part.Size
		if not cf or cf.ToRaylibMatrixScale == nil or not size or size.X == nil or size.Y == nil or size.Z == nil then
			return
		end

		local isMeshPart = part:IsA("MeshPart")
		local shapeName = part.Shape and part.Shape.Value
		local materialName = part.Material and part.Material.Value

		local mesh = nil
		local customMaterial = nil
		if isMeshPart then
			if part.MeshObject and part.MeshObject._meshgenHandle then
				mesh = part.MeshObject._meshgenHandle
				customMaterial = part.MeshObject._materialHandle
			end
		elseif shapeName then
			local meshData = preloadedMeshes and preloadedMeshes[shapeName]
			if meshData then
				mesh = meshData[2]
			end
		end

		if not mesh then
			return
		end

		local matData
		if customMaterial then
			reusableCustomMatData.material = customMaterial
			matData = reusableCustomMatData
		else
			if not materialName then
				return
			end
			matData = loadedMaterials[materialName] or loadMaterial(materialName) or fallbackMaterial
		end

		if not matData then
			return
		end

		-- Cache the transform matrix per-part. Only recomputed when CFrame or Size
		-- changes (invalidated via watchRenderablePart). For static/anchored maps
		-- this eliminates the matrix decompose + multiply every frame.
		local matrix = rawget(part, "__cachedMatrix")
		local isMatrixDirty = rawget(part, "__matrixDirty")
		if not matrix or isMatrixDirty then
			matrix = cf:ToRaylibMatrixScale(size, raylib.structs)
			rawset(part, "__cachedMatrix", matrix)
			rawset(part, "__matrixDirty", false)
		end

		-- Cache the combined material buffer per-part. Only rebuilt when Color,
		-- Transparency, Size (UV scale), or Material changes -- NOT every frame.
		-- For a 1000-part map at 60fps this eliminates ~120,000 buffer.create()
		-- calls per second down to 0 for static geometry.
		local tmpMaterial = rawget(part, "__cachedMaterial")
		local tmpAlbedo = rawget(part, "__cachedAlbedo")
		local isMaterialDirty = rawget(part, "__materialDirty")
		if not tmpMaterial or not tmpAlbedo or isMaterialDirty then
			if not tmpAlbedo then
				tmpAlbedo = buffer.create(SIZE_ALBEDO)
				rawset(part, "__cachedAlbedo", tmpAlbedo)
			end
			buffer.copy(tmpAlbedo, 0, matData.material, OFF_MATERIAL_ALBEDO, SIZE_ALBEDO)
			buffer.copy(tmpAlbedo, OFF_ALBEDO_COLOR, part.Color:ToRaylib(part.Transparency or 0))

			if not tmpMaterial then
				tmpMaterial = buffer.create(SIZE_MATERIAL)
				rawset(part, "__cachedMaterial", tmpMaterial)
			end
			buffer.copy(tmpMaterial, 0, matData.material, 0, SIZE_MATERIAL)
			buffer.copy(tmpMaterial, OFF_MATERIAL_ALBEDO, tmpAlbedo)

			buffer.writei32(
				tmpMaterial,
				OFF_MATERIAL_TRANSPARENCY_MODE,
				isPartOpaque(part) and const.R3D_TRANSPARENCY_DISABLED or const.R3D_TRANSPARENCY_PREPASS
			)

			if activeMaterialShader then
				buffer.copy(tmpMaterial, OFF_MATERIAL_SHADER, activeMaterialShader)
			end

			buffer.writei32(tmpMaterial, OFF_MATERIAL_CULL_MODE, R3D_CULL_BACK)

			buffer.writef32(tmpMaterial, OFF_MATERIAL_UVSCALE, size.X)
			buffer.writef32(tmpMaterial, OFF_MATERIAL_UVSCALE + 4, size.Z)

			local materialShader = mtsh_sh[materialName]
			local applyPerObject = materialShader and (materialShader.Apply3Dbj or materialShader.Apply3DObj)
			if applyPerObject then
				applyPerObject(part, tmpAlbedo, tmpMaterial)
			end

			rawset(part, "__materialDirty", false)
		end

		renderer.MeshPool.DrawMesh(mesh, tmpMaterial, matrix)
	end

	local globalPositionBuffer = buffer.create(1024 * INSTANCE_POSITION_STRIDE)
	local globalRotationBuffer = buffer.create(1024 * INSTANCE_ROTATION_STRIDE)
	local globalScaleBuffer = buffer.create(1024 * INSTANCE_SCALE_STRIDE)
	local globalColorBuffer = buffer.create(1024 * INSTANCE_COLOR_STRIDE)
	local globalBufferCapacity = 1024

	local function compactBatchParts(parts)
		local writeIndex = 1
		for i = 1, #parts do
			local part = parts[i]
			local cf = part and part.CFrame
			local size = part and part.Size
			if
				part
				and not part.Destroyed
				and cf
				and cf.Position
				and cf.ToQuaternion ~= nil
				and size
				and size.X ~= nil
				and size.Y ~= nil
				and size.Z ~= nil
			then
				parts[writeIndex] = part
				writeIndex += 1
			end
		end

		for i = writeIndex, #parts do
			parts[i] = nil
		end

		return writeIndex - 1
	end

	local function ensureGlobalBufferCapacity(count)
		if count > globalBufferCapacity then
			local newCapacity = count * 2
			globalPositionBuffer = buffer.create(newCapacity * INSTANCE_POSITION_STRIDE)
			globalRotationBuffer = buffer.create(newCapacity * INSTANCE_ROTATION_STRIDE)
			globalScaleBuffer = buffer.create(newCapacity * INSTANCE_SCALE_STRIDE)
			globalColorBuffer = buffer.create(newCapacity * INSTANCE_COLOR_STRIDE)
			globalBufferCapacity = newCapacity
		end
	end

	local function uploadBatchInstances(batch)
		local count = compactBatchParts(batch.parts)
		if count <= 0 then
			batch.count = 0
			return false
		end

		if batch.instanceBuffer and batch.capacity and batch.capacity < count then
			pcall(rlib.R3D_UnloadInstanceBuffer, batch.instanceBuffer)
			batch.instanceBuffer = nil
			batch.capacity = 0
		end

		if not batch.instanceBuffer then
			local okLoad, loadedBuffer = pcall(rlib.R3D_LoadInstanceBuffer, count, INSTANCE_FLAGS)
			if not okLoad or not loadedBuffer then
				return false
			end
			batch.instanceBuffer = loadedBuffer
			batch.capacity = count
		end

		local mappedPosition = nil
		local mappedRotation = nil
		local mappedScale = nil
		local mappedColor = nil

		local okMap = pcall(function()
			mappedPosition = rlib.R3D_MapInstances(batch.instanceBuffer, const.R3D_INSTANCE_POSITION)
			mappedRotation = rlib.R3D_MapInstances(batch.instanceBuffer, const.R3D_INSTANCE_ROTATION)
			mappedScale = rlib.R3D_MapInstances(batch.instanceBuffer, const.R3D_INSTANCE_SCALE)
			mappedColor = rlib.R3D_MapInstances(batch.instanceBuffer, const.R3D_INSTANCE_COLOR)
		end)

		local okUpload = false
		local mappedFlags = bit32.bor(
			mappedPosition and const.R3D_INSTANCE_POSITION or 0,
			mappedRotation and const.R3D_INSTANCE_ROTATION or 0,
			mappedScale and const.R3D_INSTANCE_SCALE or 0,
			mappedColor and const.R3D_INSTANCE_COLOR or 0
		)

		if okMap and mappedFlags == INSTANCE_FLAGS then
			local okWrite = pcall(function()
				-- Localize the parts array and stride constants to reduce table
				-- indexing and upvalue lookups in the hot inner loop.
				local parts = batch.parts
				local posStride = INSTANCE_POSITION_STRIDE
				local rotStride = INSTANCE_ROTATION_STRIDE
				local sclStride = INSTANCE_SCALE_STRIDE
				local clrStride = INSTANCE_COLOR_STRIDE
				for i = 1, count do
					local part = parts[i]
					local cf = part.CFrame
					local position = cf and cf.Position or part.Position
					local size = part.Size
					local qx, qy, qz, qw = cf:ToQuaternion()
					local color = part.Color
					local r, g, b = color:ToRGB()
					local alpha = math.clamp(math.floor(255 * (1 - (part.Transparency or 0))), 0, 255)

					local pOffset = (i - 1) * posStride
					mappedPosition:writef32(pOffset, position.X)
					mappedPosition:writef32(pOffset + 4, position.Y)
					mappedPosition:writef32(pOffset + 8, position.Z)

					local rOffset = (i - 1) * rotStride
					mappedRotation:writef32(rOffset, qx)
					mappedRotation:writef32(rOffset + 4, qy)
					mappedRotation:writef32(rOffset + 8, qz)
					mappedRotation:writef32(rOffset + 12, qw)

					local sOffset = (i - 1) * sclStride
					mappedScale:writef32(sOffset, size.X)
					mappedScale:writef32(sOffset + 4, size.Y)
					mappedScale:writef32(sOffset + 8, size.Z)

					local cOffset = (i - 1) * clrStride
					mappedColor:writeu8(cOffset, r)
					mappedColor:writeu8(cOffset + 1, g)
					mappedColor:writeu8(cOffset + 2, b)
					mappedColor:writeu8(cOffset + 3, alpha)
				end
			end)

			local okUnmap = pcall(rlib.R3D_UnmapInstances, batch.instanceBuffer, INSTANCE_FLAGS)
			okUpload = okWrite and okUnmap
		else
			if mappedFlags ~= 0 then
				pcall(rlib.R3D_UnmapInstances, batch.instanceBuffer, mappedFlags)
			end

			ensureGlobalBufferCapacity(count)

			local parts = batch.parts
			for i = 1, count do
				local part = parts[i]
				local cf = part.CFrame
				local position = cf and cf.Position or part.Position
				local size = part.Size
				local qx, qy, qz, qw = cf:ToQuaternion()
				local color = part.Color
				local r, g, b = color:ToRGB()
				local alpha = math.clamp(math.floor(255 * (1 - (part.Transparency or 0))), 0, 255)

				local pOffset = (i - 1) * INSTANCE_POSITION_STRIDE
				buffer.writef32(globalPositionBuffer, pOffset, position.X)
				buffer.writef32(globalPositionBuffer, pOffset + 4, position.Y)
				buffer.writef32(globalPositionBuffer, pOffset + 8, position.Z)

				local rOffset = (i - 1) * INSTANCE_ROTATION_STRIDE
				buffer.writef32(globalRotationBuffer, rOffset, qx)
				buffer.writef32(globalRotationBuffer, rOffset + 4, qy)
				buffer.writef32(globalRotationBuffer, rOffset + 8, qz)
				buffer.writef32(globalRotationBuffer, rOffset + 12, qw)

				local sOffset = (i - 1) * INSTANCE_SCALE_STRIDE
				buffer.writef32(globalScaleBuffer, sOffset, size.X)
				buffer.writef32(globalScaleBuffer, sOffset + 4, size.Y)
				buffer.writef32(globalScaleBuffer, sOffset + 8, size.Z)

				local cOffset = (i - 1) * INSTANCE_COLOR_STRIDE
				buffer.writeu8(globalColorBuffer, cOffset, r)
				buffer.writeu8(globalColorBuffer, cOffset + 1, g)
				buffer.writeu8(globalColorBuffer, cOffset + 2, b)
				buffer.writeu8(globalColorBuffer, cOffset + 3, alpha)
			end

			okUpload = pcall(function()
				rlib.R3D_UploadInstances(
					batch.instanceBuffer,
					const.R3D_INSTANCE_POSITION,
					0,
					count,
					globalPositionBuffer
				)
				rlib.R3D_UploadInstances(
					batch.instanceBuffer,
					const.R3D_INSTANCE_ROTATION,
					0,
					count,
					globalRotationBuffer
				)
				rlib.R3D_UploadInstances(batch.instanceBuffer, const.R3D_INSTANCE_SCALE, 0, count, globalScaleBuffer)
				rlib.R3D_UploadInstances(batch.instanceBuffer, const.R3D_INSTANCE_COLOR, 0, count, globalColorBuffer)
			end)
		end

		if not okUpload then
			pcall(rlib.R3D_UnloadInstanceBuffer, batch.instanceBuffer)
			batch.instanceBuffer = nil
			batch.capacity = 0
			return false
		end

		batch.count = count
		return true
	end

	local function refreshChunkInstanceBuffers(chunk)
		if not chunk or not chunk.batches then
			return
		end

		-- Per-batch dirty tracking: only re-upload GPU buffers for batches whose
		-- data has actually changed. Skips clean batches entirely, saving GPU
		-- bandwidth and Luau overhead when only a few parts move each frame.
		-- SinglParts don't have GPU instance buffers, so they're not touched here.
		for i = 1, #chunk.batchList do
			local batch = chunk.batchList[i]
			if batch.instancesDirty and #batch.parts >= Workspace.MinInstancesPerBatch then
				uploadBatchInstances(batch)
				batch.instancesDirty = false
			end
		end

		chunk.instanceDataDirty = false
	end

	local globalSeenTransforms = {}

	local function rebuildChunkBatches(chunk)
		unloadChunkBatches(chunk)
		chunk.batches = {}
		chunk.batchList = {}
		chunk.singleParts = {}

		-- Per-rebuild transform deduplication table.
		-- Parts that share the exact CFrame (position + rotation) and Size with
		-- a previously-processed part are completely occluded  skip them to
		-- save draw calls and GPU overdraw. This catches accidentally duplicated
		-- or layered-but-identical geometry common in imported maps.
		-- The key encodes position and size to 0.01-stud precision and rotation
		-- (via quaternion) to 0.001 precision. q and -q are the same rotation
		-- so we normalise the sign before hashing.
		table.clear(globalSeenTransforms)

		for i = 1, #chunk.parts do
			local part = chunk.parts[i]
			if not isRenderable(part) or part.Destroyed then
				continue
			end

			-- Deduplication: build a compact transform+size fingerprint and
			-- skip this part if one with the same shape already exists.
			do
				local cf = part.CFrame
				local sz = part.Size
				if
					not cf
					or not cf.Position
					or cf.ToQuaternion == nil
					or not sz
					or sz.X == nil
					or sz.Y == nil
					or sz.Z == nil
				then
					rawset(part, "__workspaceDuplicate", true)
					continue
				end

				local pos = cf.Position
				local qx, qy, qz, qw = cf:ToQuaternion()
				-- Normalise quaternion sign so q and -q hash identically.
				if qw < 0 then
					qx, qy, qz, qw = -qx, -qy, -qz, -qw
				end
				local f = math.floor
				local key = string.format(
					"%d,%d,%d,%d,%d,%d",
					f(pos.X * 10),
					f(pos.Y * 10),
					f(pos.Z * 10),
					f(sz.X * 10),
					f(sz.Y * 10),
					f(sz.Z * 10)
				)
				if globalSeenTransforms[key] then
					rawset(part, "__workspaceDuplicate", true)
					continue
				end
				globalSeenTransforms[key] = true
				rawset(part, "__workspaceDuplicate", false)
			end

			local isMeshPart = part:IsA("MeshPart")
			local shapeName = part.Shape and part.Shape.Value
			local materialName = part.Material and part.Material.Value

			local mesh = nil
			local meshKey = ""
			local customMaterial = nil
			if isMeshPart then
				local meshObject = part.MeshObject
				if meshObject and meshObject._meshgenHandle then
					mesh = meshObject._meshgenHandle
					customMaterial = meshObject._materialHandle
					-- Batch by the actual GPU mesh handle instead of per-object identity.
					-- This lets repeated MeshParts that share the same uploaded mesh
					-- collapse into one instanced batch even when their mesh objects
					-- are distinct Luau instances.
					meshKey = "meshobj_" .. tostring(mesh)
				end
			elseif shapeName then
				local meshData = preloadedMeshes and preloadedMeshes[shapeName]
				if meshData then
					mesh = meshData[2]
					meshKey = shapeName
				end
			end

			local matData
			if customMaterial then
				reusableCustomMatData.material = customMaterial
				matData = reusableCustomMatData
				materialName = "__custom_" .. tostring(customMaterial)
			else
				matData = materialName and loadedMaterials[materialName]
					or loadMaterial(materialName)
					or fallbackMaterial
			end

			if not mesh or not matData then
				continue
			end

			local materialShader = mtsh_sh[materialName]
			local hasPerObjectShader = materialShader and (materialShader.Apply3Dbj or materialShader.Apply3DObj)
			local isOpaque = isPartOpaque(part)
			local canInstance = Workspace.UseGpuInstancing
				and renderer.MeshPool.DrawMeshInstanced ~= nil
				and not hasPerObjectShader

			if canInstance then
				local key = meshKey .. "|" .. materialName .. "|" .. tostring(isOpaque)
				local batch = chunk.batches[key]
				if not batch then
					local instancedMaterial = nil
					if customMaterial then
						local matKey = "custom_"
							.. tostring(customMaterial)
							.. (isOpaque and "_opaque" or "_transparent")
						if not instancedMaterialCache[matKey] then
							local materialBuffer = buffer.create(SIZE_MATERIAL)
							buffer.copy(materialBuffer, 0, customMaterial, 0, SIZE_MATERIAL)
							buffer.writei32(
								materialBuffer,
								OFF_MATERIAL_TRANSPARENCY_MODE,
								isOpaque and const.R3D_TRANSPARENCY_DISABLED or const.R3D_TRANSPARENCY_PREPASS
							)
							buffer.writei32(materialBuffer, OFF_MATERIAL_CULL_MODE, R3D_CULL_BACK)
							instancedMaterialCache[matKey] = materialBuffer
						end
						instancedMaterial = instancedMaterialCache[matKey]
					else
						instancedMaterial = getInstancedMaterial(materialName, isOpaque)
					end

					if not instancedMaterial then
						rawset(part, "__materialDirty", true)
						rawset(part, "__matrixDirty", true)
						table.insert(chunk.singleParts, part)
						continue
					end

					batch = {
						mesh = mesh,
						material = instancedMaterial,
						parts = {},
						count = 0,
						instanceBuffer = nil,
						capacity = 0,
						instancesDirty = true,
					}
					chunk.batches[key] = batch
					chunk.batchList[#chunk.batchList + 1] = batch
				end
				-- Track which batch owns this part so Changed can mark only that
				-- batch dirty instead of the entire chunk.
				rawset(part, "__workspaceBatch", batch)
				table.insert(batch.parts, part)
			else
				-- Clear caches when falling back to single draw (no instancing)
				rawset(part, "__materialDirty", true)
				rawset(part, "__matrixDirty", true)
				rawset(part, "__workspaceBatch", nil)
				table.insert(chunk.singleParts, part)
			end
		end

		-- LOD thresholds for sorting/counting (read once per rebuild).
		local lod1Size = Workspace.LOD1MinSize or 2
		local lod2Size = Workspace.LOD2MinSize or 6
		local lod3Size = Workspace.LOD3MinSize or 16

		-- Compute chunk.maxPartSize: the largest max(X,Y,Z) across all
		-- non-duplicate renderable parts.  Lets drawChunks skip the entire
		-- chunk in a single comparison when the LOD threshold is not met.
		local maxPS = 0
		for _, part in ipairs(chunk.parts) do
			if not rawget(part, "__workspaceDuplicate") then
				local sz = part.Size
				if sz and sz.X ~= nil and sz.Y ~= nil and sz.Z ~= nil then
					local pm = math.max(sz.X, sz.Y, sz.Z)
					if pm > maxPS then
						maxPS = pm
					end
				end
			end
		end
		chunk.maxPartSize = maxPS

		local expansion = maxPS * 0.5
		chunk.r3dAABB = structs.BoundingBox:new({
			min = vector.create(chunk.aabbMin.X - expansion, chunk.aabbMin.Y - expansion, chunk.aabbMin.Z - expansion),
			max = vector.create(chunk.aabbMax.X + expansion, chunk.aabbMax.Y + expansion, chunk.aabbMax.Z + expansion),
		})

		for i = 1, #chunk.batchList do
			local batch = chunk.batchList[i]
			local n = #batch.parts

			if n >= Workspace.MinInstancesPerBatch then
				-- Sort batch parts largest-first by max dimension so that LOD
				-- distance-based count reduction always retains the most visible
				-- (biggest) instances at the head of the GPU buffer.
				table.sort(batch.parts, function(a, b)
					local sa = a.Size
					local sb = b.Size
					local ma = (sa and sa.X ~= nil and sa.Y ~= nil and sa.Z ~= nil) and math.max(sa.X, sa.Y, sa.Z) or 0
					local mb = (sb and sb.X ~= nil and sb.Y ~= nil and sb.Z ~= nil) and math.max(sb.X, sb.Y, sb.Z) or 0
					return ma > mb
				end)

				-- Precompute per-LOD-level instance counts.
				-- countLODk = number of parts at the start of the sorted array
				-- whose max(X,Y,Z) >= LODkMinSize.  Stored on the batch; used
				-- at draw time to pass a smaller count to DrawMeshInstanced.
				local countLOD1 = n -- default: all parts pass LOD1
				for j = 1, n do
					local sz = batch.parts[j].Size
					if not sz or sz.X == nil or sz.Y == nil or sz.Z == nil or math.max(sz.X, sz.Y, sz.Z) < lod1Size then
						countLOD1 = j - 1
						break
					end
				end

				local countLOD2 = 0
				for j = 1, countLOD1 do
					local sz = batch.parts[j].Size
					if not sz or sz.X == nil or sz.Y == nil or sz.Z == nil or math.max(sz.X, sz.Y, sz.Z) < lod2Size then
						break
					end
					countLOD2 = j
				end

				local countLOD3 = 0
				for j = 1, countLOD2 do
					local sz = batch.parts[j].Size
					if not sz or sz.X == nil or sz.Y == nil or sz.Z == nil or math.max(sz.X, sz.Y, sz.Z) < lod3Size then
						break
					end
					countLOD3 = j
				end

				batch.lodCount1 = countLOD1
				batch.lodCount2 = countLOD2
				batch.lodCount3 = countLOD3

				local ok = uploadBatchInstances(batch)
				if not ok then
					for j = 1, n do
						table.insert(chunk.singleParts, batch.parts[j])
					end
				end
			end
		end

		chunk.dirty = false
		chunk.instanceDataDirty = false
	end

	-- Cached settings key: rebuilt only when the relevant workspace properties
	-- actually change, avoiding a table.concat allocation every frame.
	local cachedSettingsKey = nil
	local cachedSettingsKeyMD = nil
	local cachedSettingsKeyFC = nil
	local cachedSettingsKeyFP = nil

	local function getSettingsKey()
		local md = Workspace.MAX_VIEW_DISTANCE
		local fc = Workspace.EnableViewFrustumCulling
		local fp = Workspace.ViewFrustumPadding
		if md ~= cachedSettingsKeyMD or fc ~= cachedSettingsKeyFC or fp ~= cachedSettingsKeyFP then
			cachedSettingsKey = md .. "|" .. tostring(fc) .. "|" .. fp
			cachedSettingsKeyMD = md
			cachedSettingsKeyFC = fc
			cachedSettingsKeyFP = fp
		end
		return cachedSettingsKey
	end

	local function drawChunks()
		raylib.lib.rlSetClipPlanes(0.1, Workspace.MAX_VIEW_DISTANCE)

		local Kinemium_camera = Workspace.Camera
		if not Kinemium_camera then
			return
		end

		local cameraCF = Kinemium_camera.CFrame
		if not cameraCF or cameraCF.Position == nil or cameraCF.GetLookVector == nil then
			return
		end

		local forceDirty = false
		if
			Workspace.UseGpuInstancing ~= lastUseGpuInstancing
			or Workspace.MinInstancesPerBatch ~= lastMinInstancesPerBatch
		then
			lastUseGpuInstancing = Workspace.UseGpuInstancing
			lastMinInstancesPerBatch = Workspace.MinInstancesPerBatch
			forceDirty = true
		end

		local camPos = cameraCF.Position
		local camLook = cameraCF:GetLookVector()
		local refreshDistance = Workspace.VisibilityRefreshDistance or 0
		local refreshDistanceSq = refreshDistance * refreshDistance
		local refreshDotThreshold = Workspace.VisibilityRefreshDotThreshold or 0.9925
		local settingsKey = getSettingsKey()

		local shouldRefreshVisibleChunks = forceDirty
			or visibleChunkCacheDirty
			or lastVisibleChunkSettingsKey ~= settingsKey
			or lastVisibilityMaxDistance ~= Workspace.MAX_VIEW_DISTANCE
			or lastVisibilityCameraPos == nil
			or lastVisibilityCameraLook == nil

		-- Track whether the camera POSITION changed (not just rotation). The
		-- sort is keyed on distance-from-camera, so it only needs to re-run
		-- when position changes, not every camera look-direction change.
		local cameraPositionChanged = lastVisibilityCameraPos == nil

		if not shouldRefreshVisibleChunks then
			local cameraDelta = camPos - lastVisibilityCameraPos
			local camDeltaSq = cameraDelta:MagnitudeSquared()
			if camDeltaSq >= refreshDistanceSq then
				shouldRefreshVisibleChunks = true
				cameraPositionChanged = true
			elseif camLook:Dot(lastVisibilityCameraLook) <= refreshDotThreshold then
				shouldRefreshVisibleChunks = true
				-- rotation-only refresh: visible set may change but distances don't
			end
		end

		if shouldRefreshVisibleChunks then
			-- Build frustum planes once per refresh, outside the per-chunk loop.
			-- Each plane is an inward-facing normal so that a sphere with center C
			-- and radius r is OUTSIDE the frustum when dot(C - camPos, n) < -r.
			-- This replaces per-chunk atan2/asin with five dot products per chunk.
			local frustum = nil
			if Workspace.EnableViewFrustumCulling then
				local cf = cameraCF
				local forward = cf:GetLookVector()
				local right = cf:GetRightVector()
				local up = cf:GetUpVector()

				local viewport = Kinemium_camera.ViewportSize
				local aspect = (viewport and viewport.X > 0 and viewport.Y > 0) and (viewport.X / viewport.Y)
					or (16 / 9)

				local halfVFov = math.rad((Kinemium_camera.FieldOfView or 70) * 0.5)
				local halfHFov = math.atan(math.tan(halfVFov) * aspect)
				local pad = math.rad(Workspace.ViewFrustumPadding or 0)

				local sinH = math.sin(halfHFov + pad)
				local cosH = math.cos(halfHFov + pad)
				local sinV = math.sin(halfVFov + pad)
				local cosV = math.cos(halfVFov + pad)

				frustum = {
					forward = forward,
					nRight = forward * sinH - right * cosH,
					nLeft = forward * sinH + right * cosH,
					nTop = forward * sinV - up * cosV,
					nBottom = forward * sinV + up * cosV,
				}
			end

			table.clear(visibleChunks)
			for i = 1, #chunkList do
				local chunk = chunkList[i]
				if chunk and chunkVisible(chunk, camPos, Workspace.MAX_VIEW_DISTANCE, frustum) then
					visibleChunks[#visibleChunks + 1] = chunk
				end
			end

			-- Sort closest-first for rebuild budget prioritization. Only re-sort
			-- when camera position changed -- rotation doesn't change distances.
			if cameraPositionChanged or visibleChunkCacheDirty or forceDirty then
				table.sort(visibleChunks, function(a, b)
					local da = (a.center.X - camPos.X) ^ 2 + (a.center.Y - camPos.Y) ^ 2 + (a.center.Z - camPos.Z) ^ 2
					local db = (b.center.X - camPos.X) ^ 2 + (b.center.Y - camPos.Y) ^ 2 + (b.center.Z - camPos.Z) ^ 2
					return da < db
				end)
			end

			visibleChunkCacheDirty = false
			lastVisibleChunkSettingsKey = settingsKey
			lastVisibilityCameraPos = camPos
			lastVisibilityCameraLook = camLook
			lastVisibilityMaxDistance = Workspace.MAX_VIEW_DISTANCE
		end

		-- Per-frame streaming budgets: limit how much time is spent fully rebuilding
		-- chunks (structure + GPU buffers) or partially refreshing (instance data)
		-- each frame. This prevents a single import from causing a multi-frame
		-- GPU stall while still processing small updates instantly.
		local rebuildTimeStart = os.clock()
		local rebuildTimeLimit = Workspace.ChunkRebuildTimeLimit or 0.012

		-- LOD parameters read once per frame.
		local lodEnabled = Workspace.LODEnabled ~= false
		local lod1Dist = Workspace.LOD1Distance or 60
		local lod2Dist = Workspace.LOD2Distance or 150
		local lod3Dist = Workspace.LOD3Distance or 400
		local lod1Size = Workspace.LOD1MinSize or 2
		local lod2Size = Workspace.LOD2MinSize or 6
		local lod3Size = Workspace.LOD3MinSize or 16
		local minBatch = Workspace.MinInstancesPerBatch

		for i = 1, #visibleChunks do
			local chunk = visibleChunks[i]

			-- Chunk distance from camera (squared first for the LOD skip, then
			-- sqrt only when we actually need the scalar distance).
			local cdx = chunk.center.X - camPos.X
			local cdy = chunk.center.Y - camPos.Y
			local cdz = chunk.center.Z - camPos.Z
			local chunkDistSq = cdx * cdx + cdy * cdy + cdz * cdz

			-- LOD level and minimum part size for this chunk.
			local lodLevel = 0
			local lodMinSize = 0
			if lodEnabled then
				if chunkDistSq >= lod3Dist * lod3Dist then
					lodLevel = 3
					lodMinSize = lod3Size
				elseif chunkDistSq >= lod2Dist * lod2Dist then
					lodLevel = 2
					lodMinSize = lod2Size
				elseif chunkDistSq >= lod1Dist * lod1Dist then
					lodLevel = 1
					lodMinSize = lod1Size
				end
			end

			-- Whole-chunk LOD fast-skip: if even the largest part in this chunk
			-- is smaller than the current LOD threshold, nothing here will be
			-- rendered  skip all inner loops.
			if lodMinSize > 0 and chunk.maxPartSize < lodMinSize then
				continue
			end

			-- Far chunks at LOD3 don't need structure rebuilds this frame;
			-- defer them so budget is spent on nearby visible geometry first.
			local skipRebuild = lodLevel >= 3

			-- Rebuild chunk structure (batch grouping + GPU buffer allocation)
			-- only while within the per-frame time limit. Chunks that miss the
			-- budget this frame will be rebuilt in a subsequent frame (they
			-- continue to draw with whatever stale data they already have).
			if not skipRebuild and (forceDirty or chunk.dirty) then
				if os.clock() - rebuildTimeStart < rebuildTimeLimit then
					rebuildChunkBatches(chunk)
				end
			elseif not skipRebuild and chunk.instanceDataDirty then
				if os.clock() - rebuildTimeStart < rebuildTimeLimit then
					refreshChunkInstanceBuffers(chunk)
				end
			end

			-- Always draw whatever data is currently ready for this chunk,
			-- even if it hasn't been (re)built yet this frame.
			local r3dAABB = chunk.r3dAABB
			local clusterOpen = false
			if r3dAABB then
				local ok = pcall(rlib.R3D_BeginCluster, r3dAABB)
				clusterOpen = ok
			end

			-- Single parts: apply LOD size filter before queuing each draw.
			for singleIndex = 1, #chunk.singleParts do
				local part = chunk.singleParts[singleIndex]
				if lodMinSize > 0 then
					local sz = part.Size
					if not sz or sz.X == nil or sz.Y == nil or sz.Z == nil or math.max(sz.X, sz.Y, sz.Z) < lodMinSize then
						continue
					end
				end
				queueSinglePartDraw(part, r3dAABB)
			end

			for batchIndex = 1, #chunk.batchList do
				local batch = chunk.batchList[batchIndex]
				local batchPartCount = #batch.parts

				if batchPartCount >= minBatch then
					local drawCount
					if lodLevel == 0 then
						drawCount = batch.count
					elseif lodLevel == 1 then
						drawCount = (batch.lodCount1 ~= nil) and batch.lodCount1 or batch.count
					elseif lodLevel == 2 then
						drawCount = (batch.lodCount2 ~= nil) and batch.lodCount2 or 0
					else
						drawCount = (batch.lodCount3 ~= nil) and batch.lodCount3 or 0
					end

					if not drawCount or drawCount <= 0 then
						continue -- all instances LOD'd away for this chunk
					end

					if not batch.instanceBuffer then
						local ok = uploadBatchInstances(batch)
						if not ok then
							-- Upload failed; fall back to individual single draws
							-- for parts that still pass the LOD filter.
							for partIndex = 1, math.min(drawCount, batchPartCount) do
								local part = batch.parts[partIndex]
								queueSinglePartDraw(part, r3dAABB)
							end
							continue
						end
					end

					renderer.MeshPool.DrawMeshInstanced(batch.mesh, batch.material, batch.instanceBuffer, drawCount)
				else
					for partIndex = 1, batchPartCount do
						local part = batch.parts[partIndex]
						if lodMinSize > 0 then
							local sz = part.Size
							if not sz then
								continue
							end
							if math.max(sz.X, sz.Y, sz.Z) < lodMinSize then
								continue
							end
						end
						queueSinglePartDraw(part, r3dAABB)
					end
				end
			end

			if clusterOpen then
				pcall(rlib.R3D_EndCluster)
			end
		end
	end

	proptable.loadMaterial = function(name)
		loadMaterial(name, true)
		return loadedMaterials[name]
	end
	Workspace:SetProperties(proptable)

	local activeRaycasts = {}

	local function makeFilterTester(params)
		params = params or {}
		local FilterType = Enum.RaycastFilterType
		local filterType = params.FilterType or FilterType.Exclude
		local filterInstances = type(params.FilterDescendantsInstances) == "table" and params.FilterDescendantsInstances
			or {}
		local filterSet = {}
		local hasFilter = #filterInstances > 0

		if hasFilter then
			for _, inst in ipairs(filterInstances) do
				filterSet[inst] = true
			end
		end

		return function(part)
			if params.RespectCanCollide == true and part.CanCollide == false then
				return true
			end

			if not hasFilter then
				return filterType == FilterType.Include
			end

			local current = part
			while current do
				if filterSet[current] then
					return filterType ~= FilterType.Include
				end
				current = current.Parent
			end

			return filterType == FilterType.Include
		end
	end

	local function partWorldAABB(part, padding)
		local cf = part.CFrame
		local size = part.Size
		if not cf or not cf.Position or not size then
			return nil, nil
		end

		padding = padding or Vector3.zero
		local cached = rawget(part, "__partAABB")
		local min, max
		if cached then
			min, max = cached.min, cached.max
		else
			local center = cf.Position
			local half = size * 0.5
			local right = cf:GetRightVector()
			local up = cf:GetUpVector()
			local look = cf:GetLookVector()
			local extent = Vector3.new(
				math.abs(right.X) * half.X + math.abs(up.X) * half.Y + math.abs(look.X) * half.Z,
				math.abs(right.Y) * half.X + math.abs(up.Y) * half.Y + math.abs(look.Y) * half.Z,
				math.abs(right.Z) * half.X + math.abs(up.Z) * half.Y + math.abs(look.Z) * half.Z
			)
			min = center - extent
			max = center + extent
			rawset(part, "__partAABB", { min = min, max = max })
		end

		if padding.X ~= 0 or padding.Y ~= 0 or padding.Z ~= 0 then
			return min - padding, max + padding
		end

		return min, max
	end

	local function partWorldAABBNoCache(part, padding)
		local cf = part.CFrame
		local size = part.Size
		if not cf or not cf.Position or not size then
			return nil, nil
		end

		padding = padding or Vector3.zero
		local center = cf.Position
		local half = size * 0.5
		local right = cf:GetRightVector()
		local up = cf:GetUpVector()
		local look = cf:GetLookVector()
		local extent = Vector3.new(
			math.abs(right.X) * half.X + math.abs(up.X) * half.Y + math.abs(look.X) * half.Z,
			math.abs(right.Y) * half.X + math.abs(up.Y) * half.Y + math.abs(look.Y) * half.Z,
			math.abs(right.Z) * half.X + math.abs(up.Z) * half.Y + math.abs(look.Z) * half.Z
		) + padding

		return center - extent, center + extent
	end

	local function raycastAABB(origin, direction, min, max)
		local maxDistance = direction:Magnitude()
		if maxDistance <= 1e-6 then
			return nil
		end

		local dir = direction / maxDistance
		local tMin = 0
		local tMax = maxDistance
		local hitNormal = Vector3.zero

		local function axis(o, d, mn, mx, normalNegative, normalPositive)
			if math.abs(d) <= 1e-6 then
				return o >= mn and o <= mx
			end

			local inv = 1 / d
			local t1 = (mn - o) * inv
			local t2 = (mx - o) * inv
			local normal = normalNegative
			if t1 > t2 then
				t1, t2 = t2, t1
				normal = normalPositive
			end

			if t1 > tMin then
				tMin = t1
				hitNormal = normal
			end
			tMax = math.min(tMax, t2)
			return tMin <= tMax
		end

		if not axis(origin.X, dir.X, min.X, max.X, Vector3.new(-1, 0, 0), Vector3.new(1, 0, 0)) then
			return nil
		end
		if not axis(origin.Y, dir.Y, min.Y, max.Y, Vector3.new(0, -1, 0), Vector3.new(0, 1, 0)) then
			return nil
		end
		if not axis(origin.Z, dir.Z, min.Z, max.Z, Vector3.new(0, 0, -1), Vector3.new(0, 0, 1)) then
			return nil
		end

		return math.max(tMin, 0), hitNormal
	end

	local function terrainChunkAABB(terrain, chunk)
		local vs = terrain.VoxelSize or 2
		if chunk.aabbMin and chunk.aabbMax and chunk.__workspaceAABBVoxelSize == vs then
			return chunk.aabbMin, chunk.aabbMax
		end

		if chunk.cx == nil or chunk.cy == nil or chunk.cz == nil then
			return nil, nil
		end

		local min = Vector3.new(
			chunk.cx * TERRAIN_CHUNK_SIZE * vs,
			chunk.cy * TERRAIN_CHUNK_SIZE * vs,
			chunk.cz * TERRAIN_CHUNK_SIZE * vs
		)
		local max = Vector3.new(
			(chunk.cx + 1) * TERRAIN_CHUNK_SIZE * vs,
			(chunk.cy + 1) * TERRAIN_CHUNK_SIZE * vs,
			(chunk.cz + 1) * TERRAIN_CHUNK_SIZE * vs
		)
		chunk.aabbMin = min
		chunk.aabbMax = max
		chunk.__workspaceAABBVoxelSize = vs
		return min, max
	end

	local function largePartOverlapsChunkSpan(part, minCx, maxCx, minCy, maxCy, minCz, maxCz)
		local minChunk = rawget(part, "__workspaceLargeMinChunk")
		local maxChunk = rawget(part, "__workspaceLargeMaxChunk")
		if not minChunk or not maxChunk then
			return true
		end

		return minChunk.X <= maxCx
			and maxChunk.X >= minCx
			and minChunk.Y <= maxCy
			and maxChunk.Y >= minCy
			and minChunk.Z <= maxCz
			and maxChunk.Z >= minCz
	end

	function Workspace:Blockcast(cf, size, direction, raycastParams)
		local maxDistance = direction:Magnitude()
		if maxDistance <= 1e-6 then
			return nil
		end

		local origin = cf.Position
		local padding = size * 0.5
		local isExcluded = makeFilterTester(raycastParams)
		local bestPart = nil
		local bestDist = maxDistance + 0.001
		local bestNormal = nil

		local function testPart(part)
			if isExcluded(part) then
				return
			end

			local min, max = partWorldAABBNoCache(part, padding)
			if not min then
				return
			end
			if max.Y <= origin.Y - padding.Y + 0.05 then
				return
			end

			local dist, normal = raycastAABB(origin, direction, min, max)
			if dist and dist <= maxDistance and dist < bestDist then
				bestPart = part
				bestDist = dist
				bestNormal = normal
			end
		end

		local endPos = origin + direction
		local sweepMin = Vector3.new(
			math.min(origin.X, endPos.X) - padding.X,
			math.min(origin.Y, endPos.Y) - padding.Y,
			math.min(origin.Z, endPos.Z) - padding.Z
		)
		local sweepMax = Vector3.new(
			math.max(origin.X, endPos.X) + padding.X,
			math.max(origin.Y, endPos.Y) + padding.Y,
			math.max(origin.Z, endPos.Z) + padding.Z
		)

		local minCx = math.floor(sweepMin.X / CHUNK_SIZE) - 1
		local maxCx = math.floor(sweepMax.X / CHUNK_SIZE) + 1
		local minCy = math.floor(sweepMin.Y / CHUNK_SIZE) - 1
		local maxCy = math.floor(sweepMax.Y / CHUNK_SIZE) + 1
		local minCz = math.floor(sweepMin.Z / CHUNK_SIZE) - 1
		local maxCz = math.floor(sweepMax.Z / CHUNK_SIZE) + 1

		for cx = minCx, maxCx do
			for cy = minCy, maxCy do
				for cz = minCz, maxCz do
					local chunk = chunks[cx .. "," .. cy .. "," .. cz]
					if chunk then
						for i = 1, #chunk.parts do
							testPart(chunk.parts[i])
						end
					end
				end
			end
		end

		for i = 1, #largeParts do
			local part = largeParts[i]
			if largePartOverlapsChunkSpan(part, minCx, maxCx, minCy, maxCy, minCz, maxCz) then
				testPart(part)
			end
		end

		if bestPart then
			local point = origin + direction:Unit() * bestDist
			return RaycastResult.new(bestPart, point, bestNormal or Vector3.zero, bestPart.Material, bestDist)
		end

		return nil
	end

	function Workspace:Raycast(origin, direction, raycastParams)
		raycastParams = raycastParams or {}
		local isExcluded = makeFilterTester(raycastParams)

		local maxDistance = direction:Magnitude()
		local unitDir = direction:Unit()

		local ray = structs.Ray:new({
			position = vector.create(origin.X, origin.Y, origin.Z),
			direction = vector.create(unitDir.X, unitDir.Y, unitDir.Z),
		})

		-- Cache RayCollision struct field offsets once per call (each :offset()
		-- is a keyed table lookup; they are the same values every time).
		local offHit = structs.RayCollision:offset("hit")
		local offDist = structs.RayCollision:offset("distance")
		local offPointX = structs.RayCollision:offset("point")
		local offPointY = offPointX + 4
		local offPointZ = offPointX + 8
		local offNormX = structs.RayCollision:offset("normal")
		local offNormY = offNormX + 4
		local offNormZ = offNormX + 8

		local bestPart = nil
		local bestPoint = nil
		local bestNormal = nil
		local bestDist = maxDistance + 0.001
		local bestMat = nil

		local preloadedMeshes = renderer.Mesh
			and renderer.Mesh.GetPreloadedMeshes
			and renderer.Mesh.GetPreloadedMeshes()

		-- Test one part and update the best hit if this one is closer.
		local function testPart(part)
			if isExcluded(part) then
				return
			end

			local aabbMin, aabbMax = partWorldAABB(part)
			if not aabbMin then
				return
			end

			local aabbDist = raycastAABB(origin, direction, aabbMin, aabbMax)
			if not aabbDist or aabbDist > bestDist then
				return
			end

			-- Resolve CPU mesh data for the per-triangle test.
			local cpuMeshData
			if part:IsA("MeshPart") and part.MeshObject then
				cpuMeshData = part.MeshObject._cpuMeshData
			else
				local shapeName = part.Shape and part.Shape.Name and string.lower(part.Shape.Name)
				if shapeName == "ball" then
					shapeName = "sphere"
				end
				if shapeName and preloadedMeshes then
					local entry = preloadedMeshes[shapeName]
					if entry then
						cpuMeshData = entry[1]
					end
				end
			end
			if not cpuMeshData then
				return
			end

			-- Exact per-triangle mesh test.
			local matrix = part.CFrame:ToRaylibMatrixScale(part.Size, structs)
			local ok, collision = pcall(rlib.R3D_RaycastMesh, ray, cpuMeshData, matrix)
			if not ok or not collision then
				return
			end

			local hit = buffer.readu8(collision, offHit)
			local dist = buffer.readf32(collision, offDist)
			if hit == 1 and dist <= maxDistance and dist < bestDist then
				bestDist = dist
				bestPart = part
				bestPoint = Vector3.new(
					buffer.readf32(collision, offPointX),
					buffer.readf32(collision, offPointY),
					buffer.readf32(collision, offPointZ)
				)
				bestNormal = Vector3.new(
					buffer.readf32(collision, offNormX),
					buffer.readf32(collision, offNormY),
					buffer.readf32(collision, offNormZ)
				)
				bestMat = part.Material
			end
		end

		--  Spatial acceleration
		-- Instead of scanning the flat renderablePool (O(n) over all parts),
		-- we walk only the chunk cells that the ray could possibly pass through.
		-- The chunks table is a sparse grid; each cell covers CHUNK_SIZE³ studs.
		-- We enumerate the axis-aligned bounding box of the ray's path in chunk
		-- space and look up only those cells, then pre-reject each chunk with a
		-- fast AABB test before descending into its individual parts.
		--
		-- For a short floor-detection ray (≈5 studs) this reduces work from
		-- O(all_parts) to O(parts_in_1-4_nearby_chunks), a 100-1000× speedup.
		--
		do
			local CHUNK_SIZE_INV = 1 / CHUNK_SIZE
			local ox, oy, oz = origin.X, origin.Y, origin.Z
			local endPos = origin + unitDir * maxDistance
			local ex, ey, ez = endPos.X, endPos.Y, endPos.Z

			local minCx = math.floor(math.min(ox, ex) * CHUNK_SIZE_INV) - 1
			local maxCx = math.floor(math.max(ox, ex) * CHUNK_SIZE_INV) + 1
			local minCy = math.floor(math.min(oy, ey) * CHUNK_SIZE_INV) - 1
			local maxCy = math.floor(math.max(oy, ey) * CHUNK_SIZE_INV) + 1
			local minCz = math.floor(math.min(oz, ez) * CHUNK_SIZE_INV) - 1
			local maxCz = math.floor(math.max(oz, ez) * CHUNK_SIZE_INV) + 1

			-- Returns true when the chunk should have its parts tested.
			local function chunkOverlapsRay(chunk)
				local mn = chunk.aabbMin
				local mx = chunk.aabbMax
				local expansion = (chunk.maxPartSize or 0) * 0.5
				local hitDist = raycastAABB(
					origin,
					direction,
					Vector3.new(mn.X - expansion, mn.Y - expansion, mn.Z - expansion),
					Vector3.new(mx.X + expansion, mx.Y + expansion, mx.Z + expansion)
				)
				return hitDist ~= nil and hitDist < bestDist
			end

			-- For very long rays the grid walk could visit too many empty cells;
			-- fall back to iterating only the populated chunks table instead.
			local cellCount = (maxCx - minCx + 1) * (maxCy - minCy + 1) * (maxCz - minCz + 1)
			local GRID_WALK_CELL_LIMIT = 4096

			if cellCount <= GRID_WALK_CELL_LIMIT then
				-- Grid walk: hash-lookup per cell, only existing chunks are tested.
				for cx = minCx, maxCx do
					for cy = minCy, maxCy do
						for cz = minCz, maxCz do
							local chunk = chunks[cx .. "," .. cy .. "," .. cz]
							if chunk and chunkOverlapsRay(chunk) then
								local parts = chunk.parts
								for i = 1, #parts do
									testPart(parts[i])
								end
							end
						end
					end
				end
			else
				-- Long-ray fallback: iterate only the populated chunk cells
				-- (avoids nested loops over millions of empty grid cells).
				for _, chunk in pairs(chunks) do
					if chunkOverlapsRay(chunk) then
						local parts = chunk.parts
						for i = 1, #parts do
							testPart(parts[i])
						end
					end
				end
			end

			-- Always test large parts that span multiple chunks, as the grid
			-- walk only tests the single 32x32 chunk at their center.
			for i = 1, #largeParts do
				local part = largeParts[i]
				if largePartOverlapsChunkSpan(part, minCx, maxCx, minCy, maxCy, minCz, maxCz) then
					testPart(part)
				end
			end
		end

		--  Terrain
		local terrain = Workspace:FindFirstChild("Terrain")
		if terrain and terrain._chunks then
			local shouldTestTerrain = not isExcluded(terrain)

			if shouldTestTerrain then
				local identity = raylib.lib.MatrixIdentity()
				local vs = terrain.VoxelSize or 2
				local terrainChunkWorldSize = TERRAIN_CHUNK_SIZE * vs
				local endPos = origin + direction
				local minCx = math.floor(math.min(origin.X, endPos.X) / terrainChunkWorldSize) - 1
				local maxCx = math.floor(math.max(origin.X, endPos.X) / terrainChunkWorldSize) + 1
				local minCy = math.floor(math.min(origin.Y, endPos.Y) / terrainChunkWorldSize) - 1
				local maxCy = math.floor(math.max(origin.Y, endPos.Y) / terrainChunkWorldSize) + 1
				local minCz = math.floor(math.min(origin.Z, endPos.Z) / terrainChunkWorldSize) - 1
				local maxCz = math.floor(math.max(origin.Z, endPos.Z) / terrainChunkWorldSize) + 1
				local cellCount = (maxCx - minCx + 1) * (maxCy - minCy + 1) * (maxCz - minCz + 1)
				local TERRAIN_GRID_WALK_CELL_LIMIT = 4096

				local function testTerrainChunk(chunk)
					if chunk._cpuMeshData then
						local aabbMin, aabbMax = terrainChunkAABB(terrain, chunk)
						if aabbMin and aabbMax then
							local preHitDist = raycastAABB(origin, direction, aabbMin, aabbMax)
							if preHitDist == nil or preHitDist >= bestDist then
								return
							end
						end

						local ok, collision = pcall(rlib.R3D_RaycastMesh, ray, chunk._cpuMeshData, identity)
						if ok and collision then
							local hitValue = buffer.readu8(collision, offHit)
							local distValue = buffer.readf32(collision, offDist)

							if hitValue == 1 and distValue <= maxDistance and distValue < bestDist then
								bestDist = distValue
								bestPart = terrain
								bestPoint = Vector3.new(
									buffer.readf32(collision, offPointX),
									buffer.readf32(collision, offPointY),
									buffer.readf32(collision, offPointZ)
								)
								bestNormal = Vector3.new(
									buffer.readf32(collision, offNormX),
									buffer.readf32(collision, offNormY),
									buffer.readf32(collision, offNormZ)
								)
								local matName = chunk.dominantMaterial or "Grass"
								bestMat = Enum.Material[string.upper(string.sub(matName, 1, 1)) .. string.sub(
									matName,
									2
								)] or Enum.Material.Grass
							end
						end
					end
				end

				if cellCount <= TERRAIN_GRID_WALK_CELL_LIMIT then
					for cx = minCx, maxCx do
						for cy = minCy, maxCy do
							for cz = minCz, maxCz do
								local chunk = terrain._chunks[cx .. "," .. cy .. "," .. cz]
								if chunk then
									testTerrainChunk(chunk)
								end
							end
						end
					end
				else
					for _, chunk in pairs(terrain._chunks) do
						testTerrainChunk(chunk)
					end
				end
			end
		end

		if raycastParams.VisualizeRay == true then
			table.insert(activeRaycasts, {
				org = origin,
				direction = direction,
				point = bestPoint or (origin + direction),
			})
		end

		if bestPart then
			return RaycastResult.new(bestPart, bestPoint, bestNormal, bestMat, bestDist)
		end

		return nil
	end

	if not IsHeadless then
		repeat
			task.wait()
		until renderer

		renderer.Pool.new("gizmo", function()
			for i, active in pairs(activeRaycasts) do
				local origin = active.org
				local hitPoint = active.point or (origin + active.direction)

				raylib.lib.DrawCylinderEx(
					vector.create(origin.X, origin.Y, origin.Z),
					vector.create(hitPoint.X, hitPoint.Y, hitPoint.Z),
					0.1,
					0.1,
					8,
					raylib.structs.Color:new({ r = 0, g = 0, b = 255, a = 255 })
				)

				activeRaycasts[i] = nil
			end
		end)

		renderer.Pool.new("3d", function(...)
			local _st = os.clock()
			drawChunks(...)
			local _dur = os.clock() - _st
			if _dur > 0.05 then
				print(string.format("[Workspace] drawChunks took %.2f ms", _dur * 1000))
			end
		end)
	end
end

return Workspace
