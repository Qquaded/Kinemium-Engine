-- description: "Applies torque to align two attachments or an attachment and a goal orientation."
local propTable = {
	Name = "AlignOrientation",
	Attachment0 = nil,
	Attachment1 = nil,
	Enabled = true,
	MaxTorque = 10000,
	MaxAngularVelocity = 10000,
	Responsiveness = 10,
	CFrame = nil,
	Mode = nil,
	AlignType = nil,
}

return {
	class = "AlignOrientation",
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
