-- description: "Represents a Backpack in the environment."
local propTable = {}

return {
	class = "Backpack",
	-- description: "Initializes the Backpack instance."
	-- args: "instance: table, renderer: number, game: table"
	-- returns: "table"
	callback = function(instance, renderer, game)
		instance:SetProperties(propTable)
		return instance
	end,
	-- description: "Inherits the properties of the Backpack class."
	-- args: "tble: table"
	inherit = function(tble)
		for prop, val in pairs(propTable) do
			tble[prop] = val
		end
	end,
}
