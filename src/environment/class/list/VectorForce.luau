-- description: "A force that applies a constant vector to a part."
local Vector3 = require("@Vector3")
local Enum = require("@EnumMap")

local adapter = require("@RaylibAdapter")
local rl = adapter.lib

local propTable = {
	Attachment0 = nil,

	Force = Vector3.new(0, 0, 0),
	RelativeTo = Enum.ActuatorRelativeTo.World,

	Enabled = true,
	Name = "VectorForce",
	ElapsedTime = 0,
}

return {
	class = "VectorForce",

	callback = function(instance, renderer, game)
		instance:SetProperties(propTable)

		local PhysicsService = game:GetService("UnifiedPhysicsService")

		local function shouldApplyPhysics(part)
			local replicator = game:GetService("ReplicatorService")
			local ownership = replicator and replicator.NetworkOwnership or nil
			if ownership and ownership.ShouldSimulatePhysicsForMachine then
				return ownership.ShouldSimulatePhysicsForMachine(part, game)
			end

			if part == nil then
				return false
			end

			if part.NetworkOwner == nil then
				return IsServer == true
			end

			if IsClient ~= true then
				return false
			end

			local players = game:GetService("Players")
			return players.LocalPlayer ~= nil and players.LocalPlayer == part.NetworkOwner
		end

		local function updateArrow()
			if not instance.Enabled or not instance.Attachment0 then
				return
			end

			local attach = instance.Attachment0
			if attach and attach:IsA("Attachment") then
				local parent = attach.Parent
				if parent.BaseClass == "BasePart" then
					local force = instance.Force
					local magnitude = force:Magnitude()

					if magnitude > 0 then
						local direction = force:Unit()
						local position = parent.CFrame.Position

						local arrowLength = math.min(magnitude / 20, 20) * 5
						local endPos = position + (direction * arrowLength)

						adapter.DrawCylinderEx(
							vector.create(position.X, position.Y, position.Z),
							vector.create(endPos.X, endPos.Y, endPos.Z),
							0.1,
							0.1,
							8,
							adapter.structs.Color:new({ r = 0, g = 0, b = 255, a = 255 })
						)

						adapter.DrawCubeWiresV(
							vector.create(position.X, position.Y, position.Z),
							vector.create(parent.Size.X, parent.Size.Y, parent.Size.Z),
							adapter.structs.Color:new({ r = 0, g = 0, b = 255, a = 255 })
						)
					end
				end
			end
		end

		renderer.EventBus:Connect(function(route)
			if route == "RenderStepped" then
				if not instance.Enabled then
					return
				end
				local attach = instance.Attachment0
				if attach and attach:IsA("Attachment") then
					local parent = attach.Parent
					if parent.BaseClass == "BasePart" and shouldApplyPhysics(parent) then
						PhysicsService.ApplyImpulse(parent, instance.Force)
					end
				end
			end
		end)

		renderer.Pool.new("gizmo", function()
			updateArrow()
		end)

		return instance
	end,

	inherit = function(tble)
		for prop, val in pairs(propTable) do
			tble[prop] = val
		end
	end,
}
