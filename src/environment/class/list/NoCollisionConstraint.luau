-- description: "Represents a NoCollisionConstraint in the environment."
local propTable = {
	Name = "NoCollisionConstraint",
	BaseClass = "Kinemium.constraint",

	Part0 = nil,
	Part1 = nil,
	Enabled = true,
}

return {
	class = "NoCollisionConstraint",
	-- description: "Initializes the NoCollisionConstraint instance."
	-- args: "instance: table"
	-- returns: "table"
	callback = function(instance)
		instance:SetProperties(propTable)
		return instance
	end,
	-- description: "Inherits the properties of the NoCollisionConstraint class."
	-- args: "tble: table"
	inherit = function(tble)
		for prop, val in pairs(propTable) do
			tble[prop] = val
		end
	end,
}
