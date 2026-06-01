-- description: "Uses torque to rotate an object toward and maintain a specified CFrame orientation."
local Vector3 = require("@Vector3")
local CFrame = require("@CFrame")

local propTable = {
	Part = nil,
	P = 500,
	D = 50,
	MaxTorque = Vector3.new(10000, 0, 10000),
	CFrame = CFrame.new(),
	Enabled = true,
	Name = "BodyGyro",
}

return {
	class = "BodyGyro",

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

		renderer.EventBus:Connect(function(route)
			if route ~= "RenderStepped" then
				return
			end
			if not instance.Enabled then
				return
			end

			local part = instance.Part
			if not part or not shouldApplyPhysics(part) then
				return
			end

			local currentUp = part.CFrame:GetUpVector()
			local currentLook = part.CFrame:GetLookVector()
			local targetUp = instance.CFrame:GetUpVector()
			local targetLook = instance.CFrame:GetLookVector()
			local errorAxis = currentUp:Cross(targetUp) + currentLook:Cross(targetLook)

			local angVel = PhysicsService.GetAngularVelocity(part)

			local P = instance.P
			local D = instance.D
			local maxT = instance.MaxTorque

			local function clamp(v, lo, hi)
				return math.max(lo, math.min(hi, v))
			end

			local tx, ty, tz = 0, 0, 0

			if maxT.X ~= 0 then
				tx = clamp(errorAxis.X * P - angVel.X * D, -maxT.X, maxT.X)
			end
			if maxT.Y ~= 0 then
				ty = clamp(errorAxis.Y * P - angVel.Y * D, -maxT.Y, maxT.Y)
			end
			if maxT.Z ~= 0 then
				tz = clamp(errorAxis.Z * P - angVel.Z * D, -maxT.Z, maxT.Z)
			end

			PhysicsService.ApplyTorque(part, Vector3.new(tx, ty, tz))
		end)

		return instance
	end,

	inherit = function(tble)
		for prop, val in pairs(propTable) do
			tble[prop] = val
		end
	end,
}
