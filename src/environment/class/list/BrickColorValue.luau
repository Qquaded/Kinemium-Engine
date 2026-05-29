-- description: "Represents a BrickColorValue in the environment."
local BrickColor = require("@BrickColor")

local propTable = {
	Value = BrickColor.Gray(),
}

return {
	class = "BrickColorValue",
	-- description: "Initializes the BrickColorValue instance."
	-- args: "instance: table"
	-- returns: "table"
	callback = function(instance)
		instance:SetProperties(propTable)
		return instance
	end,
	-- description: "Inherits the properties of the BrickColorValue class."
	-- args: "tble: table"
	inherit = function(tble)
		for prop, val in pairs(propTable) do
			tble[prop] = val
		end
	end,
}
