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
	for k = 0, 3 do
		ptr:writei32(base + off.boneIds + k * 4, 0)
	end
	for k = 0, 3 do
		ptr:writef32(base + off.weights + k * 4, 0)
	end
end

-- meshgen
local meshgen = {}

meshgen.Primitive =
	{ Points = 0, Lines = 1, LineStrip = 2, LineLoop = 3, Triangles = 4, TriangleStrip = 5, TriangleFan = 6 }
meshgen.Usage = { Static = 0, Dynamic = 1, Streamed = 2 }

function meshgen.autoSmooth(vertices: { any }, indices: { number }?, opts: any?)
	opts = opts or {}
	local threshold = math.rad(opts.angleThreshold or 30)
	local tolerance = opts.tolerance or EPSILON
	local tol2 = tolerance * tolerance

	-- ── 1. make sure we have zero-based indices ──────────────────────────────
	local idxs
	if indices then
		idxs = indices
	else
		idxs = table.create(#vertices)
		for i = 1, #vertices do
			idxs[i] = i - 1
		end
	end

	-- ── 2. position-weld: map every original vertex to a canonical position id
	--       so we can know which triangles truly share a corner in space.
	local posId = table.create(#vertices) -- posId[vertIdx+1] = canonical pos id
	local posList = {} -- list of {x,y,z}
	local posBuckets = {}

	local function posKey(px, py, pz)
		local bx = math.floor(px / tolerance + 0.5)
		local by = math.floor(py / tolerance + 0.5)
		local bz = math.floor(pz / tolerance + 0.5)
		return bx .. "|" .. by .. "|" .. bz
	end

	for vi = 1, #vertices do
		local v = vertices[vi]
		local px, py, pz = vec3(v.position or v.pos or v[1] or v)
		local k = posKey(px, py, pz)
		local bucket = posBuckets[k]
		local found = -1
		if bucket then
			for _, entry in ipairs(bucket) do
				local p = posList[entry]
				local dx = px - p[1]
				local dy = py - p[2]
				local dz = pz - p[3]
				if dx * dx + dy * dy + dz * dz <= tol2 then
					found = entry
					break
				end
			end
		end
		if found >= 0 then
			posId[vi] = found
		else
			local newId = #posList + 1
			posList[newId] = { px, py, pz }
			if not bucket then
				bucket = {}
				posBuckets[k] = bucket
			end
			table.insert(bucket, newId)
			posId[vi] = newId
		end
	end

	-- ── 3. compute per-face flat normal ──────────────────────────────────────
	local triCount = #idxs // 3
	local faceNormals = table.create(triCount)

	for t = 0, triCount - 1 do
		local i0 = idxs[t * 3 + 1] + 1
		local i1 = idxs[t * 3 + 2] + 1
		local i2 = idxs[t * 3 + 3] + 1
		local v0, v1, v2 = vertices[i0], vertices[i1], vertices[i2]
		local ax, ay, az = vec3(v0.position or v0.pos or v0[1] or v0)
		local bx, by, bz = vec3(v1.position or v1.pos or v1[1] or v1)
		local cx, cy, cz = vec3(v2.position or v2.pos or v2[1] or v2)
		local nx, ny, nz = faceNormal(ax, ay, az, bx, by, bz, cx, cy, cz)
		faceNormals[t + 1] = { nx, ny, nz }
	end

	-- ── 4. for each position, collect the faces that touch it ─────────────────
	local posToFaces = {} -- posToFaces[posId] = { faceIdx, ... }
	for t = 0, triCount - 1 do
		for k = 1, 3 do
			local vi = idxs[t * 3 + k] + 1
			local pid = posId[vi]
			if not posToFaces[pid] then
				posToFaces[pid] = {}
			end
			table.insert(posToFaces[pid], t + 1)
		end
	end

	-- ── 5. for each (face, corner), accumulate normals from neighbouring faces
	--       whose angle with the current face is within the threshold.
	--       Each unique (face, corner-posId) that shares a smooth group becomes
	--       one output vertex.
	local outVerts = {}
	local outIndices = {}

	-- cache: smoothNormal[faceIdx][cornerPosId] = output vertex index
	local smoothCache = {}

	for t = 0, triCount - 1 do
		local fi = t + 1
		local fn = faceNormals[fi]
		smoothCache[fi] = smoothCache[fi] or {}

		for k = 1, 3 do
			local vi = idxs[t * 3 + k] + 1
			local pid = posId[vi]

			if not smoothCache[fi][pid] then
				-- accumulate normals from all neighbour faces that are smooth
				local accX, accY, accZ = fn[1], fn[2], fn[3]

				for _, nfi in ipairs(posToFaces[pid]) do
					if nfi ~= fi then
						local nfn = faceNormals[nfi]
						local cosA = dot(fn[1], fn[2], fn[3], nfn[1], nfn[2], nfn[3])
						if math.acos(math.clamp(cosA, -1, 1)) <= threshold then
							accX += nfn[1]
							accY += nfn[2]
							accZ += nfn[3]
						end
					end
				end

				local snx, sny, snz = normalize(accX, accY, accZ)

				-- build the output vertex, copying all fields from the source
				local src = vertices[vi]
				local nv = {}
				for fk, fv in pairs(src) do
					nv[fk] = fv
				end
				nv.normal = { snx, sny, snz }

				local newIdx = #outVerts
				table.insert(outVerts, nv)
				smoothCache[fi][pid] = newIdx
			end

			table.insert(outIndices, smoothCache[fi][pid])
		end
	end

	return outVerts, outIndices
end

function meshgen.buildAutoSmooth(vertices, indices, opts)
	local sv, si = meshgen.autoSmooth(vertices, indices, opts)
	local buildOpts = {}
	if opts then
		for k, v in pairs(opts) do
			buildOpts[k] = v
		end
	end
	buildOpts.indicesAreZeroBased = true
	if opts and opts.generateTangents == nil then
		buildOpts.generateTangents = true
	end
	return meshgen.buildMesh(sv, si, buildOpts)
end

-- Transform all vertex positions (and normals) by a simple TRS.
-- opts: translate={x,y,z}  rotate={rx,ry,rz} (radians, Euler XYZ)  scale={x,y,z}
function meshgen.transformVertices(vertices: { any }, opts: any?)
	opts = opts or {}
	local tx, ty, tz = vec3(opts.translate or { 0, 0, 0 })
	local rx, ry, rz = vec3(opts.rotate or { 0, 0, 0 })
	local sx_v, sy_v, sz_v = vec3(opts.scale or { 1, 1, 1 })
	if sx_v == 0 then
		sx_v = 1
	end
	if sy_v == 0 then
		sy_v = 1
	end
	if sz_v == 0 then
		sz_v = 1
	end

	-- Build rotation matrix (XYZ Euler)
	local cx, sx = math.cos(rx), math.sin(rx)
	local cy, sy = math.cos(ry), math.sin(ry)
	local cz, sz_ = math.cos(rz), math.sin(rz)

	local function rotXYZ(px, py, pz)
		-- X
		local y1 = cx * py - sx * pz
		local z1 = sx * py + cx * pz
		-- Y
		local x2 = cy * px + sy * z1
		local z2 = -sy * px + cy * z1
		-- Z
		local x3 = cz * x2 - sz_ * y1
		local y3 = sz_ * x2 + cz * y1
		return x3, y3, z2
	end

	for _, v in ipairs(vertices) do
		local px, py, pz = vec3(v.position or v.pos or v)
		px *= sx_v
		py *= sy_v
		pz *= sz_v
		px, py, pz = rotXYZ(px, py, pz)
		px += tx
		py += ty
		pz += tz
		v.position = { px, py, pz }

		if v.normal then
			local nx, ny, nz = vec3(v.normal)
			nx, ny, nz = rotXYZ(nx, ny, nz)
			v.normal = { normalize(nx, ny, nz) }
		end
	end
end

-- Flip all normals and reverse winding order so the mesh renders inside-out.
function meshgen.invertNormals(vertices: { any }, indices: { number })
	for _, v in ipairs(vertices) do
		if v.normal then
			local nx, ny, nz = vec3(v.normal)
			v.normal = { -nx, -ny, -nz }
		end
	end
	local n = #indices
	for i = 1, n - 2, 3 do
		indices[i], indices[i + 2] = indices[i + 2], indices[i]
	end
end

-- Colorise every vertex with a gradient based on world-space Y height.
-- colorLow / colorHigh: {r,g,b,a} or Color3
function meshgen.applyHeightGradient(vertices: { any }, colorLow: any, colorHigh: any, yMin: number?, yMax: number?)
	local lr, lg, lb, la = colorRGBA(colorLow)
	local hr, hg, hb, ha = colorRGBA(colorHigh)

	-- auto-detect range if not provided
	if not yMin or not yMax then
		local mn, mx = math.huge, -math.huge
		for _, v in ipairs(vertices) do
			local _, py, _ = vec3(v.position or v.pos or v)
			if py < mn then
				mn = py
			end
			if py > mx then
				mx = py
			end
		end
		yMin = yMin or mn
		yMax = yMax or mx
	end

	local range = yMax - yMin
	if range < EPSILON then
		range = 1
	end

	for _, v in ipairs(vertices) do
		local _, py, _ = vec3(v.position or v.pos or v)
		local t = math.clamp((py - yMin) / range, 0, 1)
		v.color = {
			math.floor(lr + (hr - lr) * t + 0.5),
			math.floor(lg + (hg - lg) * t + 0.5),
			math.floor(lb + (hb - lb) * t + 0.5),
			math.floor(la + (ha - la) * t + 0.5),
		}
	end
end

function meshgen.weldVertices(vertices, indices, tolerance)
	local tol = tolerance or EPSILON
	local tol2 = tol * tol

	local function key(px, py, pz)
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
	local buckets = {}

	for _, rawIdx in ipairs(srcIndices) do
		local v = vertices[rawIdx + 1]
		local px, py, pz = vec3(v.position or v.pos or v[1] or v)
		local k = key(px, py, pz)
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

function meshgen.recalculateNormals(vertices, indices, smooth)
	if smooth then
		local accumX, accumY, accumZ = {}, {}, {}
		for i = 1, #vertices do
			accumX[i] = 0
			accumY[i] = 0
			accumZ[i] = 0
		end

		for i = 1, #indices - 2, 3 do
			local i0, i1, i2 = indices[i] + 1, indices[i + 1] + 1, indices[i + 2] + 1
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
			vertices[i].normal = { nx, ny, nz }
		end
	else
		for i = 1, #indices - 2, 3 do
			local i0, i1, i2 = indices[i] + 1, indices[i + 1] + 1, indices[i + 2] + 1
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

function meshgen.generateTangents(vertices, indices)
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

	for i = 1, #indices - 2, 3 do
		local i0, i1, i2 = indices[i] + 1, indices[i + 1] + 1, indices[i + 2] + 1
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

function meshgen.uvPlanar(vertices, axis, scale, offset)
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
		else
			u, w = px * sx + ox, pz * sy + oy
		end
		v.uv = { u, w }
	end
end

function meshgen.uvCylindrical(vertices, heightScale, yOffset)
	local hs = heightScale or 1
	local yo = yOffset or 0
	for _, v in ipairs(vertices) do
		local px, py, pz = vec3(v.position or v.pos or v)
		v.uv = { (math.atan2(pz, px) / TWO_PI) + 0.5, py * hs + yo }
	end
end

function meshgen.uvSpherical(vertices)
	for _, v in ipairs(vertices) do
		local px, py, pz = vec3(v.position or v.pos or v)
		local nx, ny, nz = normalize(px, py, pz)
		v.uv = { (math.atan2(nz, nx) / TWO_PI) + 0.5, math.acos(math.clamp(ny, -1, 1)) / math.pi }
	end
end

function meshgen.buildMeshData(vertices, indices, opts)
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
		local tx, ty, tz, tw = 0, 0, 0, 1
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

function meshgen.buildMesh(vertices, indices, opts)
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

function meshgen.mergeMeshData(meshList)
	local outVerts, outIndices, offset = {}, {}, 0
	for _, m in ipairs(meshList) do
		local verts = m.vertices
		local indices = m.indices or {}
		for _, v in ipairs(verts) do
			table.insert(outVerts, v)
		end
		for _, idx in ipairs(indices) do
			table.insert(outIndices, idx + offset)
		end
		offset += #verts
	end
	return outVerts, outIndices
end

function meshgen.buildMergedMesh(meshList, opts)
	local verts, indices = meshgen.mergeMeshData(meshList)
	local newOpts = opts or {}
	newOpts.indicesAreZeroBased = true
	return meshgen.buildMesh(verts, indices, newOpts)
end

function meshgen.genPlane(width, depth, segments, color)
	width = width or 1
	depth = depth or 1
	segments = segments or {}
	local sx = math.max(1, segments.x or segments[1] or 1)
	local sz = math.max(1, segments.z or segments[2] or 1)
	local r, g, b, a = colorRGBA(color)
	local verts, indices = {}, {}
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
				color = {
					r,
					g,
					b,
					a,
				},
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

function meshgen.genSphere(radius, stacks, slices, color)
	radius = radius or 0.5
	stacks = math.max(2, stacks or 16)
	slices = math.max(3, slices or 16)
	local r, g, b, a = colorRGBA(color)
	local verts, indices = {}, {}
	for i = 0, stacks do
		local phi = math.pi * i / stacks
		local sinPhi, cosPhi = math.sin(phi), math.cos(phi)
		local tv = i / stacks
		for j = 0, slices do
			local theta = TWO_PI * j / slices
			local nx = sinPhi * math.cos(theta)
			local ny = cosPhi
			local nz = sinPhi * math.sin(theta)
			table.insert(verts, {
				position = { nx * radius, ny * radius, nz * radius },
				normal = { nx, ny, nz },
				uv = { j / slices, tv },
				color = {
					r,
					g,
					b,
					a,
				},
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

function meshgen.genBox(sx, sy, sz, color)
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
			uvs = {
				{ 0, 0 },
				{ 0, 1 },
				{ 1, 1 },
				{ 1, 0 },
			},
		},
		{
			n = { 0, 0, -1 },
			corners = { { sx, -sy, -sz }, { sx, sy, -sz }, { -sx, sy, -sz }, { -sx, -sy, -sz } },
			uvs = { { 0, 0 }, { 0, 1 }, { 1, 1 }, { 1, 0 } },
		},
		{
			n = { 1, 0, 0 },
			corners = { { sx, -sy, sz }, { sx, sy, sz }, { sx, sy, -sz }, { sx, -sy, -sz } },
			uvs = {
				{ 0, 0 },
				{ 0, 1 },
				{ 1, 1 },
				{ 1, 0 },
			},
		},
		{
			n = { -1, 0, 0 },
			corners = { { -sx, -sy, -sz }, { -sx, sy, -sz }, { -sx, sy, sz }, { -sx, -sy, sz } },
			uvs = { { 0, 0 }, { 0, 1 }, { 1, 1 }, { 1, 0 } },
		},
	}
	local verts, indices = {}, {}
	for _, face in ipairs(faces) do
		local base = #verts
		for ci, c in ipairs(face.corners) do
			table.insert(verts, { position = c, normal = face.n, uv = face.uvs[ci], color = { r, g, b, a } })
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

function meshgen.genCapsule(radius, height, stacks, slices, color)
	radius = radius or 0.5
	height = height or 2.0
	stacks = math.max(2, stacks or 8)
	slices = math.max(3, slices or 16)
	local r, g, b, a = colorRGBA(color)
	local halfH = math.max(0, height * 0.5 - radius)
	local verts, indices = {}, {}

	local function addHemisphere(ySign, yOffset, uRowStart)
		for i = 0, stacks do
			local phi = (math.pi * 0.5) * (i / stacks)
			local sinPhi, cosPhi = math.sin(phi), math.cos(phi)
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
				color = {
					r,
					g,
					b,
					a,
				},
			})
		end
	end
	local bodyVerts = (bodyRows + 1) * (slices + 1)
	addHemisphere(1, halfH, 0.75)

	local function addGridIndices(base, rows)
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

-- Cylinder with optional top/bottom caps and independent top/bottom radii
-- (set radiusTop=0 to get a cone).
function meshgen.genCylinder(
	radiusBottom: number?,
	radiusTop: number?,
	height: number?,
	slices: number?,
	capped: boolean?,
	color: any?
)
	local rb = radiusBottom or 0.5
	local rt = radiusTop or 0.5
	local h = height or 1.0
	local sl = math.max(3, slices or 16)
	local capped = (capped ~= false) -- default true
	local r, g, b, a = colorRGBA(color)
	local verts, indices = {}, {}
	local halfH = h * 0.5

	-- body rings (2 rows: bottom, top)
	for row = 0, 1 do
		local t = row -- 0 = bottom, 1 = top
		local rad = rb + (rt - rb) * t
		local y = -halfH + h * t
		for j = 0, sl do
			local theta = TWO_PI * j / sl
			local cosT, sinT = math.cos(theta), math.sin(theta)
			-- normal points outward, slightly tilted for cones
			local slope = (rb - rt) / h -- rise/run of the side
			local nx, nz = cosT, sinT
			local ny = slope
			nx, ny, nz = normalize(nx, ny, nz)
			table.insert(verts, {
				position = { cosT * rad, y, sinT * rad },
				normal = { nx, ny, nz },
				uv = { j / sl, t },
				color = { r, g, b, a },
			})
		end
	end

	-- body quads
	local stride = sl + 1
	for j = 0, sl - 1 do
		local i0 = j
		local i1 = j + 1
		local i2 = stride + j
		local i3 = stride + j + 1
		table.insert(indices, i0)
		table.insert(indices, i2)
		table.insert(indices, i1)
		table.insert(indices, i1)
		table.insert(indices, i2)
		table.insert(indices, i3)
	end

	local bodyVerts = 2 * stride

	-- caps
	if capped then
		local function addCap(capRadius, y, normalY)
			local centerIdx = #verts
			table.insert(
				verts,
				{ position = { 0, y, 0 }, normal = { 0, normalY, 0 }, uv = { 0.5, 0.5 }, color = { r, g, b, a } }
			)
			local rimStart = #verts
			for j = 0, sl do
				local theta = TWO_PI * j / sl
				local cx, cz = math.cos(theta) * capRadius, math.sin(theta) * capRadius
				table.insert(verts, {
					position = { cx, y, cz },
					normal = { 0, normalY, 0 },
					uv = { math.cos(theta) * 0.5 + 0.5, math.sin(theta) * 0.5 + 0.5 },
					color = { r, g, b, a },
				})
			end
			for j = 0, sl - 1 do
				local a_i = rimStart + j
				local b_i = rimStart + j + 1
				if normalY > 0 then
					table.insert(indices, centerIdx)
					table.insert(indices, a_i)
					table.insert(indices, b_i)
				else
					table.insert(indices, centerIdx)
					table.insert(indices, b_i)
					table.insert(indices, a_i)
				end
			end
		end
		addCap(rb, -halfH, -1)
		addCap(rt, halfH, 1)
	end

	return verts, indices
end

-- Torus (donut)
function meshgen.genTorus(radius: number?, tubeRadius: number?, sides: number?, rings: number?, color: any?)
	local R = radius or 0.5 -- distance from centre of tube to centre of torus
	local r = tubeRadius or 0.2
	local ri = math.max(3, rings or 24)
	local si = math.max(3, sides or 16)
	local cr, cg, cb, ca = colorRGBA(color)
	local verts, indices = {}, {}

	for i = 0, ri do
		local phi = TWO_PI * i / ri
		local cosPhi, sinPhi = math.cos(phi), math.sin(phi)
		for j = 0, si do
			local theta = TWO_PI * j / si
			local cosTheta, sinTheta = math.cos(theta), math.sin(theta)
			local cx = (R + r * cosTheta) * cosPhi
			local cy = r * sinTheta
			local cz = (R + r * cosTheta) * sinPhi
			-- normal: from tube centre outward
			local nx = cosTheta * cosPhi
			local ny = sinTheta
			local nz = cosTheta * sinPhi
			table.insert(verts, {
				position = { cx, cy, cz },
				normal = { nx, ny, nz },
				uv = { i / ri, j / si },
				color = { cr, cg, cb, ca },
			})
		end
	end

	local stride = si + 1
	for i = 0, ri - 1 do
		for j = 0, si - 1 do
			local i0 = i * stride + j
			local i1 = i0 + 1
			local i2 = (i + 1) * stride + j
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

-- Icosphere – subdivision-based sphere (smoother than UV sphere at equal vertex count)
-- subdivisions: 0 = icosahedron (20 faces), 1 = 80 faces, 2 = 320 faces, etc.
function meshgen.genIcosphere(radius: number?, subdivisions: number?, color: any?)
	radius = radius or 0.5
	subdivisions = math.clamp(subdivisions or 2, 0, 6)
	local cr, cg, cb, ca = colorRGBA(color)

	local t = (1 + math.sqrt(5)) / 2 -- golden ratio
	-- 12 vertices of a unit icosahedron
	local icoVerts = {
		{ -1, t, 0 },
		{ 1, t, 0 },
		{ -1, -t, 0 },
		{ 1, -t, 0 },
		{ 0, -1, t },
		{ 0, 1, t },
		{ 0, -1, -t },
		{ 0, 1, -t },
		{ t, 0, -1 },
		{ t, 0, 1 },
		{ -t, 0, -1 },
		{ -t, 0, 1 },
	}
	for i, v in ipairs(icoVerts) do
		local nx, ny, nz = normalize(v[1], v[2], v[3])
		icoVerts[i] = { nx, ny, nz }
	end

	local icoFaces = {
		{ 1, 12, 6 },
		{ 1, 6, 2 },
		{ 1, 2, 8 },
		{ 1, 8, 11 },
		{ 1, 11, 12 },
		{ 2, 6, 10 },
		{ 6, 12, 5 },
		{ 12, 11, 3 },
		{ 11, 8, 7 },
		{ 8, 2, 9 },
		{ 4, 10, 5 },
		{ 4, 5, 3 },
		{ 4, 3, 7 },
		{ 4, 7, 9 },
		{ 4, 9, 10 },
		{ 5, 10, 6 },
		{ 3, 5, 12 },
		{ 7, 3, 11 },
		{ 9, 7, 8 },
		{ 10, 9, 2 },
	}

	-- midpoint cache for subdivision
	local midCache = {}
	local function midpoint(a, b, vlist)
		local key = math.min(a, b) * 10000 + math.max(a, b)
		if midCache[key] then
			return midCache[key]
		end
		local va, vb = vlist[a], vlist[b]
		local mx, my, mz = normalize((va[1] + vb[1]) * 0.5, (va[2] + vb[2]) * 0.5, (va[3] + vb[3]) * 0.5)
		table.insert(vlist, { mx, my, mz })
		local idx = #vlist
		midCache[key] = idx
		return idx
	end

	local positions = {}
	for _, v in ipairs(icoVerts) do
		table.insert(positions, { v[1], v[2], v[3] })
	end
	local faces = icoFaces

	for _ = 1, subdivisions do
		midCache = {}
		local newFaces = {}
		for _, f in ipairs(faces) do
			local a = midpoint(f[1], f[2], positions)
			local b = midpoint(f[2], f[3], positions)
			local c = midpoint(f[3], f[1], positions)
			table.insert(newFaces, { f[1], a, c })
			table.insert(newFaces, { f[2], b, a })
			table.insert(newFaces, { f[3], c, b })
			table.insert(newFaces, { a, b, c })
		end
		faces = newFaces
	end

	local verts, indices = {}, {}
	for _, p in ipairs(positions) do
		local nx, ny, nz = p[1], p[2], p[3]
		local u = (math.atan2(nz, nx) / TWO_PI) + 0.5
		local v = math.acos(math.clamp(ny, -1, 1)) / math.pi
		table.insert(verts, {
			position = { nx * radius, ny * radius, nz * radius },
			normal = { nx, ny, nz },
			uv = { u, v },
			color = { cr, cg, cb, ca },
		})
	end
	for _, f in ipairs(faces) do
		table.insert(indices, f[1] - 1)
		table.insert(indices, f[2] - 1)
		table.insert(indices, f[3] - 1)
	end

	return verts, indices
end

-- Tube / path extrusion
-- path: array of {x,y,z} control points
-- radius: tube radius
-- slices: cross-section resolution
function meshgen.genTube(path: { any }, radius: number?, slices: number?, color: any?, closed: boolean?)
	radius = radius or 0.2
	slices = math.max(3, slices or 12)
	local cr, cg, cb, ca = colorRGBA(color)
	local closed = closed or false
	local n = #path
	assert(n >= 2, "genTube: path needs at least 2 points")

	-- compute per-point tangents
	local tangents = {}
	for i = 1, n do
		local prev = path[i > 1 and i - 1 or 1]
		local next = path[i < n and i + 1 or n]
		local px, py, pz = vec3(prev)
		local nx_, ny_, nz_ = vec3(next)
		local tx, ty, tz = normalize(nx_ - px, ny_ - py, nz_ - pz)
		tangents[i] = { tx, ty, tz }
	end

	-- build a rotation-minimising frame at each point
	local frames = {} -- { right={x,y,z}, up={x,y,z} }
	local function buildFrame(tang, prevRight)
		local tx, ty, tz = tang[1], tang[2], tang[3]
		local rx, ry, rz
		if prevRight then
			-- project prevRight onto plane perpendicular to tang
			local d = dot(prevRight[1], prevRight[2], prevRight[3], tx, ty, tz)
			rx = prevRight[1] - tx * d
			ry = prevRight[2] - ty * d
			rz = prevRight[3] - tz * d
			rx, ry, rz = normalize(rx, ry, rz)
		else
			-- initial frame: pick an arbitrary perpendicular
			if math.abs(ty) < 0.9 then
				rx, ry, rz = normalize(cross(tx, ty, tz, 0, 1, 0))
			else
				rx, ry, rz = normalize(cross(tx, ty, tz, 1, 0, 0))
			end
		end
		local ux, uy, uz = cross(tx, ty, tz, rx, ry, rz)
		return { right = { rx, ry, rz }, up = { ux, uy, uz } }
	end

	frames[1] = buildFrame(tangents[1], nil)
	for i = 2, n do
		frames[i] = buildFrame(tangents[i], frames[i - 1].right)
	end

	local verts, indices = {}, {}

	for i = 1, n do
		local px, py, pz = vec3(path[i])
		local fr = frames[i]
		local rx, ry, rz = fr.right[1], fr.right[2], fr.right[3]
		local ux, uy, uz = fr.up[1], fr.up[2], fr.up[3]
		local t = (i - 1) / (n - 1)

		for j = 0, slices do
			local theta = TWO_PI * j / slices
			local cosT, sinT = math.cos(theta), math.sin(theta)
			local nx_ = rx * cosT + ux * sinT
			local ny_ = ry * cosT + uy * sinT
			local nz_ = rz * cosT + uz * sinT
			table.insert(verts, {
				position = { px + nx_ * radius, py + ny_ * radius, pz + nz_ * radius },
				normal = { nx_, ny_, nz_ },
				uv = { j / slices, t },
				color = { cr, cg, cb, ca },
			})
		end
	end

	local stride = slices + 1
	for i = 0, n - 2 do
		for j = 0, slices - 1 do
			local i0 = i * stride + j
			local i1 = i0 + 1
			local i2 = (i + 1) * stride + j
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

-- Grid / heightmap
-- heights: flat array [row * (sx+1) + col] of Y values, or nil for a flat grid
function meshgen.genHeightmap(
	width: number?,
	depth: number?,
	segX: number?,
	segZ: number?,
	heights: { number }?,
	color: any?
)
	width = width or 1
	depth = depth or 1
	segX = math.max(1, segX or 8)
	segZ = math.max(1, segZ or 8)
	local cr, cg, cb, ca = colorRGBA(color)
	local hw, hd = width * 0.5, depth * 0.5
	local du, dv = 1 / segX, 1 / segZ
	local verts, indices = {}, {}

	for iz = 0, segZ do
		for ix = 0, segX do
			local u, v = ix * du, iz * dv
			local y = 0
			if heights then
				local hi = iz * (segX + 1) + ix + 1
				y = heights[hi] or 0
			end
			table.insert(verts, {
				position = { u * width - hw, y, v * depth - hd },
				normal = { 0, 1, 0 },
				uv = { u, v },
				color = { cr, cg, cb, ca },
			})
		end
	end

	local stride = segX + 1
	for iz = 0, segZ - 1 do
		for ix = 0, segX - 1 do
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

local function buildPrimitive(verts, indices, opts)
	local newOpts = opts or {}
	newOpts.indicesAreZeroBased = true
	return meshgen.buildMesh(verts, indices, newOpts)
end

function meshgen.buildPlane(w, d, seg, color, opts)
	return buildPrimitive(meshgen.genPlane(w, d, seg, color), nil, opts)
end
function meshgen.buildSphere(r, st, sl, color, opts)
	return buildPrimitive(meshgen.genSphere(r, st, sl, color), nil, opts)
end
function meshgen.buildBox(sx, sy, sz, color, opts)
	return buildPrimitive(meshgen.genBox(sx, sy, sz, color), nil, opts)
end
function meshgen.buildCapsule(r, h, st, sl, color, opts)
	return buildPrimitive(meshgen.genCapsule(r, h, st, sl, color), nil, opts)
end
function meshgen.buildCylinder(rb, rt, h, sl, cap, color, opts)
	local v, i = meshgen.genCylinder(rb, rt, h, sl, cap, color)
	return buildPrimitive(v, i, opts)
end
function meshgen.buildCone(radius, height, slices, color, opts)
	local v, i = meshgen.genCylinder(radius, 0, height, slices, true, color)
	return buildPrimitive(v, i, opts)
end
function meshgen.buildTorus(R, r, si, ri, color, opts)
	local v, i = meshgen.genTorus(R, r, si, ri, color)
	return buildPrimitive(v, i, opts)
end
function meshgen.buildIcosphere(radius, subdivs, color, opts)
	local v, i = meshgen.genIcosphere(radius, subdivs, color)
	return buildPrimitive(v, i, opts)
end
function meshgen.buildTube(path, radius, slices, color, closed, opts)
	local v, i = meshgen.genTube(path, radius, slices, color, closed)
	return buildPrimitive(v, i, opts)
end
function meshgen.buildHeightmap(w, d, sx, sz, heights, color, opts)
	local v, i = meshgen.genHeightmap(w, d, sx, sz, heights, color)
	local newOpts = opts or {}
	newOpts.indicesAreZeroBased = true
	-- auto-recalculate normals for heightmaps since they're rarely flat
	if newOpts.smooth == nil and newOpts.flat == nil then
		newOpts.smooth = true
	end
	return meshgen.buildMesh(v, i, newOpts)
end

function meshgen.buildFromTriangles(triangles, opts)
	local verts, indices = {}, {}
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
