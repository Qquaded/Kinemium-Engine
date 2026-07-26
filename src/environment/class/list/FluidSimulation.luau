-- description: "Simulates and renders a deforming water surface with flow, drains, and buoyancy."

local Vector3 = require("@Vector3")
local Vector2 = require("@Vector2")
local Color3 = require("@Color3")
local signal = require("@Kinemium.signal")
local meshgen = require("@meshgen")

local r3d = require("@r3d")
local rlib = r3d.lib
local r3dstructs = r3d.structs
local r3dconst = r3d.constants
local adapter = require("@RaylibAdapter")
local lib = adapter.lib
local ffi = zune.ffi

local U32_MOD = 4294967296

local function readPtr64(buf: buffer, offset: number): number
	local lo = buffer.readu32(buf, offset)
	local hi = buffer.readu32(buf, offset + 4)
	return lo + hi * U32_MOD
end

local function ptrFromStructField(structBuf: buffer, fieldOff: number): any
	local addr = readPtr64(structBuf, fieldOff)
	if addr == 0 then
		return ffi.null
	end
	local b = buffer.create(8)
	local hi = math.floor(addr / U32_MOD)
	local lo = addr - hi * U32_MOD
	buffer.writeu32(b, 0, lo)
	buffer.writeu32(b, 4, hi)
	return ffi.ptrFromAddress(b)
end

-- ============================================================================
-- Math helpers
-- ============================================================================

local function normalize3(x: number, y: number, z: number): (number, number, number)
	local len = math.sqrt(x * x + y * y + z * z)
	if len < 1e-8 then
		return 0, 1, 0
	end
	local inv = 1 / len
	return x * inv, y * inv, z * inv
end

local function makeF32Buf(v: number): buffer
	local b = buffer.create(4)
	buffer.writef32(b, 0, v)
	return b
end

local function makeVec2Buf(x: number, y: number): buffer
	local b = buffer.create(8)
	buffer.writef32(b, 0, x)
	buffer.writef32(b, 4, y)
	return b
end

-- ============================================================================
-- Visual-only wave ripple math (overlaid on top of the simulated heights)
-- Each wave: { height, speed, scale, dirX, dirZ, phase }
-- ============================================================================

local TWO_PI = math.pi * 2

local function waveDisplacement(x: number, z: number, t: number, waves: { any }): number
	local y = 0
	for i = 1, #waves do
		local w = waves[i]
		local k = w.scale * TWO_PI
		local ph = k * (w.dirX * x + w.dirZ * z) - w.speed * k * t + w.phase
		y += w.height * math.sin(ph)
	end
	return y
end

local function waveNormal(x: number, z: number, t: number, waves: { any }): (number, number, number)
	local dydx, dydz = 0, 0
	for i = 1, #waves do
		local w = waves[i]
		local k = w.scale * TWO_PI
		local ph = k * (w.dirX * x + w.dirZ * z) - w.speed * k * t + w.phase
		local d = w.height * k * math.cos(ph)
		dydx += d * w.dirX
		dydz += d * w.dirZ
	end
	return normalize3(-dydx, 1.0, -dydz)
end

-- ============================================================================
-- Water surface shader
-- Uses TIME built-in (no manual time uniform needed).
-- R3D_NO_AUTO_FETCH → we own every output; opaque+transparent both pre-compiled.
-- ============================================================================

local WATER_SHADER_SRC = [[
#pragma usage opaque transparent
#define R3D_NO_AUTO_FETCH

uniform vec4  u_tint;
uniform float u_roughness;
uniform vec2  u_flow_uv;

void fragment() {
    vec2  uv = TEXCOORD;

    float r1 = sin(uv.x * 9.0  + TIME * 1.9 + u_flow_uv.x)
             * sin(uv.y * 9.0  + TIME * 1.6 + u_flow_uv.y) * 0.07;
    float r2 = sin(uv.x * 17.0 - TIME * 2.3 + u_flow_uv.y * 0.6)
             * sin(uv.y * 17.0 - TIME * 2.1 + u_flow_uv.x * 0.6) * 0.04;

    float ripple = r1 + r2;
    vec3  col    = clamp(u_tint.rgb + vec3(ripple * 0.15, ripple * 0.08, -ripple * 0.04),
                         vec3(0.0), vec3(1.0));

    ALBEDO    = col;
    ROUGHNESS = clamp(u_roughness - abs(ripple) * 0.15, 0.02, 1.0);
    METALNESS = 0.0;
    OCCLUSION = 1.0;
    ALPHA     = clamp(u_tint.a + ripple * 0.08, 0.05, 1.0);
}
]]

-- ============================================================================
-- Pre-cached material offsets (set once on first use)
-- ============================================================================

local OFF_MAT_TRANSPARENCY = nil
local OFF_MAT_CULL = nil
local OFF_MAT_SHADER = nil
local SIZE_MAT = nil

local function ensureOffsets()
	if OFF_MAT_TRANSPARENCY then
		return
	end
	OFF_MAT_TRANSPARENCY = r3dstructs.R3D_Material:offset("transparencyMode")
	OFF_MAT_CULL = r3dstructs.R3D_Material:offset("cullMode")
	OFF_MAT_SHADER = r3dstructs.R3D_Material:offset("shader")
	SIZE_MAT = r3dstructs.R3D_Material:size()
end

-- ============================================================================
-- Class property table
-- ============================================================================

local propTable = {
	Name = "FluidSimulation",
	BaseClass = "Instance",

	--  Geometry
	Position = Vector3.new(0, 0, 0),
	-- Size.X/Z = surface dimensions; Size.Y = max water depth.
	Size = Vector3.new(20, 4, 20),

	--  Simulation
	-- Coarse grid used for physics (NxN columns, default 16).
	SimResolution = 16,
	-- How fast water equalises between adjacent cells (0–1).
	FlowRate = 0.7,
	-- Initial fill level as a fraction of Size.Y (0 = empty, 1 = full).
	WaterLevel = 0.5,
	-- If true, water cannot exit the simulation boundary (acts like sealed walls).
	-- Set to false (or use ConnectTo) to allow leaks.
	Contained = true,

	--  Visuals
	-- Fine mesh resolution for rendering (NxN vertices, default 32).
	VisResolution = 32,
	-- Surface ripple overlay (purely visual, does not affect simulation).
	WaveHeight = 0.12,
	WaveSpeed = 0.9,
	WaveScale = 0.45,
	WaveDirection = Vector2.new(1, 0.5),
	Color = Color3.new(0.05, 0.35, 0.72),
	Roughness = 0.07,
	-- 0 = opaque, 1 = invisible.
	Transparency = 0.42,

	--  Flow
	FlowDirection = Vector2.new(0, 0),
	FlowSpeed = 0.0,

	--  Physics
	PhysicsEnabled = true,
	BuoyancyFactor = 25.0,
	Dampening = 0.55,

	--  Container fitting
	Container = nil,
	FitContainer = false,
	FillLevel = 0.85,

	Enabled = true,

	--  Events
	Splashed = signal.new(), -- (part, fraction)
	Emptied = signal.new(), -- ()
	Overflowed = signal.new(), -- (amountLost)
}

-- ============================================================================
-- Class callback
-- ============================================================================

return {
	class = "FluidSimulation",

	callback = function(instance, renderer, game)
		instance:SetProperties(propTable)

		if _G.IsHeadless or not renderer then
			return instance
		end

		ensureOffsets()

		--  Service references
		local workspace = game and game:GetService("Workspace") or nil

		--  GPU resources
		local gpuMesh = nil
		local cpuMeshData = nil
		local material = nil
		local surfaceShader = nil
		local renderId = nil
		local renderMatrix = lib.MatrixIdentity()

		-- Mesh layout offsets (cached once)
		local off_vs = 0
		local off_pos = 0
		local off_norm = 0
		local off_mdV = 0
		local offCached = false

		--  Simulation state
		local simW = math.max(4, math.min(64, math.floor(instance.SimResolution or 16)))
		local simH = simW
		local simGrid: { number } = {} -- [z*simW + x + 1] = water height (0..Size.Y)
		local simInitialised = false

		--  Visual mesh state
		-- gridPositions[i] = {worldX, worldZ, u, v}
		local gridPositions: { { number } } = {}
		local vertCount = 0

		-- Visual ripple waves
		local activeWaves: { any } = {}

		-- Shader uniform buffers (stay alive; pointer must remain valid)
		local ubTint = buffer.create(16)
		local ubRough = makeF32Buf(0.07)
		local ubFlowUV = makeVec2Buf(0, 0)

		-- Flow UV accumulator
		local flowAccumU = 0
		local flowAccumV = 0

		--  Drain connections
		-- Each entry: { target=FluidSim, wx, wz, thresholdH, flowMult }
		local drainConnections: { any } = {}

		--  Buoyancy tracking
		local submergedSet: { [any]: boolean } = {}

		-- Container signature (cheap change-detection)
		local lastContainerSig = ""

		--  Event flags
		local wasEmpty = false

		-- ====================================================================
		-- SIMULATION GRID
		-- ====================================================================

		local function simIndex(x: number, z: number): number
			return z * simW + x + 1
		end

		local function initGrid()
			local level = math.clamp(instance.WaterLevel or 0.5, 0, 1) * instance.Size.Y
			for z = 0, simH - 1 do
				for x = 0, simW - 1 do
					simGrid[simIndex(x, z)] = level
				end
			end
			simInitialised = true
		end

		-- Bilinear sample of the simulation grid at normalised coords (lx,lz in 0..1)
		local function sampleGrid(lx: number, lz: number): number
			local gx = math.clamp(lx * (simW - 1), 0, simW - 1)
			local gz = math.clamp(lz * (simH - 1), 0, simH - 1)
			local x0 = math.floor(gx)
			local z0 = math.floor(gz)
			local x1 = math.min(x0 + 1, simW - 1)
			local z1 = math.min(z0 + 1, simH - 1)
			local fx = gx - x0
			local fz = gz - z0

			local h00 = simGrid[simIndex(x0, z0)] or 0
			local h10 = simGrid[simIndex(x1, z0)] or 0
			local h01 = simGrid[simIndex(x0, z1)] or 0
			local h11 = simGrid[simIndex(x1, z1)] or 0

			return h00 * (1 - fx) * (1 - fz) + h10 * fx * (1 - fz) + h01 * (1 - fx) * fz + h11 * fx * fz
		end

		-- Convert world XZ → normalised [0..1] grid coordinates
		local function worldToNorm(wx: number, wz: number): (number, number)
			local pos = instance.Position
			local size = instance.Size
			return (wx - pos.X + size.X * 0.5) / size.X, (wz - pos.Z + size.Z * 0.5) / size.Z
		end

		-- Water surface Y at a world position (bilinear sim + wave overlay)
		local function surfaceYAt(wx: number, wz: number, t: number?): number
			local pos = instance.Position
			local size = instance.Size
			local floorY = pos.Y - size.Y * 0.5
			local lx, lz = worldToNorm(wx, wz)
			lx = math.clamp(lx, 0, 1)
			lz = math.clamp(lz, 0, 1)
			local simH_val = sampleGrid(lx, lz)
			local wave = 0
			if t and #activeWaves > 0 then
				wave = waveDisplacement(wx, wz, t, activeWaves) * math.clamp(simH_val / 0.1, 0, 1)
			end
			return floorY + simH_val + wave
		end

		-- Total water volume in the sim (sum of all cell heights × cell area)
		local function totalWater(): number
			local sum = 0
			for i = 1, simW * simH do
				sum = sum + (simGrid[i] or 0)
			end
			return sum / (simW * simH) -- average height (convenient 0..Size.Y range)
		end

		--  Simulation step
		local function stepSimulation(dt: number)
			local maxH = instance.Size.Y
			local flowFac = math.clamp((instance.FlowRate or 0.7) * dt * 18.0, 0, 0.48)
			local contained = instance.Contained

			-- Horizontal flow in X
			for z = 0, simH - 1 do
				for x = 0, simW - 2 do
					local i = simIndex(x, z)
					local j = simIndex(x + 1, z)
					local diff = (simGrid[i] or 0) - (simGrid[j] or 0)
					if diff > 0.001 then
						local flow = math.min(diff * flowFac, simGrid[i] * 0.5)
						simGrid[i] -= flow
						simGrid[j] += flow
					elseif diff < -0.001 then
						local flow = math.min(-diff * flowFac, simGrid[j] * 0.5)
						simGrid[j] -= flow
						simGrid[i] += flow
					end
				end
			end

			-- Horizontal flow in Z
			for z = 0, simH - 2 do
				for x = 0, simW - 1 do
					local i = simIndex(x, z)
					local j = simIndex(x, z + 1)
					local diff = (simGrid[i] or 0) - (simGrid[j] or 0)
					if diff > 0.001 then
						local flow = math.min(diff * flowFac, simGrid[i] * 0.5)
						simGrid[i] -= flow
						simGrid[j] += flow
					elseif diff < -0.001 then
						local flow = math.min(-diff * flowFac, simGrid[j] * 0.5)
						simGrid[j] -= flow
						simGrid[i] += flow
					end
				end
			end

			-- Edge leaking (when not Contained)
			local leaked = 0
			if not contained then
				local edgeDrain = flowFac * 0.6
				for x = 0, simW - 1 do
					-- Z = 0 and Z = simH-1 edges
					local top = simIndex(x, 0)
					local bot = simIndex(x, simH - 1)
					leaked += (simGrid[top] or 0) * edgeDrain
					simGrid[top] = (simGrid[top] or 0) * (1 - edgeDrain)
					leaked += (simGrid[bot] or 0) * edgeDrain
					simGrid[bot] = (simGrid[bot] or 0) * (1 - edgeDrain)
				end
				for z = 1, simH - 2 do
					-- X = 0 and X = simW-1 edges
					local left = simIndex(0, z)
					local right = simIndex(simW - 1, z)
					leaked += (simGrid[left] or 0) * edgeDrain
					simGrid[left] = (simGrid[left] or 0) * (1 - edgeDrain)
					leaked += (simGrid[right] or 0) * edgeDrain
					simGrid[right] = (simGrid[right] or 0) * (1 - edgeDrain)
				end
				if leaked > 0.001 then
					pcall(function()
						instance.Overflowed:Fire(leaked)
					end)
				end
			end

			-- Overflow cap (clamp to maxH, fire event for excess)
			local overflow = 0
			for i = 1, simW * simH do
				if (simGrid[i] or 0) > maxH then
					overflow += simGrid[i] - maxH
					simGrid[i] = maxH
				end
				if (simGrid[i] or 0) < 0 then
					simGrid[i] = 0
				end
			end
			if overflow > 0.01 then
				pcall(function()
					instance.Overflowed:Fire(overflow / (simW * simH))
				end)
			end

			-- Emptied event
			local avg = totalWater()
			if avg < 0.001 and not wasEmpty then
				wasEmpty = true
				pcall(function()
					instance.Emptied:Fire()
				end)
			elseif avg >= 0.001 then
				wasEmpty = false
			end
		end

		-- ====================================================================
		-- DRAIN CONNECTIONS
		-- ====================================================================

		local function updateDrains(dt: number)
			if #drainConnections == 0 then
				return
			end
			local pos = instance.Position
			local size = instance.Size
			local floorY = pos.Y - size.Y * 0.5

			for _, conn in ipairs(drainConnections) do
				local target = conn.target
				if not target or not target._fluidAPI then
					continue
				end

				local api = target._fluidAPI

				-- My water surface at the drain point
				local lx, lz = worldToNorm(conn.wx, conn.wz)
				lx, lz = math.clamp(lx, 0, 1), math.clamp(lz, 0, 1)
				local mySimH = sampleGrid(lx, lz)
				local mySurfY = floorY + mySimH

				-- Target floor and average surface
				local tPos = target.Position
				local tSize = target.Size
				local tFloorY = tPos.Y - tSize.Y * 0.5
				local tAvgH = api.avgWater()
				local tSurfY = tFloorY + tAvgH

				-- Threshold height in world space
				local threshY = floorY + (conn.thresholdH or 0)

				-- Only flow if our surface is above both the threshold and the target surface
				if mySurfY <= threshY or mySurfY <= tSurfY then
					continue
				end

				local available = mySimH - (conn.thresholdH or 0)
				if available <= 0.001 then
					continue
				end

				-- Amount to transfer this frame
				local amount = math.min(available, (mySurfY - tSurfY) * 0.5)
					* (conn.flowMult or 1.0)
					* (instance.FlowRate or 0.7)
					* dt
					* 8.0

				if amount <= 0.001 then
					continue
				end

				-- Remove from source cells near the drain point
				local srcX = math.floor(math.clamp(lx * (simW - 1), 0, simW - 1))
				local srcZ = math.floor(math.clamp(lz * (simH - 1), 0, simH - 1))
				local removed = 0
				for dz = -1, 1 do
					for dx = -1, 1 do
						local cx = math.clamp(srcX + dx, 0, simW - 1)
						local cz = math.clamp(srcZ + dz, 0, simH - 1)
						local idx = simIndex(cx, cz)
						local take = math.min(simGrid[idx] or 0, amount * 0.11)
						simGrid[idx] = (simGrid[idx] or 0) - take
						removed += take
					end
				end

				-- Add water uniformly to the target simulation
				if removed > 0.001 then
					api.addWaterUniform(removed)
				end
			end
		end

		-- ====================================================================
		-- VISUAL MESH BUILD & UPDATE
		-- ====================================================================

		local function buildWaveConfig()
			local dir = instance.WaveDirection or Vector2.new(1, 0)
			local dx, dz = dir.X, dir.Y
			local dl = math.sqrt(dx * dx + dz * dz)
			if dl < 1e-6 then
				dx, dz = 1, 0
			else
				dx, dz = dx / dl, dz / dl
			end
			local h, spd, scl = instance.WaveHeight, instance.WaveSpeed, instance.WaveScale
			local px, pz = -dz, dx
			return {
				{
					height = h,
					speed = spd,
					scale = scl,
					dirX = dx,
					dirZ = dz,
					phase = 0,
				},
				{
					height = h * 0.4,
					speed = spd * 1.3,
					scale = scl * 1.4,
					dirX = px,
					dirZ = pz,
					phase = 1.1,
				},
				{
					height = h * 0.2,
					speed = spd * 0.65,
					scale = scl * 2.7,
					dirX = (dx * 0.7 + dz * 0.7),
					dirZ = (dz * 0.7 - dx * 0.7),
					phase = 2.4,
				},
			}
		end

		local function buildGrid_vis(posX, posZ, halfW, halfL, resX, resZ)
			local positions = table.create((resX + 1) * (resZ + 1))
			local duX = 1.0 / resX
			local dvZ = 1.0 / resZ
			for iz = 0, resZ do
				for ix = 0, resX do
					local u = ix * duX
					local v = iz * dvZ
					table.insert(positions, {
						posX + (u - 0.5) * halfW * 2,
						posZ + (v - 0.5) * halfL * 2,
						u,
						v,
					})
				end
			end
			return positions
		end

		local function buildIndices_vis(resX, resZ): { number }
			local indices = table.create(resX * resZ * 6)
			local stride = resX + 1
			for iz = 0, resZ - 1 do
				for ix = 0, resX - 1 do
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
			return indices
		end

		--  Material creation
		local function createMaterial()
			local base = rlib.R3D_GetDefaultMaterial()
			local mat = buffer.create(SIZE_MAT)
			buffer.copy(mat, 0, base, 0, SIZE_MAT)

			buffer.writei32(mat, OFF_MAT_TRANSPARENCY, r3dconst.R3D_TRANSPARENCY_ALPHA)
			buffer.writei32(mat, OFF_MAT_CULL, r3dconst.R3D_CULL_NONE)

			-- Load surface shader.
			-- Use buffer.copy to embed it  this mirrors what Workspace does
			-- with its global shader (proven to work in the engine).
			local ok, sh = pcall(rlib.R3D_LoadSurfaceShaderFromMemory, WATER_SHADER_SRC)
			if ok and sh then
				surfaceShader = sh
				buffer.copy(mat, OFF_MAT_SHADER, sh)
			end

			return mat
		end

		--  GPU mesh build/rebuild
		local function buildMesh()
			if gpuMesh then
				pcall(rlib.R3D_UnloadMesh, gpuMesh)
				gpuMesh = nil
			end
			if cpuMeshData then
				pcall(rlib.R3D_UnloadMeshData, cpuMeshData)
				cpuMeshData = nil
			end

			local pos = instance.Position
			local size = instance.Size
			local res = math.max(4, math.min(128, math.floor(instance.VisResolution or 32)))
			local halfW = size.X * 0.5
			local halfL = size.Z * 0.5

			gridPositions = buildGrid_vis(pos.X, pos.Z, halfW, halfL, res, res)
			vertCount = #gridPositions

			local floorY = pos.Y - size.Y * 0.5
			local verts = table.create(vertCount)
			for i, p in ipairs(gridPositions) do
				verts[i] = {
					position = { p[1], floorY, p[2] },
					normal = { 0, 1, 0 },
					uv = { p[3], p[4] },
					color = { 255, 255, 255, 255 },
				}
			end

			local indices = buildIndices_vis(res, res)
			local result = meshgen.buildMeshWithData(verts, indices, {
				indicesAreZeroBased = true,
				usage = meshgen.Usage.Dynamic,
				flat = false,
			})
			if result then
				cpuMeshData = result[1]
				gpuMesh = result[2]
			end

			if not offCached then
				off_vs = r3dstructs.R3D_Vertex:size()
				off_pos = r3dstructs.R3D_Vertex:offset("position")
				off_norm = r3dstructs.R3D_Vertex:offset("normal")
				off_mdV = r3dstructs.R3D_MeshData:offset("vertices")
				offCached = true
			end

			activeWaves = buildWaveConfig()
			renderMatrix = lib.MatrixIdentity()
		end

		--  Vertex deformation
		local function updateMeshVerts(t: number)
			if not cpuMeshData or not gpuMesh or not offCached then
				return
			end
			local vptr = ptrFromStructField(cpuMeshData, off_mdV)
			if vptr == ffi.null then
				return
			end

			local pos = instance.Position
			local size = instance.Size
			local floorY = pos.Y - size.Y * 0.5
			local vs = off_vs
			local poff = off_pos
			local noff = off_norm

			for i = 1, vertCount do
				local p = gridPositions[i]
				local wx = p[1]
				local wz = p[2]

				-- Sample simulation grid
				local lx, lz = worldToNorm(wx, wz)
				lx = math.clamp(lx, 0, 1)
				lz = math.clamp(lz, 0, 1)
				local simH_val = sampleGrid(lx, lz)

				-- Scale wave amplitude by water level (no ripples on empty cells)
				local wScale = math.clamp(simH_val / 0.15, 0, 1)
				local wy = floorY + simH_val + waveDisplacement(wx, wz, t, activeWaves) * wScale
				local nx, ny, nz = waveNormal(wx, wz, t, activeWaves)
				-- Blend toward (0,1,0) when nearly empty
				ny = ny * wScale + (1 - wScale)
				nx, ny, nz = normalize3(nx * wScale, ny, nz * wScale)

				local base = (i - 1) * vs
				vptr:writef32(base + poff + 0, wx)
				vptr:writef32(base + poff + 4, wy)
				vptr:writef32(base + poff + 8, wz)
				vptr:writef32(base + noff + 0, nx)
				vptr:writef32(base + noff + 4, ny)
				vptr:writef32(base + noff + 8, nz)
			end

			pcall(rlib.R3D_UpdateMesh, gpuMesh, cpuMeshData, ffi.null)
		end

		--  Shader uniforms
		local function syncShaderUniforms()
			if not surfaceShader then
				return
			end
			local col = instance.Color or Color3.new(0.05, 0.35, 0.72)
			local alpha = math.clamp(1 - (instance.Transparency or 0.42), 0.05, 1)
			buffer.writef32(ubTint, 0, col.R)
			buffer.writef32(ubTint, 4, col.G)
			buffer.writef32(ubTint, 8, col.B)
			buffer.writef32(ubTint, 12, alpha)
			buffer.writef32(ubRough, 0, math.clamp(instance.Roughness or 0.07, 0, 1))
			buffer.writef32(ubFlowUV, 0, flowAccumU)
			buffer.writef32(ubFlowUV, 4, flowAccumV)
			pcall(rlib.R3D_SetSurfaceShaderUniform, surfaceShader, "u_tint", ubTint)
			pcall(rlib.R3D_SetSurfaceShaderUniform, surfaceShader, "u_roughness", ubRough)
			pcall(rlib.R3D_SetSurfaceShaderUniform, surfaceShader, "u_flow_uv", ubFlowUV)
		end

		-- ====================================================================
		-- CONTAINER FITTING
		-- ====================================================================

		local function syncToContainer()
			if not instance.FitContainer then
				return
			end
			local container = instance.Container
			if not container and instance.Parent and instance.Parent.BaseClass == "BasePart" then
				container = instance.Parent
			end
			if not container or not container.Size or not container.Position then
				return
			end
			local cs = container.Size
			local cp = container.Position
			local sig = string.format(
				"%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f",
				cp.X,
				cp.Y,
				cp.Z,
				cs.X,
				cs.Y,
				cs.Z,
				instance.FillLevel or 0.85
			)
			if sig == lastContainerSig then
				return
			end
			lastContainerSig = sig
			local inset = 0.04
			local fillY = (cp.Y - cs.Y * 0.5) + cs.Y * math.clamp(instance.FillLevel or 0.85, 0, 1)
			local props = rawget(instance, "_props")
			if props then
				props.Position = Vector3.new(cp.X, fillY, cp.Z)
				props.Size =
					Vector3.new(math.max(1, cs.X * (1 - inset)), instance.Size.Y, math.max(1, cs.Z * (1 - inset)))
			end
			buildMesh()
		end

		-- ====================================================================
		-- BUOYANCY
		-- ====================================================================

		local function runBuoyancy(dt: number)
			if not instance.PhysicsEnabled then
				return
			end
			if not workspace then
				return
			end
			dt = math.clamp(dt, 0, 0.05)
			if dt < 1 / 120 then
				return
			end

			local pos = instance.Position
			local size = instance.Size
			local halfW = size.X * 0.5
			local halfL = size.Z * 0.5
			local depth = size.Y
			local buoy = instance.BuoyancyFactor or 25
			local drag = math.clamp(instance.Dampening or 0.55, 0, 1)
			local t = lib.GetTime()

			local fdir = instance.FlowDirection or Vector2.new(0, 0)
			local fspd = instance.FlowSpeed or 0
			local fdl = math.sqrt(fdir.X ^ 2 + fdir.Y ^ 2)
			local fvx, fvz = 0, 0
			if fdl > 1e-6 then
				fvx = fdir.X / fdl * fspd
				fvz = fdir.Y / fdl * fspd
			end

			local ok, descendants = pcall(function()
				return workspace:GetDescendants()
			end)
			if not ok then
				return
			end

			for _, part in ipairs(descendants) do
				if part.BaseClass ~= "BasePart" then
					continue
				end
				if part.Anchored then
					continue
				end
				if not part.ApplyImpulse then
					continue
				end

				local ppos = part.Position
				if not ppos then
					continue
				end

				local hpx = (part.Size and part.Size.X or 1) * 0.5
				local hpz = (part.Size and part.Size.Z or 1) * 0.5
				if math.abs(ppos.X - pos.X) > halfW + hpx then
					continue
				end
				if math.abs(ppos.Z - pos.Z) > halfL + hpz then
					continue
				end

				local fluidH = surfaceYAt(ppos.X, ppos.Z, t)
				local partH = (part.Size and part.Size.Y) or 1
				local partBot = ppos.Y - partH * 0.5
				local partTop = ppos.Y + partH * 0.5
				local fBot = fluidH - depth

				if partBot >= fluidH then
					submergedSet[part] = nil
					continue
				end
				if partTop <= fBot then
					continue
				end

				local subH = math.min(partTop, fluidH) - math.max(partBot, fBot)
				local frac = math.clamp(subH / partH, 0, 1)
				if frac <= 0 then
					continue
				end

				if not submergedSet[part] then
					submergedSet[part] = true
					pcall(function()
						instance.Splashed:Fire(part, frac)
					end)
				end

				local psz = part.Size or Vector3.new(1, 1, 1)
				local vol = psz.X * psz.Y * psz.Z
				local upY = buoy * frac * vol * dt
				local vel = part.Velocity or Vector3.new(0, 0, 0)
				local dFac = drag * frac * dt * 8
				local dX = (fvx - vel.X) * dFac
				local dY = -vel.Y * dFac * 0.3
				local dZ = (fvz - vel.Z) * dFac
				pcall(function()
					part:ApplyImpulse(Vector3.new(dX, upY + dY, dZ))
				end)
			end
		end

		-- ====================================================================
		-- PUBLIC API
		-- ====================================================================

		-- Internal fluid API table (used by drain connections)
		instance._fluidAPI = {
			avgWater = function()
				return totalWater()
			end,
			addWaterUniform = function(amount: number)
				local perCell = amount / (simW * simH)
				local maxH = instance.Size.Y
				for i = 1, simW * simH do
					simGrid[i] = math.clamp((simGrid[i] or 0) + perCell, 0, maxH)
				end
				wasEmpty = false
			end,
		}

		-- description: "Sets every simulation cell to a fill level from 0 to 1."
		-- args: "level: number"
		function instance:SetWaterLevel(level: number)
			local h = math.clamp(level, 0, 1) * self.Size.Y
			for i = 1, simW * simH do
				simGrid[i] = h
			end
			wasEmpty = (h < 0.001)
		end

		-- description: "Returns the current average fill level from 0 to 1."
		-- returns: "number"
		function instance:GetWaterLevel(): number
			return math.clamp(totalWater() / self.Size.Y, 0, 1)
		end

		-- description: "Adds water uniformly across the simulation surface."
		-- args: "amount: number"
		function instance:AddWater(amount: number)
			instance._fluidAPI.addWaterUniform(amount)
		end

		-- description: "Removes water uniformly across the simulation surface."
		-- args: "amount: number"
		function instance:RemoveWater(amount: number)
			local perCell = amount / (simW * simH)
			for i = 1, simW * simH do
				simGrid[i] = math.max(0, (simGrid[i] or 0) - perCell)
			end
		end

		-- description: "Adds water to the simulation cell nearest a world-space XZ position."
		-- args: "worldX: number, worldZ: number, amount: number"
		function instance:AddWaterAt(worldX: number, worldZ: number, amount: number)
			local lx, lz = worldToNorm(worldX, worldZ)
			local cx = math.floor(math.clamp(lx * (simW - 1), 0, simW - 1))
			local cz = math.floor(math.clamp(lz * (simH - 1), 0, simH - 1))
			local maxH = self.Size.Y
			local idx = simIndex(cx, cz)
			simGrid[idx] = math.clamp((simGrid[idx] or 0) + amount, 0, maxH)
			wasEmpty = false
		end

		-- description: "Removes water from the simulation cell nearest a world-space XZ position and returns the amount removed."
		-- args: "worldX: number, worldZ: number, amount: number"
		-- returns: "number"
		function instance:RemoveWaterAt(worldX: number, worldZ: number, amount: number): number
			local lx, lz = worldToNorm(worldX, worldZ)
			local cx = math.floor(math.clamp(lx * (simW - 1), 0, simW - 1))
			local cz = math.floor(math.clamp(lz * (simH - 1), 0, simH - 1))
			local idx = simIndex(cx, cz)
			local have = simGrid[idx] or 0
			local take = math.min(have, amount)
			simGrid[idx] = have - take
			return take
		end

		-- description: "Returns the water surface Y position at a world-space XZ position."
		-- args: "worldX: number, worldZ: number"
		-- returns: "number"
		function instance:GetWaterHeight(worldX: number, worldZ: number): number
			return surfaceYAt(worldX, worldZ, lib.GetTime())
		end

		-- description: "Returns whether a world-space point is inside the current water volume."
		-- args: "worldPos: Vector3"
		-- returns: "boolean"
		function instance:IsPointSubmerged(worldPos: any): boolean
			local pos = self.Position
			local size = self.Size
			if math.abs(worldPos.X - pos.X) > size.X * 0.5 then
				return false
			end
			if math.abs(worldPos.Z - pos.Z) > size.Z * 0.5 then
				return false
			end
			local h = self:GetWaterHeight(worldPos.X, worldPos.Z)
			return worldPos.Y <= h and worldPos.Y >= h - size.Y
		end

		-- description: "Returns how much of a part's height is submerged, from 0 to 1."
		-- args: "part: any"
		-- returns: "number"
		function instance:GetSubmergedFraction(part: any): number
			if not part or not part.Position then
				return 0
			end
			local h = self:GetWaterHeight(part.Position.X, part.Position.Z)
			local pH = (part.Size and part.Size.Y) or 1
			local bot = part.Position.Y - pH * 0.5
			if bot >= h then
				return 0
			end
			return math.clamp((math.min(part.Position.Y + pH * 0.5, h) - bot) / pH, 0, 1)
		end

		-- description: "Connects this simulation to another so water can flow through a drain point."
		-- args: "targetSim: any, worldX: number, worldZ: number, thresholdH: number?, flowMult: number?"
		function instance:ConnectTo(
			targetSim: any,
			worldX: number,
			worldZ: number,
			thresholdH: number?,
			flowMult: number?
		)
			table.insert(drainConnections, {
				target = targetSim,
				wx = worldX,
				wz = worldZ,
				thresholdH = thresholdH or 0,
				flowMult = flowMult or 1.0,
			})
		end

		-- description: "Removes all drain connections from this simulation to a target simulation."
		-- args: "targetSim: any"
		function instance:Disconnect(targetSim: any)
			for i = #drainConnections, 1, -1 do
				if drainConnections[i].target == targetSim then
					table.remove(drainConnections, i)
				end
			end
		end

		-- description: "Rebuilds the render mesh and resets the simulation grid when already initialized."
		function instance:Rebuild()
			buildMesh()
			if simInitialised then
				initGrid()
			end
		end

		-- ====================================================================
		-- INITIALISE
		-- ====================================================================

		material = createMaterial()
		initGrid()
		syncToContainer()
		buildMesh()

		-- Register in the 3D render pool
		renderId = renderer.Pool.new("3d", function()
			if not instance.Enabled then
				return
			end
			if not gpuMesh or not material then
				return
			end
			renderer.MeshPool.DrawMesh(gpuMesh, material, renderMatrix)
		end)

		-- ====================================================================
		-- PER-FRAME LOOP
		-- ====================================================================

		renderer.Hook.new("Renderstep", function(dt: number)
			if not instance.Enabled then
				return
			end
			local t = lib.GetTime()

			syncToContainer()

			-- Flow UV scroll
			local fdir = instance.FlowDirection or Vector2.new(0, 0)
			local fspd = instance.FlowSpeed or 0
			local fdl = math.sqrt(fdir.X ^ 2 + fdir.Y ^ 2)
			if fdl > 1e-6 then
				local inv = fspd * dt / fdl
				flowAccumU += fdir.X * inv
				flowAccumV += fdir.Y * inv
			end

			stepSimulation(dt)
			updateDrains(dt)
			updateMeshVerts(t)
			syncShaderUniforms()
			runBuoyancy(dt)
		end)

		-- ====================================================================
		-- PROPERTY CHANGE REACTIONS
		-- ====================================================================

		instance.Changed:Connect(function(property, _value)
			if property == "Size" or property == "Position" or property == "VisResolution" then
				if not instance.FitContainer then
					buildMesh()
				end
			elseif property == "SimResolution" then
				simW = math.max(4, math.min(64, math.floor(instance.SimResolution)))
				simH = simW
				initGrid()
				buildMesh()
			elseif property == "WaterLevel" then
				instance:SetWaterLevel(instance.WaterLevel)
			elseif
				property == "WaveHeight"
				or property == "WaveSpeed"
				or property == "WaveScale"
				or property == "WaveDirection"
			then
				activeWaves = buildWaveConfig()
			elseif property == "Container" or property == "FitContainer" or property == "FillLevel" then
				lastContainerSig = ""
				syncToContainer()
			end
		end)

		-- ====================================================================
		-- CLEANUP
		-- ====================================================================

		instance.Destroying:Connect(function()
			if renderId then
				renderer.Pool.Destroy(renderId)
				renderId = nil
			end
			if gpuMesh then
				pcall(rlib.R3D_UnloadMesh, gpuMesh)
				gpuMesh = nil
			end
			if cpuMeshData then
				pcall(rlib.R3D_UnloadMeshData, cpuMeshData)
				cpuMeshData = nil
			end
			if surfaceShader then
				pcall(rlib.R3D_UnloadSurfaceShader, surfaceShader)
				surfaceShader = nil
			end
		end)

		return instance
	end,

	inherit = function(tble)
		for prop, val in pairs(propTable) do
			if tble[prop] == nil then
				tble[prop] = val
			end
		end
	end,
}
