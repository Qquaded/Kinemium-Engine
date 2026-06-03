-- description: "Applies a torque to an object."
local Vector3 = require("@Vector3")
local propTable = {
	Name = "Torque",
	Attachment0 = nil,
	Attachment1 = nil,
	Enabled = true,
	Torque = Vector3.new(0,0,0),
	RelativeTo = nil,
}

return {
	class = "Torque",
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
