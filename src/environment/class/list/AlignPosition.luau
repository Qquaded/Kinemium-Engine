-- description: "Represents an AlignPosition in the environment."
local propTable = {
	Name = "AlignPosition",
	Attachment0 = nil,
	Attachment1 = nil,
	Enabled = true,
	MaxForce = 10000,
	MaxVelocity = 10000,
	Responsiveness = 10,
	Position = nil,
	Mode = nil,
	ApplyAtCenterOfMass = false,
}

return {
	class = "AlignPosition",
	-- description: "Initializes the AlignPosition instance."
	-- args: "instance: table"
	-- returns: "table"
	callback = function(instance)
		instance:SetProperties(propTable)
		return instance
	end,
	-- description: "Inherits the properties of the AlignPosition class."
	-- args: "tble: table"
	inherit = function(tble)
		for prop, val in pairs(propTable) do
			tble[prop] = val
		end
	end,
}
