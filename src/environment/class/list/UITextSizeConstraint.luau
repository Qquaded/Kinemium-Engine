-- description: "A modifier class that constrains the text size of a GUI element."
local propTable = {
	Name = "UITextSizeConstraint",
	BaseClass = "Kinemium.uimodifier",

	MaxTextSize = 100,
	MinTextSize = 1,
}

return {
	class = "UITextSizeConstraint",
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
