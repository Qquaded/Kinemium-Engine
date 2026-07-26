-- description: "Applies a torsional spring constraint between two attachments."
local Color3 = require("@Color3")
local NetworkOwnership = require("@NetworkOwnership")

local adapter = require("@RaylibAdapter")
local rl = adapter.lib

local propTable = {
	Attachment0 = nil,
	Attachment1 = nil,
	Enabled = true,
	Visible = true,
	Color = Color3.fromRGB(255, 165, 0), -- Orange

	MaxAngle = 45,
	Damping = 1,
	Stiffness = 10,
}

return {
	class = "TorsionSpringConstraint",

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

			_activeConstraint = KinemiumPhysicsService.CreateTorsionSpring(
				part0,
				part1,
				wPos0,
				wAxisX0,
				wAxisY0,
				wPos1,
				wAxisX1,
				wAxisY1,
				instance.Stiffness,
				instance.Damping,
				math.rad(instance.MaxAngle)
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
			local axisX = att.Parent.CFrame:VectorToWorldSpace(att.Axis):Unit()

			local rlPos = vector.create(pos.X, pos.Y, pos.Z)
			local rlColorEdge = adapter.structs.Color:new({
				r = instance.Color.R * 255,
				g = instance.Color.G * 255,
				b = instance.Color.B * 255,
				a = 255,
			})

			-- Draw an arc to represent torsion around axis X
			local cx = rlPos.x
			local cy = rlPos.y
			local cz = rlPos.z

			local steps = 16
			local radius = 0.5
			local axisYZ = att.Parent.CFrame:VectorToWorldSpace(att.SecondaryAxis):Unit()
			local axisZZ = att.Parent.CFrame:VectorToWorldSpace(att.Axis:Cross(att.SecondaryAxis)):Unit()

			local lastPoint = nil
			for i = 0, steps do
				local ang = (i / steps) * math.pi * 2
				local pX = cx + axisYZ.X * math.cos(ang) * radius + axisZZ.X * math.sin(ang) * radius
				local pY = cy + axisYZ.Y * math.cos(ang) * radius + axisZZ.Y * math.sin(ang) * radius
				local pZ = cz + axisYZ.Z * math.cos(ang) * radius + axisZZ.Z * math.sin(ang) * radius

				local pt = vector.create(pX, pY, pZ)
				if lastPoint then
					adapter.DrawLine3D(lastPoint, pt, rlColorEdge)
				end
				lastPoint = pt
			end
		end

		instance.Changed:Connect(function(prop)
			if
				prop == "Enabled"
				or prop == "Attachment0"
				or prop == "Attachment1"
				or prop == "Stiffness"
				or prop == "Damping"
				or prop == "MaxAngle"
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
