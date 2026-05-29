-- description: "Represents a ModuleScript in the environment."
local Enum = require("@EnumMap")

local propTable = {
	Name = "ModuleScript",
	BaseClass = "ScriptContainer",
	ClassName = "ModuleScript",
	Source = [[]],
	RunContext = Enum.RunContext.Client,
	Language = Enum.Language.Luau,
}

return {
	class = "ModuleScript",
	-- description: "Initializes the ModuleScript instance."
	-- args: "instance: table"
	-- returns: "table"
	callback = function(instance)
		instance:SetProperties(propTable)

		return instance
	end,
	-- description: "Inherits the properties of the ModuleScript class."
	-- args: "tble: table"
	inherit = function(tble)
		for prop, val in pairs(propTable) do
			tble[prop] = val
		end
	end,
}
