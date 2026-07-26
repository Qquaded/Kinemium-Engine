-- description: "Maintains a fixed distance between two attachments while allowing free rotation."
local Color3 = require("@Color3")
local NetworkOwnership = require("@NetworkOwnership")

local adapter = require("@RaylibAdapter")
local rl = adapter.lib

local propTable = {
	Attachment0 = nil,
	Attachment1 = nil,
	Enabled = true,
	Visible = true,
	Color = Color3.fromRGB(150, 150, 150),

	Length = 5,
}

return {
	class = "RodConstraint",
	callback = function(instance, renderer, datamodel)
		local KinemiumPhysicsService = datamodel:GetService("UnifiedPhysicsService")
		instance:SetProperties(propTable)

		local _activeConstraint = nil

		local function cleanup()
			if _activeConstraint and KinemiumPhysicsService then
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

			_activeConstraint = KinemiumPhysicsService.CreateRod(part0, part1, wPos0, wPos1, instance.Length)

			local function onPartChanged(prop)
				if prop == "Anchored" then
					task.defer(rebuild)
				end
			end
			part0.Changed:Connect(onPartChanged)
			part1.Changed:Connect(onPartChanged)
		end

		local function drawGizmo()
			if not instance.Visible or not instance.Attachment0 or not instance.Attachment1 then
				return
			end
			local att0 = instance.Attachment0
			local att1 = instance.Attachment1

			local pos0 = att0.Parent.CFrame * att0.Position
			local pos1 = att1.Parent.CFrame * att1.Position

			local rlPos0 = vector.create(pos0.X, pos0.Y, pos0.Z)
			local rlPos1 = vector.create(pos1.X, pos1.Y, pos1.Z)
			local rlColor = adapter.structs.Color:new({
				r = instance.Color.R * 255,
				g = instance.Color.G * 255,
				b = instance.Color.B * 255,
				a = 255,
			})

			adapter.DrawLine3D(rlPos0, rlPos1, rlColor)
			adapter.DrawSphere(rlPos0, 0.15, rlColor)
			adapter.DrawSphere(rlPos1, 0.15, rlColor)
		end

		instance.Changed:Connect(function(prop)
			if prop == "Enabled" or prop == "Length" or prop == "Attachment0" or prop == "Attachment1" then
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
