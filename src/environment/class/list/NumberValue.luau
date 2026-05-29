-- description: "Represents a NumberValue in the environment."
local propTable = {
	Value = 0,
}

return {
	class = "NumberValue",
	-- description: "Initializes the NumberValue instance."
	-- args: "instance: table"
	-- returns: "table"
	callback = function(instance)
		instance:SetProperties(propTable)
		return instance
	end,
	-- description: "Inherits the properties of the NumberValue class."
	-- args: "tble: table"
	inherit = function(tble)
		for prop, val in pairs(propTable) do
			tble[prop] = val
		end
	end,
}
