-- description: "Represents a Bone in the environment."
local CFrame = require("@CFrame")

local propTable = {
	Name = "Bone",
	BaseClass = "Kinemium.attachment",

	Transform = CFrame.new(),
}

return {
	class = "Bone",
	-- description: "Initializes the Bone instance."
	-- args: "instance: table"
	-- returns: "table"
	callback = function(instance)
		instance:SetProperties(propTable)
		return instance
	end,
	-- description: "Inherits the properties of the Bone class."
	-- args: "tble: table"
	inherit = function(tble)
		for prop, val in pairs(propTable) do
			tble[prop] = val
		end
	end,
}
