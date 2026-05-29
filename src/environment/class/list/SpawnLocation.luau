-- description: "Represents a SpawnLocation in the environment."
local Part = require("./Part")
local BrickColor = require("@BrickColor")

local propTable = {}
Part.inherit(propTable)

propTable.AllowTeamChangeOnTouch = false
propTable.Duration = 0
propTable.Enabled = true
propTable.Neutral = true
propTable.TeamColor = BrickColor.Gray()
propTable.Name = "SpawnLocation"
propTable.BaseClass = "Part"

return {
	class = "SpawnLocation",

	-- description: "Initializes the SpawnLocation instance."
	-- args: "instance: table, renderer: number, game: table"
	-- returns: "table"
	callback = function(instance, renderer, game)
		Part.callback(instance, renderer, game)
		instance:SetProperties(propTable)
		return instance
	end,

	-- description: "Inherits the properties of the SpawnLocation class."
	-- args: "tble: table"
	inherit = function(tble)
		for prop, val in pairs(propTable) do
			tble[prop] = val
		end
	end,
}
