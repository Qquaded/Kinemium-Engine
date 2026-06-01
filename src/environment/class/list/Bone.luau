-- description: "Bone attachment, Not used for anything currently."
local CFrame = require("@CFrame")

local propTable = {
	Name = "Bone",
	BaseClass = "Kinemium.attachment",

	Transform = CFrame.new(),
}

return {
	class = "Bone",
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
