-- description: "A modifier class that displays a tooltip when hovering over a GUI element."
local Vector2 = require("@Vector2")
local Color3 = require("@Color3")
local Enum = require("@EnumMap")
local adapter = require("@RaylibAdapter")
local RichText = require("@Kinemium.richtext")

local aereon = require("@Aereon")
local arect = aereon.rect()
local defaultFont = adapter.lib.GetFontDefault()

local propTable = {
	Name = "UITooltip",
	BackgroundColor3 = Color3.new(0, 0, 0),
	BackgroundTransparency = 0.3,
	TextColor3 = Color3.new(0, 0, 0),
	TextTransparency = 0,
	TextStrokeColor = Color3.new(0, 0, 0),
	TextStrokeTransparency = 1,
	TextSize = 18,
	Visible = true,
	Font = Enum.Font.DefaultEngineFont,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextYAlignment = Enum.TextYAlignment.Top,
	TextSpacing = 1,
	TextWrapped = false,
	TextTruncate = Enum.TextTruncate.None,
	TextScaled = false,
	RichText = false,
	MaxVisibleGraphemes = -1,
	LineHeight = 1,
	Text = "Hello World!",
}

return {
	class = "UITooltip",

	callback = function(instance)
		propTable.render = function(lib, object, dt, structs, renderer)
			if not object.Visible then
				return
			end
			if object.Parent then
				local adornee = object.Parent
				if adornee.BaseClass == "GuiObject" then
					local absolutePosition, absoluteSize = adornee.AbsolutePosition, adornee.AbsoluteSize

					if not absolutePosition or not absoluteSize then
						return
					end

					local new = arect.new(absolutePosition.X, absolutePosition.Y, absoluteSize.X, absoluteSize.Y)
					if arect.MouseIsInRect(new) then
						local position = adapter.lib.GetMousePosition()
						local framePos = Vector2.new(position.x + 5, position.y - object.TextSize - 3)
						local frameSize = Vector2.new(10000, math.max(object.TextSize * 4, 48))
						local layout, spacing = RichText.GetLayout(object, frameSize, renderer, defaultFont)
						if layout then
							RichText.DrawLayout(adapter.lib, object, framePos, frameSize, layout, spacing)
						end
					end
				end
			end
		end

		instance:SetProperties(propTable)

		return instance
	end,

	inherit = function(tble)
		for prop, val in pairs(propTable) do
			tble[prop] = val
		end
	end,
}
