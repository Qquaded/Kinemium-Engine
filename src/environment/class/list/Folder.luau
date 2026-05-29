-- description: "Represents a Folder in the environment."
local Color3 = require("@Color3")

local propTable = {
	Name = "Folder",
}

return {
	class = "Folder",
	-- description: "Initializes the Folder instance."
	-- args: "instance: table"
	-- returns: "table"
	callback = function(instance)
		instance:SetProperties(propTable)

		return instance
	end,
	-- description: "Inherits the properties of the Folder class."
	-- args: "tble: table"
	inherit = function(tble)
		for prop, val in pairs(propTable) do
			tble[prop] = val
		end
	end,
}
