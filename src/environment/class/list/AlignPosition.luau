-- description: "Applies force to align an attachment with a target position or another attachment."
local propTable = {
	Name = "AlignPosition",
	Attachment0 = nil,
	Attachment1 = nil,
	Enabled = true,
	MaxForce = 10000,
	MaxVelocity = 10000,
	Responsiveness = 10,
	Position = nil,
	Mode = nil,
	ApplyAtCenterOfMass = false,
}

return {
	class = "AlignPosition",
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
