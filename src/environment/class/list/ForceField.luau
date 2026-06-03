-- description: "Protects the humanoid."
local propTable = {
	Name = "ForceField",
	BaseClass = "Kinemium.instance",

	Visible = true,
}

return {
	class = "ForceField",
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
