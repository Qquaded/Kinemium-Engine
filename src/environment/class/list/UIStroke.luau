-- description: "Represents an UIStroke in the environment."
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
	-- description: "Initializes the UIStroke instance."
	-- args: "instance: table"
	-- returns: "table"
	callback = function(instance)
		instance:SetProperties(propTable)
		return instance
	end,
	-- description: "Inherits the properties of the UIStroke class."
	-- args: "tble: table"
	inherit = function(tble)
		for prop, val in pairs(propTable) do
			tble[prop] = val
		end
	end,
}
