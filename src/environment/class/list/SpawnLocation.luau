-- description: "A point in the world that determines where a player spawns."
local Part = require("@Part")
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
