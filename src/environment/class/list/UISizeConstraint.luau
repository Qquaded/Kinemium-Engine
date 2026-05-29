-- description: "Represents an UISizeConstraint in the environment."
local Vector2 = require("@Vector2")

local propTable = {
	Name = "UISizeConstraint",
	BaseClass = "Kinemium.uimodifier",

	MaxSize = Vector2.new(math.huge, math.huge),
	MinSize = Vector2.new(0, 0),
}

return {
	class = "UISizeConstraint",
	-- description: "Initializes the UISizeConstraint instance."
	-- args: "instance: table"
	-- returns: "table"
	callback = function(instance)
		instance:SetProperties(propTable)
		return instance
	end,
	-- description: "Inherits the properties of the UISizeConstraint class."
	-- args: "tble: table"
	inherit = function(tble)
		for prop, val in pairs(propTable) do
			tble[prop] = val
		end
	end,
}
