-- description: "Represents a Weld in the environment."
local a = require("../../game/services/ReplicatorService/NetworkOwnership")

local b = {
	Part0 = nil,
	Part1 = nil,

	Enabled = true,
	Name = "Weld",
	ElapsedTime = 0,
}

return {
	class = "Weld",

	-- description: "Initializes the Weld instance."
	-- args: "c: any, d: any, e: any"
	-- returns: "table"
	callback = function(c, d, e)
		local f = e:GetService("UnifiedPhysicsService")

		c:SetProperties(b)

		-- description: "Rebuilds the state."
		local function rebuild()
			if c._active then
				local g = f.jolt
				if g and g.lib and g.physicsSystem then
					g.lib.JPH_PhysicsSystem_RemoveConstraint(g.physicsSystem, c._active)
				end
				c._active = nil
			end

			if not c.Enabled then
				return
			end

			if not c.Part0 or not c.Part1 then
				return
			end

			if not a.ShouldSimulateConstraintForMachine(c, e) then
				return
			end

			local g = 0
			-- description: "Tries create."
			local function tryCreate()
				if not c.Part0 or not c.Part1 or not c.Enabled then
					return
				end

				if not a.ShouldSimulateConstraintForMachine(c, e) then
					return
				end

				local h = f.CreateWeld(c.Part0, c.Part1)
				if h then
					c._active = h
				else
					g += 1
					if g < 30 then
						task.defer(tryCreate)
					else
						warn("[Weld] Gave up waiting for physics bodies for", c.Name)
					end
				end
			end

			tryCreate()
		end

		c.Changed:Connect(function(g)
			if g == "Part0" or g == "Part1" or g == "Enabled" then
				rebuild()
			end
		end)

		return c
	end,

	-- description: "Inherits the properties of the Weld class."
	-- args: "c: any"
	inherit = function(c)
		for d, e in pairs(b) do
			c[d] = e
		end
	end,
}
