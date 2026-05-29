-- description: "Represents an UIVignette in the environment."
local Color3 = require("@Color3")

local propTable = {
	Color = Color3.new(0, 0, 0),
	Transparency = 0.7,
	Thickness = 18,
	Steps = 8,
	Enabled = true,
	Name = "UIVignette",
	BaseClass = "Kinemium.uimodifier",
}

return {
	class = "UIVignette",
	-- description: "Initializes the UIVignette instance."
	-- args: "instance: table"
	-- returns: "table"
	callback = function(instance)
		instance:SetProperties(propTable)
		return instance
	end,
	-- description: "Inherits the properties of the UIVignette class."
	-- args: "tble: table"
	inherit = function(tble)
		for prop, val in pairs(propTable) do
			tble[prop] = val
		end
	end,
}
