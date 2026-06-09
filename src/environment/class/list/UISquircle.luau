-- description: "A modifier class that creates a squircle effect on a GUI element."
local UDim = require("@UDim")

local propTable = {
	CornerRadius = UDim.new(0, 0),
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
