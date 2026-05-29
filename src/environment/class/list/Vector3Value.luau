-- description: "Represents a Vector3Value in the environment."
local Vector3 = require("@Vector3")

local propTable = {
	Value = Vector3.new(0, 0, 0),
}

return {
	class = "Vector3Value",
	-- description: "Initializes the Vector3Value instance."
	-- args: "instance: table"
	-- returns: "table"
	callback = function(instance)
		instance:SetProperties(propTable)
		return instance
	end,
	-- description: "Inherits the properties of the Vector3Value class."
	-- args: "tble: table"
	inherit = function(tble)
		for prop, val in pairs(propTable) do
			tble[prop] = val
		end
	end,
}
