-- description: "Represents an AlignOrientation in the environment."
local propTable = {
	Name = "AlignOrientation",
	Attachment0 = nil,
	Attachment1 = nil,
	Enabled = true,
	MaxTorque = 10000,
	MaxAngularVelocity = 10000,
	Responsiveness = 10,
	CFrame = nil,
	Mode = nil,
	AlignType = nil,
}

return {
	class = "AlignOrientation",
	-- description: "Initializes the AlignOrientation instance."
	-- args: "instance: table"
	-- returns: "table"
	callback = function(instance)
		instance:SetProperties(propTable)
		return instance
	end,
	-- description: "Inherits the properties of the AlignOrientation class."
	-- args: "tble: table"
	inherit = function(tble)
		for prop, val in pairs(propTable) do
			tble[prop] = val
		end
	end,
}
