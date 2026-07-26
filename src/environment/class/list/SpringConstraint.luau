-- description: "A constraint that simulates a spring between two attachments."
local _Vector3 = require("@Vector3")
local _signal = require("@Kinemium.signal")
local _state = require("@State")
local Color3 = require("@Color3")
local Vector3 = require("@Vector3")
local NetworkOwnership = require("@NetworkOwnership")

local adapter = require("@RaylibAdapter")
local rl = adapter.lib

local propTable = {
	Attachment0 = nil,
	Attachment1 = nil,
	Enabled = true,
	Visible = true,
	Color = Color3.fromRGB(255, 128, 0),

	Damping = 0.5,
	Stiffness = 10,
	Frequency = 2,
	SpringMode = 0,

	LimitsEnabled = false,
	MinLength = 0,
	MaxLength = 10,

	Coils = 4,
	SegmentsPerCoil = 24,
	Radius = 0.25,
	Thickness = 1,
}

return {
	class = "SpringConstraint",

	callback = function(instance, renderer, datamodel)
		local KinemiumPhysicsService = datamodel:GetService("UnifiedPhysicsService")
		instance:SetProperties(propTable)

		local _activeConstraint = nil

		local function cleanup()
			if _activeConstraint then
				KinemiumPhysicsService.jolt.lib.JPH_PhysicsSystem_RemoveConstraint(
					KinemiumPhysicsService.jolt.physicsSystem,
					_activeConstraint
				)
				_activeConstraint = nil
			end
		end

		local function rebuild()
			cleanup()

			if not instance.Enabled then
				return
			end
			if not instance.Attachment0 or not instance.Attachment1 then
				return
			end

			local att0 = instance.Attachment0
			local att1 = instance.Attachment1
			local part0 = att0.Parent
			local part1 = att1.Parent

			if not part0 or not part1 then
				return
			end

			if not NetworkOwnership.ShouldSimulateConstraintForMachine(instance, datamodel) then
				return
			end

			local bodyID0 = KinemiumPhysicsService.GetBody(part0)
			local bodyID1 = KinemiumPhysicsService.GetBody(part1)

			if not bodyID0 or not bodyID1 then
				task.defer(rebuild)
				return
			end

			local wPos0 = part0.CFrame * att0.Position
			local wPos1 = part1.CFrame * att1.Position

			local minL = instance.LimitsEnabled and instance.MinLength or 0
			local maxL = instance.LimitsEnabled and instance.MaxLength or 100000

			local freqOrStiff = instance.SpringMode == 0 and instance.Frequency or instance.Stiffness

			_activeConstraint = KinemiumPhysicsService.CreateSpring(
				part0,
				part1,
				wPos0,
				wPos1,
				minL,
				maxL,
				instance.SpringMode,
				freqOrStiff,
				instance.Damping
			)

			if _activeConstraint then
				print("[SpringConstraint] Constraint created successfully")
			else
				warn("[SpringConstraint] CreateSpring returned nil - bodies may not be registered yet")
				task.defer(rebuild)
			end
		end

		function instance:UpdateSpringSettings()
			if not _activeConstraint then
				return
			end
			local freqOrStiff = instance.SpringMode == 0 and instance.Frequency or instance.Stiffness
			KinemiumPhysicsService.SetSpringSettings(
				_activeConstraint,
				instance.SpringMode,
				freqOrStiff,
				instance.Damping
			)

			local att0 = instance.Attachment0
			local att1 = instance.Attachment1
			if att0 and att0.Parent then
				KinemiumPhysicsService.ActivatePart(att0.Parent)
			end
			if att1 and att1.Parent then
				KinemiumPhysicsService.ActivatePart(att1.Parent)
			end
		end

		-- description: "Updates spring limits."
		function instance:UpdateLimits()
			if not _activeConstraint then
				return
			end
			local minL = instance.LimitsEnabled and instance.MinLength or 0
			local maxL = instance.LimitsEnabled and instance.MaxLength or 100000
			KinemiumPhysicsService.SetSpringLimits(_activeConstraint, minL, maxL)
		end

		local function drawGizmo()
			if not instance.Visible then
				return
			end
			local att0 = instance.Attachment0
			local att1 = instance.Attachment1
			if not att0 or not att1 then
				return
			end

			local p0 = att0.Parent
			local p1 = att1.Parent
			if not p0 or not p1 then
				return
			end

			local wPos0 = p0.CFrame * att0.Position
			local wPos1 = p1.CFrame * att1.Position

			local color = instance.Color
			local rlColor =
				adapter.structs.Color:new({ r = color.R * 255, g = color.G * 255, b = color.B * 255, a = 255 })

			local diff = wPos1 - wPos0
			local length = diff:Magnitude()
			if length < 0.001 then
				return
			end

			local dir = diff:Unit()

			local up = Vector3.new(0, 1, 0)
			local dirDotUp = dir.X * up.X + dir.Y * up.Y + dir.Z * up.Z
			if math.abs(dirDotUp) > 0.99 then
				up = Vector3.new(1, 0, 0)
			end

			local perp1 =
				Vector3.new(dir.Y * up.Z - dir.Z * up.Y, dir.Z * up.X - dir.X * up.Z, dir.X * up.Y - dir.Y * up.X)
					:Unit()

			local perp2 = Vector3.new(
				dir.Y * perp1.Z - dir.Z * perp1.Y,
				dir.Z * perp1.X - dir.X * perp1.Z,
				dir.X * perp1.Y - dir.Y * perp1.X
			):Unit()

			local radius = instance.Radius
			local coils = instance.Coils -- Adjust number of coils based on length
			local segmentsPerCoil = instance.SegmentsPerCoil
			local totalSegments = coils * segmentsPerCoil

			local prevPos = wPos0
			for i = 1, totalSegments do
				local t = i / totalSegments

				local currentRadius = radius
				local easeMargin = 0.05
				if t < easeMargin then
					currentRadius = radius * (math.sin((t / easeMargin) * (math.pi / 2)))
				elseif t > 1 - easeMargin then
					currentRadius = radius * (math.sin(((1 - t) / easeMargin) * (math.pi / 2)))
				end

				local angle = t * coils * math.pi * 2
				local baseCenter = wPos0 + dir * (length * t)
				local offset = perp1 * (math.cos(angle) * currentRadius) + perp2 * (math.sin(angle) * currentRadius)

				local currentPos = baseCenter + offset

				adapter.DrawLineEx(
					vector.create(prevPos.X, prevPos.Y, prevPos.Z),
					vector.create(currentPos.X, currentPos.Y, currentPos.Z),
					instance.Thickness,
					rlColor
				)

				prevPos = currentPos
			end
		end

		instance.Changed:Connect(function(prop)
			if prop == "Attachment0" or prop == "Attachment1" or prop == "Enabled" then
				rebuild()
			elseif prop == "Damping" or prop == "Stiffness" or prop == "Frequency" or prop == "SpringMode" then
				instance:UpdateSpringSettings()
			elseif prop == "LimitsEnabled" or prop == "MinLength" or prop == "MaxLength" then
				instance:UpdateLimits()
			end
		end)

		instance.AncestryChanged:Connect(function(_, parent)
			if not parent then
				cleanup()
			end
		end)

		renderer.Pool.new("gizmo", function()
			drawGizmo()
		end)

		rebuild()

		return instance
	end,

	inherit = function(tble)
		for prop, val in pairs(propTable) do
			tble[prop] = val
		end
	end,
}
