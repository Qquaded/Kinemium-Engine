-- description: "Represents an UITextSizeConstraint in the environment."
local propTable = {
	Name = "UITextSizeConstraint",
	BaseClass = "Kinemium.uimodifier",

	MaxTextSize = 100,
	MinTextSize = 1,
}

return {
	class = "UITextSizeConstraint",
	-- description: "Initializes the UITextSizeConstraint instance."
	-- args: "instance: table"
	-- returns: "table"
	callback = function(instance)
		instance:SetProperties(propTable)
		return instance
	end,
	-- description: "Inherits the properties of the UITextSizeConstraint class."
	-- args: "tble: table"
	inherit = function(tble)
		for prop, val in pairs(propTable) do
			tble[prop] = val
		end
	end,
}
