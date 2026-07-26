-- description: "A 2D GUI component that displays text."
local Vector2 = require("@Vector2")
local UDim2 = require("@UDim2")
local Frame = require("@Frame")
local Color3 = require("@Color3")
local Enum = require("@EnumMap")
local adapter = require("@RaylibAdapter")
local lib = adapter.lib
local GuiObject = require("@GuiObject")
local RichText = require("@Kinemium.richtext")

local propTable = {
	Position = UDim2.new(0, 0, 0, 0),
	Size = UDim2.new(0, 200, 0, 50),
	Text = "Hello World!",
	TextColor3 = Color3.new(0, 0, 0),
	TextSize = 24,
	Font = Enum.Font.DefaultEngineFont,
	TextXAlignment = Enum.TextXAlignment.Center,
	TextYAlignment = Enum.TextYAlignment.Center,
	TextSpacing = 1,
	TextTransparency = 0,
	TextStrokeColor = Color3.new(0, 0, 0),
	TextStrokeTransparency = 1,
	TextWrapped = false,
	TextTruncate = Enum.TextTruncate.None,
	TextScaled = false,
	RichText = false,
	MaxVisibleGraphemes = -1,
	LineHeight = 1,
	BackgroundTransparency = 0,
	BackgroundColor = Color3.new(1, 1, 1),
	BorderSize = 0,
	BorderColor = Color3.new(0, 0, 0),
	BorderTransparency = 0,
	AnchorPoint = Vector2.new(0, 0),
	Rotation = 0,
	Name = "TextLabel",
	BackgroundColor3 = Color3.new(1, 1, 1),
	Visible = true,
}

Frame.inherit(propTable)

local defaultFont = lib.GetFontDefault()

propTable.render = function(lib, object, dt, structs, renderer)
	local framePos, frameSize = GuiObject.render(lib, object, dt, adapter.structs, renderer)
	if not object.Visible or not framePos or not frameSize then
		return
	end
	local layout, spacing = RichText.GetLayout(object, frameSize, renderer, defaultFont)
	if not layout then
		return framePos, frameSize
	end

	local blend = object:FindFirstChildOfClass("UIBlend")
	local didBlend = false
	if blend and blend.Enabled ~= false and blend.AffectSelf ~= false then
		lib.BeginBlendMode(GuiObject.resolveBlendMode(raylib, blend.Mode))
		didBlend = true
	end

	RichText.DrawLayout(lib, object, framePos, frameSize, layout, spacing)

	if didBlend then
		lib.EndBlendMode()
	end

	GuiObject.renderChildren(lib, object, dt, structs, renderer)

	return framePos, frameSize
end

return {
	class = "TextLabel",
	render = propTable.render,
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
