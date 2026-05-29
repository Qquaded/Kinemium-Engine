-- description: "Represents a DataModel in the environment."
local propTable = {
	Name = "DataModel",
}

return {
	class = "DataModel",
	non_creatable = true,

	-- description: "Initializes the DataModel instance."
	-- args: "instance: table"
	-- returns: "table"
	callback = function(instance)
		instance:SetProperties(propTable)
		return instance
	end,
	-- description: "Inherits the properties of the DataModel class."
	-- args: "tble: table"
	inherit = function(tble)
		for prop, val in pairs(propTable) do
			tble[prop] = val
		end
	end,
}
