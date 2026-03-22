local r3dapi = require("@r3d")
local r3d = r3dapi.lib
local r3dstructs = r3dapi.structs
local ffi = zune.ffi

local U32 = 4294967296
local TWO_PI = math.pi * 2
local EPSILON = 1e-8

local function readPtr64FromBuffer(buf: buffer, offset: number)
	local lo = buffer.readu32(buf, offset)
	local hi = buffer.readu32(buf, offset + 4)
	return lo + (hi * U32)
end

local function ptrFromStructFieldBuf(structBuf: buffer, fieldOff: number)
	local addr = readPtr64FromBuffer(structBuf, fieldOff)
	if addr == 0 then
		return ffi.null
	end
	local b = buffer.create(8)
	local hi = math.floor(addr / U32)
	local lo = addr - (hi * U32)
	buffer.writeu32(b, 0, lo)
	buffer.writeu32(b, 4, hi)
	return ffi.ptrFromAddress(b)
end

local function vec3(v: any)
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

local function vec2(v: any)
	if type(v) == "table" then
		if v.X ~= nil then
			return v.X, v.Y
		end
		if v.x ~= nil then
			return v.x, v.y
		end
		return v[1] or 0, v[2] or 0
	end
	return 0, 0
end

local function colorRGBA(v: any)
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

local function normalize(x, y, z)
	local len = math.sqrt(x * x + y * y + z * z)
	if len < EPSILON then
		return 0, 1, 0
	end
	local inv = 1 / len
	return x * inv, y * inv, z * inv
end

local function cross(ax, ay, az, bx, by, bz)
	return ay * bz - az * by, az * bx - ax * bz, ax * by - ay * bx
end

local function dot(ax, ay, az, bx, by, bz)
	return ax * bx + ay * by + az * bz
end

local function faceNormal(ax, ay, az, bx, by, bz, cx, cy, cz)
	local ux, uy, uz = bx - ax, by - ay, bz - az
	local vx, vy, vz = cx - ax, cy - ay, cz - az
	return normalize(cross(ux, uy, uz, vx, vy, vz))
end

local function normalFrom(a, b, c)
	local ax, ay, az = vec3(a)
	local bx, by, bz = vec3(b)
	local cx, cy, cz = vec3(c)
	return faceNormal(ax, ay, az, bx, by, bz, cx, cy, cz)
end

local _offsets = nil
local function getOffsets()
	if _offsets then
		return _offsets
	end
	_offsets = {
		vertexSize = r3dstructs.R3D_Vertex:size(),
		pos = r3dstructs.R3D_Vertex:offset("position"),
		uv = r3dstructs.R3D_Vertex:offset("texcoord"),
		normal = r3dstructs.R3D_Vertex:offset("normal"),
		color = r3dstructs.R3D_Vertex:offset("color"),
		tangent = r3dstructs.R3D_Vertex:offset("tangent"),
		boneIds = r3dstructs.R3D_Vertex:offset("boneIds"),
		weights = r3dstructs.R3D_Vertex:offset("weights"),

		mdVertices = r3dstructs.R3D_MeshData:offset("vertices"),
		mdIndices = r3dstructs.R3D_MeshData:offset("indices"),
		mdVertexCount = r3dstructs.R3D_MeshData:offset("vertexCount"),
		mdIndexCount = r3dstructs.R3D_MeshData:offset("indexCount"),
	}
	return _offsets
end

local function writeVertex(ptr, base, off, px, py, pz, nx, ny, nz, u, v, r, g, b, a, tx, ty, tz, tw)
	ptr:writef32(base + off.pos + 0, px)
	ptr:writef32(base + off.pos + 4, py)
	ptr:writef32(base + off.pos + 8, pz)
	ptr:writef32(base + off.uv + 0, u)
	ptr:writef32(base + off.uv + 4, v)
	ptr:writef32(base + off.normal + 0, nx)
	ptr:writef32(base + off.normal + 4, ny)
	ptr:writef32(base + off.normal + 8, nz)
	ptr:writeu8(base + off.color + 0, r)
	ptr:writeu8(base + off.color + 1, g)
	ptr:writeu8(base + off.color + 2, b)
	ptr:writeu8(base + off.color + 3, a)
	ptr:writef32(base + off.tangent + 0, tx)
	ptr:writef32(base + off.tangent + 4, ty)
	ptr:writef32(base + off.tangent + 8, tz)
	ptr:writef32(base + off.tangent + 12, tw)
	ptr:writei32(base + off.boneIds + 0, 0)
	ptr:writei32(base + off.boneIds + 4, 0)
	ptr:writei32(base + off.boneIds + 8, 0)
	ptr:writei32(base + off.boneIds + 12, 0)
	ptr:writef32(base + off.weights + 0, 0)
	ptr:writef32(base + off.weights + 4, 0)
	ptr:writef32(base + off.weights + 8, 0)
	ptr:writef32(base + off.weights + 12, 0)
end

local meshgen = {}

meshgen.Primitive = {
	Points = 0,
	Lines = 1,
	LineStrip = 2,
	LineLoop = 3,
	Triangles = 4,
	TriangleStrip = 5,
	TriangleFan = 6,
}

meshgen.Usage = {
	Static = 0,
	Dynamic = 1,
	Streamed = 2,
}

function meshgen.weldVertices(vertices: { any }, indices: { number }?, tolerance: number?)
	local tol = tolerance or EPSILON
	local tol2 = tol * tol

	local function key(px, py, pz, nx, ny, nz, u, v)
		local bx = math.floor(px / tol + 0.5)
		local by = math.floor(py / tol + 0.5)
		local bz = math.floor(pz / tol + 0.5)
		return bx .. "|" .. by .. "|" .. bz
	end

	local srcIndices = indices
	if not srcIndices then
		srcIndices = {}
		for i = 1, #vertices do
			srcIndices[i] = i - 1
		end
	end

	local newVerts = {}
	local newIndices = {}
	local buckets = {} -- key -> list of {newIdx, px,py,pz,nx,ny,nz,u,v}

	for _, rawIdx in ipairs(srcIndices) do
		local v = vertices[rawIdx + 1]
		local px, py, pz = vec3(v.position or v.pos or v[1] or v)
		local nx, ny, nz = vec3(v.normal or v.n)
		local u, w = vec2(v.uv or v.texcoord or v.t)

		local k = key(px, py, pz, nx, ny, nz, u, w)
		local bucket = buckets[k]
		local found = -1

		if bucket then
			for _, entry in ipairs(bucket) do
				local dx = px - entry[2]
				local dy = py - entry[3]
				local dz = pz - entry[4]
				if dx * dx + dy * dy + dz * dz <= tol2 then
					found = entry[1]
					break
				end
			end
		end

		if found >= 0 then
			table.insert(newIndices, found)
		else
			local newIdx = #newVerts
			table.insert(newVerts, v)
			table.insert(newIndices, newIdx)
			if not bucket then
				bucket = {}
				buckets[k] = bucket
			end
			table.insert(bucket, { newIdx, px, py, pz })
		end
	end

	return newVerts, newIndices
end

function meshgen.recalculateNormals(vertices: { any }, indices: { number }, smooth: boolean?)
	if smooth then
		local accumX = {}
		local accumY = {}
		local accumZ = {}
		for i = 1, #vertices do
			accumX[i] = 0
			accumY[i] = 0
			accumZ[i] = 0
		end

		local icount = #indices
		for i = 1, icount - 2, 3 do
			local i0 = indices[i] + 1
			local i1 = indices[i + 1] + 1
			local i2 = indices[i + 2] + 1
			local v0, v1, v2 = vertices[i0], vertices[i1], vertices[i2]
			local ax, ay, az = vec3(v0.position or v0.pos or v0)
			local bx, by, bz = vec3(v1.position or v1.pos or v1)
			local cx, cy, cz = vec3(v2.position or v2.pos or v2)
			local ux, uy, uz = bx - ax, by - ay, bz - az
			local vx, vy, vz = cx - ax, cy - ay, cz - az
			local nx, ny, nz = cross(ux, uy, uz, vx, vy, vz)
			accumX[i0] += nx
			accumY[i0] += ny
			accumZ[i0] += nz
			accumX[i1] += nx
			accumY[i1] += ny
			accumZ[i1] += nz
			accumX[i2] += nx
			accumY[i2] += ny
			accumZ[i2] += nz
		end

		for i = 1, #vertices do
			local nx, ny, nz = normalize(accumX[i], accumY[i], accumZ[i])
			local v = vertices[i]
			v.normal = { nx, ny, nz }
		end
	else
		local icount = #indices
		for i = 1, icount - 2, 3 do
			local i0 = indices[i] + 1
			local i1 = indices[i + 1] + 1
			local i2 = indices[i + 2] + 1
			local v0, v1, v2 = vertices[i0], vertices[i1], vertices[i2]
			local ax, ay, az = vec3(v0.position or v0.pos or v0)
			local bx, by, bz = vec3(v1.position or v1.pos or v1)
			local cx, cy, cz = vec3(v2.position or v2.pos or v2)
			local nx, ny, nz = faceNormal(ax, ay, az, bx, by, bz, cx, cy, cz)
			local n = { nx, ny, nz }
			v0.normal = n
			v1.normal = n
			v2.normal = n
		end
	end
end

function meshgen.generateTangents(vertices: { any }, indices: { number })
	local vcount = #vertices
	local tanAx, tanAy, tanAz = {}, {}, {}
	local tanBx, tanBy, tanBz = {}, {}, {}

	for i = 1, vcount do
		tanAx[i] = 0
		tanAy[i] = 0
		tanAz[i] = 0
		tanBx[i] = 0
		tanBy[i] = 0
		tanBz[i] = 0
	end

	local icount = #indices
	for i = 1, icount - 2, 3 do
		local i0 = indices[i] + 1
		local i1 = indices[i + 1] + 1
		local i2 = indices[i + 2] + 1
		local v0, v1, v2 = vertices[i0], vertices[i1], vertices[i2]

		local x1, y1, z1 = vec3(v1.position or v1.pos or v1)
		local x2, y2, z2 = vec3(v2.position or v2.pos or v2)
		local x0, y0, z0 = vec3(v0.position or v0.pos or v0)
		x1 -= x0
		y1 -= y0
		z1 -= z0
		x2 -= x0
		y2 -= y0
		z2 -= z0

		local u0, v0uv = vec2(v0.uv or v0.texcoord or v0.t)
		local u1, v1uv = vec2(v1.uv or v1.texcoord or v1.t)
		local u2, v2uv = vec2(v2.uv or v2.texcoord or v2.t)
		local s1, t1 = u1 - u0, v1uv - v0uv
		local s2, t2 = u2 - u0, v2uv - v0uv

		local denom = s1 * t2 - s2 * t1
		local r = (math.abs(denom) > EPSILON) and (1 / denom) or 0

		local tsx = (t2 * x1 - t1 * x2) * r
		local tsy = (t2 * y1 - t1 * y2) * r
		local tsz = (t2 * z1 - t1 * z2) * r
		local ttx = (s1 * x2 - s2 * x1) * r
		local tty = (s1 * y2 - s2 * y1) * r
		local ttz = (s1 * z2 - s2 * z1) * r

		for _, idx in ipairs({ i0, i1, i2 }) do
			tanAx[idx] += tsx
			tanAy[idx] += tsy
			tanAz[idx] += tsz
			tanBx[idx] += ttx
			tanBy[idx] += tty
			tanBz[idx] += ttz
		end
	end

	for i = 1, vcount do
		local v = vertices[i]
		local nx, ny, nz = vec3(v.normal or v.n)
		local tx, ty, tz = tanAx[i], tanAy[i], tanAz[i]

		local d = dot(nx, ny, nz, tx, ty, tz)
		tx -= nx * d
		ty -= ny * d
		tz -= nz * d
		tx, ty, tz = normalize(tx, ty, tz)

		local cx, cy, cz = cross(nx, ny, nz, tanAx[i], tanAy[i], tanAz[i])
		local w = (dot(cx, cy, cz, tanBx[i], tanBy[i], tanBz[i]) < 0) and -1 or 1

		v.tangent = { tx, ty, tz, w }
	end
end

function meshgen.uvPlanar(vertices: { any }, axis: string?, scale: { number }?, offset: { number }?)
	axis = axis or "y"
	local sx = scale and (scale[1] or 1) or 1
	local sy = scale and (scale[2] or 1) or 1
	local ox = offset and (offset[1] or 0) or 0
	local oy = offset and (offset[2] or 0) or 0

	for _, v in ipairs(vertices) do
		local px, py, pz = vec3(v.position or v.pos or v)
		local u, w
		if axis == "x" then
			u, w = pz * sx + ox, py * sy + oy
		elseif axis == "z" then
			u, w = px * sx + ox, py * sy + oy
		else -- y (default)
			u, w = px * sx + ox, pz * sy + oy
		end
		v.uv = { u, w }
	end
end

function meshgen.uvCylindrical(vertices: { any }, heightScale: number?, yOffset: number?)
	local hs = heightScale or 1
	local yo = yOffset or 0
	for _, v in ipairs(vertices) do
		local px, py, pz = vec3(v.position or v.pos or v)
		local u = (math.atan2(pz, px) / TWO_PI) + 0.5
		local w = py * hs + yo
		v.uv = { u, w }
	end
end

function meshgen.uvSpherical(vertices: { any })
	for _, v in ipairs(vertices) do
		local px, py, pz = vec3(v.position or v.pos or v)
		local nx, ny, nz = normalize(px, py, pz)
		local u = (math.atan2(nz, nx) / TWO_PI) + 0.5
		local w = math.acos(math.clamp(ny, -1, 1)) / math.pi
		v.uv = { u, w }
	end
end

-- opts:
--   primitive         meshgen.Primitive.*
--   usage             meshgen.Usage.*
--   indicesAreZeroBased  boolean
--   weld              boolean  – deduplicate vertices before upload
--   weldTolerance     number
--   smooth            boolean  – recalculate smooth normals (overrides per-vertex normals)
--   flat              boolean  – recalculate flat normals
--   generateTangents  boolean  – auto-generate tangents after normals

function meshgen.buildMeshData(vertices: { any }, indices: { number }?, opts: any?)
	local verts = vertices
	local idxs = indices

	if opts and opts.weld then
		verts, idxs = meshgen.weldVertices(verts, idxs, opts.weldTolerance)
		opts = opts or {}
		opts.indicesAreZeroBased = true
	end

	local vcount = #verts
	if vcount <= 0 then
		warn("meshgen.buildMeshData: no vertices")
		return nil
	end

	if not idxs then
		idxs = table.create(vcount)
		for i = 1, vcount do
			idxs[i] = i - 1
		end
	end
	local icount = #idxs

	local zeroBased = opts and opts.indicesAreZeroBased
	if not zeroBased then
		local shifted = table.create(icount)
		for i = 1, icount do
			shifted[i] = idxs[i] - 1
		end
		idxs = shifted
	end

	if opts and (opts.smooth or opts.flat) then
		meshgen.recalculateNormals(verts, idxs, opts.smooth == true)
	end
	if opts and opts.generateTangents then
		meshgen.generateTangents(verts, idxs)
	end

	local meshData = r3d.R3D_LoadMeshData(vcount, icount)
	local off = getOffsets()
	local verticesPtr = ptrFromStructFieldBuf(meshData, off.mdVertices)
	local indicesPtr = ptrFromStructFieldBuf(meshData, off.mdIndices)

	if verticesPtr == ffi.null then
		warn("meshgen.buildMeshData: vertices pointer is null")
		return nil
	end

	local vsize = off.vertexSize
	for i = 1, vcount do
		local v = verts[i]
		local base = (i - 1) * vsize

		local px, py, pz = vec3(v.position or v.pos or v[1] or v)
		local hasN = v.normal ~= nil or v.n ~= nil
		local nx, ny, nz = vec3(v.normal or v.n)
		if not hasN then
			nx, ny, nz = 0, 1, 0
		end
		local u, w = vec2(v.uv or v.texcoord or v.t)
		local r, g, b, a = colorRGBA(v.color or v.c)
		local tan = v.tangent or v.tan
		local tx, ty, tz = 0, 0, 0
		local tw = 1
		if tan then
			tx, ty, tz = vec3(tan)
			tw = tan.w or tan.W or tan[4] or 1
		end

		writeVertex(verticesPtr, base, off, px, py, pz, nx, ny, nz, u, w, r, g, b, a, tx, ty, tz, tw)
	end

	if icount > 0 and indicesPtr ~= ffi.null then
		for i = 1, icount do
			indicesPtr:writeu32((i - 1) * 4, idxs[i])
		end
	end

	buffer.writei32(meshData, off.mdVertexCount, vcount)
	buffer.writei32(meshData, off.mdIndexCount, icount)

	return meshData
end

function meshgen.buildMesh(vertices: { any }, indices: { number }?, opts: any?)
	local meshData = meshgen.buildMeshData(vertices, indices, opts)
	if not meshData then
		return nil
	end

	local primitive = (opts and opts.primitive) or meshgen.Primitive.Triangles
	local usage = (opts and opts.usage) or meshgen.Usage.Static

	local mesh = r3d.R3D_LoadMesh(primitive, meshData, ffi.null, usage)
	r3d.R3D_UnloadMeshData(meshData)
	return mesh
end

function meshgen.mergeMeshData(meshList: { { vertices: { any }, indices: { number } } })
	local outVerts = {}
	local outIndices = {}
	local offset = 0

	for _, m in ipairs(meshList) do
		local verts = m.vertices
		local indices = m.indices or {}
		local vcount = #verts

		for _, v in ipairs(verts) do
			table.insert(outVerts, v)
		end
		for _, idx in ipairs(indices) do
			table.insert(outIndices, idx + offset)
		end
		offset += vcount
	end

	return outVerts, outIndices
end

function meshgen.buildMergedMesh(meshList: { { vertices: { any }, indices: { number } } }, opts: any?)
	local verts, indices = meshgen.mergeMeshData(meshList)
	local newOpts = opts or {}
	newOpts.indicesAreZeroBased = true
	return meshgen.buildMesh(verts, indices, newOpts)
end

function meshgen.genPlane(width: number?, depth: number?, segments: any?, color: any?)
	width = width or 1
	depth = depth or 1
	segments = segments or {}
	local sx = math.max(1, segments.x or segments[1] or 1)
	local sz = math.max(1, segments.z or segments[2] or 1)

	local r, g, b, a = colorRGBA(color)
	local verts = {}
	local indices = {}

	local hw, hd = width * 0.5, depth * 0.5
	local du, dv = 1 / sx, 1 / sz

	for iz = 0, sz do
		for ix = 0, sx do
			local u = ix * du
			local v = iz * dv
			table.insert(verts, {
				position = { u * width - hw, 0, v * depth - hd },
				normal = { 0, 1, 0 },
				uv = { u, v },
				color = { r, g, b, a },
			})
		end
	end

	local stride = sx + 1
	for iz = 0, sz - 1 do
		for ix = 0, sx - 1 do
			local i00 = iz * stride + ix
			local i10 = i00 + 1
			local i01 = i00 + stride
			local i11 = i01 + 1
			table.insert(indices, i00)
			table.insert(indices, i01)
			table.insert(indices, i10)
			table.insert(indices, i10)
			table.insert(indices, i01)
			table.insert(indices, i11)
		end
	end

	return verts, indices
end

function meshgen.genSphere(radius: number?, stacks: number?, slices: number?, color: any?)
	radius = radius or 0.5
	stacks = math.max(2, stacks or 16)
	slices = math.max(3, slices or 16)

	local r, g, b, a = colorRGBA(color)
	local verts = {}
	local indices = {}

	for i = 0, stacks do
		local phi = math.pi * i / stacks -- 0 .. π
		local sinPhi = math.sin(phi)
		local cosPhi = math.cos(phi)
		local tv = i / stacks

		for j = 0, slices do
			local theta = TWO_PI * j / slices -- 0 .. 2π
			local sinT = math.sin(theta)
			local cosT = math.cos(theta)

			local nx = sinPhi * cosT
			local ny = cosPhi
			local nz = sinPhi * sinT
			local u = j / slices
			table.insert(verts, {
				position = { nx * radius, ny * radius, nz * radius },
				normal = { nx, ny, nz },
				uv = { u, tv },
				color = { r, g, b, a },
			})
		end
	end

	local stride = slices + 1
	for i = 0, stacks - 1 do
		for j = 0, slices - 1 do
			local i0 = i * stride + j
			local i1 = i0 + 1
			local i2 = i0 + stride
			local i3 = i2 + 1
			table.insert(indices, i0)
			table.insert(indices, i2)
			table.insert(indices, i1)
			table.insert(indices, i1)
			table.insert(indices, i2)
			table.insert(indices, i3)
		end
	end

	return verts, indices
end

function meshgen.genBox(sx: number?, sy: number?, sz: number?, color: any?)
	sx = (sx or 1) * 0.5
	sy = (sy or 1) * 0.5
	sz = (sz or 1) * 0.5
	local r, g, b, a = colorRGBA(color)

	local faces = {
		{
			n = { 0, 1, 0 },
			corners = { { -sx, sy, -sz }, { sx, sy, -sz }, { sx, sy, sz }, { -sx, sy, sz } },
			uvs = {
				{ 0, 0 },
				{ 1, 0 },
				{ 1, 1 },
				{ 0, 1 },
			},
		},
		{
			n = { 0, -1, 0 },
			corners = { { -sx, -sy, sz }, { sx, -sy, sz }, { sx, -sy, -sz }, { -sx, -sy, -sz } },
			uvs = { { 0, 0 }, { 1, 0 }, { 1, 1 }, { 0, 1 } },
		},
		{
			n = { 0, 0, 1 },
			corners = { { -sx, -sy, sz }, { -sx, sy, sz }, { sx, sy, sz }, { sx, -sy, sz } },
			uvs = { { 0, 0 }, { 0, 1 }, { 1, 1 }, { 1, 0 } },
		},
		{
			n = { 0, 0, -1 },
			corners = { { sx, -sy, -sz }, { sx, sy, -sz }, { -sx, sy, -sz }, { -sx, -sy, -sz } },
			uvs = { { 0, 0 }, { 0, 1 }, { 1, 1 }, { 1, 0 } },
		},
		{
			n = { 1, 0, 0 },
			corners = { { sx, -sy, sz }, { sx, sy, sz }, { sx, sy, -sz }, { sx, -sy, -sz } },
			uvs = { { 0, 0 }, { 0, 1 }, { 1, 1 }, { 1, 0 } },
		},
		{
			n = { -1, 0, 0 },
			corners = { { -sx, -sy, -sz }, { -sx, sy, -sz }, { -sx, sy, sz }, { -sx, -sy, sz } },
			uvs = { { 0, 0 }, { 0, 1 }, { 1, 1 }, { 1, 0 } },
		},
	}

	local verts = {}
	local indices = {}

	for _, face in ipairs(faces) do
		local base = #verts
		for ci, c in ipairs(face.corners) do
			table.insert(verts, {
				position = c,
				normal = face.n,
				uv = face.uvs[ci],
				color = { r, g, b, a },
			})
		end
		table.insert(indices, base + 0)
		table.insert(indices, base + 1)
		table.insert(indices, base + 2)
		table.insert(indices, base + 0)
		table.insert(indices, base + 2)
		table.insert(indices, base + 3)
	end

	return verts, indices
end

function meshgen.genCapsule(radius: number?, height: number?, stacks: number?, slices: number?, color: any?)
	radius = radius or 0.5
	height = height or 2.0
	stacks = math.max(2, stacks or 8)
	slices = math.max(3, slices or 16)

	local r, g, b, a = colorRGBA(color)
	local halfH = height * 0.5 - radius
	if halfH < 0 then
		halfH = 0
	end

	local verts = {}
	local indices = {}

	local function addHemisphere(ySign: number, yOffset: number, uRowStart: number)
		for i = 0, stacks do
			local phi = (math.pi * 0.5) * (i / stacks)
			local sinPhi = math.sin(phi)
			local cosPhi = math.cos(phi)
			local tv = uRowStart + (i / stacks) * 0.25

			for j = 0, slices do
				local theta = TWO_PI * j / slices
				local nx = math.sin(theta) * sinPhi
				local ny = cosPhi * ySign
				local nz = math.cos(theta) * sinPhi
				table.insert(verts, {
					position = { nx * radius, ny * radius + yOffset, nz * radius },
					normal = { nx, ny, nz },
					uv = { j / slices, tv },
					color = { r, g, b, a },
				})
			end
		end
	end

	addHemisphere(-1, -halfH, 0)
	local capVerts = (stacks + 1) * (slices + 1)

	local bodyRows = 2
	for i = 0, bodyRows do
		local t = i / bodyRows
		local y = -halfH + t * halfH * 2
		local tv = 0.25 + t * 0.5
		for j = 0, slices do
			local theta = TWO_PI * j / slices
			local nx = math.sin(theta)
			local nz = math.cos(theta)
			table.insert(verts, {
				position = { nx * radius, y, nz * radius },
				normal = { nx, 0, nz },
				uv = { j / slices, tv },
				color = { r, g, b, a },
			})
		end
	end
	local bodyVerts = (bodyRows + 1) * (slices + 1)

	addHemisphere(1, halfH, 0.75)

	local function addGridIndices(base: number, rows: number)
		local stride = slices + 1
		for i = 0, rows - 1 do
			for j = 0, slices - 1 do
				local i0 = base + i * stride + j
				local i1 = i0 + 1
				local i2 = i0 + stride
				local i3 = i2 + 1
				table.insert(indices, i0)
				table.insert(indices, i2)
				table.insert(indices, i1)
				table.insert(indices, i1)
				table.insert(indices, i2)
				table.insert(indices, i3)
			end
		end
	end

	addGridIndices(0, stacks)
	addGridIndices(capVerts, bodyRows)
	addGridIndices(capVerts + bodyVerts, stacks)

	return verts, indices
end

local function buildPrimitive(verts, indices, opts)
	local newOpts = opts or {}
	newOpts.indicesAreZeroBased = true
	return meshgen.buildMesh(verts, indices, newOpts)
end

function meshgen.buildPlane(width, depth, segments, color, opts)
	local v, i = meshgen.genPlane(width, depth, segments, color)
	return buildPrimitive(v, i, opts)
end

function meshgen.buildSphere(radius, stacks, slices, color, opts)
	local v, i = meshgen.genSphere(radius, stacks, slices, color)
	return buildPrimitive(v, i, opts)
end

function meshgen.buildBox(sx, sy, sz, color, opts)
	local v, i = meshgen.genBox(sx, sy, sz, color)
	return buildPrimitive(v, i, opts)
end

function meshgen.buildCapsule(radius, height, stacks, slices, color, opts)
	local v, i = meshgen.genCapsule(radius, height, stacks, slices, color)
	return buildPrimitive(v, i, opts)
end

function meshgen.buildFromTriangles(triangles: { any }, opts: any?)
	local verts = {}
	local indices = {}
	local vi = 0

	for _, tri in ipairs(triangles) do
		local p1, p2, p3 = tri[1], tri[2], tri[3]
		local nx, ny, nz = normalFrom(p1, p2, p3)

		table.insert(verts, { position = p1, normal = { nx, ny, nz }, uv = { 0, 0 } })
		table.insert(verts, { position = p2, normal = { nx, ny, nz }, uv = { 1, 0 } })
		table.insert(verts, { position = p3, normal = { nx, ny, nz }, uv = { 0, 1 } })

		table.insert(indices, vi)
		table.insert(indices, vi + 1)
		table.insert(indices, vi + 2)
		vi += 3
	end

	local newOpts = opts or {}
	newOpts.indicesAreZeroBased = true
	return meshgen.buildMesh(verts, indices, newOpts)
end

return meshgen
