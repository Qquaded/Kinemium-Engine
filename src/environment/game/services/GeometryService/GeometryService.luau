local Instance = require("@Instance")
local Enum = require("@EnumMap")
local Registry = require("@Kinemium.registry")

local GeometryService = Instance.new("GeometryService")
GeometryService.ExplorerHidden = true
GeometryService._Intents = Enum.PluginIntents.CSG

local manifold = require("@manifold")
local gen = manifold.gen

local serviceRenderer = nil
local serviceDatamodel = nil

local function transformManifold(manifoldPtr, cf)
	local out = gen.alloc()
	if not cf or not cf.Position or not cf.Rotation then
		manifold.lib.manifold_copy(out, manifoldPtr)
		return out
	end

	local r = cf.Rotation
	local p = cf.Position
	manifold.lib.manifold_transform(
		out,
		manifoldPtr,
		r[1][1],
		r[2][1],
		r[3][1],
		r[1][2],
		r[2][2],
		r[3][2],
		r[1][3],
		r[2][3],
		r[3][3],
		p.X,
		p.Y,
		p.Z
	)
	return out
end

local function getWorldManifold(part)
	if not part or not part._manifoldptr then
		return nil
	end
	return transformManifold(part._manifoldptr, part.CFrame)
end

local function getManifoldAtCFrame(part, cf)
	if not part or not part._manifoldptr or not cf then
		return nil
	end
	return transformManifold(part._manifoldptr, cf)
end

local function combineManifolds(seedPart, operandParts, combiner)
	local result = getWorldManifold(seedPart)
	if not result then
		return nil
	end

	for _, operand in ipairs(operandParts) do
		local operandWorld = getWorldManifold(operand)
		if operandWorld then
			local combined = combiner(result, operandWorld)
			gen.free(result)
			gen.free(operandWorld)
			result = combined
		end
	end

	return result
end

local function worldResultToLocalSpace(worldManifold, localCFrame)
	if not localCFrame then
		return worldManifold
	end
	local inverse = localCFrame:Inverse()
	local localManifold = transformManifold(worldManifold, inverse)
	gen.free(worldManifold)
	return localManifold
end

local function collectOperandParts(parts)
	local operandParts = {}
	for _, p in ipairs(parts) do
		if p and p._manifoldptr then
			operandParts[#operandParts + 1] = p
		end
	end
	return operandParts
end

local function applyCsgOptions(instance, primaryPart, options)
	options = options or {}
	instance.Material = primaryPart.Material or Enum.Material.SmoothPlastic
	instance.Color = primaryPart.Color
	instance.Transparency = primaryPart.Transparency or 0
	if options.CollisionFidelity then
		instance.CollisionFidelity = options.CollisionFidelity
	end
	if options.RenderFidelity then
		instance.RenderFidelity = options.RenderFidelity
	end
	if options.FluidFidelity then
		instance.FluidFidelity = options.FluidFidelity
	end
end

local function buildMeshResult(primaryPart, localCFrame, worldManifold)
	local localManifold = worldResultToLocalSpace(worldManifold, localCFrame)
	local built = gen.buildMeshWithDataFromManifold(localManifold, {
		includeNormals = true,
		indicesAreZeroBased = true,
		generateTangents = true,
	})
	gen.free(localManifold)

	if not built then
		return nil, nil
	end

	return built[1], built[2]
end

local function createPartOperationResult(className, primaryPart, operandParts, worldManifold, options)
	local meshData, gpuMesh = buildMeshResult(primaryPart, primaryPart.CFrame, worldManifold)
	if not gpuMesh then
		return {}
	end

	local result = Registry.new(className, serviceRenderer, serviceDatamodel)
	result:SetProperty("_mesh", gpuMesh)
	result:SetProperty("_cpuMeshData", meshData)
	result.CFrame = primaryPart.CFrame
	result.Size = primaryPart.Size
	result.ConnectedParts = operandParts
	applyCsgOptions(result, primaryPart, options)

	return { result }
end

local function createMeshPartResult(primaryPart, localCFrame, worldManifold, options)
	local meshData, gpuMesh = buildMeshResult(primaryPart, localCFrame, worldManifold)
	if not gpuMesh then
		return nil
	end

	local meshPart = Registry.new("MeshPart", serviceRenderer, serviceDatamodel)
	meshPart:SetProperty("_mesh", gpuMesh)
	meshPart:SetProperty("_cpuMeshData", meshData)
	meshPart.CFrame = localCFrame
	meshPart.Size = primaryPart.Size
	applyCsgOptions(meshPart, primaryPart, options)

	return meshPart
end

local function unionOperands(operandParts)
	if #operandParts == 0 then
		return nil
	end
	return combineManifolds(operandParts[1], { table.unpack(operandParts, 2) }, gen.union)
end

GeometryService.InitRenderer = function(renderer, renderer_signal, datamodel)
	serviceRenderer = renderer
	serviceDatamodel = datamodel
	GeometryService:SetProperties({})

	function GeometryService:IntersectAsync(part: Instance, parts: { any }, options: {})
		local operandParts = collectOperandParts(parts)
		if #operandParts == 0 then
			return {}
		end

		local unioned = unionOperands(operandParts)
		if not unioned then
			return {}
		end

		local primaryWorld = getWorldManifold(part)
		if not primaryWorld then
			gen.free(unioned)
			return {}
		end

		local resultPtr = gen.intersection(primaryWorld, unioned)
		gen.free(primaryWorld)
		gen.free(unioned)

		return createPartOperationResult("IntersectOperation", part, operandParts, resultPtr, options)
	end

	function GeometryService:SubtractAsync(part: Instance, parts: { any }, options: {})
		local operandParts = collectOperandParts(parts)
		if #operandParts == 0 then
			return {}
		end

		local subtractVolume = unionOperands(operandParts)
		if not subtractVolume then
			return {}
		end

		local primaryWorld = getWorldManifold(part)
		if not primaryWorld then
			gen.free(subtractVolume)
			return {}
		end

		local resultPtr = gen.difference(primaryWorld, subtractVolume)
		gen.free(primaryWorld)
		gen.free(subtractVolume)

		return createPartOperationResult("NegateOperation", part, operandParts, resultPtr, options)
	end

	function GeometryService:UnionAsync(part: Instance, parts: { any }, options: {})
		local operandParts = collectOperandParts(parts)
		local allParts = { part }
		for _, p in ipairs(operandParts) do
			allParts[#allParts + 1] = p
		end

		if #allParts < 2 then
			return {}
		end

		local worldUnion = unionOperands(allParts)
		if not worldUnion then
			return {}
		end

		return createPartOperationResult("UnionOperation", part, allParts, worldUnion, options)
	end

	function GeometryService:SweepPartAsync(part: Instance, cframes: { any }, options: {})
		options = options or {}
		if not part or not part._manifoldptr or not cframes or #cframes == 0 then
			return nil
		end

		local referenceCFrame = cframes[1] or part.CFrame
		local swept = getManifoldAtCFrame(part, referenceCFrame)
		if not swept then
			return nil
		end

		for i = 2, #cframes do
			local cf = cframes[i]
			if cf then
				local next = getManifoldAtCFrame(part, cf)
				if next then
					local combined = gen.union(swept, next)
					gen.free(swept)
					gen.free(next)
					swept = combined
				end
			end
		end

		return createMeshPartResult(part, referenceCFrame, swept, options)
	end
end

return GeometryService
