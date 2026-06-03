-- description: "A layout class that affects the positioning of gui objects."
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
