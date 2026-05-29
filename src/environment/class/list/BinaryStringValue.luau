-- description: "Represents a BinaryStringValue in the environment."
local propTable = {
	BinaryString = "",
}

return {
	class = "BinaryStringValue",
	-- description: "Initializes the BinaryStringValue instance."
	-- args: "instance: table"
	-- returns: "table"
	callback = function(instance)
		instance:SetProperties(propTable)
		return instance
	end,
	-- description: "Inherits the properties of the BinaryStringValue class."
	-- args: "tble: table"
	inherit = function(tble)
		for prop, val in pairs(propTable) do
			tble[prop] = val
		end
	end,
}
