-- description: "Represents a LegIK in the environment."
-- LegIK.lua
local Vector3 = require("@Vector3")
local CFrame = require("@CFrame")
local Enum = require("@Enum")

local ZERO = Vector3.new(0, 0, 0)
local RAY_DOWN = Vector3.new(0, -1, 0)

-- description: "Solves two bone."
-- args: "root: any, target: table, poleHint: any, upperLen: any, lowerLen: any"
local function solveTwoBone(root, target, poleHint, upperLen, lowerLen)
	local toTarget = target - root
	local dist = math.clamp(toTarget:Magnitude(), 0.001, upperLen + lowerLen - 0.001)

	local cosUpper = (upperLen * upperLen + dist * dist - lowerLen * lowerLen) / (2 * upperLen * dist)
	cosUpper = math.clamp(cosUpper, -1, 1)
	local angleUpper = math.acos(cosUpper)

	local targetDir = toTarget / math.max(toTarget:Magnitude(), 0.001)
	local poleDir = poleHint - root
	local projected = poleDir - targetDir * poleDir:Dot(targetDir)
	if projected:Magnitude() < 0.001 then
		projected = Vector3.new(0, 0, 1)
	end
	local poleNorm = projected / projected:Magnitude()

	local kneePos = root + targetDir * (upperLen * math.cos(angleUpper)) + poleNorm * (upperLen * math.sin(angleUpper))

	return kneePos, target
end

local propTable = {
	Name = "LegIK",
	Enabled = true,
	Humanoid = nil,
	Workspace = nil,
	StepDistThreshold = 0.55,
	StepHeight = 0.28,
	StepSpeed = 8,
	PoleForwardBias = 0.6,
	PoleSideBias = 0.2,
}

return {
	class = "LegIK",
	-- description: "Initializes the LegIK instance."
	-- args: "instance: table"
	-- returns: "table"
	callback = function(instance)
		instance:SetProperties(propTable)

		-- Private state (not replicated properties)
		rawset(instance, "_measured", false)
		rawset(instance, "_upperLen", { LeftLeg = 1, RightLeg = 1 })
		rawset(instance, "_lowerLen", { LeftLeg = 1, RightLeg = 1 })
		rawset(instance, "_footTargets", { LeftLeg = nil, RightLeg = nil })
		rawset(instance, "_planted", { LeftLeg = nil, RightLeg = nil })
		rawset(instance, "_stepping", { LeftLeg = false, RightLeg = false })
		rawset(instance, "_footPhase", { LeftLeg = 0, RightLeg = 0.5 })
		rawset(instance, "_stepTarget", {})

		-- Reset all foot state (call when character respawns / teleports)
		-- description: "Resets."
		function instance:Reset()
			rawset(self, "_measured", false)
			rawset(self, "_upperLen", { LeftLeg = 1, RightLeg = 1 })
			rawset(self, "_lowerLen", { LeftLeg = 1, RightLeg = 1 })
			rawset(self, "_footTargets", { LeftLeg = nil, RightLeg = nil })
			rawset(self, "_planted", { LeftLeg = nil, RightLeg = nil })
			rawset(self, "_stepping", { LeftLeg = false, RightLeg = false })
			rawset(self, "_footPhase", { LeftLeg = 0, RightLeg = 0.5 })
			rawset(self, "_stepTarget", {})
		end

		-- description: "_measures bones."
		function instance:_measureBones()
			if rawget(self, "_measured") then
				return
			end
			local h = self.Humanoid
			if not h then
				return
			end

			local upperLen = rawget(self, "_upperLen")
			local lowerLen = rawget(self, "_lowerLen")

			for _, side in ipairs({ "LeftLeg", "RightLeg" }) do
				local bindings = h:GetRigBindings()
				local b = bindings and bindings[side]
				if b and #b.Segments >= 2 then
					local upper = b.Segments[1].Part
					local lower = b.Segments[2].Part
					if upper and lower then
						upperLen[side] = upper.Size.Y
						lowerLen[side] = lower.Size.Y
					end
				else
					local part = h:GetRigPart(side)
					if part then
						upperLen[side] = part.Size.Y * 0.5
						lowerLen[side] = part.Size.Y * 0.5
					end
				end
			end

			rawset(self, "_measured", true)
		end

		-- Returns a pose table to merge into the animator pose.
		-- Call this from humanoid:SetIKCallback or a pose layer.
		-- description: "Steps."
		-- args: "dt: number, animContext: table"
		function instance:Step(dt, animContext)
			if self.Enabled == false then
				return {}
			end

			self:_measureBones()

			local h = self.Humanoid
			local ws = self.Workspace
			if not h or not ws then
				return {}
			end

			local root = h.RootPart
			if not root then
				return {}
			end

			local rootCF = root.CFrame
			local hipHeight = h.HipHeight or 1
			local isGrounded = animContext and animContext.airborne == false

			local upperLen = rawget(self, "_upperLen")
			local lowerLen = rawget(self, "_lowerLen")
			local footTargets = rawget(self, "_footTargets")
			local planted = rawget(self, "_planted")
			local stepping = rawget(self, "_stepping")
			local footPhase = rawget(self, "_footPhase")
			local stepTarget = rawget(self, "_stepTarget")

			local pose = {}

			for _, side in ipairs({ "LeftLeg", "RightLeg" }) do
				local bindings = h:GetRigBindings()
				local b = bindings and bindings[side]
				if not b then
					continue
				end

				local hipCF = rootCF * b.Transform
				local hipPos = hipCF.Position
				local legLen = upperLen[side] + lowerLen[side]

				-- Ground probe
				local hit = ws:Raycast(
					hipPos + Vector3.new(0, hipHeight + 0.5, 0), -- start well above
					RAY_DOWN * (legLen + hipHeight + 1.5),
					h._ikRayParams or nil
				)

				local desiredFoot = hit and hit.Position or (hipPos + Vector3.new(0, -legLen, 0))

				-- Initialise on first frame
				if not planted[side] then
					planted[side] = desiredFoot
					footTargets[side] = desiredFoot
				end

				-- Decide whether to lift and replant
				local driftXZ = desiredFoot - planted[side]
				local drift = Vector3.new(driftXZ.X, 0, driftXZ.Z):Magnitude()

				if isGrounded and not stepping[side] and drift > self.StepDistThreshold then
					local other = side == "LeftLeg" and "RightLeg" or "LeftLeg"
					if not stepping[other] then
						stepping[side] = true
						footPhase[side] = 0
						local lv = animContext and animContext.lookVector
						stepTarget[side] = desiredFoot + (lv and Vector3.new(lv.X, 0, lv.Z) * 0.15 or ZERO)
					end
				end

				-- Advance step arc
				if stepping[side] then
					footPhase[side] = math.min(1, footPhase[side] + dt * self.StepSpeed)
					local t = footPhase[side]
					local from = planted[side]
					local to = stepTarget[side] or desiredFoot
					local arc = math.sin(t * math.pi) * self.StepHeight

					footTargets[side] = from:Lerp(to, t) + Vector3.new(0, arc, 0)

					if t >= 1 then
						stepping[side] = false
						planted[side] = to
						footTargets[side] = to
					end
				else
					footTargets[side] = planted[side]
				end

				-- IK solve
				local footTarget = footTargets[side]
				local kneeSide = side == "LeftLeg" and -1 or 1
				local kneeHint = hipPos
					+ rootCF:GetLookVector() * self.PoleForwardBias
					+ rootCF:GetRightVector() * (kneeSide * self.PoleSideBias)

				local kneePos = solveTwoBone(hipPos, footTarget, kneeHint, upperLen[side], lowerLen[side])

				-- Upper bone pitch (hip → knee, relative to binding)
				local upperDir = (kneePos - hipPos)
				if upperDir:Magnitude() > 0.001 then
					upperDir = upperDir:Unit()
				end

				-- Express upperDir in the hip binding's local space
				local localUpperDir = hipCF:VectorToObjectSpace(upperDir)
				-- In local space, straight down = (0, -1, 0), so pitch = angle away from -Y in the YZ plane
				local upperPitch = math.atan2(-localUpperDir.Z, -localUpperDir.Y)

				-- Lower bone pitch (knee → foot)
				local lowerDir = (footTarget - kneePos)
				if lowerDir:Magnitude() > 0.001 then
					lowerDir = lowerDir:Unit()
				end

				-- Knee local space: built from the upper bone's orientation
				local kneeBasisCF = CFrame.new(kneePos, kneePos + upperDir)
				local localLowerDir = kneeBasisCF:VectorToObjectSpace(lowerDir)
				local lowerPitch = math.atan2(-localLowerDir.Z, -localLowerDir.Y)

				local segs = b.Segments
				if #segs >= 2 then
					pose[side] = {
						[segs[1].Name] = CFrame.Angles(upperPitch, 0, 0),
						[segs[2].Name] = CFrame.Angles(lowerPitch, 0, 0),
					}
				else
					pose[side] = CFrame.Angles(upperPitch, 0, 0)
				end
			end

			return pose
		end

		-- Convenience: wires itself directly into the humanoid's IK callback.
		-- Call once after parenting; call again if the humanoid changes.
		-- description: "Attaches."
		-- args: "humanoid: string"
		function instance:Attach(humanoid)
			self.Humanoid = humanoid
			self:Reset()

			humanoid:SetIKCallback(function(h, dt, pose)
				local ctx = {
					airborne = h.State == Enum.HumanoidStateType.Freefall or h.State == Enum.HumanoidStateType.Jumping,
					lookVector = h:GetLookVector(),
					speed = h.MoveVelocity and h.MoveVelocity:Magnitude() or 0,
				}
				local ikPose = self:Step(dt, ctx)
				for partName, cf in pairs(ikPose) do
					pose[partName] = cf
				end
				return pose
			end)
		end

		return instance
	end,
	-- description: "Inherits the properties of the LegIK class."
	-- args: "tble: table"
	inherit = function(tble)
		for prop, val in pairs(propTable) do
			tble[prop] = val
		end
	end,
}
