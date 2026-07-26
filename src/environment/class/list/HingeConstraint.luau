-- description: "Creates a hinge joint that allows rotation around one axis, like a door or wheel."
local _Vector3 = require("@Vector3")
local Enum = require("@EnumMap")
local _signal = require("@Kinemium.signal")
local _state = require("@State")
local Color3 = require("@Color3")
local CFrame = require("@CFrame")
local NetworkOwnership = require("@NetworkOwnership")

local adapter = require("@RaylibAdapter")
local rl = adapter.lib

local propTable = {
	Attachment0 = nil,
	Attachment1 = nil,
	Enabled = true,
	Visible = true,
	Color = Color3.fromRGB(255, 255, 0),

	ActuatorType = Enum.ActuatorType.None,
	AngularVelocity = 2, -- rad/s
	MotorMaxAcceleration = 100,
	MotorMaxTorque = 10000,
	ServoMaxTorque = 10000,
	TargetAngle = 0,

	LimitsEnabled = false,
	LowerAngle = -45,
	UpperAngle = 45,
	Restitution = 0,

	Offset = CFrame.new(0, 0, 0),
}

return {
	class = "HingeConstraint",

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

			-- Attachment1 is offset by the constraint's Offset property
			local offsetCF = instance.Offset
			local wPos1 = part1.CFrame * (att1.Position + offsetCF.Position)
			local wAxis1 = part1.CFrame:VectorToWorldSpace(offsetCF:VectorToWorldSpace(att1.Axis)):Unit()
			local wNormal1 = part1.CFrame:VectorToWorldSpace(offsetCF:VectorToWorldSpace(att1.SecondaryAxis)):Unit()

			_activeConstraint = KinemiumPhysicsService.CreateHinge(
				part0,
				part1,
				wPos0,
				wAxis0,
				wNormal0,
				wPos1,
				wAxis1,
				wNormal1,
				instance.MotorMaxTorque
			)

			if _activeConstraint then
				-- Initial state sync
				instance:UpdateActuator()
				instance:UpdateLimits()

				-- Re-apply motor state when a connected body becomes dynamic.
				-- Jolt silently ignores motor state on static bodies; once unanchored
				-- we must push the motor settings + state again.
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
				warn("[HingeConstraint] CreateHinge returned nil - bodies may not be registered yet")
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
				KinemiumPhysicsService.SetHingeMotorState(_activeConstraint, 0) -- Off
			elseif actuator == Enum.ActuatorType.Motor then
				-- Settings MUST be applied before state for Jolt motor to work
				KinemiumPhysicsService.SetHingeMotorSettings(_activeConstraint, instance.MotorMaxTorque)
				KinemiumPhysicsService.SetHingeMotorState(_activeConstraint, 1) -- Velocity
				KinemiumPhysicsService.SetHingeTargetVelocity(_activeConstraint, instance.AngularVelocity)
			elseif actuator == Enum.ActuatorType.Servo then
				KinemiumPhysicsService.SetHingeMotorSettings(_activeConstraint, instance.ServoMaxTorque)
				KinemiumPhysicsService.SetHingeMotorState(_activeConstraint, 2) -- Position
				KinemiumPhysicsService.SetHingeTargetAngle(_activeConstraint, math.rad(instance.TargetAngle))
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
				KinemiumPhysicsService.SetHingeLimits(
					_activeConstraint,
					math.rad(instance.LowerAngle),
					math.rad(instance.UpperAngle)
				)
			else
				-- Jolt "no limits" is usually -PI to PI or similar, but specifically disabling it in settings is best.
				-- For now, if disabled, we set a huge range.
				KinemiumPhysicsService.SetHingeLimits(_activeConstraint, -math.pi * 10, math.pi * 10)
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

			-- World coordinates
			local wPos0 = p0.CFrame * att0.Position
			local wAxis0 = p0.CFrame:VectorToWorldSpace(att0.Axis):Unit()
			local wNormal0 = p0.CFrame:VectorToWorldSpace(att0.SecondaryAxis):Unit()
			local wPerp0 = wAxis0:Cross(wNormal0):Unit() -- The other axis in the plane

			local color = instance.Color
			-- description: "Tos raylib color."
			-- args: "c: any, a: number"
			local function toRaylibColor(c, a)
				return adapter.structs.Color:new({ r = c.R * 255, g = c.G * 255, b = c.B * 255, a = a or 255 })
			end

			local mainColor = toRaylibColor(color)
			local secondaryColor = toRaylibColor(Color3.fromRGB(150, 150, 150), 100) -- Faded grey
			local limitColor = toRaylibColor(Color3.fromRGB(255, 50, 50), 150) -- Transparent red

			-- 1. Draw Central Axis (Cylinder)
			local axisLen = 1.0
			local axisStart = wPos0 - (wAxis0 * (axisLen / 2))
			local axisEnd = wPos0 + (wAxis0 * (axisLen / 2))
			adapter.DrawCylinderEx(
				vector.create(axisStart.X, axisStart.Y, axisStart.Z),
				vector.create(axisEnd.X, axisEnd.Y, axisEnd.Z),
				0.02,
				0.02,
				8,
				mainColor
			)

			-- 2. Draw Pivot Sphere
			adapter.DrawSphere(vector.create(wPos0.X, wPos0.Y, wPos0.Z), 0.05, mainColor)

			-- 3. Draw Rotation Ring (Circle)
			local ringRadius = 0.5
			local segments = 32
			local prevRingPoint = nil
			for i = 0, segments do
				local rad = (i / segments) * math.pi * 2
				local ringPoint = wPos0
					+ (wNormal0 * math.cos(rad) * ringRadius)
					+ (wPerp0 * math.sin(rad) * ringRadius)
				if prevRingPoint then
					adapter.DrawLine3D(
						vector.create(prevRingPoint.X, prevRingPoint.Y, prevRingPoint.Z),
						vector.create(ringPoint.X, ringPoint.Y, ringPoint.Z),
						secondaryColor
					)
				end
				prevRingPoint = ringPoint
			end

			-- 4. Draw Current Angle (if active)
			local currentAngle = 0
			if _activeConstraint then
				currentAngle = KinemiumPhysicsService.GetHingeAngle(_activeConstraint)
			end

			local angleDir = (wNormal0 * math.cos(currentAngle) + wPerp0 * math.sin(currentAngle)):Unit()
			local angleEnd = wPos0 + (angleDir * ringRadius)
			adapter.DrawLine3D(
				vector.create(wPos0.X, wPos0.Y, wPos0.Z),
				vector.create(angleEnd.X, angleEnd.Y, angleEnd.Z),
				mainColor
			)

			-- 5. Draw Limits (Arcs)
			if instance.LimitsEnabled then
				local low = math.rad(instance.LowerAngle)
				local high = math.rad(instance.UpperAngle)
				local limitSegments = 16

				-- Draw boundary lines
				local lowDir = (wNormal0 * math.cos(low) + wPerp0 * math.sin(low)):Unit()
				local highDir = (wNormal0 * math.cos(high) + wPerp0 * math.sin(high)):Unit()

				adapter.DrawLine3D(
					vector.create(wPos0.X, wPos0.Y, wPos0.Z),
					vector.create(
						wPos0.X + lowDir.X * ringRadius,
						wPos0.Y + lowDir.Y * ringRadius,
						wPos0.Z + lowDir.Z * ringRadius
					),
					limitColor
				)
				adapter.DrawLine3D(
					vector.create(wPos0.X, wPos0.Y, wPos0.Z),
					vector.create(
						wPos0.X + highDir.X * ringRadius,
						wPos0.Y + highDir.Y * ringRadius,
						wPos0.Z + highDir.Z * ringRadius
					),
					limitColor
				)

				-- Draw arc
				local prevLimitPoint = nil
				for i = 0, limitSegments do
					local rad = low + (i / limitSegments) * (high - low)
					local limitPoint = wPos0
						+ (wNormal0 * math.cos(rad) * ringRadius)
						+ (wPerp0 * math.sin(rad) * ringRadius)
					if prevLimitPoint then
						adapter.DrawLine3D(
							vector.create(prevLimitPoint.X, prevLimitPoint.Y, prevLimitPoint.Z),
							vector.create(limitPoint.X, limitPoint.Y, limitPoint.Z),
							limitColor
						)
					end
					prevLimitPoint = limitPoint
				end
			end
		end

		instance.Changed:Connect(function(prop)
			if prop == "Attachment0" or prop == "Attachment1" or prop == "Enabled" or prop == "Offset" then
				rebuild()
			elseif
				prop == "ActuatorType"
				or prop == "AngularVelocity"
				or prop == "TargetAngle"
				or prop == "MotorMaxTorque"
				or prop == "ServoMaxTorque"
			then
				instance:UpdateActuator()
			elseif prop == "LimitsEnabled" or prop == "LowerAngle" or prop == "UpperAngle" then
				instance:UpdateLimits()
			end
		end)

		-- Handle parent cleanup
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
