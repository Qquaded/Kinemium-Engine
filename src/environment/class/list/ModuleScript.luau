-- description: "A reusable code module that exposes functions, tables, or data to other scripts."
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

	callback = function(instance)
		instance:SetProperties(propTable)

		return instance
	end,

	inherit = function(tble)
		for prop, val in pairs(propTable) do
			tble[prop] = val
		end
	end,
}
