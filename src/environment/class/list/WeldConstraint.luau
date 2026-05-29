-- description: "Represents a WeldConstraint in the environment."
local NetworkOwnership = require("../../game/services/ReplicatorService/NetworkOwnership")

local propTable = {
	Part0 = nil,
	Part1 = nil,

	Enabled = true,
	Name = "WeldConstraint",
	ElapsedTime = 0,
}

return {
	class = "WeldConstraint",

	-- description: "Initializes the WeldConstraint instance."
	-- args: "instance: table, renderer: number, datamodel: table"
	-- returns: "table"
	callback = function(instance, renderer, datamodel)
		local KinemiumPhysicsService = datamodel:GetService("UnifiedPhysicsService")

		instance:SetProperties(propTable)

		-- description: "Rebuilds the state."
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

			-- Bodies may not exist yet if the parts just entered the world.
			-- Retry via task.defer until both are registered, with a safety cap.
			local retryCount = 0
			-- description: "Tries create."
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

	-- description: "Inherits the properties of the WeldConstraint class."
	-- args: "tble: table"
	inherit = function(tble)
		for prop, val in pairs(propTable) do
			tble[prop] = val
		end
	end,
}
