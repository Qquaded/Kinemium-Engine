-- description: "Represents an ObjectValue in the environment."
local propTable = {
	Value = nil,
}

return {
	class = "ObjectValue",
	-- description: "Initializes the ObjectValue instance."
	-- args: "instance: table"
	-- returns: "table"
	callback = function(instance)
		instance:SetProperties(propTable)
		return instance
	end,
	-- description: "Inherits the properties of the ObjectValue class."
	-- args: "tble: table"
	inherit = function(tble)
		for prop, val in pairs(propTable) do
			tble[prop] = val
		end
	end,
}
