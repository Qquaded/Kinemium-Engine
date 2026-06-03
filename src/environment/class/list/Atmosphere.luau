-- description: `You know i would put something here but you know what? "The Atmosphere object pushes Roblox closer toward realistic environments where sunlight scatters in different ways depending on density and other air particle ..." my ass, For gods sake go get a job for once, Anyway an atmosphere object makes the environment "more realistic" or something, Often parented under Lighting.`
local Color3 = require("@Color3")

local propTable = {
	Name = "Atmosphere",
	BaseClass = "Kinemium.posteffect",

	Density = 0.3,
	Offset = 0,
	Color = Color3.new(0.5, 0.5, 0.5),
	Decay = Color3.new(0.5, 0.5, 0.5),
	Glare = 0,
	Haze = 0,
}

return {
	class = "Atmosphere",
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
