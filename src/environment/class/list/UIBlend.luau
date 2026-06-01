-- description: "A blend effect for UI elements."
local propTable = {
	Mode = "Alpha",
	AffectSelf = true,
	AffectChildren = true,
	Enabled = true,
	Name = "UIBlend",
	BaseClass = "Kinemium.uimodifier",
}

return {
	class = "UIBlend",
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
