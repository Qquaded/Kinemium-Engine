-- description: "A modifier class that adds a tilt effect to a GUI element based on mouse position."
local Vector2 = require("@Vector2")

local propTable = {
	MaxOffset = Vector2.new(6, 6),
	Enabled = true,
	Name = "UITilt",
	BaseClass = "Kinemium.uimodifier",
}

return {
	class = "UITilt",
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
