-- description: "Represents an UIPageLayout in the environment."
local UDim = require("@UDim")

local propTable = {
	Name = "UIPageLayout",
	BaseClass = "Kinemium.uimodifier",

	Animated = true,
	Circular = false,
	EasingDirection = 1, -- Enum
	EasingStyle = 1, -- Enum
	FillDirection = 1, -- Enum
	GamepadInputEnabled = true,
	HorizontalAlignment = 1, -- Enum
	Padding = UDim.new(0, 0),
	ScrollWheelInputEnabled = true,
	SortOrder = 1, -- Enum
	TouchInputEnabled = true,
	TweenTime = 1,
	VerticalAlignment = 1, -- Enum
}

return {
	class = "UIPageLayout",
	-- description: "Initializes the UIPageLayout instance."
	-- args: "instance: table"
	-- returns: "table"
	callback = function(instance)
		instance:SetProperties(propTable)
		return instance
	end,
	-- description: "Inherits the properties of the UIPageLayout class."
	-- args: "tble: table"
	inherit = function(tble)
		for prop, val in pairs(propTable) do
			tble[prop] = val
		end
	end,
}
