-- description: "Represents an UIScale in the environment."
local propTable = {
	Name = "UIScale",
	BaseClass = "Kinemium.uimodifier",

	Scale = 1,
}

return {
	class = "UIScale",
	-- description: "Initializes the UIScale instance."
	-- args: "instance: table"
	-- returns: "table"
	callback = function(instance)
		instance:SetProperties(propTable)
		return instance
	end,
	-- description: "Inherits the properties of the UIScale class."
	-- args: "tble: table"
	inherit = function(tble)
		for prop, val in pairs(propTable) do
			tble[prop] = val
		end
	end,
}
