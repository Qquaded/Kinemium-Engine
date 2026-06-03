-- description: "Has a Value property which is a Brick Color value, and is Customizable."
local BrickColor = require("@BrickColor")

local propTable = {
	Value = BrickColor.Gray(),
}

return {
	class = "BrickColorValue",
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
