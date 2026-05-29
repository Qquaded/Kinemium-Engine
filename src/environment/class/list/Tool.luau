-- description: "Represents a Tool in the environment."
local CFrame = require("@CFrame")

local propTable = {
	Enabled = true,
	RequiresHandle = true,
	Grip = CFrame.new(),
	ToolTip = "",
	TextureId = "",
}

return {
	class = "Tool",
	-- description: "Initializes the Tool instance."
	-- args: "instance: table"
	-- returns: "table"
	callback = function(instance)
		instance:SetProperties(propTable)
		return instance
	end,
	-- description: "Inherits the properties of the Tool class."
	-- args: "tble: table"
	inherit = function(tble)
		for prop, val in pairs(propTable) do
			tble[prop] = val
		end
	end,
}
