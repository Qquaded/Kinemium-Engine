-- description: "Represents a ValueBase in the environment."
local propTable = {
	Value = nil,
}

return {
	class = "ValueBase",
	-- description: "Initializes the ValueBase instance."
	-- args: "instance: table"
	-- returns: "table"
	callback = function(instance)
		instance:SetProperties(propTable)
		return instance
	end,
	-- description: "Inherits the properties of the ValueBase class."
	-- args: "tble: table"
	inherit = function(tble)
		for prop, val in pairs(propTable) do
			tble[prop] = val
		end
	end,
}
