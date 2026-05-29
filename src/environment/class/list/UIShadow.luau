-- description: "Represents an UIShadow in the environment."
local Color3 = require("@Color3")
local Vector2 = require("@Vector2")

local propTable = {
	Color = Color3.new(0, 0, 0),
	Transparency = 0.65,
	Offset = Vector2.new(0, 0),
	Blur = 8,
	Spread = 0,
	Enabled = true,
	Name = "UIShadow",
	BaseClass = "Kinemium.uimodifier",
}

return {
	class = "UIShadow",
	-- description: "Initializes the UIShadow instance."
	-- args: "instance: table"
	-- returns: "table"
	callback = function(instance)
		instance:SetProperties(propTable)
		return instance
	end,
	-- description: "Inherits the properties of the UIShadow class."
	-- args: "tble: table"
	inherit = function(tble)
		for prop, val in pairs(propTable) do
			tble[prop] = val
		end
	end,
}
