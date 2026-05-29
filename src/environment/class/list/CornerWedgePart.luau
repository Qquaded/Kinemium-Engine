-- description: "Represents a CornerWedgePart in the environment."
local Part = require("./Part")
local Enum = require("@EnumMap")

local propTable = {}
Part.inherit(propTable)

propTable.Shape = Enum.PartType.CornerWedge
propTable.Name = "CornerWedgePart"
propTable.BaseClass = "Part"

return {
	class = "CornerWedgePart",

	-- description: "Initializes the CornerWedgePart instance."
	-- args: "instance: table, renderer: number, game: table"
	-- returns: "table"
	callback = function(instance, renderer, game)
		Part.callback(instance, renderer, game)
		instance:SetProperties(propTable)
		return instance
	end,

	-- description: "Inherits the properties of the CornerWedgePart class."
	-- args: "tble: table"
	inherit = function(tble)
		for prop, val in pairs(propTable) do
			tble[prop] = val
		end
	end,
}
