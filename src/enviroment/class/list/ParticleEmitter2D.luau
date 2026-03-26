local Vector2 = require("@Vector2")
local Color3 = require("@Color3")
local Enum = require("@EnumMap")
local NumberSequence = require("@NumberSequence")
local NumberSequenceKeypoint = require("@NumberSequenceKeypoint")
local NumberRange = require("@NumberRange")
local ColorSequence = require("@ColorSequence")
local ColorSequenceKeypoint = require("@ColorSequenceKeypoint")
local raylib = require("@raylib")

local lib = raylib.lib
local structs = raylib.structs
local const = raylib.const

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

local function getSpreadAngle(spread)
	if type(spread) == "number" then
		return spread
	end
	if type(spread) == "table" and spread.__type == "Vector2" then
		return spread.X
	end
	return 0
end

local function resolveUIBlendMode(value)
	local v = value
	if type(v) == "table" and v.Value ~= nil then
		v = v.Value
	end
	if v == Enum.ParticleBlendMode.Additive.Value then
		return const.BlendMode.BLEND_ADDITIVE
	elseif v == Enum.ParticleBlendMode.Multiply.Value then
		return const.BlendMode.BLEND_MULTIPLIED
	elseif v == Enum.ParticleBlendMode.PremultipliedAlpha.Value then
		return const.BlendMode.BLEND_ALPHA_PREMULTIPLY
	end
	return const.BlendMode.BLEND_ALPHA
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

local function getEmissionDirection(direction)
	if direction == Enum.NormalId.Bottom then
		return Vector2.new(0, 1)
	elseif direction == Enum.NormalId.Left then
		return Vector2.new(-1, 0)
	elseif direction == Enum.NormalId.Right then
		return Vector2.new(1, 0)
	elseif direction == Enum.NormalId.Back then
		return Vector2.new(0, 1)
	elseif direction == Enum.NormalId.Front then
		return Vector2.new(0, -1)
	end
	return Vector2.new(0, -1)
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

local function getEnumValue(value, fallback)
	if type(value) == "number" then
		return value
	end
	if type(value) == "table" and value.Value ~= nil then
		return value.Value
	end
	return fallback
end

local function rotateVector2(vec, degrees)
	local angle = math.rad(degrees or 0)
	local cosA = math.cos(angle)
	local sinA = math.sin(angle)
	return Vector2.new(vec.X * cosA - vec.Y * sinA, vec.X * sinA + vec.Y * cosA)
end

local function randomSign()
	return math.random() * 2 - 1
end

local function randomPointInShape(shapeValue, shapeSize, shapeThickness, emitFromEdge, shapeRotation)
	local size = shapeSize or Vector2.new(0, 0)
	local thickness = math.max(0, shapeThickness or 0)

	local offset = Vector2.new(0, 0)
	if shapeValue == Enum.UIParticleEmitterShape.Box.Value then
		local halfX = size.X * 0.5
		local halfY = size.Y * 0.5
		if emitFromEdge and (halfX > 0 or halfY > 0) then
			local perimeter = (halfX * 2 + halfY * 2) * 2
			local pick = math.random() * perimeter
			if pick <= halfX * 2 then
				offset = Vector2.new(-halfX + pick, -halfY)
			elseif pick <= halfX * 2 + halfY * 2 then
				offset = Vector2.new(halfX, -halfY + (pick - halfX * 2))
			elseif pick <= halfX * 4 + halfY * 2 then
				offset = Vector2.new(halfX - (pick - (halfX * 2 + halfY * 2)), halfY)
			else
				offset = Vector2.new(-halfX, halfY - (pick - (halfX * 4 + halfY * 2)))
			end
		else
			offset = Vector2.new(randomSign() * halfX, randomSign() * halfY)
		end
	elseif shapeValue == Enum.UIParticleEmitterShape.Circle.Value then
		local radius = math.min(size.X, size.Y) * 0.5
		if radius <= 0 then
			offset = Vector2.new(0, 0)
		else
			local angle = math.random() * math.pi * 2
			local dist = radius
			if not emitFromEdge then
				dist = math.sqrt(math.random()) * radius
			end
			offset = Vector2.new(math.cos(angle) * dist, math.sin(angle) * dist)
		end
	elseif shapeValue == Enum.UIParticleEmitterShape.Ring.Value then
		local radius = math.min(size.X, size.Y) * 0.5
		if radius <= 0 then
			offset = Vector2.new(0, 0)
		else
			local inner = math.max(0, radius - thickness)
			local angle = math.random() * math.pi * 2
			local dist = radius
			if not emitFromEdge and thickness > 0 then
				local r2 = radius * radius
				local inner2 = inner * inner
				dist = math.sqrt(inner2 + math.random() * (r2 - inner2))
			end
			offset = Vector2.new(math.cos(angle) * dist, math.sin(angle) * dist)
		end
	else
		offset = Vector2.new(0, 0)
	end

	if shapeRotation and shapeRotation ~= 0 then
		offset = rotateVector2(offset, shapeRotation)
	end

	return offset
end

local propTable = {
	Enabled = true,
	Rate = 10,
	Lifetime = NumberRange.new(1, 2),
	Speed = NumberRange.new(30, 60),
	Rotation = NumberRange.new(0, 0),
	RotSpeed = NumberRange.new(0, 0),
	Size = Vector2.new(16, 16),
	SizeScale = buildDefaultSize(),
	SizeSpread = Vector2.new(0, 0),
	Shape = Enum.UIParticleEmitterShape.Point,
	ShapeSize = Vector2.new(100, 100),
	ShapeThickness = 0,
	ShapeRotation = 0,
	EmitFromEdge = false,
	AlignToVelocity = false,
	Color = buildDefaultColor(),
	Transparency = buildDefaultTransparency(),
	Acceleration = Vector2.new(0, 0),
	Drag = 0,
	EmissionDirection = Enum.NormalId.Top,
	SpreadAngle = Vector2.new(0, 0),
	Texture = "./src/assets/images/placeholder.png",
	BlendMode = Enum.ParticleBlendMode.Mix,
	UVScale = Vector2.new(1, 1),
	UVOffset = Vector2.new(0, 0),
	FlipbookColumns = 1,
	FlipbookRows = 1,
	FlipbookFramerate = 0,
	FlipbookMode = Enum.ParticleFlipbookMode.Loop,
	FlipbookStartRandom = false,
	MaxParticles = 256,
	LockedToParent = false,
	Position = Vector2.new(0, 0),
}

return {
	class = "UIParticleEmitter",

	callback = function(instance, renderer)
		instance:SetProperties(propTable)

		if _G.IsHeadless or not renderer then
			return instance
		end

		local texture = nil
		local particles = {}
		local activeCount = 0
		local emitAccumulator = 0
		local flipbookTime = 0
		local flipbookFrame = 0
		local flipbookDir = 1

		local function updateTexture()
			if texture then
				lib.UnloadTexture(texture)
				texture = nil
			end
			if type(instance.Texture) == "string" and instance.Texture ~= "" then
				texture = lib.LoadTexture(instance.Texture)
				if texture then
					lib.SetTextureFilter(texture, const.TextureFilter.TEXTURE_FILTER_TRILINEAR)
					lib.SetTextureWrap(texture, const.TextureWrap.TEXTURE_WRAP_REPEAT)
				end
			end
		end

		updateTexture()

		local function updateFlipbook(dt)
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
		end

		if instance.FlipbookStartRandom then
			local cols = math.max(1, tonumber(instance.FlipbookColumns) or 1)
			local rows = math.max(1, tonumber(instance.FlipbookRows) or 1)
			local frames = cols * rows
			if frames > 1 then
				flipbookFrame = math.random(0, frames - 1)
			end
		end

		local function emitParticle(origin)
			if activeCount >= instance.MaxParticles then
				return
			end

			local shapeValue = getEnumValue(instance.Shape, Enum.UIParticleEmitterShape.Point.Value)
			local shapeOffset = randomPointInShape(
				shapeValue,
				instance.ShapeSize,
				instance.ShapeThickness,
				instance.EmitFromEdge,
				instance.ShapeRotation
			)

			local baseDir = getEmissionDirection(instance.EmissionDirection)
			local angle = math.atan2(baseDir.Y, baseDir.X)
			local spread = getSpreadAngle(instance.SpreadAngle)
			if spread ~= 0 then
				angle += math.rad((math.random() * 2 - 1) * spread * 0.5)
			end

			local dir = Vector2.new(math.cos(angle), math.sin(angle))
			local lifetime = randomRange(instance.Lifetime, 1, 1)
			if lifetime <= 0 then
				return
			end

			local baseSize = instance.Size or Vector2.new(16, 16)
			local sizeSpread = instance.SizeSpread or Vector2.new(0, 0)
			local spawnSize = Vector2.new(
				math.max(0, baseSize.X + randomSign() * sizeSpread.X),
				math.max(0, baseSize.Y + randomSign() * sizeSpread.Y)
			)

			activeCount += 1
			particles[activeCount] = {
				position = origin + shapeOffset,
				velocity = dir * randomRange(instance.Speed, 0, 0),
				life = lifetime,
				lifetime = lifetime,
				rotation = math.rad(randomRange(instance.Rotation, 0, 0)),
				rotSpeed = math.rad(randomRange(instance.RotSpeed, 0, 0)),
				localOffset = shapeOffset,
				size = spawnSize,
			}
		end

		instance.Emit = function(_, count)
			local parent = instance.Parent
			local origin = Vector2.new(0, 0)
			if parent and parent.AbsolutePosition and parent.AbsoluteSize then
				origin = Vector2.new(
					parent.AbsolutePosition.X
						+ parent.AbsoluteSize.X * 0.5
						+ (instance.Position and instance.Position.X or 0),
					parent.AbsolutePosition.Y
						+ parent.AbsoluteSize.Y * 0.5
						+ (instance.Position and instance.Position.Y or 0)
				)
			end
			for _ = 1, math.max(0, count or 1) do
				emitParticle(origin)
			end
		end

		local function updateParticles(dt)
			local parent = instance.Parent
			local origin = Vector2.new(0, 0)
			if parent and parent.AbsolutePosition and parent.AbsoluteSize then
				origin = Vector2.new(
					parent.AbsolutePosition.X
						+ parent.AbsoluteSize.X * 0.5
						+ (instance.Position and instance.Position.X or 0),
					parent.AbsolutePosition.Y
						+ parent.AbsoluteSize.Y * 0.5
						+ (instance.Position and instance.Position.Y or 0)
				)
			end

			if instance.Enabled then
				emitAccumulator += (instance.Rate or 0) * dt
				local emitCount = math.floor(emitAccumulator)
				if emitCount > 0 then
					emitAccumulator -= emitCount
					for _ = 1, emitCount do
						emitParticle(origin)
					end
				end
			end

			local accel = instance.Acceleration or Vector2.new(0, 0)
			local drag = instance.Drag or 0

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
					if instance.LockedToParent then
						p.localOffset = p.localOffset + p.velocity * dt
						p.position = origin + p.localOffset
					else
						p.position = p.position + p.velocity * dt
					end
					p.rotation += p.rotSpeed * dt
					i += 1
				end
			end
		end

		local renderId = renderer.Pool.new("2d", function(_, object, _, _, _)
			if activeCount <= 0 or not texture then
				return
			end

			local blend = resolveUIBlendMode(instance.BlendMode)
			lib.BeginBlendMode(blend)

			local texW = buffer.readi32(texture, 4)
			local texH = buffer.readi32(texture, 8)
			local cols = math.max(1, tonumber(instance.FlipbookColumns) or 1)
			local rows = math.max(1, tonumber(instance.FlipbookRows) or 1)
			local frameW = texW / cols
			local frameH = texH / rows
			local col = flipbookFrame % cols
			local row = math.floor(flipbookFrame / cols)

			local baseScale = instance.UVScale or Vector2.new(1, 1)
			local baseOffset = instance.UVOffset or Vector2.new(0, 0)
			local srcW = frameW * baseScale.X
			local srcH = frameH * baseScale.Y
			local srcX = col * frameW + baseOffset.X * frameW
			local srcY = row * frameH + baseOffset.Y * frameH

			for idx = 1, activeCount do
				local p = particles[idx]
				local age = 1 - (p.life / p.lifetime)
				local t = clamp01(age)

				local sizeScale = evalNumberSequence(instance.SizeScale, t, 1)
				local size = Vector2.new(p.size.X * sizeScale, p.size.Y * sizeScale)
				local color = evalColorSequence(instance.Color, t, Color3.new(1, 1, 1))
				local transparency = evalNumberSequence(instance.Transparency, t, 0)

				local r, g, b = color:ToRGB()
				local alpha = math.floor(255 * (1 - clamp01(transparency)))

				local src = structs.Rectangle:new({
					x = srcX,
					y = srcY,
					width = srcW,
					height = srcH,
				})
				local dest = structs.Rectangle:new({
					x = p.position.X,
					y = p.position.Y,
					width = size.X,
					height = size.Y,
				})

				local origin = vector.create(size.X * 0.5, size.Y * 0.5, 0)
				local rotation = p.rotation
				if instance.AlignToVelocity then
					rotation += math.atan2(p.velocity.Y, p.velocity.X)
				end
				lib.DrawTexturePro(
					texture,
					src,
					dest,
					origin,
					math.deg(rotation),
					structs.Color:new({ r = r, g = g, b = b, a = alpha })
				)
			end

			lib.EndBlendMode()
		end)

		renderer.Hook.new("Renderstep", function(dt)
			updateParticles(dt)
			updateFlipbook(dt)
		end)

		instance.Changed:Connect(function(property)
			if property == "Texture" then
				updateTexture()
			elseif
				property == "FlipbookColumns"
				or property == "FlipbookRows"
				or property == "FlipbookFramerate"
				or property == "FlipbookMode"
			then
				updateFlipbook(0)
			end
		end)

		instance.Destroying:Connect(function()
			if renderId then
				renderer.Pool.Destroy(renderId)
			end
			if texture then
				lib.UnloadTexture(texture)
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
