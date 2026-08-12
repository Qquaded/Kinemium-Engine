-- description: "A GUI component class that can be used under a gui container."
local GuiObject = require("@GuiObject")
local Color3 = require("@Color3")
local UDim2 = require("@UDim2")
local Enum = require("@EnumMap")

local Aereon = require("@Aereon")
local gui = Aereon.gui

local propTable = {
	Name = "UIBadge",
	BaseClass = "GuiObject",
	AbsoluteSize = nil,
	AbsolutePosition = nil,
	Size = UDim2.new(0, 18, 0, 18),
	Text = "1",
	Font = Enum.Font.DefaultEngineFont,
	FontSize = 12,
	Spacing = 1,
	BackgroundColor3 = Color3.new(1, 0.2, 0.2),
	TextColor3 = Color3.new(1, 1, 1),
	MinWidth = 18,
	Visible = true,
}

GuiObject.inherit(propTable)

return {
	class = "UIBadge",

	callback = function(instance, renderer, game)
		local function resolveFont(fontEnum)
			local name = fontEnum and fontEnum.Value or "DefaultEngineFont"
			local resolvedFont = renderer.Font.Get(name) or defaultFont
			return resolvedFont
		end

		local badge = gui.badge({
			x = 0,
			y = 0,
			text = instance.Text,
			fontSize = instance.FontSize,
			spacing = instance.Spacing,
			backgroundColor = instance.BackgroundColor3,
			textColor = instance.TextColor3,
			minWidth = instance.MinWidth,
		})

		instance:SetProperties(propTable)
		instance._badge = badge

		instance.render = function(lib, object, dt, structs, renderer)
			if object.Visible == false then
				return
			end

			local pos, size = GuiObject.calculatePositions(lib, object, dt, structs, renderer)

			if not badge then
				badge = gui.badge({
					x = 0,
					y = 0,
					text = instance.Text,
					fontSize = instance.FontSize,
					spacing = instance.Spacing,
					backgroundColor = instance.BackgroundColor3,
					textColor = instance.TextColor3,
					minWidth = instance.MinWidth,
				})
				instance._badge = badge
			end

			badge.set("x", pos.X)
			badge.set("y", pos.Y)
			badge.setText(tostring(object.Text))
			badge.set("font", resolveFont(object.Font))
			badge.set("fontSize", tonumber(object.FontSize) or 12)
			badge.set("spacing", tonumber(object.Spacing) or 1)
			badge.set("backgroundColor", object.BackgroundColor3)
			badge.set("textColor", object.TextColor3)
			badge.set("minWidth", tonumber(object.MinWidth) or 18)

			badge.render(dt)

			return pos, size
		end

		return instance
	end,

	inherit = function(tble)
		GuiObject.inherit(tble)
	end,
}
