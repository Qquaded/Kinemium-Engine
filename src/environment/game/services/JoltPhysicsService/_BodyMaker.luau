local ffi = zune.ffi
local jolt = require("@jolt")
local lib = jolt.lib
local structs = jolt.structs

local LAYER_NON_MOVING = 0
local LAYER_MOVING = 1

local vertbody = {}

local function vec3(v)
	if type(v) == "table" then
		if v.X ~= nil then
			return v.X, v.Y, v.Z
		end
		if v.x ~= nil then
			return v.x, v.y, v.z
		end
		return v[1] or 0, v[2] or 0, v[3] or 0
	end
	return 0, 0, 0
end

local function RVec3(x, y, z)
	local vec = structs.JPH_RVec3:new({})
	buffer.writef64(vec, 0, x)
	buffer.writef64(vec, 8, y)
	buffer.writef64(vec, 16, z)
	return vec
end

local function allocVec3Array(points)
	local count = #points
	local vec3Size = structs.JPH_Vec3:size()
	local vec3Align = structs.JPH_Vec3:alignment()
	local bytes = count * vec3Size
	local ptr = ffi.alloc(bytes, vec3Align)

	for i, p in ipairs(points) do
		local x, y, z = vec3(p)
		local base = (i - 1) * vec3Size
		ptr:writef32(base + 0, x)
		ptr:writef32(base + 4, y)
		ptr:writef32(base + 8, z)
	end

	return ptr, count
end

local function allocTriangleArray(triangles)
	local count = #triangles
	local bytes = count * 16
	local ptr = ffi.alloc(bytes, 4)

	for i, tri in ipairs(triangles) do
		local base = (i - 1) * 16
		ptr:writeu32(base + 0, tri[1] or tri.i0 or 0)
		ptr:writeu32(base + 4, tri[2] or tri.i1 or 0)
		ptr:writeu32(base + 8, tri[3] or tri.i2 or 0)
		ptr:writeu32(base + 12, tri.material or 0) -- materialIndex
	end

	return ptr, count
end

local function indicesToTriangles(indices)
	local tris = {}
	for i = 1, #indices - 2, 3 do
		table.insert(tris, { indices[i], indices[i + 1], indices[i + 2] })
	end
	return tris
end

function vertbody.convexHullShape(points, maxConvexRadius)
	assert(#points >= 4, "convexHullShape needs at least 4 points")
	maxConvexRadius = maxConvexRadius or 0.05

	local vertPtr, vertCount = allocVec3Array(points)
	local settings = lib.JPH_ConvexHullShapeSettings_Create(vertPtr, vertCount, maxConvexRadius)
	if settings == ffi.null then
		warn("[vertbody] JPH_ConvexHullShapeSettings_Create returned null")
		return ffi.null
	end

	local shape = lib.JPH_ConvexHullShapeSettings_CreateShape(settings)
	lib.JPH_ShapeSettings_Destroy(settings)

	if shape == ffi.null then
		warn("[vertbody] ConvexHull shape creation failed")
	end
	return shape
end

local function allocJPH_TriangleArray(points, triangles)
	local count = #triangles
	local triSize = structs.JPH_Triangle:size()
	local ptr = ffi.alloc(count * triSize, structs.JPH_Triangle:alignment())

	for i, tri in ipairs(triangles) do
		local base = (i - 1) * triSize

		local idx1 = tri[1] or tri.i0 or 0
		local idx2 = tri[2] or tri.i1 or 0
		local idx3 = tri[3] or tri.i2 or 0

		-- Try idx+1 first (assuming 0-based), fallback to idx (assuming 1-based)
		local p1 = points[idx1 + 1] or points[idx1] or { 0, 0, 0 }
		local p2 = points[idx2 + 1] or points[idx2] or { 0, 0, 0 }
		local p3 = points[idx3 + 1] or points[idx3] or { 0, 0, 0 }

		ptr:writef32(base + 0, p1[1])
		ptr:writef32(base + 4, p1[2])
		ptr:writef32(base + 8, p1[3])

		ptr:writef32(base + 12, p2[1])
		ptr:writef32(base + 16, p2[2])
		ptr:writef32(base + 20, p2[3])

		ptr:writef32(base + 24, p3[1])
		ptr:writef32(base + 28, p3[2])
		ptr:writef32(base + 32, p3[3])

		ptr:writeu32(base + 36, tri.material or 0)
	end

	return ptr, count
end

function vertbody.meshShape(points, triangles, indices)
	local tris = triangles
	if not tris then
		assert(indices and #indices >= 3, "meshShape: provide either triangles or indices")
		tris = indicesToTriangles(indices)
	end
	assert(#tris >= 1, "meshShape: no triangles")

	local triPtr, triCount = allocJPH_TriangleArray(points, tris)

	local settings = lib.JPH_MeshShapeSettings_Create(triPtr, triCount)
	if settings == ffi.null then
		warn("[vertbody] JPH_MeshShapeSettings_Create returned null")
		return ffi.null
	end

	local shape = lib.JPH_MeshShapeSettings_CreateShape(settings)
	if shape == ffi.null then
		warn("[vertbody] Mesh shape creation failed")
	end

	lib.JPH_ShapeSettings_Destroy(settings)
	return shape
end

function vertbody.createBody(bodyInterface, shape, opts)
	opts = opts or {}
	assert(shape ~= ffi.null, "[vertbody] createBody: invalid shape")

	-- position
	local px, py, pz = 0, 0, 0
	if opts.position then
		px, py, pz = vec3(opts.position)
	end
	local posPtr = RVec3(px, py, pz)

	-- rotation (quaternion)
	local rx, ry, rz, rw = 0, 0, 0, 1
	if opts.rotation then
		local r = opts.rotation
		if r.ToQuaternion then
			rx, ry, rz, rw = r:ToQuaternion()
		elseif r.x ~= nil then
			rx, ry, rz, rw = r.x, r.y, r.z, r.w
		elseif r[1] ~= nil then
			rx, ry, rz, rw = r[1], r[2], r[3], r[4]
		end
	end
	local rotPtr = structs.JPH_Quat:new({})
	buffer.writef32(rotPtr, 0, rx)
	buffer.writef32(rotPtr, 4, ry)
	buffer.writef32(rotPtr, 8, rz)
	buffer.writef32(rotPtr, 12, rw)

	-- motion type
	local motionType = opts.motionType
	if motionType == nil then
		motionType = 2
	end -- Dynamic

	-- object layer
	local layer = opts.layer
	if layer == nil then
		layer = (motionType == 0) and LAYER_NON_MOVING or LAYER_MOVING
	end

	-- activation
	local activation = (opts.activate == false) and 1 or 0 -- 0=Activate 1=DontActivate

	local bodySettings = lib.JPH_BodyCreationSettings_Create3(shape, posPtr, rotPtr, motionType, layer)
	if bodySettings == ffi.null then
		warn("[vertbody] JPH_BodyCreationSettings_Create3 returned null")
		return nil
	end

	if opts.allowSleep ~= false then
		lib.JPH_BodyCreationSettings_SetAllowSleeping(bodySettings, 1)
	end

	local bodyID = lib.JPH_BodyInterface_CreateAndAddBody(bodyInterface, bodySettings, activation)
	lib.JPH_BodyCreationSettings_Destroy(bodySettings)

	if bodyID == nil then
		warn("[vertbody] CreateAndAddBody failed")
		return nil
	end

	return bodyID
end

function vertbody.buildConvexBody(bodyInterface, points, opts)
	opts = opts or {}
	local shape = vertbody.convexHullShape(points, opts.maxConvexRadius)
	if shape == ffi.null then
		return nil
	end
	return vertbody.createBody(bodyInterface, shape, opts)
end

function vertbody.buildMeshBody(bodyInterface, points, triangles, indices, opts)
	opts = opts or {}
	-- Mesh shapes must be static or kinematic
	if opts.motionType == nil then
		opts.motionType = 0
	end
	if opts.layer == nil then
		opts.layer = LAYER_NON_MOVING
	end

	local shape = vertbody.meshShape(points, triangles, indices)
	if shape == ffi.null then
		return nil
	end
	return vertbody.createBody(bodyInterface, shape, opts)
end

function vertbody.pointsFromMeshgenVerts(verts)
	local out = {}
	for _, v in ipairs(verts) do
		local px, py, pz = vec3(v.position or v.pos or v)
		table.insert(out, { px, py, pz })
	end
	return out
end

return vertbody
