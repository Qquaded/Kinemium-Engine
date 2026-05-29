-- description: "Represents a LocalScript in the environment."
local Enum = require("@EnumMap")

local propTable = {
	Name = "LocalScript",
	BaseClass = "ScriptContainer",
	Source = [[print("Hello World!")]],
	RunContext = Enum.RunContext.Client,
	Language = Enum.Language.Luau,
}

return {
	class = "LocalScript",
	-- description: "Initializes the LocalScript instance."
	-- args: "instance: table"
	-- returns: "table"
	callback = function(instance)
		instance:SetProperties(propTable)

		return instance
	end,
	-- description: "Inherits the properties of the LocalScript class."
	-- args: "tble: table"
	inherit = function(tble)
		for prop, val in pairs(propTable) do
			tble[prop] = val
		end
	end,
}
