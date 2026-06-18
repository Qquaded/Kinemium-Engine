-- description: "A Corner Wedge shape type for Part."
local Part = require("@Part")
local Enum = require("@EnumMap")

local propTable = {}
Part.inherit(propTable)

propTable.Shape = Enum.PartType.CornerWedge
propTable.Name = "CornerWedgePart"
propTable.BaseClass = "Part"

return {
	class = "CornerWedgePart",

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
