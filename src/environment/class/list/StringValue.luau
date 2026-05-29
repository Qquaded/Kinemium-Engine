-- description: "Represents a StringValue in the environment."
local propTable = {
	Value = "",
}

return {
	class = "StringValue",
	-- description: "Initializes the StringValue instance."
	-- args: "instance: table"
	-- returns: "table"
	callback = function(instance)
		instance:SetProperties(propTable)
		return instance
	end,
	-- description: "Inherits the properties of the StringValue class."
	-- args: "tble: table"
	inherit = function(tble)
		for prop, val in pairs(propTable) do
			tble[prop] = val
		end
	end,
}
