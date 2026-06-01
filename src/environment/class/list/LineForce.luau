-- description: "Applies force along a line."
local propTable = {
	ApplyAtCenterOfMass = false,
	InverseSquareLaw = false,
	Magnitude = 1000,
	MaxForce = 10000,
	ReactionForceEnabled = false,
}

return {
	class = "LineForce",
	callback = function(instance)
		instance:SetProperties(propTable)
		return instance
	end,
	inherit = function(tble)
		for prop, val in pairs(propTable) do
			tble[prop] = val
		end
	end,
}
