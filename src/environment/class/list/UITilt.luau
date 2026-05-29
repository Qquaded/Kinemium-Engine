-- description: "Represents an UITilt in the environment."
local Vector2 = require("@Vector2")

local propTable = {
	MaxOffset = Vector2.new(6, 6),
	Enabled = true,
	Name = "UITilt",
	BaseClass = "Kinemium.uimodifier",
}

return {
	class = "UITilt",
	-- description: "Initializes the UITilt instance."
	-- args: "instance: table"
	-- returns: "table"
	callback = function(instance)
		instance:SetProperties(propTable)
		return instance
	end,
	-- description: "Inherits the properties of the UITilt class."
	-- args: "tble: table"
	inherit = function(tble)
		for prop, val in pairs(propTable) do
			tble[prop] = val
		end
	end,
}
