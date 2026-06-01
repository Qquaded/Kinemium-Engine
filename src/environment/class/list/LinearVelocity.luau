-- description: "Forces an object to travel in a straight line at a set speed and direction."
local Vector2 = require("@Vector2")
local Vector3 = require("@Vector3")
local Enum = require("@EnumMap")

local propTable = {
	Attachment0 = nil,
	Attachment1 = nil,

	ForceLimitMode = Enum.ForceLimitMode.Magnitude,
	ForceLimitsEnabled = false,
	LineDirection = Vector3.new(1, 0, 0),
	LineVelocity = 0,
	MaxAxesForce = Vector3.new(math.huge, math.huge, math.huge),
	MaxForce = math.huge,
	MaxPlanarAxesForce = Vector2.new(math.huge, math.huge),
	PlaneVelocity = Vector2.new(0, 0),
	PrimaryTangentAxis = Vector3.new(1, 0, 0),
	ReactionForceEnabled = false,
	RelativeTo = Enum.ActuatorRelativeTo.World,
	SecondaryTangentAxis = Vector3.new(0, 0, 1),
	VectorVelocity = Vector3.new(0, 0, 0),
	VelocityConstraintMode = Enum.VelocityConstraintMode.Vector,

	Enabled = true,
	Name = "LinearVelocity",
}

return {
	class = "LinearVelocity",

	callback = function(instance, renderer, game)
		instance:SetProperties(propTable)

		local PhysicsService = game:GetService("UnifiedPhysicsService")

		-- returns: "boolean"
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

		local function getAttachmentPart(attachment)
			if attachment and attachment:IsA("Attachment") then
				local parent = attachment.Parent
				if parent and parent.BaseClass == "BasePart" then
					return parent
				end
			end
			return nil
		end

		local function resolvePart()
			local part = getAttachmentPart(instance.Attachment0)
			if part then
				return part
			end

			local parent = instance.Parent
			if parent and parent.BaseClass == "BasePart" then
				return parent
			end

			return nil
		end

		local function getReferenceCFrame(part)
			local relativeTo = instance.RelativeTo
			if relativeTo == Enum.ActuatorRelativeTo.Attachment0 then
				local attachmentPart = getAttachmentPart(instance.Attachment0)
				return attachmentPart and attachmentPart.CFrame or (part and part.CFrame or nil)
			elseif relativeTo == Enum.ActuatorRelativeTo.Attachment1 then
				local attachmentPart = getAttachmentPart(instance.Attachment1)
				return attachmentPart and attachmentPart.CFrame or (part and part.CFrame or nil)
			end

			return nil
		end

		local function vectorToWorld(vectorValue, part)
			local reference = getReferenceCFrame(part)
			if reference and reference.VectorToWorldSpace then
				return reference:VectorToWorldSpace(vectorValue)
			end
			return vectorValue
		end

		local function vectorToRelative(vectorValue, part)
			local reference = getReferenceCFrame(part)
			if reference and reference.VectorToObjectSpace then
				return reference:VectorToObjectSpace(vectorValue)
			end
			return vectorValue
		end

		local function orthonormalize(primary, secondary)
			local p = primary:IsZero() and Vector3.new(1, 0, 0) or primary:Unit()
			local s = secondary - p * secondary:Dot(p)
			if s:IsZero() then
				s = p:Cross(Vector3.new(0, 1, 0))
				if s:IsZero() then
					s = p:Cross(Vector3.new(0, 0, 1))
				end
			end
			return p, s:Unit()
		end

		local function resolvePlaneAxes(part)
			local primary = vectorToWorld(instance.PrimaryTangentAxis, part)
			local secondary = vectorToWorld(instance.SecondaryTangentAxis, part)
			return orthonormalize(primary, secondary)
		end

		local function resolveTargetVelocity(part)
			if instance.VelocityConstraintMode == Enum.VelocityConstraintMode.Line then
				local direction = vectorToWorld(instance.LineDirection, part)
				if direction:IsZero() then
					direction = Vector3.new(1, 0, 0)
				end
				return direction:Unit() * instance.LineVelocity
			elseif instance.VelocityConstraintMode == Enum.VelocityConstraintMode.Plane then
				local primary, secondary = resolvePlaneAxes(part)
				return primary * instance.PlaneVelocity.X + secondary * instance.PlaneVelocity.Y
			end

			return vectorToWorld(instance.VectorVelocity, part)
		end

		local function clampVectorMagnitude(vectorValue, maxMagnitude)
			if maxMagnitude == nil or maxMagnitude == math.huge or maxMagnitude <= 0 then
				return vectorValue
			end
			local magnitude = vectorValue:Magnitude()
			if magnitude > maxMagnitude and magnitude > 0 then
				return vectorValue:Unit() * maxMagnitude
			end
			return vectorValue
		end

		local function clampPerAxis(forceValue, part)
			if instance.VelocityConstraintMode == Enum.VelocityConstraintMode.Plane then
				local primary, secondary = resolvePlaneAxes(part)
				local primaryForce =
					math.clamp(forceValue:Dot(primary), -instance.MaxPlanarAxesForce.X, instance.MaxPlanarAxesForce.X)
				local secondaryForce =
					math.clamp(forceValue:Dot(secondary), -instance.MaxPlanarAxesForce.Y, instance.MaxPlanarAxesForce.Y)
				return primary * primaryForce + secondary * secondaryForce
			end

			local relativeForce = vectorToRelative(forceValue, part)
			relativeForce = Vector3.new(
				math.clamp(relativeForce.X, -instance.MaxAxesForce.X, instance.MaxAxesForce.X),
				math.clamp(relativeForce.Y, -instance.MaxAxesForce.Y, instance.MaxAxesForce.Y),
				math.clamp(relativeForce.Z, -instance.MaxAxesForce.Z, instance.MaxAxesForce.Z)
			)
			return vectorToWorld(relativeForce, part)
		end

		renderer.EventBus:Connect(function(route, dt)
			if route ~= "RenderStepped" then
				return
			end
			if not instance.Enabled then
				return
			end

			local part = resolvePart()
			if not part or not shouldApplyPhysics(part) then
				return
			end
			if not PhysicsService.GetBody or not PhysicsService.GetBody(part) then
				return
			end

			local targetVelocity = resolveTargetVelocity(part)
			PhysicsService.ActivatePart(part)

			if not instance.ForceLimitsEnabled then
				PhysicsService.SetVelocity(part, targetVelocity)
				return
			end

			local currentVelocity = PhysicsService.GetVelocity(part)
			local deltaVelocity = targetVelocity - currentVelocity
			if deltaVelocity:IsZero() then
				return
			end

			local mass = math.max(part.AssemblyMass or part.Mass or 1, 0.001)
			local safeDt = math.max(dt or 0, 1 / 240)
			local desiredForce = deltaVelocity * (mass / safeDt)

			if instance.ForceLimitMode == Enum.ForceLimitMode.PerAxis then
				desiredForce = clampPerAxis(desiredForce, part)
			else
				desiredForce = clampVectorMagnitude(desiredForce, instance.MaxForce)
			end

			if desiredForce:IsZero() then
				return
			end

			PhysicsService.ApplyImpulse(part, desiredForce * safeDt)
		end)

		return instance
	end,

	inherit = function(tble)
		for prop, val in pairs(propTable) do
			tble[prop] = val
		end
	end,
}
