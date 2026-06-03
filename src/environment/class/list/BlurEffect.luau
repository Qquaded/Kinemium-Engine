-- description: "Creates a blur effect in the Environment, Parented under Lighting."
local propTable = {
	Size = 5.0,
	Enabled = true,
	Name = "BlurEffect",
}

return {
	class = "BlurEffect",
	callback = function(instance, renderer)
		propTable.render = function(effect, camera, lib) end

		instance:SetProperties(propTable)
		return instance
	end,

	inherit = function(tble)
		for prop, val in pairs(propTable) do
			tble[prop] = val
		end
	end,
}
