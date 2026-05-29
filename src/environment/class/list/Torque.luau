-- description: "Represents a Torque in the environment."
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
	-- description: "Initializes the Torque instance."
	-- args: "instance: table"
	-- returns: "table"
	callback = function(instance)
		instance:SetProperties(propTable)
		return instance
	end,
	-- description: "Inherits the properties of the Torque class."
	-- args: "tble: table"
	inherit = function(tble)
		for prop, val in pairs(propTable) do
			tble[prop] = val
		end
	end,
}
