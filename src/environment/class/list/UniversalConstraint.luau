-- description: "A modifier class that creates a universal constraint between two attachments."
local Color3 = require("@Color3")
local adapter = require("@RaylibAdapter")
local rl = adapter.lib
local NetworkOwnership = require("@NetworkOwnership")

local propTable = {
	Attachment0 = nil,
	Attachment1 = nil,
	Enabled = true,
	Visible = true,
	Color = Color3.fromRGB(0, 255, 0),

	LimitsEnabled = false,
	MaxAngle = 45,

	Name = "UniversalConstraint",
}

return {
	class = "UniversalConstraint",

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
			local wAxisX0 = part0.CFrame:VectorToWorldSpace(att0.Axis):Unit()
			local wAxisY0 = part0.CFrame:VectorToWorldSpace(att0.SecondaryAxis):Unit()

			local wPos1 = part1.CFrame * att1.Position
			local wAxisX1 = part1.CFrame:VectorToWorldSpace(att1.Axis):Unit()
			local wAxisY1 = part1.CFrame:VectorToWorldSpace(att1.SecondaryAxis):Unit()

			local limitR = 3.1415
			if instance.LimitsEnabled then
				limitR = math.rad(math.clamp(instance.MaxAngle, 0, 180))
			end

			_activeConstraint = KinemiumPhysicsService.CreateUniversal(
				part0,
				part1,
				wPos0,
				wAxisX0,
				wAxisY0,
				wPos1,
				wAxisX1,
				wAxisY1,
				-limitR,
				limitR,
				-limitR,
				limitR
			)

			local function onPartChanged(prop)
				if prop == "Anchored" then
					task.defer(rebuild)
				end
			end
			part0.Changed:Connect(onPartChanged)
			part1.Changed:Connect(onPartChanged)
		end

		local function drawGizmo()
			if not instance.Visible or not instance.Attachment0 then
				return
			end
			local att = instance.Attachment0
			local pos = att.Parent.CFrame * att.Position
			local axisZ = att.Parent.CFrame:VectorToWorldSpace(att.Axis:Cross(att.SecondaryAxis)):Unit()

			local rlPos = vector.create(pos.X, pos.Y, pos.Z)
			local rlDir = vector.create(pos.X + axisZ.X, pos.Y + axisZ.Y, pos.Z + axisZ.Z)
			local rlColor = adapter.structs.Color:new({ r = 255, g = 0, b = 0, a = 200 })
			local rlLines = adapter.structs.Color:new({ r = 0, g = 255, b = 0, a = 200 })

			adapter.DrawLine3D(rlPos, rlDir, rlColor) -- Draw strictly locked twist axis in Red
			adapter.DrawSphere(rlPos, 0.1, rlLines) -- Center
		end

		instance.Changed:Connect(function(prop)
			if
				prop == "Enabled"
				or prop == "LimitsEnabled"
				or prop == "MaxAngle"
				or prop == "Attachment0"
				or prop == "Attachment1"
			then
				rebuild()
			end
		end)

		renderer.Pool.new("gizmo", drawGizmo)
		task.spawn(rebuild)

		return instance
	end,

	inherit = function(tble)
		for prop, val in pairs(propTable) do
			tble[prop] = val
		end
	end,
}
