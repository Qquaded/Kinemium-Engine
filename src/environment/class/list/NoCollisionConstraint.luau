-- description: "Prevents collision between two attachments or parts."
local propTable = {
	Name = "NoCollisionConstraint",
	BaseClass = "Kinemium.constraint",

	Part0 = nil,
	Part1 = nil,
	Enabled = true,
}

return {
	class = "NoCollisionConstraint",
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
