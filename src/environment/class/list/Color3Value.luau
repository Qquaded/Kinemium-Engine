-- description: "Represents a Color3Value in the environment."
local Color3 = require("@Color3")

local propTable = {
	Value = Color3.new(0, 0, 0),
}

return {
	class = "Color3Value",
	-- description: "Initializes the Color3Value instance."
	-- args: "instance: table"
	-- returns: "table"
	callback = function(instance)
		instance:SetProperties(propTable)
		return instance
	end,
	-- description: "Inherits the properties of the Color3Value class."
	-- args: "tble: table"
	inherit = function(tble)
		for prop, val in pairs(propTable) do
			tble[prop] = val
		end
	end,
}
