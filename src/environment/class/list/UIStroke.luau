-- description: "A modifier class that adds a stroke (border) effect to a GUI element."
local Color3 = require("@Color3")

local propTable = {
	Thickness = 1,
	Color = Color3.new(0, 0, 0),
	Transparency = 0,
	ApplyStrokeMode = "Border",
	Name = "UIStroke",
	BaseClass = "Kinemium.uimodifier",
}

return {
	class = "UIStroke",
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
