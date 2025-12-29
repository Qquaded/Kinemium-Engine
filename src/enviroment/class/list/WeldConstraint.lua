local Vector3 = require("@Vector3")
local CFrame = require("@CFrame")

local propTable = {
	Part0 = nil,
	Part1 = nil,

	Enabled = true,
	Name = "WeldConstraint",
	ElapsedTime = 0,
}

return {
	class = "WeldConstraint",

	callback = function(instance, renderer, datamodel)
		local KinemiumPhysicsService = datamodel:GetService("PhysicsService")

		local lib = KinemiumPhysicsService.jolt.lib
		local structs = KinemiumPhysicsService.jolt.structs
		local RVec3 = KinemiumPhysicsService.jolt.RVec3

		instance:SetProperties(propTable)

		local function rebuild()
			if instance._active then
				lib.JPH_PhysicsSystem_RemoveConstraint(KinemiumPhysicsService.jolt.physicsSystem, instance._active)
				instance._active = nil
			end

			if not instance.Enabled then
				return
			end

			if not instance.Part0 or not instance.Part1 then
				return
			end

			local part0 = instance.Part0
			local part1 = instance.Part1

			local relCF = part0.CFrame:Inverse() * part1.CFrame

			local settings = structs.JPH_FixedConstraintSettings:new({
				mSpace = 0,
				mPoint1 = RVec3(0, 0, 0),
				mPoint2 = RVec3(relCF.Position.X, relCF.Position.Y, relCF.Position.Z),
				mAxisX1 = structs.JPH_Vec3:new({ x = 1, y = 0, z = 0 }),
				mAxisY1 = structs.JPH_Vec3:new({ x = 0, y = 1, z = 0 }),
				mAxisX2 = structs.JPH_Vec3:new({ x = 1, y = 0, z = 0 }),
				mAxisY2 = structs.JPH_Vec3:new({ x = 0, y = 1, z = 0 }),
			})

			instance._active = lib.JPH_FixedConstraint_Create(
				settings,
				KinemiumPhysicsService.GetBody(part0),
				KinemiumPhysicsService.GetBody(part1)
			)

			lib.JPH_PhysicsSystem_AddConstraint(KinemiumPhysicsService.jolt.physicsSystem, instance._active)
		end

		instance.Changed:Connect(function(property)
			if property == "Part0" or property == "Part1" or property == "Enabled" then
				print("Rebuilt")
				rebuild()
			end
		end)

		return instance
	end,

	inherit = function(tble)
		for prop, val in pairs(propTable) do
			tble[prop] = val
		end
	end,
}
