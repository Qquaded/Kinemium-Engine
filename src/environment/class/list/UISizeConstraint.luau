-- description: "A modifier class that constrains the size of a GUI element."
local Vector2 = require("@Vector2")

local propTable = {
	Name = "UISizeConstraint",
	BaseClass = "Kinemium.uimodifier",

	MaxSize = Vector2.new(math.huge, math.huge),
	MinSize = Vector2.new(0, 0),
}

return {
	class = "UISizeConstraint",
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
