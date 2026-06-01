-- description: "Simple instance, I think you know what it is."
local propTable = {
	Name = "Configuration",
}

return {
	class = "Configuration",
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
