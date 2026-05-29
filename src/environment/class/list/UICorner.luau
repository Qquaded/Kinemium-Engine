-- description: "Represents an UICorner in the environment."
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
	-- description: "Initializes the UICorner instance."
	-- args: "instance: table"
	-- returns: "table"
	callback = function(instance)
		instance:SetProperties(propTable)
		return instance
	end,
	-- description: "Inherits the properties of the UICorner class."
	-- args: "tble: table"
	inherit = function(tble)
		for prop, val in pairs(propTable) do
			tble[prop] = val
		end
	end,
}
