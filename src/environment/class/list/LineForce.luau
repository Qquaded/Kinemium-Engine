-- description: "Represents a LineForce in the environment."
local propTable = {
	ApplyAtCenterOfMass = false,
	InverseSquareLaw = false,
	Magnitude = 1000,
	MaxForce = 10000,
	ReactionForceEnabled = false,
}

return {
	class = "LineForce",
	-- description: "Initializes the LineForce instance."
	-- args: "instance: table"
	-- returns: "table"
	callback = function(instance)
		instance:SetProperties(propTable)
		return instance
	end,
	-- description: "Inherits the properties of the LineForce class."
	-- args: "tble: table"
	inherit = function(tble)
		for prop, val in pairs(propTable) do
			tble[prop] = val
		end
	end,
}
