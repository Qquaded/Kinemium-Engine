-- description: "Represents an UIGlow in the environment."
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
	-- description: "Initializes the UIGlow instance."
	-- args: "instance: table"
	-- returns: "table"
	callback = function(instance)
		instance:SetProperties(propTable)
		return instance
	end,
	-- description: "Inherits the properties of the UIGlow class."
	-- args: "tble: table"
	inherit = function(tble)
		for prop, val in pairs(propTable) do
			tble[prop] = val
		end
	end,
}
