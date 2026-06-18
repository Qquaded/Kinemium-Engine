-- description: "Creates a Fire particle in 3d space."
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

-- description: "Builds color sequence."
-- args: "primary: number, secondary: number"
local function buildColorSequence(primary, secondary)
	return ColorSequence.new({
		ColorSequenceKeypoint.new(0, secondary),
		ColorSequenceKeypoint.new(0.45, primary),
		ColorSequenceKeypoint.new(1, Color3.new(0.15, 0.02, 0)),
	})
end

-- description: "Builds size sequence."
-- args: "size: number"
local function buildSizeSequence(size)
	local scale = math.max(0, size)
	return NumberSequence.new({
		NumberSequenceKeypoint.new(0, scale * 0.35),
		NumberSequenceKeypoint.new(0.35, scale),
		NumberSequenceKeypoint.new(1, 0),
	})
end

-- description: "Builds transparency sequence."
-- args: "modifier: number"
local function buildTransparencySequence(modifier)
	local alpha = math.clamp(modifier or 0, 0, 1)
	return NumberSequence.new({
		NumberSequenceKeypoint.new(0, alpha),
		NumberSequenceKeypoint.new(0.75, alpha + (1 - alpha) * 0.35),
		NumberSequenceKeypoint.new(1, 1),
	})
end

local propTable = {
	Color = Color3.new(1, 1, 1),
	Enabled = true,
	Heat = 30,
	LocalTransparencyModifier = 0,
	SecondaryColor = Color3.fromRGB(255, 133, 0),
	Size = 5,
	TimeScale = 1,
	Name = "Fire",
	BaseClass = "Instance",
}

return {
	class = "Fire",

	-- description: "Initializes the Fire instance."
	-- args: "instance: table, renderer: number, game: table"
	-- returns: "table"
	callback = function(instance, renderer, game)
		instance:SetProperties(propTable)

		local emitter = Instance.new("ParticleEmitter")
		emitter.Name = "__FireEmitter"
		emitter.Parent = instance.Parent
		ParticleEmitter.callback(emitter, renderer, game)

		local smokeEmitter = Instance.new("ParticleEmitter")
		smokeEmitter.Name = "__FireSmokeEmitter"
		smokeEmitter.Parent = instance.Parent
		ParticleEmitter.callback(smokeEmitter, renderer, game)

		-- description: "Updates emitter."
		local function updateEmitter()
			local size = math.max(0, instance.Size or 0)
			local heat = math.max(0, instance.Heat or 0)
			local timeScale = math.max(0, instance.TimeScale or 0)

			emitter.Enabled = instance.Enabled and size > 0 and timeScale > 0
			emitter.Rate = size * 18 * timeScale
			emitter.Lifetime = NumberRange.new(0.35 / math.max(timeScale, 0.001), 0.8 / math.max(timeScale, 0.001))
			emitter.Speed = NumberRange.new(heat * 0.45 * timeScale, math.max(heat, 0.1) * timeScale)
			emitter.Size = buildSizeSequence(size)
			emitter.Color = buildColorSequence(instance.Color, instance.SecondaryColor)
			emitter.Transparency = buildTransparencySequence(instance.LocalTransparencyModifier)
			emitter.Acceleration = Vector3.new(0, heat * 0.5, 0)
			emitter.Drag = 1.5
			emitter.EmissionDirection = Enum.NormalId.Top
			emitter.Texture = "./src/assets/images/shadow_circle.png"
			emitter.SpreadAngle = Vector2.new(35, 35)
			emitter.BlendMode = Enum.ParticleBlendMode.Additive
			emitter.EmissionColor = instance.SecondaryColor
			emitter.TransparencyMode = Enum.ParticleTransparencyMode.Alpha
			emitter.EmissionEnergy = math.max(0, heat * 0.15)
			emitter.LockedToPart = false
		end

		-- description: "Updates smoke emitter."
		local function updateSmokeEmitter()
			local size = math.max(0, instance.Size or 0)
			local heat = math.max(0, instance.Heat or 0)
			local timeScale = math.max(0, instance.TimeScale or 0)

			smokeEmitter.Enabled = instance.Enabled and size > 0 and timeScale > 0
			smokeEmitter.Rate = size * 6 * timeScale
			smokeEmitter.Lifetime = NumberRange.new(1.2 / math.max(timeScale, 0.001), 2.5 / math.max(timeScale, 0.001))
			smokeEmitter.Speed = NumberRange.new(heat * 0.2 * timeScale, math.max(heat, 0.1) * 0.6 * timeScale)
			smokeEmitter.Size = NumberSequence.new({
				NumberSequenceKeypoint.new(0, size * 0.4),
				NumberSequenceKeypoint.new(0.5, size * 1.2),
				NumberSequenceKeypoint.new(1, size * 2.0),
			})
			smokeEmitter.Texture = "./src/assets/images/shadow_circle.png"

			smokeEmitter.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.new(0.25, 0.20, 0.18)),
				ColorSequenceKeypoint.new(0.5, Color3.new(0.15, 0.12, 0.10)),
				ColorSequenceKeypoint.new(1, Color3.new(0.05, 0.04, 0.04)),
			})
			smokeEmitter.Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.6),
				NumberSequenceKeypoint.new(0.5, 0.75),
				NumberSequenceKeypoint.new(1, 1),
			})
			smokeEmitter.Acceleration = Vector3.new(0, heat * 0.15 + 0.5, 0)
			smokeEmitter.Drag = 0.8
			smokeEmitter.EmissionDirection = Enum.NormalId.Top
			smokeEmitter.SpreadAngle = Vector2.new(20, 20)
			smokeEmitter.BlendMode = Enum.ParticleBlendMode.Mix -- NOT additive
			smokeEmitter.EmissionEnergy = 0
			smokeEmitter.LockedToPart = true
		end

		updateEmitter()
		updateSmokeEmitter()

		instance.Changed:Connect(function(property)
			if property == "Parent" then
				emitter.Parent = instance.Parent
			else
				updateEmitter()
			end
		end)

		instance.Destroying:Connect(function()
			emitter:Destroy()
		end)

		return instance
	end,

	-- description: "Inherits the properties of the Fire class."
	-- args: "tble: table"
	inherit = function(tble)
		for prop, val in pairs(propTable) do
			tble[prop] = val
		end
	end,
}
