local Vector2 = require("@Vector2")
local UDim2 = require("@UDim2")
local UDim = require("@UDim")
local Frame = require("@Frame")
local Color3 = require("@Color3")
local Enum = require("@EnumMap")

local propTable = {
	Position = UDim2.new(0, 0, 0, 0),
	Size = UDim2.new(0, 200, 0, 50),
	Text = "Hello Kinemium!",
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

propTable.render = function(lib, object, dt, structs, renderer)
	local framePos, frameSize = Frame.render(lib, object, dt, structs, renderer)
	if not object.Visible or not framePos or not frameSize then
		return
	end

	local function Color3ToRaylib(c, transparency)
		local r, g, b = c:ToRGB()
		return structs.Color:new({
			r = r,
			g = g,
			b = b,
			a = math.floor(255 * (1 - transparency)),
		})
	end

	local function applyTruncate(text, mode)
		if mode == Enum.TextTruncate.None then
			return text
		end
		if mode == Enum.TextTruncate.Head then
			return #text <= 3 and "..." or "..." .. text:sub(#text - 20)
		elseif mode == Enum.TextTruncate.Tail then
			return #text <= 3 and "..." or text:sub(1, 20) .. "..."
		end
		return text
	end

	local font = renderer.GetFont(object.Font.Value)
	if not font then
		font = lib.GetFontDefault()
	end

	local fontSize = object.TextSize
	local measured = lib.MeasureTextEx(font, object.Text, fontSize, 0)

	if object.TextScaled then
		local scaleX = frameSize.X / measured.x
		local scaleY = frameSize.Y / measured.y
		local scale = math.min(scaleX, scaleY)
		fontSize = fontSize * scale
		measured = lib.MeasureTextEx(font, object.Text, fontSize, 0)
	end

	local lines = {}
	if object.TextWrapped then
		local currentLine = ""
		for word in object.Text:gmatch("%S+") do
			local testLine = currentLine == "" and word or currentLine .. " " .. word
			local w = lib.MeasureTextEx(font, testLine, fontSize, 0).x
			if w <= frameSize.X then
				currentLine = testLine
			else
				table.insert(lines, currentLine)
				currentLine = word
			end
		end
		table.insert(lines, currentLine)
	else
		lines = { applyTruncate(object.Text, object.TextTruncate) }
	end

	local lineHeightPx = fontSize * object.LineHeight
	local totalHeight = #lines * lineHeightPx

	local offsetX, offsetY = 0, 0

	if object.TextYAlignment == Enum.TextYAlignment.Center then
		offsetY = (frameSize.Y - totalHeight) * 0.5
	elseif object.TextYAlignment == Enum.TextYAlignment.Bottom then
		offsetY = frameSize.Y - totalHeight
	end

	local tint = Color3ToRaylib(object.TextColor3, object.TextTransparency)
	for i, line in ipairs(lines) do
		-- Calculate line-specific X offset based on alignment
		local lineWidth = lib.MeasureTextEx(font, line, fontSize, 0).x
		local lineOffsetX = 0

		if object.TextXAlignment == Enum.TextXAlignment.Center then
			lineOffsetX = (frameSize.X - lineWidth) * 0.5
		elseif object.TextXAlignment == Enum.TextXAlignment.Right then
			lineOffsetX = frameSize.X - lineWidth
		end

		-- Position is relative to framePos (which already accounts for anchor point)
		local linePos = vector.create(framePos.X + lineOffsetX, framePos.Y + offsetY + (i - 1) * lineHeightPx)
		lib.DrawTextEx(font, line, linePos, fontSize, object.TextSpacing or 0, tint)
	end

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
