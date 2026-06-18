-- description: "A wedge shape type part."
local Part = require("@Part")
local Enum = require("@EnumMap")

local propTable = {
	Name = "WedgePart",
	Shape = Enum.PartType.Wedge,
}

return {
	class = "WedgePart",
	callback = function(instance, renderer, game)
		Part.callback(instance, renderer, game)
		instance:SetProperties(propTable)
		return instance
	end,

	inherit = function(tble)
		for prop, val in pairs(propTable) do
			tble[prop] = val
		end
	end,
}
