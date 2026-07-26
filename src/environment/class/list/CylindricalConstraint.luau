-- description: "Constrains two attachments to slide and rotate along a shared axis."
local Color3 = require("@Color3")
local NetworkOwnership = require("@NetworkOwnership")

local adapter = require("@RaylibAdapter")
local rl = adapter.lib

local propTable = {
	Attachment0 = nil,
	Attachment1 = nil,
	Enabled = true,
	Visible = true,
	Color = Color3.fromRGB(0, 255, 255), -- Cyan

	LimitsEnabled = false,
	LowerLimit = -5,
	UpperLimit = 5,
}

return {
	class = "CylindricalConstraint",

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

			local lower = -1000000
			local upper = 1000000

			if instance.LimitsEnabled then
				lower = instance.LowerLimit
				upper = instance.UpperLimit
			end

			_activeConstraint = KinemiumPhysicsService.CreateCylindrical(
				part0,
				part1,
				wPos0,
				wAxisX0,
				wAxisY0,
				wPos1,
				wAxisX1,
				wAxisY1,
				lower,
				upper
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

			local rlColorEdge = adapter.structs.Color:new({
				r = instance.Color.R * 255,
				g = instance.Color.G * 255,
				b = instance.Color.B * 255,
				a = 255,
			})

			local len = math.clamp(instance.UpperLimit or 5, 1, 10)
			local endPos = pos + (axisX * len)
			local startPos = pos + (axisX * (instance.LimitsEnabled and instance.LowerLimit or -len))

			local rlStart = vector.create(startPos.X, startPos.Y, startPos.Z)
			local rlEnd = vector.create(endPos.X, endPos.Y, endPos.Z)

			adapter.DrawLine3D(rlStart, rlEnd, rlColorEdge)
			adapter.DrawSphere(rlStart, 0.1, rlColorEdge)
			adapter.DrawSphere(rlEnd, 0.1, rlColorEdge)
		end

		instance.Changed:Connect(function(prop)
			if
				prop == "Enabled"
				or prop == "Attachment0"
				or prop == "Attachment1"
				or prop == "LimitsEnabled"
				or prop == "LowerLimit"
				or prop == "UpperLimit"
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
