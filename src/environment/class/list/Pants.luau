-- description: "Represents a Pants in the environment."
local Color3 = require("@Color3")

local propTable = {
	Name = "Pants",
	BaseClass = "Kinemium.instance",

	PantsTemplate = "",
	Color3 = Color3.new(1, 1, 1),
}

return {
	class = "Pants",
	-- description: "Initializes the Pants instance."
	-- args: "instance: table"
	-- returns: "table"
	callback = function(instance)
		instance:SetProperties(propTable)
		return instance
	end,
	-- description: "Inherits the properties of the Pants class."
	-- args: "tble: table"
	inherit = function(tble)
		for prop, val in pairs(propTable) do
			tble[prop] = val
		end
	end,
}
