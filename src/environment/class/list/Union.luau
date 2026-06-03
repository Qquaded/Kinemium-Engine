-- description: "A modifier class that combines multiple parts into a single union."
local Part = require("./Part")

local propTable = {
	Name = "Union",
}
Part.inherit(propTable)

return {
	class = "Union",

	callback = function(instance, renderer, game)
		Part.callback(instance, renderer, game)
		
		propTable.render = function(part, camera, lib) end
		instance:SetProperties(propTable)

		return instance
	end,

	inherit = function(tble)
		for prop, val in pairs(propTable) do
			tble[prop] = val
		end
	end,
}
