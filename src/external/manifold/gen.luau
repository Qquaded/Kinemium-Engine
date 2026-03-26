--!strict
--!optimize 2

local manifold = require("./init")
local meshgen = require("@meshgen")
local ffi = zune.ffi

local lib = manifold.lib

local gen = {}

local function vec3(v: any): (number, number, number)
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

local function colorRGBA(v: any): (number, number, number, number)
	if v == nil then
		return 255, 255, 255, 255
	end
	if type(v) == "table" then
		if v.ToRGB then
			local r, g, b = v:ToRGB()
			return r, g, b, 255
		end
		local r = v.r or v.R or v[1] or 255
		local g = v.g or v.G or v[2] or 255
		local b = v.b or v.B or v[3] or 255
		local a = v.a or v.A or v[4] or 255
		return r, g, b, a
	end
	return 255, 255, 255, 255
end

local function allocManifold()
	return lib.manifold_alloc_manifold()
end

local function freeManifold(m: any)
	if m and m ~= ffi.null then
		lib.manifold_delete_manifold(m)
	end
end

gen.alloc = allocManifold
gen.free = freeManifold

function gen.box(sx: number?, sy: number?, sz: number?, center: boolean?): any
	local m = allocManifold()
	sx = sx or 1
	sy = sy or sx
	sz = sz or sx
	if center == nil or center == true then
		local hx, hy, hz = sx * 0.5, sy * 0.5, sz * 0.5
		lib.manifold_box(m, -hx, -hy, -hz, hx, hy, hz)
	else
		lib.manifold_box(m, 0, 0, 0, sx, sy, sz)
	end
	return m
end

function gen.boxFromMinMax(min: any, max: any): any
	local m = allocManifold()
	local x1, y1, z1 = vec3(min)
	local x2, y2, z2 = vec3(max)
	lib.manifold_box(m, x1, y1, z1, x2, y2, z2)
	return m
end

function gen.cube(size: any?, center: boolean?): any
	local m = allocManifold()
	local sx, sy, sz = 1, 1, 1
	if type(size) == "table" then
		sx, sy, sz = vec3(size)
	else
		sx = size or 1
		sy = sx
		sz = sx
	end
	if center == nil then
		center = true
	end
	lib.manifold_cube(m, sx, sy, sz, center and 1 or 0)
	return m
end

function gen.sphere(radius: number?, segments: number?): any
	local m = allocManifold()
	radius = radius or 0.5
	segments = segments or lib.manifold_get_circular_segments(radius)
	lib.manifold_sphere(m, radius, segments)
	return m
end

function gen.cylinder(radius: number?, height: number?, segments: number?, center: boolean?, radiusTop: number?): any
	local m = allocManifold()
	radius = radius or 0.5
	height = height or 1
	radiusTop = radiusTop or radius
	segments = segments or lib.manifold_get_circular_segments(math.max(radius, radiusTop))
	lib.manifold_cylinder(m, height, radius, radiusTop, segments, center and 1 or 0)
	return m
end

function gen.cone(radius: number?, height: number?, segments: number?, center: boolean?): any
	return gen.cylinder(radius, height, segments, center, 0)
end

function gen.tetrahedron(): any
	local m = allocManifold()
	lib.manifold_tetrahedron(m)
	return m
end

function gen.translate(m: any, offset: any): any
	local out = allocManifold()
	local x, y, z = vec3(offset)
	lib.manifold_translate(out, m, x, y, z)
	return out
end

function gen.scale(m: any, scale: any): any
	local out = allocManifold()
	local x, y, z = vec3(scale)
	lib.manifold_scale(out, m, x, y, z)
	return out
end

function gen.union(a: any, b: any): any
	local out = allocManifold()
	lib.manifold_union(out, a, b)
	return out
end

function gen.difference(a: any, b: any): any
	local out = allocManifold()
	lib.manifold_difference(out, a, b)
	return out
end

function gen.intersection(a: any, b: any): any
	local out = allocManifold()
	lib.manifold_intersection(out, a, b)
	return out
end

local function readMeshGL(m: any, opts: any?)
	opts = opts or {}
	local use64 = opts.use64 == true
	local includeNormals = opts.includeNormals == true
	local normalIdx = opts.normalIdx or 3

	local mesh = use64 and lib.manifold_alloc_meshgl64() or lib.manifold_alloc_meshgl()
	if mesh == ffi.null then
		warn("[manifold.gen] manifold_alloc_meshgl returned null")
		return nil
	end

	if includeNormals then
		if use64 then
			lib.manifold_get_meshgl64_w_normals(mesh, m, normalIdx)
		else
			lib.manifold_get_meshgl_w_normals(mesh, m, normalIdx)
		end
	else
		if use64 then
			lib.manifold_get_meshgl64(mesh, m)
		else
			lib.manifold_get_meshgl(mesh, m)
		end
	end

	local numVert = use64 and lib.manifold_meshgl64_num_vert(mesh) or lib.manifold_meshgl_num_vert(mesh)
	local numTri = use64 and lib.manifold_meshgl64_num_tri(mesh) or lib.manifold_meshgl_num_tri(mesh)
	local numProp = use64 and lib.manifold_meshgl64_num_prop(mesh) or lib.manifold_meshgl_num_prop(mesh)
	if numVert <= 0 then
		if use64 then
			lib.manifold_delete_meshgl64(mesh)
		else
			lib.manifold_delete_meshgl(mesh)
		end
		return {}, {}
	end
	if numProp < 3 then
		if use64 then
			lib.manifold_delete_meshgl64(mesh)
		else
			lib.manifold_delete_meshgl(mesh)
		end
		warn("[manifold.gen] meshgl has fewer than 3 properties per vertex")
		return nil
	end

	local propsPtr = use64 and lib.manifold_meshgl64_vert_properties(mesh, mesh)
		or lib.manifold_meshgl_vert_properties(mesh, mesh)
	local triPtr = use64 and lib.manifold_meshgl64_tri_verts(mesh, mesh) or lib.manifold_meshgl_tri_verts(mesh, mesh)

	if propsPtr == ffi.null or triPtr == ffi.null then
		if use64 then
			lib.manifold_delete_meshgl64(mesh)
		else
			lib.manifold_delete_meshgl(mesh)
		end
		warn("[manifold.gen] meshgl pointers are null")
		return nil
	end

	local bytesPer = use64 and 8 or 4
	local readFloat = use64 and function(ptr: any, offset: number)
		return ptr:readf64(offset)
	end or function(ptr: any, offset: number)
		return ptr:readf32(offset)
	end

	local useColor = opts.color ~= nil
	local cr, cg, cb, ca = colorRGBA(opts.color)
	local hasNormals = includeNormals and (normalIdx + 2) < numProp

	local vertices = table.create(numVert)
	for i = 0, numVert - 1 do
		local base = i * numProp
		local px = readFloat(propsPtr, (base + 0) * bytesPer)
		local py = readFloat(propsPtr, (base + 1) * bytesPer)
		local pz = readFloat(propsPtr, (base + 2) * bytesPer)
		local v = { position = { px, py, pz } }
		if hasNormals then
			local nx = readFloat(propsPtr, (base + normalIdx + 0) * bytesPer)
			local ny = readFloat(propsPtr, (base + normalIdx + 1) * bytesPer)
			local nz = readFloat(propsPtr, (base + normalIdx + 2) * bytesPer)
			v.normal = { nx, ny, nz }
		end
		if useColor then
			v.color = { cr, cg, cb, ca }
		end
		vertices[i + 1] = v
	end

	local indices = table.create(numTri * 3)
	for i = 0, numTri - 1 do
		local base = i * 3
		local off = i * 12
		indices[base + 1] = triPtr:readu32(off + 0)
		indices[base + 2] = triPtr:readu32(off + 4)
		indices[base + 3] = triPtr:readu32(off + 8)
	end

	if use64 then
		lib.manifold_delete_meshgl64(mesh)
	else
		lib.manifold_delete_meshgl(mesh)
	end

	return vertices, indices
end

function gen.meshDataFromManifold(m: any, opts: any?)
	if not m or m == ffi.null then
		warn("[manifold.gen] meshDataFromManifold: invalid manifold pointer")
		return nil
	end
	return readMeshGL(m, opts)
end

local function buildOptsFromManifold(opts: any?)
	local out = {
		indicesAreZeroBased = true,
	}
	if not opts then
		return out
	end
	out.primitive = opts.primitive
	out.usage = opts.usage
	out.smooth = opts.smooth
	out.flat = opts.flat
	out.generateTangents = opts.generateTangents
	out.weld = opts.weld
	out.weldTolerance = opts.weldTolerance
	return out
end

function gen.buildMeshFromManifold(m: any, opts: any?)
	local verts, indices = readMeshGL(m, opts)
	if not verts then
		return nil
	end
	return meshgen.buildMesh(verts, indices, buildOptsFromManifold(opts))
end

function gen.buildMeshDataFromManifold(m: any, opts: any?)
	local verts, indices = readMeshGL(m, opts)
	if not verts then
		return nil
	end
	return meshgen.buildMeshData(verts, indices, buildOptsFromManifold(opts))
end

function gen.manifoldFromMeshData(vertices: { any }, indices: { number }?, opts: any?): any
	opts = opts or {}
	local vcount = #vertices
	if vcount <= 0 then
		warn("[manifold.gen] manifoldFromMeshData: no vertices")
		return nil
	end

	local idxs = indices
	if not idxs then
		idxs = table.create(vcount)
		for i = 1, vcount do
			idxs[i] = i - 1
		end
	elseif opts.indicesAreZeroBased ~= true then
		local shifted = table.create(#idxs)
		for i = 1, #idxs do
			shifted[i] = idxs[i] - 1
		end
		idxs = shifted
	end

	if (#idxs % 3) ~= 0 then
		warn("[manifold.gen] manifoldFromMeshData: indices must be multiple of 3")
		return nil
	end

	local nTris = #idxs // 3
	local nProps = opts.nProps or 3
	if nProps < 3 then
		warn("[manifold.gen] manifoldFromMeshData: nProps must be >= 3")
		return nil
	end

	local use64 = opts.use64 == true
	local bytesPer = use64 and 8 or 4
	local vertProps = ffi.alloc(vcount * nProps * bytesPer, use64 and 8 or 4)
	local writeFloat = use64 and function(ptr: any, offset: number, value: number)
		ptr:writef64(offset, value)
	end or function(ptr: any, offset: number, value: number)
		ptr:writef32(offset, value)
	end

	for i = 1, vcount do
		local v = vertices[i]
		local source = v
		if type(v) == "table" then
			source = v.position or v.pos or v
		end
		local px, py, pz = vec3(source)
		local base = (i - 1) * nProps
		writeFloat(vertProps, (base + 0) * bytesPer, px)
		writeFloat(vertProps, (base + 1) * bytesPer, py)
		writeFloat(vertProps, (base + 2) * bytesPer, pz)
	end

	local triPtr = ffi.alloc(nTris * 3 * 4, 4)
	for i = 0, nTris - 1 do
		local base = i * 3
		local off = i * 12
		triPtr:writeu32(off + 0, idxs[base + 1])
		triPtr:writeu32(off + 4, idxs[base + 2])
		triPtr:writeu32(off + 8, idxs[base + 3])
	end

	local mesh = use64 and lib.manifold_alloc_meshgl64() or lib.manifold_alloc_meshgl()
	if use64 then
		lib.manifold_meshgl64(mesh, vertProps, vcount, nProps, triPtr, nTris)
	else
		lib.manifold_meshgl(mesh, vertProps, vcount, nProps, triPtr, nTris)
	end

	local out = allocManifold()
	if use64 then
		lib.manifold_of_meshgl64(out, mesh)
		lib.manifold_delete_meshgl64(mesh)
	else
		lib.manifold_of_meshgl(out, mesh)
		lib.manifold_delete_meshgl(mesh)
	end

	return out
end

function gen.indicesToTriangles(indices: { number })
	local tris = {}
	for i = 1, #indices - 2, 3 do
		table.insert(tris, { indices[i], indices[i + 1], indices[i + 2] })
	end
	return tris
end

local function buildAndFree(m: any, opts: any?)
	if not m or m == ffi.null then
		return nil
	end
	local mesh = gen.buildMeshFromManifold(m, opts)
	freeManifold(m)
	return mesh
end

function gen.buildBox(sx: number?, sy: number?, sz: number?, center: boolean?, opts: any?)
	return buildAndFree(gen.box(sx, sy, sz, center), opts)
end

function gen.buildBoxFromMinMax(min: any, max: any, opts: any?)
	return buildAndFree(gen.boxFromMinMax(min, max), opts)
end

function gen.buildCube(size: any?, center: boolean?, opts: any?)
	return buildAndFree(gen.cube(size, center), opts)
end

function gen.buildSphere(radius: number?, segments: number?, opts: any?)
	return buildAndFree(gen.sphere(radius, segments), opts)
end

function gen.buildCylinder(radius: number?, height: number?, segments: number?, center: boolean?, radiusTop: number?, opts: any?)
	return buildAndFree(gen.cylinder(radius, height, segments, center, radiusTop), opts)
end

function gen.buildCone(radius: number?, height: number?, segments: number?, center: boolean?, opts: any?)
	return buildAndFree(gen.cone(radius, height, segments, center), opts)
end

function gen.buildTetrahedron(opts: any?)
	return buildAndFree(gen.tetrahedron(), opts)
end

return gen
