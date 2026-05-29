-- description: "Represents a Snap in the environment."
local propTable = {
	Name = "Snap",
}

return {
	class = "Snap",
	-- description: "Initializes the Snap instance."
	-- args: "instance: table"
	-- returns: "table"
	callback = function(instance)
		instance:SetProperties(propTable)

		-- TODO: Implement functionality

		return instance
	end,
	-- description: "Inherits the properties of the Snap class."
	-- args: "tble: table"
	inherit = function(tble)
		for prop, val in pairs(propTable) do
			tble[prop] = val
		end
	end,
}
