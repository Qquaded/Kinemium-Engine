-- description: "A script that runs on the client to handle local gameplay logic."
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
