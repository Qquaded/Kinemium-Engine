-- description: "A bevel effect for UI elements."
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
