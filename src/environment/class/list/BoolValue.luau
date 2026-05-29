-- description: "Represents a BoolValue in the environment."
local propTable = {
	Value = false,
}

return {
	class = "BoolValue",
	-- description: "Initializes the BoolValue instance."
	-- args: "instance: table"
	-- returns: "table"
	callback = function(instance)
		instance:SetProperties(propTable)
		return instance
	end,
	-- description: "Inherits the properties of the BoolValue class."
	-- args: "tble: table"
	inherit = function(tble)
		for prop, val in pairs(propTable) do
			tble[prop] = val
		end
	end,
}
