-- description: "A corner radius modifier for UI elements."
local UDim = require("@UDim")

local propTable = {
	CornerRadius = UDim.new(0, 15),
	Name = "UICorner",
	BaseClass = "Kinemium.uimodifier",

	BottomLeftRadius = UDim.new(0, 15),
	BottomRightRadius = UDim.new(0, 15),
	TopLeftRadius = UDim.new(0, 15),
	TopRightRadius = UDim.new(0, 15),
}

return {
	class = "UICorner",
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
