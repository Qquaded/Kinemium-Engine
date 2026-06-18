-- description: "Creates an explosion particle in 3d space."
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
	-- Visual
	Color = Color3.fromRGB(255, 160, 40), -- core fireball color
	SmokeColor = Color3.fromRGB(60, 55, 50), -- dark billowing smoke
	BlastRadius = 5, -- scales all emitter rates/sizes
	Intensity = 1, -- multiplier for speed / heat
	-- Lifecycle
	Enabled = true,
	TimeScale = 1,
	-- Meta
	Name = "Explosion",
	BaseClass = "Instance",
}

--  Module

return {
	class = "Explosion",

	callback = function(instance, renderer, game)
		instance:SetProperties(propTable)

		local flashEmitter = Instance.new("ParticleEmitter")
		flashEmitter.Name = "__ExplosionFlash"
		flashEmitter.Parent = instance.Parent
		ParticleEmitter.callback(flashEmitter, renderer, game)

		local fireEmitter = Instance.new("ParticleEmitter")
		fireEmitter.Name = "__ExplosionFire"
		fireEmitter.Parent = instance.Parent
		ParticleEmitter.callback(fireEmitter, renderer, game)

		local smokeEmitter = Instance.new("ParticleEmitter")
		smokeEmitter.Name = "__ExplosionSmoke"
		smokeEmitter.Parent = instance.Parent
		ParticleEmitter.callback(smokeEmitter, renderer, game)

		local sparkEmitter = Instance.new("ParticleEmitter")
		sparkEmitter.Name = "__ExplosionSparks"
		sparkEmitter.Parent = instance.Parent
		ParticleEmitter.callback(sparkEmitter, renderer, game)

		--  Update helpers

		local function updateFlash()
			local r = math.max(0, instance.BlastRadius or 5)
			local ts = math.max(0.001, instance.TimeScale or 1)
			local inten = math.max(0, instance.Intensity or 1)
			local col = instance.Color or Color3.fromRGB(255, 160, 40)

			flashEmitter.Enabled = instance.Enabled
			flashEmitter.Rate = 0 -- burst-only via Emit()
			flashEmitter.Lifetime = NumberRange.new(0.08 / ts, 0.18 / ts)
			flashEmitter.Speed = NumberRange.new(0, r * 0.3 * inten)
			flashEmitter.SpreadAngle = Vector2.new(180, 180)
			flashEmitter.EmissionDirection = Enum.NormalId.Top
			flashEmitter.BlendMode = Enum.ParticleBlendMode.Additive
			flashEmitter.TransparencyMode = Enum.ParticleTransparencyMode.Alpha
			flashEmitter.Texture = "./src/assets/images/shadow_circle.png"

			flashEmitter.Color = cs(0, Color3.new(1, 1, 0.85), 0.4, col, 1, Color3.new(0.6, 0.1, 0))
			flashEmitter.Transparency = ns(0, 0, 0.3, 0.2, 1, 1)
			flashEmitter.Size = ns(0, r * 0.6, 0.5, r * 1.4, 1, r * 0.2)
			flashEmitter.EmissionColor = Color3.new(1, 0.95, 0.6)
			flashEmitter.EmissionEnergy = inten * 3.5
			flashEmitter.Drag = 3
			flashEmitter.Acceleration = Vector3.new(0, 0, 0)
		end

		local function updateFire()
			local r = math.max(0, instance.BlastRadius or 5)
			local ts = math.max(0.001, instance.TimeScale or 1)
			local inten = math.max(0, instance.Intensity or 1)
			local col = instance.Color or Color3.fromRGB(255, 160, 40)

			fireEmitter.Enabled = instance.Enabled
			fireEmitter.Rate = 0 -- burst only
			fireEmitter.Lifetime = NumberRange.new(0.4 / ts, 0.9 / ts)
			fireEmitter.Speed = NumberRange.new(r * 0.5 * inten, r * 1.8 * inten)
			fireEmitter.SpreadAngle = Vector2.new(180, 180)
			fireEmitter.EmissionDirection = Enum.NormalId.Top
			fireEmitter.BlendMode = Enum.ParticleBlendMode.Additive
			fireEmitter.TransparencyMode = Enum.ParticleTransparencyMode.Alpha
			fireEmitter.Texture = "./src/assets/images/shadow_circle.png"

			fireEmitter.Color = cs(
				0,
				Color3.new(1, 0.95, 0.5),
				0.25,
				col,
				0.7,
				Color3.fromRGB(180, 40, 5),
				1,
				Color3.new(0.05, 0.03, 0.02)
			)
			fireEmitter.Transparency = ns(0, 0, 0.55, 0.3, 1, 1)
			fireEmitter.Size = ns(0, r * 0.5, 0.3, r * 1.1, 1, r * 0.05)
			fireEmitter.EmissionColor = col
			fireEmitter.EmissionEnergy = inten * 1.8
			fireEmitter.Drag = 1.2
			-- slight upward buoyancy
			fireEmitter.Acceleration = Vector3.new(0, inten * 4, 0)
		end

		local function updateSmoke()
			local r = math.max(0, instance.BlastRadius or 5)
			local ts = math.max(0.001, instance.TimeScale or 1)
			local inten = math.max(0, instance.Intensity or 1)
			local col = instance.SmokeColor or Color3.fromRGB(60, 55, 50)

			smokeEmitter.Enabled = instance.Enabled
			smokeEmitter.Rate = 0 -- burst only
			smokeEmitter.Lifetime = NumberRange.new(1.5 / ts, 3.5 / ts)
			smokeEmitter.Speed = NumberRange.new(r * 0.3 * inten, r * 0.9 * inten)
			smokeEmitter.SpreadAngle = Vector2.new(140, 140)
			smokeEmitter.EmissionDirection = Enum.NormalId.Top
			smokeEmitter.BlendMode = Enum.ParticleBlendMode.Mix
			smokeEmitter.TransparencyMode = Enum.ParticleTransparencyMode.Alpha
			smokeEmitter.Texture = "./src/assets/images/shadow_circle.png"

			smokeEmitter.Color = cs(0, Color3.new(0.5, 0.45, 0.35), 0.4, col, 1, Color3.new(0.08, 0.07, 0.07))
			smokeEmitter.Transparency = ns(0, 0.45, 0.5, 0.65, 1, 1)
			smokeEmitter.Size = ns(0, r * 0.6, 0.4, r * 1.8, 1, r * 3.5)
			smokeEmitter.EmissionEnergy = 0
			smokeEmitter.Drag = 0.5
			smokeEmitter.Acceleration = Vector3.new(0, inten * 1.5, 0)
		end

		local function updateSparks()
			local r = math.max(0, instance.BlastRadius or 5)
			local ts = math.max(0.001, instance.TimeScale or 1)
			local inten = math.max(0, instance.Intensity or 1)

			sparkEmitter.Enabled = instance.Enabled
			sparkEmitter.Rate = 0 -- burst only
			sparkEmitter.Lifetime = NumberRange.new(0.6 / ts, 1.4 / ts)
			sparkEmitter.Speed = NumberRange.new(r * 1.5 * inten, r * 4.0 * inten)
			sparkEmitter.SpreadAngle = Vector2.new(180, 180)
			sparkEmitter.EmissionDirection = Enum.NormalId.Top
			sparkEmitter.CollideParticles = true
			sparkEmitter.BlendMode = Enum.ParticleBlendMode.Additive
			sparkEmitter.TransparencyMode = Enum.ParticleTransparencyMode.Alpha
			sparkEmitter.Texture = "./src/assets/images/shadow_circle.png"

			sparkEmitter.Color =
				cs(0, Color3.new(1, 1, 0.7), 0.4, Color3.fromRGB(255, 120, 20), 1, Color3.new(0.1, 0.05, 0.02))
			sparkEmitter.Transparency = ns(0, 0, 0.7, 0.5, 1, 1)
			-- thin elongated sparks
			sparkEmitter.Size = ns(0, r * 0.07, 0.1, r * 0.12, 1, 0)
			sparkEmitter.EmissionColor = Color3.new(1, 0.8, 0.3)
			sparkEmitter.EmissionEnergy = inten * 2.5
			-- gravity pulls sparks down
			sparkEmitter.Drag = 0.4
			sparkEmitter.Acceleration = Vector3.new(0, -inten * 9.8, 0)
			sparkEmitter.Restitution = 0.35
		end

		updateFlash()
		updateFire()
		updateSmoke()
		updateSparks()

		local function doBurst()
			local r = math.max(1, instance.BlastRadius or 5)
			flashEmitter:Emit(math.ceil(r * 1))
			fireEmitter:Emit(math.ceil(r * 4))
			smokeEmitter:Emit(math.ceil(r * 3))
			sparkEmitter:Emit(math.ceil(r * 6))
		end

		-- description: "Explodes the object with a radius."
		-- args: "_: any"
		instance.Explode = function(_)
			doBurst()
		end

		if instance.Enabled then
			doBurst()
		end

		instance.Changed:Connect(function(property)
			if property == "Parent" then
				flashEmitter.Parent = instance.Parent
				fireEmitter.Parent = instance.Parent
				smokeEmitter.Parent = instance.Parent
				sparkEmitter.Parent = instance.Parent
			elseif property == "Enabled" and instance.Enabled then
				updateFlash()
				updateFire()
				updateSmoke()
				updateSparks()
				doBurst()
			else
				updateFlash()
				updateFire()
				updateSmoke()
				updateSparks()
			end
		end)

		instance.Destroying:Connect(function()
			flashEmitter:Destroy()
			fireEmitter:Destroy()
			smokeEmitter:Destroy()
			sparkEmitter:Destroy()
		end)

		return instance
	end,

	inherit = function(tble)
		for prop, val in pairs(propTable) do
			tble[prop] = val
		end
	end,
}
