-- description: "Creates clouds in the Environment"
local Color3 = require("@Color3")
local propTable = {
	Speed = 1,
	Color = Color3.new(1, 1, 1),
	Name = "Clouds",
}

return {
	class = "Clouds",

	callback = function(instance, renderer)
		propTable.render = function(effect, camera, lib) end

		-- Handled by lighting

		instance:SetProperties(propTable)
		return instance
	end,

	inherit = function(tble)
		for prop, val in pairs(propTable) do
			tble[prop] = val
		end
	end,
}
