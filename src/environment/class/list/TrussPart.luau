-- description: "Creates a lightweight truss structure using repeated mesh instances."
local Part = require("@Part")

local propTable = {
	Name = "TrussPart",
	Style = 0,
}

return {
	class = "TrussPart",
	callback = function(instance, renderer, game)
		Part.callback(instance, renderer, game)
		instance:SetProperties(propTable)

		-- TODO: Implement functionality, use custom repeating mesh

		return instance
	end,

	inherit = function(tble)
		for prop, val in pairs(propTable) do
			tble[prop] = val
		end
	end,
}
