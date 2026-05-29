-- description: "Represents an UIMask in the environment."
local UDim2 = require("@UDim2")

local propTable = {
	Inset = UDim2.new(0, 0, 0, 0),
	Enabled = true,
	AffectChildren = true,
	Name = "UIMask",
	BaseClass = "Kinemium.uimodifier",
}

return {
	class = "UIMask",
	-- description: "Initializes the UIMask instance."
	-- args: "instance: table"
	-- returns: "table"
	callback = function(instance)
		instance:SetProperties(propTable)
		return instance
	end,
	-- description: "Inherits the properties of the UIMask class."
	-- args: "tble: table"
	inherit = function(tble)
		for prop, val in pairs(propTable) do
			tble[prop] = val
		end
	end,
}
