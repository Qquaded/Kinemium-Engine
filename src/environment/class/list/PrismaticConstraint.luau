-- description: "Constrains two attachments to slide along a single axis."
local _Vector3 = require("@Vector3")
local Enum = require("@EnumMap")
local _signal = require("@Kinemium.signal")
local _state = require("@State")
local Color3 = require("@Color3")
local NetworkOwnership = require("@NetworkOwnership")

local adapter = require("@RaylibAdapter")
local rl = adapter.lib

local propTable = {
	Attachment0 = nil,
	Attachment1 = nil,
	Enabled = true,
	Visible = true,
	Color = Color3.fromRGB(0, 255, 255), -- Cyan for prismatic

	ActuatorType = Enum.ActuatorType.None,
	Velocity = 2, -- m/s
	MotorMaxForce = 10000,
	ServoMaxForce = 10000,
	TargetPosition = 0,

	LimitsEnabled = false,
	LowerLimit = -5,
	UpperLimit = 5,
	Restitution = 0,
}

return {
	class = "PrismaticConstraint",

	-- description: "Initializes the PrismaticConstraint instance."
	-- args: "instance: table, renderer: number, datamodel: table"
	-- returns: "table"
	callback = function(instance, renderer, datamodel)
		local KinemiumPhysicsService = datamodel:GetService("UnifiedPhysicsService")
		instance:SetProperties(propTable)

		local _activeConstraint = nil

		-- description: "Cleans up the resources."
		local function cleanup()
			if _activeConstraint then
				KinemiumPhysicsService.jolt.lib.JPH_PhysicsSystem_RemoveConstraint(
					KinemiumPhysicsService.jolt.physicsSystem,
					_activeConstraint
				)
				_activeConstraint = nil
			end
		end

		-- description: "Rebuilds the state."
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

			-- Wait for bodies to exist
			local bodyID0 = KinemiumPhysicsService.GetBody(part0)
			local bodyID1 = KinemiumPhysicsService.GetBody(part1)

			if not bodyID0 or not bodyID1 then
				task.defer(rebuild)
				return
			end

			-- Convert attachments to World Space
			local wPos0 = part0.CFrame * att0.Position
			local wAxis0 = part0.CFrame:VectorToWorldSpace(att0.Axis):Unit()
			local wNormal0 = part0.CFrame:VectorToWorldSpace(att0.SecondaryAxis):Unit()

			local wPos1 = part1.CFrame * att1.Position
			local wAxis1 = part1.CFrame:VectorToWorldSpace(att1.Axis):Unit()
			local wNormal1 = part1.CFrame:VectorToWorldSpace(att1.SecondaryAxis):Unit()

			_activeConstraint =
				KinemiumPhysicsService.CreateSlider(part0, part1, wPos0, wAxis0, wNormal0, wPos1, wAxis1, wNormal1)

			if _activeConstraint then
				-- Initial state sync
				instance:UpdateActuator()
				instance:UpdateLimits()

				-- Re-apply motor state when a connected body becomes dynamic.
				-- description: "Ons part changed."
				-- args: "property: number"
				local function onPartChanged(property)
					if property == "Anchored" then
						task.defer(function()
							instance:UpdateActuator()
						end)
					end
				end
				if part0 then
					part0.Changed:Connect(onPartChanged)
				end
				if part1 then
					part1.Changed:Connect(onPartChanged)
				end
			else
				warn("[PrismaticConstraint] CreateSlider returned nil")
				task.defer(rebuild)
			end
		end

		-- description: "Updates actuator."
		function instance:UpdateActuator()
			if not _activeConstraint then
				return
			end

			local actuator = instance.ActuatorType
			if actuator == Enum.ActuatorType.None then
				KinemiumPhysicsService.SetSliderMotorState(_activeConstraint, 0) -- Off
			elseif actuator == Enum.ActuatorType.Motor then
				KinemiumPhysicsService.SetSliderMotorSettings(_activeConstraint, instance.MotorMaxForce)
				KinemiumPhysicsService.SetSliderMotorState(_activeConstraint, 1) -- Velocity
				KinemiumPhysicsService.SetSliderTargetVelocity(_activeConstraint, instance.Velocity)
			elseif actuator == Enum.ActuatorType.Servo then
				KinemiumPhysicsService.SetSliderMotorSettings(_activeConstraint, instance.ServoMaxForce)
				KinemiumPhysicsService.SetSliderMotorState(_activeConstraint, 2) -- Position
				KinemiumPhysicsService.SetSliderTargetPosition(_activeConstraint, instance.TargetPosition)
			end

			-- Force activation to ensure motor starts immediately
			local att0 = instance.Attachment0
			local att1 = instance.Attachment1
			if att0 and att0.Parent then
				KinemiumPhysicsService.ActivatePart(att0.Parent)
			end
			if att1 and att1.Parent then
				KinemiumPhysicsService.ActivatePart(att1.Parent)
			end
		end

		-- description: "Updates limits."
		function instance:UpdateLimits()
			if not _activeConstraint then
				return
			end
			if instance.LimitsEnabled then
				KinemiumPhysicsService.SetSliderLimits(_activeConstraint, instance.LowerLimit, instance.UpperLimit)
			else
				-- Huge range if disabled
				KinemiumPhysicsService.SetSliderLimits(_activeConstraint, -1e6, 1e6)
			end
		end

		-- description: "Draws the visual representation."
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

			-- Center of slider axis
			local wPos0 = p0.CFrame * att0.Position
			local wAxis0 = p0.CFrame:VectorToWorldSpace(att0.Axis):Unit()

			local color = instance.Color
			-- description: "Tos raylib color."
			-- args: "c: any, a: number"
			local function toRaylibColor(c, a)
				return adapter.structs.Color:new({ r = c.R * 255, g = c.G * 255, b = c.B * 255, a = a or 255 })
			end

			local mainColor = toRaylibColor(color)
			local secondaryColor = toRaylibColor(Color3.fromRGB(150, 150, 150), 100)
			local limitColor = toRaylibColor(Color3.fromRGB(255, 50, 50), 150)

			-- 1. Draw Axis Line
			local axisLen = 10.0
			local axisStart = wPos0 - (wAxis0 * (axisLen / 2))
			local axisEnd = wPos0 + (wAxis0 * (axisLen / 2))
			adapter.DrawLine3D(
				vector.create(axisStart.X, axisStart.Y, axisStart.Z),
				vector.create(axisEnd.X, axisEnd.Y, axisEnd.Z),
				secondaryColor
			)

			-- 2. Draw Attachment Points
			adapter.DrawSphere(vector.create(wPos0.X, wPos0.Y, wPos0.Z), 0.05, mainColor)

			-- 3. Draw Current Position (if active)
			local currentPos = 0
			if _activeConstraint then
				currentPos = KinemiumPhysicsService.GetSliderPosition(_activeConstraint)
			end
			local relativePos = wPos0 + (wAxis0 * currentPos)
			adapter.DrawSphere(vector.create(relativePos.X, relativePos.Y, relativePos.Z), 0.08, mainColor)

			-- 4. Draw Limits
			if instance.LimitsEnabled then
				local lowPos = wPos0 + (wAxis0 * instance.LowerLimit)
				local highPos = wPos0 + (wAxis0 * instance.UpperLimit)

				-- Draw ticks at limits
				local perp = (math.abs(wAxis0.X) < 0.9 and _Vector3.new(1, 0, 0) or _Vector3.new(0, 1, 0))
					:Cross(wAxis0)
					:Unit()
				local tickLen = 0.2

				-- description: "Draws the visual representation."
				-- args: "center: number"
				local function drawTick(center)
					local s = center - (perp * tickLen)
					local e = center + (perp * tickLen)
					adapter.DrawLine3D(vector.create(s.X, s.Y, s.Z), vector.create(e.X, e.Y, e.Z), limitColor)
				end

				drawTick(lowPos)
				drawTick(highPos)

				-- Draw segment between limits
				adapter.DrawLine3D(
					vector.create(lowPos.X, lowPos.Y, lowPos.Z),
					vector.create(highPos.X, highPos.Y, highPos.Z),
					limitColor
				)
			end
		end

		instance.Changed:Connect(function(prop)
			if prop == "Attachment0" or prop == "Attachment1" or prop == "Enabled" then
				rebuild()
			elseif
				prop == "ActuatorType"
				or prop == "Velocity"
				or prop == "TargetPosition"
				or prop == "MotorMaxForce"
				or prop == "ServoMaxForce"
			then
				instance:UpdateActuator()
			elseif prop == "LimitsEnabled" or prop == "LowerLimit" or prop == "UpperLimit" then
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

	-- description: "Inherits the properties of the PrismaticConstraint class."
	-- args: "tble: table"
	inherit = function(tble)
		for prop, val in pairs(propTable) do
			tble[prop] = val
		end
	end,
}
