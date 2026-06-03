-- description: "A mask that clips child content to a specified area."
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
