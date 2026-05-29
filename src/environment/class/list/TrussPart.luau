-- description: "Represents a TrussPart in the environment."
local Part = require("./Part")

local propTable = {
	Name = "TrussPart",
	Style = 0,
}

return {
	class = "TrussPart",
	-- description: "Initializes the TrussPart instance."
	-- args: "instance: table, renderer: number, game: table"
	-- returns: "table"
	callback = function(instance, renderer, game)
		Part.callback(instance, renderer, game)
		instance:SetProperties(propTable)

		-- TODO: Implement functionality, use custom repeating mesh

		return instance
	end,

	-- description: "Inherits the properties of the TrussPart class."
	-- args: "tble: table"
	inherit = function(tble)
		for prop, val in pairs(propTable) do
			tble[prop] = val
		end
	end,
}
