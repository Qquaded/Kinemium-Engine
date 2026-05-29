-- description: "Represents a Configuration in the environment."
local propTable = {
	Name = "Configuration",
}

return {
	class = "Configuration",
	-- description: "Initializes the Configuration instance."
	-- args: "instance: table"
	-- returns: "table"
	callback = function(instance)
		instance:SetProperties(propTable)
		return instance
	end,
	-- description: "Inherits the properties of the Configuration class."
	-- args: "tble: table"
	inherit = function(tble)
		for prop, val in pairs(propTable) do
			tble[prop] = val
		end
	end,
}
