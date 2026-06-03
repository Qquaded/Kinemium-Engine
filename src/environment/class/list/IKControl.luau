-- description: "Used for Inverse Kinematics."
local Enum = require("@EnumMap")

local propTable = {
	Enabled = true,
	Target = nil,
	EndEffector = nil,
	ChainRoot = nil,
	Type = Enum.IKControlType.Transform,
	Weight = 1,
	Pole = nil,
}

return {
	class = "IKControl",

	callback = function(instance, renderer, datamodel)
		instance:SetProperties(propTable)
		return instance
	end,

	inherit = function(tble)
		for prop, val in pairs(propTable) do
			tble[prop] = val
		end
	end,
}
