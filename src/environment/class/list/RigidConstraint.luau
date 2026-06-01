-- description: "Rigidly connects two attachments, preventing any relative movement between them."
local propTable = {
	Name = "RigidConstraint",
	BaseClass = "Kinemium.constraint",

	Attachment0 = nil,
	Attachment1 = nil,
	Enabled = true,
	Visible = false,
}

return {
	class = "RigidConstraint",
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
