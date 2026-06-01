-- description: "A script that runs on the server to handle server-side gameplay logic."
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
