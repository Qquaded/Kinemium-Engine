-- description: "Represents an UIBevel in the environment."
local Color3 = require("@Color3")

local propTable = {
	LightColor = Color3.new(1, 1, 1),
	LightTransparency = 0.45,
	ShadowColor = Color3.new(0, 0, 0),
	ShadowTransparency = 0.65,
	Thickness = 2,
	Style = "Raised",
	Enabled = true,
	Name = "UIBevel",
	BaseClass = "Kinemium.uimodifier",
}

return {
	class = "UIBevel",
	-- description: "Initializes the UIBevel instance."
	-- args: "instance: table"
	-- returns: "table"
	callback = function(instance)
		instance:SetProperties(propTable)
		return instance
	end,
	-- description: "Inherits the properties of the UIBevel class."
	-- args: "tble: table"
	inherit = function(tble)
		for prop, val in pairs(propTable) do
			tble[prop] = val
		end
	end,
}
