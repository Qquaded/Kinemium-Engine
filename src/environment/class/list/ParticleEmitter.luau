-- description: "Emits particles in 3D space with a custom image template, and with configurable properties such as Color, Transparency, etc"
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
local zembed = require("@zembed")

local BLEND_MIX = 0

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

local function getEmitterVelocity(instance)
	local parent = instance.Parent
	if parent then
		if type(parent.AssemblyLinearVelocity) == "table" and parent.AssemblyLinearVelocity.__type == "Vector3" then
			return parent.AssemblyLinearVelocity
		end
		if
			parent.Parent
			and type(parent.Parent.AssemblyLinearVelocity) == "table"
			and parent.Parent.AssemblyLinearVelocity.__type == "Vector3"
		then
			return parent.Parent.AssemblyLinearVelocity
		end
	end
	return Vector3.new(0, 0, 0)
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
	local baseMaterial = adapter.lib.R3D_GetDefaultMaterial()
	local material = buffer.create(r3dstructs.R3D_Material:size())
	buffer.copy(material, 0, baseMaterial, 0, r3dstructs.R3D_Material:size())

	if type(texturePath) == "string" and texturePath ~= "" then
		texturePath = zembed.AssetPath(texturePath)
		local ok, data = pcall(zune.fs.readFileSync, texturePath, true)
		if ok and data then
			local ext = lib.GetFileExtension(texturePath)
			local okLoad, map =
				pcall(adapter.lib.R3D_LoadAlbedoMapFromMemory, ext, data, buffer.len(data), adapter.const.WHITE)
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
	Rate = 20,
	Lifetime = NumberRange.new(1, 2),
	Speed = NumberRange.new(4, 7),
	Rotation = NumberRange.new(0, 0),
	RotSpeed = NumberRange.new(0, 0),
	Size = buildDefaultSize(),
	Color = buildDefaultColor(),
	Transparency = buildDefaultTransparency(),
	Acceleration = Vector3.new(0, 0, 0),
	Drag = 0,
	Restitution = 0.5,
	CollisionGroup = "Particles",
	Friction = 0.3,
	VelocityInheritance = 0,
	TimeScale = 1,
	WindAffectsDrag = false,
	CollideParticles = false,
	CollisionRadius = 0.5,
	EmissionDirection = Enum.NormalId.Top,
	SpreadAngle = Vector2.new(0, 0),
	Texture = "./src/assets/images/placeholder.png",
	EmissionTexture = nil,
	EmissionColor = Color3.new(1, 1, 1),
	EmissionEnergy = 0,
	TransparencyMode = Enum.ParticleTransparencyMode.Alpha,
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
	CastShadow = true,
}

local function writePositionMapped(mappedPosition)
	return function(offset, pos)
		mappedPosition:writef32(offset, pos.X)
		mappedPosition:writef32(offset + 4, pos.Y)
		mappedPosition:writef32(offset + 8, pos.Z)
	end
end

local function writeRotationMapped(mappedRotation)
	return function(offset, qx, qy, qz, qw)
		mappedRotation:writef32(offset, qx)
		mappedRotation:writef32(offset + 4, qy)
		mappedRotation:writef32(offset + 8, qz)
		mappedRotation:writef32(offset + 12, qw)
	end
end

local function writeScaleMapped(mappedScale)
	return function(offset, size)
		mappedScale:writef32(offset, size)
		mappedScale:writef32(offset + 4, size)
		mappedScale:writef32(offset + 8, size)
	end
end

local function writeColorMapped(mappedColor)
	return function(offset, r, g, b, a)
		mappedColor:writeu8(offset, r)
		mappedColor:writeu8(offset + 1, g)
		mappedColor:writeu8(offset + 2, b)
		mappedColor:writeu8(offset + 3, a)
	end
end

local function writePositionBuffer(targetBuffer)
	return function(offset, pos)
		buffer.writef32(targetBuffer, offset, pos.X)
		buffer.writef32(targetBuffer, offset + 4, pos.Y)
		buffer.writef32(targetBuffer, offset + 8, pos.Z)
	end
end

local function writeRotationBuffer(targetBuffer)
	return function(offset, qx, qy, qz, qw)
		buffer.writef32(targetBuffer, offset, qx)
		buffer.writef32(targetBuffer, offset + 4, qy)
		buffer.writef32(targetBuffer, offset + 8, qz)
		buffer.writef32(targetBuffer, offset + 12, qw)
	end
end

local function writeScaleBuffer(targetBuffer)
	return function(offset, size)
		buffer.writef32(targetBuffer, offset, size)
		buffer.writef32(targetBuffer, offset + 4, size)
		buffer.writef32(targetBuffer, offset + 8, size)
	end
end

local function writeColorBuffer(targetBuffer)
	return function(offset, r, g, b, a)
		buffer.writeu8(targetBuffer, offset, r)
		buffer.writeu8(targetBuffer, offset + 1, g)
		buffer.writeu8(targetBuffer, offset + 2, b)
		buffer.writeu8(targetBuffer, offset + 3, a)
	end
end

return {
	class = "ParticleEmitter",

	callback = function(instance, renderer, game)
		instance:SetProperties(propTable)

		if _G.IsHeadless or not renderer then
			return instance
		end

		local particleMesh = adapter.lib.R3D_GenMeshQuad(1, 1, 1, 1, vector.create(0, 0, 1))
		local particleMaterial, albedoMap = createMaterial(instance.Texture)
		local emissionMap = nil
		local instanceFlags = bit32.bor(
			const.R3D_INSTANCE_POSITION,
			const.R3D_INSTANCE_ROTATION,
			const.R3D_INSTANCE_SCALE,
			const.R3D_INSTANCE_COLOR
		)
		local instanceBuffer = adapter.lib.R3D_LoadInstanceBuffer(instance.MaxParticles, instanceFlags)
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
				pcall(adapter.lib.R3D_UnloadInstanceBuffer, instanceBuffer)
			end
			instanceBuffer = adapter.lib.R3D_LoadInstanceBuffer(instance.MaxParticles, instanceFlags)
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
				pcall(adapter.lib.R3D_UnloadAlbedoMap, albedoMap)
				albedoMap = nil
			end
			if emissionMap then
				pcall(adapter.lib.R3D_UnloadEmissionMap, emissionMap)
				emissionMap = nil
			end
			local material, map = createMaterial(instance.Texture)
			particleMaterial = material
			albedoMap = map

			if type(instance.EmissionTexture) == "string" and instance.EmissionTexture ~= "" then
				local emissionTexture = zembed.AssetPath(instance.EmissionTexture)
				local ok, data = pcall(zune.fs.readFileSync, emissionTexture, true)
				if ok and data then
					local ext = lib.GetFileExtension(emissionTexture)
					local okLoad, map2 = pcall(
						adapter.lib.R3D_LoadEmissionMapFromMemory,
						ext,
						data,
						buffer.len(data),
						adapter.const.WHITE,
						1
					)
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

			local spread = instance.SpreadAngle
			local isFullSphere = spread and spread.X >= 180 and spread.Y >= 180
			if isFullSphere then
				-- true uniform sphere sampling
				local u = math.random() * 2 - 1
				local theta = math.random() * math.pi * 2
				local r = math.sqrt(1 - u * u)
				dir = Vector3.new(r * math.cos(theta), u, r * math.sin(theta))
			else
				dir = applySpread(baseDir, emitterCF:GetRightVector(), emitterCF:GetUpVector(), spread)
			end

			local lifetime = randomRange(instance.Lifetime, 1, 1)
			if lifetime <= 0 then
				return
			end

			local baseVel = dir * randomRange(instance.Speed, 0, 0)
			local inheritance = instance.VelocityInheritance or 0
			if inheritance ~= 0 then
				baseVel = baseVel + getEmitterVelocity(instance) * inheritance
			end

			local rawBodyID = nil
			if game then
				local ups = game:GetService("UnifiedPhysicsService")
				if ups and ups.CreateRawBody then
					rawBodyID = ups.CreateRawBody({
						Position = emitterCF.Position,
						Size = Vector3.new(1, 1, 1) * (instance.CollisionRadius or 0.5) * 2,
						Shape = Enum.PartType.Ball,
						CanCollide = instance.CollideParticles,
						Anchored = false,
						Mass = 1,
						AssemblyLinearVelocity = baseVel,
						Friction = instance.Friction,
						Restitution = instance.Restitution,
						CollisionGroup = instance.CollisionGroup or "Particles",
					})
				end
			end

			activeCount += 1
			particles[activeCount] = {
				bodyID = rawBodyID,
				life = lifetime,
				lifetime = lifetime,
				rotation = math.rad(randomRange(instance.Rotation, 0, 0)),
				rotSpeed = math.rad(randomRange(instance.RotSpeed, 0, 0)),
				axis = dir,
				-- Fallback physics if UPS is unavailable
				position = not rawBodyID and emitterCF.Position or nil,
				velocity = not rawBodyID and baseVel or nil,
			}
		end

		local function emit(count)
			for _ = 1, count do
				emitParticle()
			end
		end

		-- description: "Emits a specified amount of particles."
		-- args: "self: table, count: number"
		instance.Emit = function(_, count)
			emit(math.max(0, count or 1))
		end

		local function updateParticles(dt)
			local timeScale = instance.TimeScale or 1
			local scaledDt = dt * timeScale

			if instance.Enabled then
				emitAccumulator += (instance.Rate or 0) * dt -- Rate is typically real-time
				local emitCount = math.floor(emitAccumulator)
				if emitCount > 0 then
					emitAccumulator -= emitCount
					emit(emitCount)
				end
			end

			local accel = instance.Acceleration or Vector3.new(0, 0, 0)
			local drag = instance.Drag or 0
			local windAffectsDrag = instance.WindAffectsDrag or false

			local globalWind = Vector3.new(0, 0, 0)
			if windAffectsDrag and game then
				local workspace = game:GetService("Workspace")
				if workspace and type(workspace.GlobalWind) == "table" and workspace.GlobalWind.__type == "Vector3" then
					globalWind = workspace.GlobalWind
				end
			end

			local ups = game and game:GetService("UnifiedPhysicsService")

			local i = 1
			while i <= activeCount do
				local p = particles[i]
				p.life -= scaledDt
				if p.life <= 0 then
					if p.bodyID and ups and ups.DeleteRawBody then
						ups.DeleteRawBody(p.bodyID)
					end
					particles[i] = particles[activeCount]
					particles[activeCount] = nil
					activeCount -= 1
				else
					if p.bodyID then
						if ups and ups.ApplyForceToRawBody then
							if accel.X ~= 0 or accel.Y ~= 0 or accel.Z ~= 0 then
								ups.ApplyForceToRawBody(p.bodyID, accel) -- mass is 1
							end

							if drag > 0 then
								local vel = ups.GetRawBodyVelocity(p.bodyID)
								if
									windAffectsDrag and (globalWind.X ~= 0 or globalWind.Y ~= 0 or globalWind.Z ~= 0)
								then
									local force = (globalWind - vel) * (drag * 60)
									ups.ApplyForceToRawBody(p.bodyID, force)
								else
									local force = -vel * (drag * 60)
									ups.ApplyForceToRawBody(p.bodyID, force)
								end
							end
						end
					else
						-- Optional manual physics fallback
						local velocity = p.velocity
						local position = p.position

						-- Apply acceleration
						velocity = velocity + accel * scaledDt

						-- Apply drag
						if drag > 0 then
							if windAffectsDrag then
								velocity = velocity + (globalWind - velocity) * (drag * scaledDt)
							else
								velocity = velocity * (1 - drag * scaledDt)
							end
						end

						p.velocity = velocity
						p.position = position + velocity * scaledDt
					end

					p.rotation += p.rotSpeed * scaledDt
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

			local ups = game and game:GetService("UnifiedPhysicsService")

			local okMap = pcall(function()
				mappedPosition = adapter.lib.R3D_MapInstances(instanceBuffer, const.R3D_INSTANCE_POSITION)
				mappedRotation = adapter.lib.R3D_MapInstances(instanceBuffer, const.R3D_INSTANCE_ROTATION)
				mappedScale = adapter.lib.R3D_MapInstances(instanceBuffer, const.R3D_INSTANCE_SCALE)
				mappedColor = adapter.lib.R3D_MapInstances(instanceBuffer, const.R3D_INSTANCE_COLOR)
			end)

			local mappedFlags = bit32.bor(
				mappedPosition and const.R3D_INSTANCE_POSITION or 0,
				mappedRotation and const.R3D_INSTANCE_ROTATION or 0,
				mappedScale and const.R3D_INSTANCE_SCALE or 0,
				mappedColor and const.R3D_INSTANCE_COLOR or 0
			)

			-- description: "Writes instances."
			-- args: "writePosition: any, writeRotation: number, writeScale: number, writeColor: number"
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
						local pos = Vector3.zero
						if p.bodyID then
							if ups and ups.GetRawBodyPosition then
								pos = ups.GetRawBodyPosition(p.bodyID)
							end
						else
							pos = p.position or Vector3.zero
						end
						writePosition(pOffset, pos)
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
					writeInstances(
						writePositionMapped(mappedPosition),
						writeRotationMapped(mappedRotation),
						writeScaleMapped(mappedScale),
						writeColorMapped(mappedColor)
					)
				end)
				if okWrite then
					pcall(adapter.lib.R3D_UnmapInstances, instanceBuffer, instanceFlags)
					return
				end
			end

			if mappedFlags ~= 0 then
				pcall(adapter.lib.R3D_UnmapInstances, instanceBuffer, mappedFlags)
			end

			local positionBuffer = buffer.create(activeCount * 12)
			local rotationBuffer = buffer.create(activeCount * 16)
			local scaleBuffer = buffer.create(activeCount * 12)
			local colorBuffer = buffer.create(activeCount * 4)

			writeInstances(
				writePositionBuffer(positionBuffer),
				writeRotationBuffer(rotationBuffer),
				writeScaleBuffer(scaleBuffer),
				writeColorBuffer(colorBuffer)
			)

			pcall(function()
				adapter.lib.R3D_UploadInstances(
					instanceBuffer,
					const.R3D_INSTANCE_POSITION,
					0,
					activeCount,
					positionBuffer
				)
				adapter.lib.R3D_UploadInstances(
					instanceBuffer,
					const.R3D_INSTANCE_ROTATION,
					0,
					activeCount,
					rotationBuffer
				)
				adapter.lib.R3D_UploadInstances(instanceBuffer, const.R3D_INSTANCE_SCALE, 0, activeCount, scaleBuffer)
				adapter.lib.R3D_UploadInstances(instanceBuffer, const.R3D_INSTANCE_COLOR, 0, activeCount, colorBuffer)
			end)
		end

		-- description: "Updates flipbook."
		-- args: "dt: number"
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
						if flipbookFrame + flipbookDir >= frames or flipbookFrame + flipbookDir < 0 then
							flipbookDir = -flipbookDir
						end
						flipbookFrame = flipbookFrame + flipbookDir
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
			elseif
				property == "FlipbookColumns"
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
				pcall(adapter.lib.R3D_UnloadInstanceBuffer, instanceBuffer)
			end
			if particleMesh then
				pcall(adapter.lib.R3D_UnloadMesh, particleMesh)
			end
			if albedoMap then
				pcall(adapter.lib.R3D_UnloadAlbedoMap, albedoMap)
			end
			local ups = game and game:GetService("UnifiedPhysicsService")
			for i = 1, activeCount do
				if particles[i] and particles[i].bodyID and ups and ups.DeleteRawBody then
					pcall(ups.DeleteRawBody, particles[i].bodyID)
				end
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
