-- description: "Represents an UISquircle in the environment."
local UDim = require("@UDim")

local propTable = {
	CornerRadius = UDim.new(0, 15),
	Exponent = 4,
	Name = "UISquircle",
	BaseClass = "Kinemium.uimodifier",

	BottomLeftRadius = UDim.new(0, 0),
	BottomRightRadius = UDim.new(0, 0),
	TopLeftRadius = UDim.new(0, 0),
	TopRightRadius = UDim.new(0, 0),
}

return {
	class = "UISquircle",
	-- description: "Initializes the UISquircle instance."
	-- args: "instance: table"
	-- returns: "table"
	callback = function(instance)
		instance:SetProperties(propTable)
		return instance
	end,
	-- description: "Inherits the properties of the UISquircle class."
	-- args: "tble: table"
	inherit = function(tble)
		for prop, val in pairs(propTable) do
			tble[prop] = val
		end
	end,
}
