-- description: "Represents a PlayerGui in the environment."
local propTable = {}

return {
	class = "PlayerGui",
	-- description: "Initializes the PlayerGui instance."
	-- args: "instance: table, starterGui: table"
	-- returns: "table"
	callback = function(instance, starterGui)
		return instance
	end,
	-- description: "Inherits the properties of the PlayerGui class."
	-- args: "tble: table"
	inherit = function(tble)
		for prop, val in pairs(propTable) do
			tble[prop] = val
		end
	end,
}
