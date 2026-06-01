-- description: "A post-processing effect that simulates sunlight rays or god rays."
local propTable = {
	Name = "SunRaysEffect",
	BaseClass = "Kinemium.posteffect",

	Intensity = 0.25,
	Spread = 0.1,
}

return {
	class = "SunRaysEffect",
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
