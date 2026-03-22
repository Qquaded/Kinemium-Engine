local meshgen = require("@meshgen")

local TWO_PI = math.pi * 2

local function makeAlignMatrix(nx, ny, nz)
	local upX, upY, upZ = nx, ny, nz -- new "up" is the surface normal

	local refX, refY, refZ = 0, 0, 1
	if math.abs(nz) > 0.99 then
		refX, refY, refZ = 1, 0, 0
	end

	local rx = upY * refZ - upZ * refY
	local ry = upZ * refX - upX * refZ
	local rz = upX * refY - upY * refX
	local rlen = math.sqrt(rx * rx + ry * ry + rz * rz)
	rx, ry, rz = rx / rlen, ry / rlen, rz / rlen

	local fx = ry * upZ - rz * upY
	local fy = rz * upX - rx * upZ
	local fz = rx * upY - ry * upX

	return rx,
		ry,
		rz, -- right basis
		upX,
		upY,
		upZ, -- up basis
		fx,
		fy,
		fz -- forward basis
end

local function applyMatrix(px, py, pz, rx, ry, rz, ux, uy, uz, fx, fy, fz)
	return px * rx + py * ux + pz * fx, px * ry + py * uy + pz * fy, px * rz + py * uz + pz * fz
end

local function makeRng(seed: number?)
	local s = seed or 12345
	return function(min: number?, max: number?)
		s = (s * 1664525 + 1013904223) % (2 ^ 32)
		local t = s / (2 ^ 32)
		local lo = min or 0
		local hi = max or 1
		return lo + t * (hi - lo)
	end
end

-- Rotate a (x, z) pair around the Y axis
local function rotateY(x: number, z: number, angle: number)
	local c = math.cos(angle)
	local s = math.sin(angle)
	return x * c - z * s, x * s + z * c
end

-- opts:
--   baseWidth   number   half-width at the base           (default 0.06)
--   tipWidth    number   half-width at the tip            (default 0.008)
--   height      number   blade height                     (default 0.8)
--   segments    number   vertical quad strips             (default 5)
--   lean        number   lateral tip offset (wind lean)   (default 0.2)
--   bow         number   mid-arc bow (sine curve bulge)   (default 0.15)
--   twist       number   roll angle at tip (radians)      (default 0.1)
--   color       any      vertex color passed to meshgen

local function genBlade(opts: any?)
	local o = opts or {}
	local baseWidth = o.baseWidth or 0.06
	local tipWidth = o.tipWidth or 0.008
	local height = o.height or 0.8
	local segments = math.max(2, math.floor(o.segments or 5))
	local lean = o.lean or 0.2
	local bow = o.bow or 0.15
	local twist = o.twist or 0.1
	local color = o.color

	local verts = {}
	local indices = {}

	for i = 0, segments do
		local t = i / segments

		local halfW = baseWidth * (1 - t) + tipWidth * t

		local curveX = lean * t + bow * math.sin(t * math.pi)

		local twistAngle = twist * t
		local cos = math.cos(twistAngle)
		local sin = math.sin(twistAngle)

		local lx = -halfW * cos
		local lz = -halfW * sin
		local rx = halfW * cos
		local rz = halfW * sin

		local y = height * t

		local nx, ny, nz = 0, 0, 1 -- placeholder; recalculated below

		table.insert(verts, {
			position = { lx + curveX, y, lz },
			normal = { nx, ny, nz },
			uv = { 0, t },
			color = color,
		})
		table.insert(verts, {
			position = { rx + curveX, y, rz },
			normal = { nx, ny, nz },
			uv = { 1, t },
			color = color,
		})
	end

	for i = 0, segments - 1 do
		local b = i * 2
		table.insert(indices, b + 0)
		table.insert(indices, b + 1)
		table.insert(indices, b + 2)
		table.insert(indices, b + 1)
		table.insert(indices, b + 3)
		table.insert(indices, b + 2)
	end

	return verts, indices
end

-- opts (all blade opts +):
--   count       number   number of blades            (default 16)
--   spread      number   XZ radius of patch          (default 1.2)
--   jitter      number   per-blade param randomness  (default 0.25)
--   seed        number   RNG seed for repeatability  (default 42)
--   alignY      boolean  keep blades vertical        (default true)

local function genPatch(opts: any?)
	local o = opts or {}
	local count = math.max(1, math.floor(o.count or 16))
	local spread = o.spread ~= nil and o.spread or 1.2
	local jitter = o.jitter ~= nil and o.jitter or 0.25
	local seed = o.seed or 42

	local rng = makeRng(seed)

	local meshList = {}

	for _ = 1, count do
		-- Randomise individual blade shape
		local j = jitter
		local bOpts = {
			baseWidth = (o.baseWidth or 0.06) * (1 + rng(-j, j)),
			tipWidth = math.max(0, (o.tipWidth or 0.008) * (1 + rng(-j, j))),
			height = (o.height or 0.8) * (1 + rng(-j, j)),
			segments = o.segments or 5,
			lean = (o.lean or 0.2) * (1 + rng(-j, j)) * (rng() > 0.5 and 1 or -1),
			bow = (o.bow or 0.15) * (1 + rng(-j, j)),
			twist = (o.twist or 0.1) * rng(-1, 1),
			color = o.color,
		}

		local verts, idxs = genBlade(bOpts)

		-- Random placement in the patch
		local ox = rng(-spread, spread)
		local oz = rng(-spread, spread)
		local rotY = rng(0, TWO_PI)

		-- Apply Y-rotation + XZ offset to each vertex
		local transformed = {}
		for _, v in ipairs(verts) do
			local px, py, pz = v.position[1], v.position[2], v.position[3]
			local rx, rz = rotateY(px, pz, rotY)
			transformed[#transformed + 1] = {
				position = { rx + ox, py, rz + oz },
				normal = v.normal,
				uv = v.uv,
				color = v.color,
			}
		end

		meshList[#meshList + 1] = { vertices = transformed, indices = idxs }
	end

	return meshList
end

local grassgen = {}

function grassgen.genBlade(opts: any?)
	return genBlade(opts)
end

function grassgen.genPatch(opts: any?)
	return genPatch(opts)
end

function grassgen.buildBlade(opts: any?)
	local verts, idxs = genBlade(opts)
	local buildOpts = opts or {}
	buildOpts.indicesAreZeroBased = true
	buildOpts.flat = buildOpts.flat ~= nil and buildOpts.flat or true
	buildOpts.generateTangents = buildOpts.generateTangents ~= nil and buildOpts.generateTangents or false
	return meshgen.buildMesh(verts, idxs, buildOpts)
end

function grassgen.buildPatch(opts: any?)
	local meshList = genPatch(opts)
	local buildOpts = opts or {}
	buildOpts.flat = buildOpts.flat ~= nil and buildOpts.flat or true
	buildOpts.generateTangents = buildOpts.generateTangents ~= nil and buildOpts.generateTangents or false
	return meshgen.buildMergedMesh(meshList, buildOpts)
end

function grassgen.buildPatchData(opts: any?)
	local meshList = genPatch(opts)
	local verts, idxs = meshgen.mergeMeshData(meshList)
	local buildOpts = opts or {}
	buildOpts.indicesAreZeroBased = true
	buildOpts.flat = buildOpts.flat ~= nil and buildOpts.flat or true
	if buildOpts.flat or buildOpts.smooth then
		meshgen.recalculateNormals(verts, idxs, buildOpts.smooth == true)
	end
	if buildOpts.generateTangents then
		meshgen.generateTangents(verts, idxs)
	end
	return verts, idxs
end

function grassgen.genBladeAligned(opts)
	local o = opts or {}
	local sn = o.surfaceNormal or { 0, 1, 0 }
	local slopeLean = o.slopeLeaning or 0.3

	local nx, ny, nz = sn[1], sn[2], sn[3]
	local dot = -ny -- dot(-Y, normal)
	local slopeX = -nx + dot * nx -- actually just (-0 - dot*nx) simplified:
	local sX = -(dot * nx)
	local sY = -1 - (dot * ny)
	local sZ = -(dot * nz)
	local sLen = math.sqrt(sX * sX + sY * sY + sZ * sZ)
	if sLen > 1e-6 then
		sX, sY, sZ = sX / sLen, sY / sLen, sZ / sLen
	else
		sX, sY, sZ = 0, 0, 0
	end

	local baseLean = o.lean or 0.2
	local innerOpts = {}
	for k, v in pairs(o) do
		innerOpts[k] = v
	end
	innerOpts.lean = baseLean + slopeLean * math.sqrt(sX * sX + sZ * sZ)

	local verts, indices = genBlade(innerOpts)

	local r1, r2, r3, u1, u2, u3, f1, f2, f3 = makeAlignMatrix(nx, ny, nz)

	for _, v in ipairs(verts) do
		local px, py, pz = v.position[1], v.position[2], v.position[3]
		local tx, ty, tz = applyMatrix(px, py, pz, r1, r2, r3, u1, u2, u3, f1, f2, f3)
		v.position = { tx, ty, tz }
		local nx2, ny2, nz2 = v.normal[1], v.normal[2], v.normal[3]
		local tnx, tny, tnz = applyMatrix(nx2, ny2, nz2, r1, r2, r3, u1, u2, u3, f1, f2, f3)
		v.normal = { tnx, tny, tnz }
	end

	return verts, indices
end

return grassgen
