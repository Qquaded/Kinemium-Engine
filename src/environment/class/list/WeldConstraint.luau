-- description: "Creates a weld constraint between two parts."
local NetworkOwnership = require("@NetworkOwnership")

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
		local KinemiumPhysicsService = datamodel:GetService("UnifiedPhysicsService")

		instance:SetProperties(propTable)

		local function rebuild()
			if instance._active then
				local jolt = KinemiumPhysicsService.jolt
				if jolt and jolt.lib and jolt.physicsSystem then
					jolt.lib.JPH_PhysicsSystem_RemoveConstraint(jolt.physicsSystem, instance._active)
				end
				instance._active = nil
			end

			if not instance.Enabled then
				return
			end

			if not instance.Part0 or not instance.Part1 then
				return
			end

			if not NetworkOwnership.ShouldSimulateConstraintForMachine(instance, datamodel) then
				return
			end

			local retryCount = 0
			local function tryCreate()
				if not instance.Part0 or not instance.Part1 or not instance.Enabled then
					return
				end

				if not NetworkOwnership.ShouldSimulateConstraintForMachine(instance, datamodel) then
					return
				end

				local result = KinemiumPhysicsService.CreateWeld(instance.Part0, instance.Part1)
				if result then
					instance._active = result
				else
					retryCount += 1
					if retryCount < 30 then
						task.defer(tryCreate)
					else
						warn("[WeldConstraint] Gave up waiting for physics bodies for", instance.Name)
					end
				end
			end

			tryCreate()
		end

		instance.Changed:Connect(function(property)
			if property == "Part0" or property == "Part1" or property == "Enabled" then
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
