-- description: "A modifier class that creates a squircle effect on a GUI element."
local UDim = require("@UDim")

local propTable = {
	CornerRadius = UDim.new(0, 0),
	Exponent = 4,
	Name = "UISquircle",
	BaseClass = "Kinemium.uimodifier",

	BottomLeftRadius = UDim.new(0, 15),
	BottomRightRadius = UDim.new(0, 15),
	TopLeftRadius = UDim.new(0, 15),
	TopRightRadius = UDim.new(0, 15),
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
