-- description: "Maintains a flexible rope-like connection between two attachments."
local Color3 = require("@Color3")
local NetworkOwnership = require("@NetworkOwnership")

local adapter = require("@RaylibAdapter")
local rl = adapter.lib

local propTable = {
	Attachment0 = nil,
	Attachment1 = nil,
	Enabled = true,
	Visible = true,
	Color = Color3.fromRGB(120, 80, 40),

	Length = 8,
	Thickness = 0.05,
	Stiffness = 0,
	Damping = 0.1,
}

return {
	class = "RopeConstraint",

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

			_activeConstraint = KinemiumPhysicsService.CreateRope(
				part0,
				part1,
				wPos0,
				wPos1,
				instance.Length,
				instance.Stiffness,
				instance.Damping
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
			if not instance.Visible or not instance.Attachment0 or not instance.Attachment1 then
				return
			end

			local att0 = instance.Attachment0
			local att1 = instance.Attachment1
			local p0 = att0.Parent.CFrame * att0.Position
			local p1 = att1.Parent.CFrame * att1.Position

			local ropeLen = instance.Length
			local straightDist = (p1 - p0):Magnitude()
			local sag = math.max(ropeLen - straightDist, 0) * 0.5

			local rlColor = adapter.structs.Color:new({
				r = instance.Color.R * 255,
				g = instance.Color.G * 255,
				b = instance.Color.B * 255,
				a = 255,
			})

			local SEGMENTS = 16
			local lastPt = nil
			for i = 0, SEGMENTS do
				local t = i / SEGMENTS
				local lx = p0.X + (p1.X - p0.X) * t
				local ly = p0.Y + (p1.Y - p0.Y) * t
				local lz = p0.Z + (p1.Z - p0.Z) * t
				local sagAmount = sag * 4 * t * (1 - t)
				ly = ly - sagAmount

				local pt = vector.create(lx, ly, lz)
				if lastPt then
					adapter.DrawCylinderEx(lastPt, pt, instance.Thickness, instance.Thickness, 8, rlColor)
				else
					adapter.DrawSphere(vector.create(p0.X, p0.Y, p0.Z), 0.1, rlColor)
				end
				lastPt = pt
			end
			adapter.DrawSphere(vector.create(p1.X, p1.Y, p1.Z), 0.1, rlColor)
		end

		instance.Changed:Connect(function(prop)
			if
				prop == "Enabled"
				or prop == "Length"
				or prop == "Stiffness"
				or prop == "Damping"
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
