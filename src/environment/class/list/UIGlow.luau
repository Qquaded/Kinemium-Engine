-- description: "A glow effect for GUI components."
local Color3 = require("@Color3")

local propTable = {
	Color = Color3.new(1, 1, 1),
	Transparency = 0.65,	
	Blur = 8,
	Spread = 0,
	BlendMode = "Additive",
	Enabled = true,
	Name = "UIGlow",
	BaseClass = "Kinemium.uimodifier",
}

return {
	class = "UIGlow",
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
