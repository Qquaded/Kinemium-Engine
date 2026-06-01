-- description: "A modifier class that adds a vignette effect to a GUI element."
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
