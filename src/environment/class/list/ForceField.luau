-- description: "Represents a ForceField in the environment."
local propTable = {
	Name = "ForceField",
	BaseClass = "Kinemium.instance",

	Visible = true,
}

return {
	class = "ForceField",
	-- description: "Initializes the ForceField instance."
	-- args: "instance: table"
	-- returns: "table"
	callback = function(instance)
		instance:SetProperties(propTable)

		-- TODO: Implement functionality, use already existing Particle Emitter
		-- Detect forcefield from humanoid

		return instance
	end,
	-- description: "Inherits the properties of the ForceField class."
	-- args: "tble: table"
	inherit = function(tble)
		for prop, val in pairs(propTable) do
			tble[prop] = val
		end
	end,
}
