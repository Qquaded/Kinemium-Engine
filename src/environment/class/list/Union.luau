-- description: "Represents an Union in the environment."
local Part = require("./Part")

local propTable = {
	Name = "Union",
}
Part.inherit(propTable)

return {
	class = "Union",

	-- description: "Initializes the Union instance."
	-- args: "instance: table, renderer: number, game: table"
	-- returns: "table"
	callback = function(instance, renderer, game)
		Part.callback(instance, renderer, game)
		
		-- description: "Renders the component."
		-- args: "part: any, camera: number, lib: number"
		propTable.render = function(part, camera, lib) end
		instance:SetProperties(propTable)

		return instance
	end,

	-- description: "Inherits the properties of the Union class."
	-- args: "tble: table"
	inherit = function(tble)
		for prop, val in pairs(propTable) do
			tble[prop] = val
		end
	end,
}
