-- description: "Represents an UIGradient in the environment."
local ColorSequence = require("@ColorSequence")
local ColorSequenceKeypoint = require("@ColorSequenceKeypoint")
local Color3 = require("@Color3")

local propTable = {
	Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
		ColorSequenceKeypoint.new(1, Color3.new(0, 0, 0)),
	}),
	Rotation = 0,
	Name = "UIGradient",
	BaseClass = "Kinemium.uimodifier",
}

return {
	class = "UIGradient",
	-- description: "Initializes the UIGradient instance."
	-- args: "instance: table"
	-- returns: "table"
	callback = function(instance)
		instance:SetProperties(propTable)
		return instance
	end,
	-- description: "Inherits the properties of the UIGradient class."
	-- args: "tble: table"
	inherit = function(tble)
		for prop, val in pairs(propTable) do
			tble[prop] = val
		end
	end,
}
