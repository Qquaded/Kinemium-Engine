local meshgen = require("@meshgen")

local r3dapi = require("@r3d")
local r3dlib = r3dapi.lib
local r3dstructs = r3dapi.structs
local r3dconst = r3dapi.constants
local ffi = zune.ffi
local mem = zune.mem
local sharedGrassMaterialPtr: any = nil

local grassgen = {}

local TWO_PI = math.pi * 2

grassgen.BLADE_QUAD_WIDTH = 0.1
grassgen.BLADE_QUAD_LENGTH = 1.0

local INSTANCE_POSITION_STRIDE = 12
local INSTANCE_ROTATION_STRIDE = 16
local INSTANCE_SCALE_STRIDE = 12
local INSTANCE_COLOR_STRIDE = 4
local INSTANCE_FLAGS = bit32.bor(
	r3dconst.R3D_INSTANCE_POSITION,
	r3dconst.R3D_INSTANCE_ROTATION,
	r3dconst.R3D_INSTANCE_SCALE,
	r3dconst.R3D_INSTANCE_COLOR
)

local sharedBladeQuadMesh: any = nil
local sharedGrassMaterial: buffer? = nil
local sharedGrassShader: any = nil

local function readGrassShaderSource(): string?
	return [[
#pragma usage transparent shadow

uniform float u_windStrength;
uniform float u_time;

void vertex() {
    float h = TEXCOORD.y;
    float sway = sin(u_time * 2.2 + INSTANCE_POSITION.x * 7.1 + INSTANCE_POSITION.z * 5.3) * u_windStrength;
    float flutter = sin(u_time * 6.7 + INSTANCE_POSITION.x * 13.0 + INSTANCE_POSITION.z * 9.4) * u_windStrength * 0.3;
    POSITION.x += (sway + flutter) * h * h;
    POSITION.z += sin(u_time * 1.8 + INSTANCE_POSITION.x * 4.2) * u_windStrength * 0.4 * h * h;
}

void fragment() {
    vec2 uv = TEXCOORD;

    float greenVar = vColor.g / 255.0;

    vec3 base = vec3(0.05, 0.25 + greenVar * 0.2, 0.03);
    vec3 tip  = vec3(0.20, 0.55 + greenVar * 0.3, 0.10);
    vec3 blade = mix(base, tip, uv.y);

    blade *= mix(0.4, 1.0, smoothstep(0.0, 0.4, uv.y));

    ALBEDO = blade;
    ROUGHNESS = mix(0.85, 0.4, uv.y);
    METALNESS = 0.0;
    ALPHA = mix(0.7, 1.0, uv.y);
}]]
end

local function setMaterialShaderField(matBuf: buffer, shaderPtr: any)
	local off = r3dstructs.R3D_Material:offset("shader")
	local staging = ffi.dupe(buffer.create(8))
	staging:writeptr(0, shaderPtr)
	for i = 0, 7 do
		buffer.writeu8(matBuf, off + i, staging:readu8(i))
	end
end

function grassgen.getGrassMaterial(): buffer?
	if sharedGrassMaterial then
		return sharedGrassMaterial
	end

	local defaultMat = r3dlib.R3D_GetDefaultMaterial()
	local matBuf = buffer.create(r3dstructs.R3D_Material:size())
	buffer.copy(matBuf, 0, defaultMat, 0, r3dstructs.R3D_Material:size())

	buffer.writei32(matBuf, r3dstructs.R3D_Material:offset("transparencyMode"), r3dconst.R3D_TRANSPARENCY_ALPHA)
	buffer.writei32(matBuf, r3dstructs.R3D_Material:offset("cullMode"), r3dconst.R3D_CULL_NONE)

	local src = readGrassShaderSource()
	local sh = r3dlib.R3D_LoadSurfaceShaderFromMemory(src)

	if sh then
		sharedGrassShader = sh
		setMaterialShaderField(matBuf, sh)
	end

	sharedGrassMaterial = matBuf
	sharedGrassMaterialPtr = ffi.dupe(matBuf)

	return sharedGrassMaterialPtr
end

function grassgen.getGrassSurfaceShader(): any
	return sharedGrassShader
end

function grassgen.createGrassInstanceBuffer(rlib: any, instances: { any }): (any?, number)
	local count = #instances
	if count <= 0 then
		return nil, 0
	end
	local ok, buf = pcall(rlib.R3D_LoadInstanceBuffer, count, INSTANCE_FLAGS)
	if not ok or not buf then
		return nil, 0
	end

	local mappedPosition = nil
	local mappedRotation = nil
	local mappedScale = nil
	local mappedColor = nil

	local okMap = pcall(function()
		mappedPosition = rlib.R3D_MapInstances(buf, r3dconst.R3D_INSTANCE_POSITION)
		mappedRotation = rlib.R3D_MapInstances(buf, r3dconst.R3D_INSTANCE_ROTATION)
		mappedScale = rlib.R3D_MapInstances(buf, r3dconst.R3D_INSTANCE_SCALE)
		mappedColor = rlib.R3D_MapInstances(buf, r3dconst.R3D_INSTANCE_COLOR)
	end)

	if not okMap or not mappedPosition or not mappedRotation or not mappedScale or not mappedColor then
		pcall(rlib.R3D_UnloadInstanceBuffer, buf)
		return nil, 0
	end

	for i = 1, count do
		local t = instances[i]
		local pOffset = (i - 1) * INSTANCE_POSITION_STRIDE
		mappedPosition:writef32(pOffset, t.px)
		mappedPosition:writef32(pOffset + 4, t.py)
		mappedPosition:writef32(pOffset + 8, t.pz)

		local rOffset = (i - 1) * INSTANCE_ROTATION_STRIDE
		mappedRotation:writef32(rOffset, t.qx or 0)
		mappedRotation:writef32(rOffset + 4, t.qy or 0)
		mappedRotation:writef32(rOffset + 8, t.qz or 0)
		mappedRotation:writef32(rOffset + 12, t.qw or 1)

		local sOffset = (i - 1) * INSTANCE_SCALE_STRIDE
		mappedScale:writef32(sOffset, t.sx)
		mappedScale:writef32(sOffset + 4, t.sy)
		mappedScale:writef32(sOffset + 8, t.sz)

		local cOffset = (i - 1) * INSTANCE_COLOR_STRIDE
		mappedColor:writeu8(cOffset, t.r)
		mappedColor:writeu8(cOffset + 1, t.g)
		mappedColor:writeu8(cOffset + 2, t.b)
		mappedColor:writeu8(cOffset + 3, t.a)
	end

	local okUnmap = pcall(rlib.R3D_UnmapInstances, buf, INSTANCE_FLAGS)
	if not okUnmap then
		pcall(rlib.R3D_UnloadInstanceBuffer, buf)
		return nil, 0
	end

	return buf, count
end

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

function grassgen.getBladeQuadMesh(): any
	if not sharedBladeQuadMesh then
		local verts, idxs = genBlade({
			baseWidth = 0.05,
			tipWidth = 0.0,
			height = 1.0,
			segments = 3,
			lean = 0.15,
			bow = 0.0,
			twist = 0.0,
		})
		sharedBladeQuadMesh = meshgen.buildMesh(verts, idxs, {
			indicesAreZeroBased = true,
			flat = true,
			generateTangents = false,
		})
	end
	return sharedBladeQuadMesh
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
