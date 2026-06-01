-- description: "A modifier class that adds a shadow effect to a GUI element."
local Color3 = require("@Color3")
local Vector2 = require("@Vector2")

local propTable = {
	Color = Color3.new(0, 0, 0),
	Transparency = 0.65,
	Offset = Vector2.new(0, 0),
	Blur = 8,
	Spread = 0,
	Enabled = true,
	Name = "UIShadow",
	BaseClass = "Kinemium.uimodifier",
}

return {
	class = "UIShadow",
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
