-- description: "Defines flex behavior for a GuiObject within a UIListLayout."
local Enum = require("@EnumMap")

local propTable = {
	Name = "UIFlexItem",

	FlexMode = Enum.UIFlexMode.None,
	GrowRatio = 1,
	ShrinkRatio = 1,
	ItemLineAlignment = Enum.ItemLineAlignment.Automatic,
}

return {
	class = "UIFlexItem",
	callback = function(instance)
		instance:SetProperties(propTable)
		return instance
	end,
}
