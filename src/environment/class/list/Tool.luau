-- description: "A tool that can be equipped and used by players."
local CFrame = require("@CFrame")
local signal = require("@Kinemium.signal")

local propTable = {
	Enabled = true,
	RequiresHandle = true,
	Grip = CFrame.new(),
	ToolTip = "",
	TextureId = "",

	Activate = signal.new(),
	Deactivate = signal.new(),
	Equipped = signal.new(),
	Unequipped = signal.new(),
}

return {
	class = "Tool",
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
