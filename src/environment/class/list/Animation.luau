-- description: "Represents an Animation object that can be loaded and played by the Animator Instance (mainly used by Humanoids)."
local propTable = {
	AnimationId = "",
}

return {
	class = "Animation",
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
