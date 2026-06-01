-- description: "A GUI Effect class that works best under buttons like TextButton or ImageButton."
local Color3 = require("@Color3")

local propTable = {
	Color = Color3.new(1, 1, 1),
	Transparency = 0.45,
	Duration = 0.6,
	MaxRadiusScale = 1.2,
	Fill = true,
	Thickness = 2,
	BlendMode = "Alpha",
	Enabled = true,
	Name = "UIRipple",
	BaseClass = "Kinemium.uimodifier",
}

return {
	class = "UIRipple",

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
