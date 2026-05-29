-- description: "Represents a Script in the environment."
local Enum = require("@EnumMap")

local propTable = {
	Name = "Script",
	BaseClass = "ScriptContainer",
	Source = [[print("Hello World!")]],
	RunContext = Enum.RunContext.Server,
	Language = Enum.Language.Luau,
}

return {
	class = "Script",
	-- description: "Initializes the Script instance."
	-- args: "instance: table"
	-- returns: "table"
	callback = function(instance)
		instance:SetProperties(propTable)

		return instance
	end,
	-- description: "Inherits the properties of the Script class."
	-- args: "tble: table"
	inherit = function(tble)
		for prop, val in pairs(propTable) do
			tble[prop] = val
		end
	end,
}
