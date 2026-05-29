-- description: "Represents an IntValue in the environment."
local propTable = {
	Value = 0,
}

return {
	class = "IntValue",
	-- description: "Initializes the IntValue instance."
	-- args: "instance: table"
	-- returns: "table"
	callback = function(instance)
		instance:SetProperties(propTable)
		return instance
	end,
	-- description: "Inherits the properties of the IntValue class."
	-- args: "tble: table"
	inherit = function(tble)
		for prop, val in pairs(propTable) do
			tble[prop] = val
		end
	end,
}
