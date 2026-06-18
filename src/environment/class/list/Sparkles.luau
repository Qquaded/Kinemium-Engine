-- description: "Emits sparkles in 3D space."
local Color3 = require("@Color3")
local Vector2 = require("@Vector2")
local Vector3 = require("@Vector3")
local Enum = require("@EnumMap")
local NumberRange = require("@NumberRange")
local NumberSequence = require("@NumberSequence")
local NumberSequenceKeypoint = require("@NumberSequenceKeypoint")
local ColorSequence = require("@ColorSequence")
local ColorSequenceKeypoint = require("@ColorSequenceKeypoint")
local Instance = require("@Instance")
local ParticleEmitter = require("@ParticleEmitter")

local function ns(...)
	local kps = {}
	local args = { ... }
	for i = 1, #args, 2 do
		kps[#kps + 1] = NumberSequenceKeypoint.new(args[i], args[i + 1])
	end
	return NumberSequence.new(kps)
end

local function cs(...)
	local kps = {}
	local args = { ... }
	for i = 1, #args, 2 do
		kps[#kps + 1] = ColorSequenceKeypoint.new(args[i], args[i + 1])
	end
	return ColorSequence.new(kps)
end

local propTable = {
	Color = Color3.fromRGB(200, 180, 255),
	GlowColor = Color3.fromRGB(255, 255, 200),
	Radius = 3,
	Intensity = 1,
	Enabled = true,
	TimeScale = 1,
	Name = "Sparkles",
	BaseClass = "Instance",
}

return {
	class = "Sparkles",

	callback = function(instance, renderer, game)
		instance:SetProperties(propTable)

		local coreEmitter = Instance.new("ParticleEmitter")
		coreEmitter.Name = "__SparklesCore"
		coreEmitter.Parent = instance.Parent
		ParticleEmitter.callback(coreEmitter, renderer, game)

		local glintEmitter = Instance.new("ParticleEmitter")
		glintEmitter.Name = "__SparklesGlint"
		glintEmitter.Parent = instance.Parent
		ParticleEmitter.callback(glintEmitter, renderer, game)

		local dustEmitter = Instance.new("ParticleEmitter")
		dustEmitter.Name = "__SparklesDust"
		dustEmitter.Parent = instance.Parent
		ParticleEmitter.callback(dustEmitter, renderer, game)

		local trailEmitter = Instance.new("ParticleEmitter")
		trailEmitter.Name = "__SparklesTrail"
		trailEmitter.Parent = instance.Parent
		ParticleEmitter.callback(trailEmitter, renderer, game)

		local function updateCore()
			local r = math.max(0, instance.Radius or 3)
			local ts = math.max(0.001, instance.TimeScale or 1)
			local inten = math.max(0, instance.Intensity or 1)
			local col = instance.Color or Color3.fromRGB(200, 180, 255)
			local glow = instance.GlowColor or Color3.fromRGB(255, 255, 200)

			coreEmitter.Enabled = instance.Enabled
			coreEmitter.Rate = 18 * inten
			coreEmitter.Lifetime = NumberRange.new(0.6 / ts, 1.2 / ts)
			coreEmitter.Speed = NumberRange.new(r * 0.4 * inten, r * 1.2 * inten)
			coreEmitter.SpreadAngle = Vector2.new(180, 180)
			coreEmitter.EmissionDirection = Enum.NormalId.Top
			coreEmitter.BlendMode = Enum.ParticleBlendMode.Additive
			coreEmitter.TransparencyMode = Enum.ParticleTransparencyMode.Alpha
			coreEmitter.Texture = "./src/assets/images/sparkle.png"

			coreEmitter.Color = cs(0, glow, 0.3, col, 1, col)
			coreEmitter.Transparency = ns(0, 0, 0.4, 0.2, 0.8, 0.6, 1, 1)
			coreEmitter.Size = ns(0, r * 0.18, 0.2, r * 0.28, 0.7, r * 0.14, 1, 0)
			coreEmitter.EmissionColor = glow
			coreEmitter.EmissionEnergy = inten * 2.2
			coreEmitter.Drag = 1.5
			coreEmitter.Acceleration = Vector3.new(0, inten * 0.8, 0)
		end

		local function updateGlint()
			local r = math.max(0, instance.Radius or 3)
			local ts = math.max(0.001, instance.TimeScale or 1)
			local inten = math.max(0, instance.Intensity or 1)
			local col = instance.Color or Color3.fromRGB(200, 180, 255)
			local glow = instance.GlowColor or Color3.fromRGB(255, 255, 200)

			glintEmitter.Enabled = instance.Enabled
			glintEmitter.Rate = 8 * inten
			glintEmitter.Lifetime = NumberRange.new(0.3 / ts, 0.7 / ts)
			glintEmitter.Speed = NumberRange.new(r * 0.1 * inten, r * 0.5 * inten)
			glintEmitter.SpreadAngle = Vector2.new(180, 180)
			glintEmitter.EmissionDirection = Enum.NormalId.Top
			glintEmitter.BlendMode = Enum.ParticleBlendMode.Additive
			glintEmitter.TransparencyMode = Enum.ParticleTransparencyMode.Alpha
			glintEmitter.Texture = "./src/assets/images/sparkle.png"

			glintEmitter.Color = cs(0, Color3.new(1, 1, 1), 0.5, glow, 1, col)
			glintEmitter.Transparency = ns(0, 0.3, 0.2, 0, 0.6, 0.4, 1, 1)
			glintEmitter.Size = ns(0, r * 0.35, 0.15, r * 0.5, 0.5, r * 0.3, 1, 0)
			glintEmitter.EmissionColor = Color3.new(1, 1, 1)
			glintEmitter.EmissionEnergy = inten * 3.5
			glintEmitter.Drag = 3.0
			glintEmitter.Acceleration = Vector3.new(0, inten * 0.3, 0)
		end

		local function updateDust()
			local r = math.max(0, instance.Radius or 3)
			local ts = math.max(0.001, instance.TimeScale or 1)
			local inten = math.max(0, instance.Intensity or 1)
			local col = instance.Color or Color3.fromRGB(200, 180, 255)

			dustEmitter.Enabled = instance.Enabled
			dustEmitter.Rate = 12 * inten
			dustEmitter.Lifetime = NumberRange.new(1.0 / ts, 2.2 / ts)
			dustEmitter.Speed = NumberRange.new(r * 0.05 * inten, r * 0.3 * inten)
			dustEmitter.SpreadAngle = Vector2.new(180, 180)
			dustEmitter.EmissionDirection = Enum.NormalId.Top
			dustEmitter.BlendMode = Enum.ParticleBlendMode.Mix
			dustEmitter.TransparencyMode = Enum.ParticleTransparencyMode.Alpha
			dustEmitter.Texture = "./src/assets/images/sparkle.png"

			dustEmitter.Color = cs(0, Color3.new(1, 1, 1), 0.5, col, 1, col)
			dustEmitter.Transparency = ns(0, 0.6, 0.3, 0.4, 0.7, 0.7, 1, 1)
			dustEmitter.Size = ns(0, r * 0.08, 0.4, r * 0.12, 1, r * 0.04)
			dustEmitter.EmissionEnergy = 0
			dustEmitter.Drag = 2.0
			dustEmitter.Acceleration = Vector3.new(0, inten * 0.15, 0)
		end

		local function updateTrail()
			local r = math.max(0, instance.Radius or 3)
			local ts = math.max(0.001, instance.TimeScale or 1)
			local inten = math.max(0, instance.Intensity or 1)
			local col = instance.Color or Color3.fromRGB(200, 180, 255)
			local glow = instance.GlowColor or Color3.fromRGB(255, 255, 200)

			trailEmitter.Enabled = instance.Enabled
			trailEmitter.Rate = 25 * inten
			trailEmitter.Lifetime = NumberRange.new(0.4 / ts, 0.9 / ts)
			trailEmitter.Speed = NumberRange.new(r * 1.2 * inten, r * 3.0 * inten)
			trailEmitter.SpreadAngle = Vector2.new(180, 180)
			trailEmitter.EmissionDirection = Enum.NormalId.Top
			trailEmitter.BlendMode = Enum.ParticleBlendMode.Additive
			trailEmitter.TransparencyMode = Enum.ParticleTransparencyMode.Alpha
			trailEmitter.Texture = "./src/assets/images/sparkle.png"

			trailEmitter.Color = cs(0, glow, 0.3, col, 0.8, col, 1, Color3.new(0.3, 0.2, 0.5))
			trailEmitter.Transparency = ns(0, 0, 0.5, 0.4, 1, 1)
			trailEmitter.Size = ns(0, r * 0.06, 0.1, r * 0.09, 1, 0)
			trailEmitter.EmissionColor = glow
			trailEmitter.EmissionEnergy = inten * 1.8
			trailEmitter.Drag = 0.6
			trailEmitter.Acceleration = Vector3.new(0, inten * -1.5, 0)
		end

		updateCore()
		updateGlint()
		updateDust()
		updateTrail()

		instance.Changed:Connect(function(property)
			if property == "Parent" then
				coreEmitter.Parent = instance.Parent
				glintEmitter.Parent = instance.Parent
				dustEmitter.Parent = instance.Parent
				trailEmitter.Parent = instance.Parent
			else
				updateCore()
				updateGlint()
				updateDust()
				updateTrail()
			end
		end)

		instance.Destroying:Connect(function()
			coreEmitter:Destroy()
			glintEmitter:Destroy()
			dustEmitter:Destroy()
			trailEmitter:Destroy()
		end)

		return instance
	end,

	inherit = function(tble)
		for prop, val in pairs(propTable) do
			tble[prop] = val
		end
	end,
}
