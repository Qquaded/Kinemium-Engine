-- description: "Represents a Clouds in the environment."
local Color3 = require("@Color3")
local propTable = {
	Speed = 1,
	Color = Color3.new(1, 1, 1),
	Name = "Clouds",
}

return {
	class = "Clouds",

	-- description: "Initializes the Clouds instance."
	-- args: "instance: table, renderer: number"
	-- returns: "table"
	callback = function(instance, renderer)
		-- description: "Renders the component."
		-- args: "effect: table, camera: number, lib: number"
		propTable.render = function(effect, camera, lib) end

		-- Handled by lighting

		instance:SetProperties(propTable)
		return instance
	end,

	-- description: "Inherits the properties of the Clouds class."
	-- args: "tble: table"
	inherit = function(tble)
		for prop, val in pairs(propTable) do
			tble[prop] = val
		end
	end,
}
