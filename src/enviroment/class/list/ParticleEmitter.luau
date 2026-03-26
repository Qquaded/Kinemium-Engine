local Vector2 = require("@Vector2")
local Vector3 = require("@Vector3")
local Color3 = require("@Color3")
local CFrame = require("@CFrame")
local Enum = require("@EnumMap")
local NumberSequence = require("@NumberSequence")
local NumberSequenceKeypoint = require("@NumberSequenceKeypoint")
local ColorSequence = require("@ColorSequence")
local NumberRange = require("@NumberRange")
local ColorSequenceKeypoint = require("@ColorSequenceKeypoint")
local r3d = require("@r3d")
local raylib = require("@raylib")

local rlib = r3d.lib
local r3dstructs = r3d.structs
local const = r3d.constants
local lib = raylib.lib
local structs = raylib.structs

local BLEND_MIX = 0
local BLEND_ADDITIVE = 1
local BLEND_MULTIPLY = 2
local BLEND_PREMULTIPLIED_ALPHA = 3

local function getRange(value, defaultMin, defaultMax)
	if type(value) == "number" then
		return value, value
	end
	if type(value) == "table" then
		if value.Min ~= nil and value.Max ~= nil then
			return value.Min, value.Max
		end
	end
	return defaultMin, defaultMax
end

local function randomRange(value, defaultMin, defaultMax)
	local minVal, maxVal = getRange(value, defaultMin, defaultMax)
	if minVal == nil or maxVal == nil then
		return 0
	end
	if minVal == maxVal then
		return minVal
	end
	return minVal + math.random() * (maxVal - minVal)
end

local function clamp01(v)
	if v < 0 then
		return 0
	end
	if v > 1 then
		return 1
	end
	return v
end

local function resolveTransparencyMode(value)
	if type(value) == "number" then
		return value
	end
	if type(value) == "table" and value.Value ~= nil then
		return value.Value
	end
	return const.R3D_TRANSPARENCY_PREPASS
end

local function resolveBillboardMode(value)
	if type(value) == "number" then
		return value
	end
	if type(value) == "table" and value.Value ~= nil then
		return value.Value
	end
	return const.R3D_BILLBOARD_FRONT
end

local function resolveCullMode(value)
	if type(value) == "number" then
		return value
	end
	if type(value) == "table" and value.Value ~= nil then
		return value.Value
	end
	return 1
end

local function resolveBlendMode(value)
	if type(value) == "number" then
		return value
	end
	if type(value) == "table" and value.Value ~= nil then
		return value.Value
	end
	return BLEND_MIX
end

local function getVector2(value, fallback)
	if type(value) == "table" and value.__type == "Vector2" then
		return value
	end
	return fallback
end

local function getColor3(value, fallback)
	if type(value) == "table" and value.__type == "Color3" then
		return value
	end
	return fallback
end

local function evalNumberSequence(seq, t, fallback)
	if type(seq) == "number" then
		return seq
	end
	if type(seq) == "table" and seq.Evaluate then
		return seq:Evaluate(t)
	end
	return fallback
end

local function evalColorSequence(seq, t, fallback)
	if type(seq) == "table" and seq.Evaluate then
		return seq:Evaluate(t)
	end
	if type(seq) == "table" and seq.__type == "Color3" then
		return seq
	end
	return fallback
end

local function getFlipbookMode(value)
	if type(value) == "number" then
		return value
	end
	if type(value) == "table" and value.Value ~= nil then
		return value.Value
	end
	return 0
end

local function getEmitterCFrame(instance)
	local parent = instance.Parent
	if parent then
		if parent.WorldCFrame then
			return parent.WorldCFrame
		end
		if parent.CFrame then
			return parent.CFrame
		end
	end
	return CFrame.new(0, 0, 0)
end

local function getEmissionDirection(cf, normalId)
	if normalId == Enum.NormalId.Bottom then
		return -cf:GetUpVector()
	elseif normalId == Enum.NormalId.Top then
		return cf:GetUpVector()
	elseif normalId == Enum.NormalId.Left then
		return -cf:GetRightVector()
	elseif normalId == Enum.NormalId.Right then
		return cf:GetRightVector()
	elseif normalId == Enum.NormalId.Back then
		return -cf:GetLookVector()
	end
	return cf:GetLookVector()
end

local function applySpread(baseDir, basisRight, basisUp, spread)
	if not spread or type(spread) ~= "table" then
		return baseDir
	end

	local spreadX = math.tan(math.rad(spread.X or 0) * 0.5)
	local spreadY = math.tan(math.rad(spread.Y or 0) * 0.5)
	if spreadX == 0 and spreadY == 0 then
		return baseDir
	end

	local rx = (math.random() * 2 - 1) * spreadX
	local ry = (math.random() * 2 - 1) * spreadY
	local dir = baseDir + (basisRight * rx) + (basisUp * ry)
	return dir:Unit()
end

local function buildDefaultColor()
	return ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
		ColorSequenceKeypoint.new(1, Color3.new(1, 1, 1)),
	})
end

local function buildDefaultTransparency()
	return NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(1, 0),
	})
end

local function buildDefaultSize()
	return NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(1, 1),
	})
end

local function createMaterial(texturePath)
	local baseMaterial = rlib.R3D_GetDefaultMaterial()
	local material = buffer.create(r3dstructs.R3D_Material:size())
	buffer.copy(material, 0, baseMaterial, 0, r3dstructs.R3D_Material:size())

	if type(texturePath) == "string" and texturePath ~= "" then
		local ok, data = pcall(zune.fs.readFileSync, texturePath, true)
		if ok and data then
			local ext = lib.GetFileExtension(texturePath)
			local okLoad, map = pcall(rlib.R3D_LoadAlbedoMapFromMemory, ext, data, buffer.len(data), raylib.const.WHITE)
			if okLoad then
				buffer.copy(material, r3dstructs.R3D_Material:offset("albedo"), map, 0, r3dstructs.R3D_AlbedoMap:size())
				return material, map
			end
		end
	end

	return material, nil
end

local propTable = {
	Enabled = true,
	Rate = 10,
	Lifetime = NumberRange.new(1, 2),
	Speed = NumberRange.new(4, 7),
	Rotation = NumberRange.new(0, 0),
	RotSpeed = NumberRange.new(0, 0),
	Size = buildDefaultSize(),
	Color = buildDefaultColor(),
	Transparency = buildDefaultTransparency(),
	Acceleration = Vector3.new(0, 0, 0),
	Drag = 0,
	Restitution = 0,
	EmissionDirection = Enum.NormalId.Top,
	SpreadAngle = Vector2.new(0, 0),
	Texture = "./src/assets/images/placeholder.png",
	EmissionTexture = nil,
	EmissionColor = Color3.new(1, 1, 1),
	EmissionEnergy = 0,
	TransparencyMode = Enum.ParticleTransparencyMode.Prepass,
	BlendMode = Enum.ParticleBlendMode.Mix,
	CullMode = Enum.ParticleCullMode.None,
	BillboardMode = Enum.ParticleBillboardMode.Front,
	UVScale = Vector2.new(1, 1),
	UVOffset = Vector2.new(0, 0),
	FlipbookColumns = 1,
	FlipbookRows = 1,
	FlipbookFramerate = 0,
	FlipbookMode = Enum.ParticleFlipbookMode.Loop,
	FlipbookStartRandom = false,
	MaxParticles = 256,
	LockedToPart = false,
	CastShadow = false,
}

return {
	class = "ParticleEmitter",

	callback = function(instance, renderer, game)
		instance:SetProperties(propTable)

		if _G.IsHeadless or not renderer then
			return instance
		end

	local particleMesh = rlib.R3D_GenMeshQuad(1, 1, 1, 1, vector.create(0, 0, 1))
		local particleMaterial, albedoMap = createMaterial(instance.Texture)
		local emissionMap = nil
		local instanceFlags = bit32.bor(
			const.R3D_INSTANCE_POSITION,
			const.R3D_INSTANCE_ROTATION,
			const.R3D_INSTANCE_SCALE,
			const.R3D_INSTANCE_COLOR
		)
		local instanceBuffer = rlib.R3D_LoadInstanceBuffer(instance.MaxParticles, instanceFlags)
		local SHADOW_AUTO = 0
		local SHADOW_DISABLED = 8
		local flipbookTime = 0
		local flipbookFrame = 0
		local flipbookDir = 1

		local particles = {}
		local activeCount = 0
		local emitAccumulator = 0

		local function rebuildInstanceBuffer()
			if instanceBuffer then
				pcall(rlib.R3D_UnloadInstanceBuffer, instanceBuffer)
			end
			instanceBuffer = rlib.R3D_LoadInstanceBuffer(instance.MaxParticles, instanceFlags)
		end

		local updateFlipbook

		local function applyMaterialSettings()
			if not particleMaterial then
				return
			end

			buffer.writei32(
				particleMaterial,
				r3dstructs.R3D_Material:offset("transparencyMode"),
				resolveTransparencyMode(instance.TransparencyMode)
			)
			buffer.writei32(
				particleMaterial,
				r3dstructs.R3D_Material:offset("blendMode"),
				resolveBlendMode(instance.BlendMode)
			)
			buffer.writei32(
				particleMaterial,
				r3dstructs.R3D_Material:offset("billboardMode"),
				resolveBillboardMode(instance.BillboardMode)
			)
			buffer.writei32(
				particleMaterial,
				r3dstructs.R3D_Material:offset("cullMode"),
				resolveCullMode(instance.CullMode)
			)

			local uvScale = getVector2(instance.UVScale, Vector2.new(1, 1))
			local uvOffset = getVector2(instance.UVOffset, Vector2.new(0, 0))
			buffer.writef32(particleMaterial, r3dstructs.R3D_Material:offset("uvScale"), uvScale.X)
			buffer.writef32(particleMaterial, r3dstructs.R3D_Material:offset("uvScale") + 4, uvScale.Y)
			buffer.writef32(particleMaterial, r3dstructs.R3D_Material:offset("uvOffset"), uvOffset.X)
			buffer.writef32(particleMaterial, r3dstructs.R3D_Material:offset("uvOffset") + 4, uvOffset.Y)

		local emissionColor = getColor3(instance.EmissionColor, Color3.new(1, 1, 1))
		local emissionEnergy = instance.EmissionEnergy or 0
		if emissionMap then
			buffer.copy(
				emissionMap,
				r3dstructs.R3D_EmissionMap:offset("color"),
				emissionColor:ToRaylib(0),
				0,
				structs.Color:size()
			)
			buffer.writef32(emissionMap, r3dstructs.R3D_EmissionMap:offset("energy"), emissionEnergy)
			buffer.copy(
				particleMaterial,
				r3dstructs.R3D_Material:offset("emission"),
				emissionMap,
				0,
				r3dstructs.R3D_EmissionMap:size()
			)
		else
			local emissionMapLocal = r3dstructs.R3D_EmissionMap:new({
				color = emissionColor:ToRaylib(0),
				energy = emissionEnergy,
			})
			buffer.copy(
				particleMaterial,
				r3dstructs.R3D_Material:offset("emission"),
				emissionMapLocal,
				0,
				r3dstructs.R3D_EmissionMap:size()
			)
		end
		end

		local function updateMaterial()
			if albedoMap then
				pcall(rlib.R3D_UnloadAlbedoMap, albedoMap)
				albedoMap = nil
			end
			if emissionMap then
				pcall(rlib.R3D_UnloadEmissionMap, emissionMap)
				emissionMap = nil
			end
			local material, map = createMaterial(instance.Texture)
			particleMaterial = material
			albedoMap = map

			if type(instance.EmissionTexture) == "string" and instance.EmissionTexture ~= "" then
				local ok, data = pcall(zune.fs.readFileSync, instance.EmissionTexture, true)
				if ok and data then
					local ext = lib.GetFileExtension(instance.EmissionTexture)
					local okLoad, map2 =
						pcall(rlib.R3D_LoadEmissionMapFromMemory, ext, data, buffer.len(data), raylib.const.WHITE, 1)
					if okLoad then
						emissionMap = map2
						buffer.copy(
							particleMaterial,
							r3dstructs.R3D_Material:offset("emission"),
							emissionMap,
							0,
							r3dstructs.R3D_EmissionMap:size()
						)
					end
				end
			end

			applyMaterialSettings()
			if updateFlipbook then
				updateFlipbook(0)
			end
		end

	local function applyShadowMode()
		if particleMesh then
			local mode = instance.CastShadow and SHADOW_AUTO or SHADOW_DISABLED
			buffer.writei32(particleMesh, r3dstructs.R3D_Mesh:offset("shadowCastMode"), mode)
		end
	end

		applyShadowMode()
		applyMaterialSettings()

		local function emitParticle()
			if activeCount >= instance.MaxParticles then
				return
			end

			local emitterCF = getEmitterCFrame(instance)
			local baseDir = getEmissionDirection(emitterCF, instance.EmissionDirection)
			local dir = applySpread(baseDir, emitterCF:GetRightVector(), emitterCF:GetUpVector(), instance.SpreadAngle)

			local lifetime = randomRange(instance.Lifetime, 1, 1)
			if lifetime <= 0 then
				return
			end

			activeCount += 1
			particles[activeCount] = {
				position = emitterCF.Position,
				velocity = dir * randomRange(instance.Speed, 0, 0),
				life = lifetime,
				lifetime = lifetime,
				rotation = math.rad(randomRange(instance.Rotation, 0, 0)),
				rotSpeed = math.rad(randomRange(instance.RotSpeed, 0, 0)),
				axis = dir,
			}
		end

		local function emit(count)
			for _ = 1, count do
				emitParticle()
			end
		end

		instance.Emit = function(_, count)
			emit(math.max(0, count or 1))
		end

		local function updateParticles(dt)
			if instance.Enabled then
				emitAccumulator += (instance.Rate or 0) * dt
				local emitCount = math.floor(emitAccumulator)
				if emitCount > 0 then
					emitAccumulator -= emitCount
					emit(emitCount)
				end
			end

			local accel = instance.Acceleration or Vector3.new(0, 0, 0)
			local drag = instance.Drag or 0
			local restitution = math.max(0, math.min(instance.Restitution or 0, 1))
			local planeNormal = nil
			local planeOrigin = nil
			if restitution > 0 then
				local emitterCF = getEmitterCFrame(instance)
				planeNormal = emitterCF:GetUpVector()
				planeOrigin = emitterCF.Position
			end

			local i = 1
			while i <= activeCount do
				local p = particles[i]
				p.life -= dt
				if p.life <= 0 then
					particles[i] = particles[activeCount]
					particles[activeCount] = nil
					activeCount -= 1
				else
					p.velocity = p.velocity + accel * dt
					if drag > 0 then
						local dragFactor = math.max(0, 1 - drag * dt)
						p.velocity = p.velocity * dragFactor
					end
					p.position = p.position + p.velocity * dt
					if planeNormal then
						local rel = p.position - planeOrigin
						local dist = rel:Dot(planeNormal)
						if dist < 0 then
							local vDot = p.velocity:Dot(planeNormal)
							if vDot < 0 then
								p.velocity = p.velocity - planeNormal * ((1 + restitution) * vDot)
							end
							p.position = p.position - planeNormal * dist
						end
					end
					p.rotation += p.rotSpeed * dt
					i += 1
				end
			end
		end

		local function updateInstanceBuffer()
			if activeCount <= 0 or not instanceBuffer then
				return
			end

			local mappedPosition = nil
			local mappedRotation = nil
			local mappedScale = nil
			local mappedColor = nil

			local okMap = pcall(function()
				mappedPosition = rlib.R3D_MapInstances(instanceBuffer, const.R3D_INSTANCE_POSITION)
				mappedRotation = rlib.R3D_MapInstances(instanceBuffer, const.R3D_INSTANCE_ROTATION)
				mappedScale = rlib.R3D_MapInstances(instanceBuffer, const.R3D_INSTANCE_SCALE)
				mappedColor = rlib.R3D_MapInstances(instanceBuffer, const.R3D_INSTANCE_COLOR)
			end)

			local mappedFlags = bit32.bor(
				mappedPosition and const.R3D_INSTANCE_POSITION or 0,
				mappedRotation and const.R3D_INSTANCE_ROTATION or 0,
				mappedScale and const.R3D_INSTANCE_SCALE or 0,
				mappedColor and const.R3D_INSTANCE_COLOR or 0
			)

			local function writeInstances(writePosition, writeRotation, writeScale, writeColor)
				for idx = 1, activeCount do
					local p = particles[idx]
					local age = 1 - (p.life / p.lifetime)
					local t = clamp01(age)

					local size = evalNumberSequence(instance.Size, t, 1)
					local color = evalColorSequence(instance.Color, t, Color3.new(1, 1, 1))
					local transparency = evalNumberSequence(instance.Transparency, t, 0)

					local r, g, b = color:ToRGB()
					local alpha = math.floor(255 * (1 - clamp01(transparency)))

					if writePosition then
						local pOffset = (idx - 1) * 12
						writePosition(pOffset, p.position)
					end

					if writeRotation then
						local rotCF = CFrame.fromAxisAngle(p.axis, p.rotation)
						local qx, qy, qz, qw = rotCF:ToQuaternion()
						local rOffset = (idx - 1) * 16
						writeRotation(rOffset, qx, qy, qz, qw)
					end

					if writeScale then
						local sOffset = (idx - 1) * 12
						writeScale(sOffset, size)
					end

					if writeColor then
						local cOffset = (idx - 1) * 4
						writeColor(cOffset, r, g, b, alpha)
					end
				end
			end

			if okMap and mappedFlags == instanceFlags then
				local okWrite = pcall(function()
					writeInstances(function(offset, pos)
						mappedPosition:writef32(offset, pos.X)
						mappedPosition:writef32(offset + 4, pos.Y)
						mappedPosition:writef32(offset + 8, pos.Z)
					end, function(offset, qx, qy, qz, qw)
						mappedRotation:writef32(offset, qx)
						mappedRotation:writef32(offset + 4, qy)
						mappedRotation:writef32(offset + 8, qz)
						mappedRotation:writef32(offset + 12, qw)
					end, function(offset, size)
						mappedScale:writef32(offset, size)
						mappedScale:writef32(offset + 4, size)
						mappedScale:writef32(offset + 8, size)
					end, function(offset, r, g, b, a)
						mappedColor:writeu8(offset, r)
						mappedColor:writeu8(offset + 1, g)
						mappedColor:writeu8(offset + 2, b)
						mappedColor:writeu8(offset + 3, a)
					end)
				end)
				if okWrite then
					pcall(rlib.R3D_UnmapInstances, instanceBuffer, instanceFlags)
					return
				end
			end

			if mappedFlags ~= 0 then
				pcall(rlib.R3D_UnmapInstances, instanceBuffer, mappedFlags)
			end

			local positionBuffer = buffer.create(activeCount * 12)
			local rotationBuffer = buffer.create(activeCount * 16)
			local scaleBuffer = buffer.create(activeCount * 12)
			local colorBuffer = buffer.create(activeCount * 4)

			writeInstances(function(offset, pos)
				buffer.writef32(positionBuffer, offset, pos.X)
				buffer.writef32(positionBuffer, offset + 4, pos.Y)
				buffer.writef32(positionBuffer, offset + 8, pos.Z)
			end, function(offset, qx, qy, qz, qw)
				buffer.writef32(rotationBuffer, offset, qx)
				buffer.writef32(rotationBuffer, offset + 4, qy)
				buffer.writef32(rotationBuffer, offset + 8, qz)
				buffer.writef32(rotationBuffer, offset + 12, qw)
			end, function(offset, size)
				buffer.writef32(scaleBuffer, offset, size)
				buffer.writef32(scaleBuffer, offset + 4, size)
				buffer.writef32(scaleBuffer, offset + 8, size)
			end, function(offset, r, g, b, a)
				buffer.writeu8(colorBuffer, offset, r)
				buffer.writeu8(colorBuffer, offset + 1, g)
				buffer.writeu8(colorBuffer, offset + 2, b)
				buffer.writeu8(colorBuffer, offset + 3, a)
			end)

			pcall(function()
				rlib.R3D_UploadInstances(instanceBuffer, const.R3D_INSTANCE_POSITION, 0, activeCount, positionBuffer)
				rlib.R3D_UploadInstances(instanceBuffer, const.R3D_INSTANCE_ROTATION, 0, activeCount, rotationBuffer)
				rlib.R3D_UploadInstances(instanceBuffer, const.R3D_INSTANCE_SCALE, 0, activeCount, scaleBuffer)
				rlib.R3D_UploadInstances(instanceBuffer, const.R3D_INSTANCE_COLOR, 0, activeCount, colorBuffer)
			end)
		end

		updateFlipbook = function(dt)
			local cols = math.max(1, tonumber(instance.FlipbookColumns) or 1)
			local rows = math.max(1, tonumber(instance.FlipbookRows) or 1)
			local frames = cols * rows
			local framerate = tonumber(instance.FlipbookFramerate) or 0

			if frames <= 1 then
				return
			end

			if framerate > 0 then
				flipbookTime += dt * framerate
				while flipbookTime >= 1 do
					flipbookTime -= 1
					local mode = getFlipbookMode(instance.FlipbookMode)
					if mode == 1 then
						flipbookFrame = math.min(frames - 1, flipbookFrame + 1)
					elseif mode == 2 then
						flipbookFrame += flipbookDir
						if flipbookFrame <= 0 then
							flipbookFrame = 0
							flipbookDir = 1
						elseif flipbookFrame >= frames - 1 then
							flipbookFrame = frames - 1
							flipbookDir = -1
						end
					elseif mode == 3 then
						flipbookFrame = math.random(0, frames - 1)
					else
						flipbookFrame = (flipbookFrame + 1) % frames
					end
				end
			end

			local baseScale = getVector2(instance.UVScale, Vector2.new(1, 1))
			local baseOffset = getVector2(instance.UVOffset, Vector2.new(0, 0))
			local frameScaleX = 1 / cols
			local frameScaleY = 1 / rows
			local col = flipbookFrame % cols
			local row = math.floor(flipbookFrame / cols)

			local finalScaleX = baseScale.X * frameScaleX
			local finalScaleY = baseScale.Y * frameScaleY
			local finalOffsetX = baseOffset.X + (col * frameScaleX * baseScale.X)
			local finalOffsetY = baseOffset.Y + (row * frameScaleY * baseScale.Y)

			buffer.writef32(particleMaterial, r3dstructs.R3D_Material:offset("uvScale"), finalScaleX)
			buffer.writef32(particleMaterial, r3dstructs.R3D_Material:offset("uvScale") + 4, finalScaleY)
			buffer.writef32(particleMaterial, r3dstructs.R3D_Material:offset("uvOffset"), finalOffsetX)
			buffer.writef32(particleMaterial, r3dstructs.R3D_Material:offset("uvOffset") + 4, finalOffsetY)
		end

		local renderId = renderer.Pool.new("3d", function()
			if activeCount <= 0 then
				return
			end
			renderer.MeshPool.DrawMeshInstanced(particleMesh, particleMaterial, instanceBuffer, activeCount)
		end)

		if instance.FlipbookStartRandom then
			local cols = math.max(1, tonumber(instance.FlipbookColumns) or 1)
			local rows = math.max(1, tonumber(instance.FlipbookRows) or 1)
			local frames = cols * rows
			if frames > 1 then
				flipbookFrame = math.random(0, frames - 1)
			end
		end

		renderer.Hook.new("Renderstep", function(dt)
			updateParticles(dt)
			updateInstanceBuffer()
			updateFlipbook(dt)
		end)

		instance.Changed:Connect(function(property)
			if property == "Texture" then
				updateMaterial()
			elseif property == "EmissionTexture" then
				updateMaterial()
			elseif property == "EmissionColor" or property == "EmissionEnergy" then
				applyMaterialSettings()
			elseif property == "TransparencyMode" or property == "BlendMode" or property == "CullMode" then
				applyMaterialSettings()
			elseif property == "BillboardMode" or property == "UVScale" or property == "UVOffset" then
				applyMaterialSettings()
				updateFlipbook(0)
			elseif property == "FlipbookColumns"
				or property == "FlipbookRows"
				or property == "FlipbookFramerate"
				or property == "FlipbookMode"
			then
				updateFlipbook(0)
			elseif property == "MaxParticles" then
				rebuildInstanceBuffer()
			elseif property == "CastShadow" then
				applyShadowMode()
			end
		end)

		instance.Destroying:Connect(function()
			if renderId then
				renderer.Pool.Destroy(renderId)
			end
			if instanceBuffer then
				pcall(rlib.R3D_UnloadInstanceBuffer, instanceBuffer)
			end
			if particleMesh then
				pcall(rlib.R3D_UnloadMesh, particleMesh)
			end
			if albedoMap then
				pcall(rlib.R3D_UnloadAlbedoMap, albedoMap)
			end
		end)

		return instance
	end,

	inherit = function(tble)
		for prop, val in pairs(propTable) do
			tble[prop] = val
		end
	end,
}
