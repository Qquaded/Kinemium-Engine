-- description: "Represents an IKControl in the environment."
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
	-- description: "Initializes the IKControl instance."
	-- args: "instance: table, renderer: number, datamodel: table"
	-- returns: "table"
	callback = function(instance, renderer, datamodel)
		instance:SetProperties(propTable)
		return instance
	end,
	-- description: "Inherits the properties of the IKControl class."
	-- args: "tble: table"
	inherit = function(tble)
		for prop, val in pairs(propTable) do
			tble[prop] = val
		end
	end,
}
