-- description: "Represents a WedgePart in the environment."
local Part = require("./Part")
local Enum = require("@EnumMap")

local propTable = {
	Name = "WedgePart",
	Shape = Enum.PartType.Wedge,
}

return {
	class = "WedgePart",
	-- description: "Initializes the WedgePart instance."
	-- args: "instance: table, renderer: number, game: table"
	-- returns: "table"
	callback = function(instance, renderer, game)
		Part.callback(instance, renderer, game)
		instance:SetProperties(propTable)
		return instance
	end,

	-- description: "Inherits the properties of the WedgePart class."
	-- args: "tble: table"
	inherit = function(tble)
		for prop, val in pairs(propTable) do
			tble[prop] = val
		end
	end,
}
