local logic = {}

local Enum = require("@EnumMap")
local MouseCursor = require("@Kinemium.MouseCursor")
local signal = require("@Kinemium.signal")
local raylib = require("@raylib")

local function renderCaret(showCaret, object, renderer, lib)
	if showCaret then
		if not object.AbsolutePosition then
			return
		end
		local fontValue = object.Font
		local fontName = if type(fontValue) == "table" then fontValue.Value else fontValue
		local font = renderer.Font and renderer.Font.Get and renderer.Font.Get(fontName)
		if not font then
			font = lib.GetFontDefault()
		end
		local fontSize = object.TextSize
		local measured = lib.MeasureTextEx(font, object.Text, fontSize, 0)
		local lineWidth = measured.x
		local totalHeight = fontSize * (object.LineHeight or 1)

		local offsetY = 0
		if object.TextYAlignment == Enum.TextYAlignment.Center then
			offsetY = (object.AbsoluteSize.Y - totalHeight) * 0.5
		elseif object.TextYAlignment == Enum.TextYAlignment.Bottom then
			offsetY = object.AbsoluteSize.Y - totalHeight
		end

		local lineOffsetX = 0
		if object.TextXAlignment == Enum.TextXAlignment.Center then
			lineOffsetX = (object.AbsoluteSize.X - lineWidth) * 0.5
		elseif object.TextXAlignment == Enum.TextXAlignment.Right then
			lineOffsetX = object.AbsoluteSize.X - lineWidth
		end

		local textX = object.AbsolutePosition.X + lineOffsetX
		local textY = object.AbsolutePosition.Y + offsetY
		local caretX = textX + lineWidth
		local caretY = textY
		local caretHeight = fontSize

		--DrawRectangle: (posX: int, posY: int, width: int, height: int, color: Color) -> (),
		lib.DrawRectangle(caretX, caretY, 2, caretHeight, raylib.const.BLACK)
	end
end

function logic:Step(object, lib, renderer, callbackHover, callbackLeave)
	if object.CaretPosition == nil then
		object.CaretPosition = #object.Text
	end

	if object.Focused == true then
		lib.SetExitKey(0)

		-- left
		if lib.IsKeyPressed(263) == 1 then
			object.CaretPosition = math.max(0, object.CaretPosition - 1)
		end

		-- right
		if lib.IsKeyPressed(262) == 1 then
			object.CaretPosition = math.min(#object.Text, object.CaretPosition + 1)
		end

		-- home and end
		if lib.IsKeyPressed(268) == 1 then
			object.CaretPosition = 0
		end

		--end
		if lib.IsKeyPressed(269) == 1 then
			object.CaretPosition = #object.Text
		end

		local currentKey = lib.GetCharPressed()
		while currentKey ~= 0 do
			local char = string.char(currentKey)
			-- insert character at caret position
			local before = object.Text:sub(1, object.CaretPosition)
			local after = object.Text:sub(object.CaretPosition + 1)
			object.Text = before .. char .. after
			object.CaretPosition = object.CaretPosition + 1

			currentKey = lib.GetCharPressed()
		end

		-- backspace
		if lib.IsKeyPressed(259) == 1 and object.CaretPosition > 0 then
			local before = object.Text:sub(1, object.CaretPosition - 1)
			local after = object.Text:sub(object.CaretPosition + 1)
			object.Text = before .. after
			object.CaretPosition = object.CaretPosition - 1
		end

		-- enter or escape
		if lib.IsKeyPressed(257) == 1 or lib.IsKeyPressed(256) == 1 then
			object.Focused = false
		end

		local caretBlinkSpeed = 0.5 -- Blink every 0.5 seconds
		local time = lib.GetTime()
		local showCaret = (time % (caretBlinkSpeed * 2)) < caretBlinkSpeed

		renderCaret(showCaret, object, renderer, lib)
	end
	if object.MouseIsInObject == true then
		if object.ChangeCursorOnHover then
			MouseCursor.request(Enum.KinemiumMouseCursor.MOUSE_CURSOR_IBEAM.Value)
		end

		if callbackHover then
			callbackHover()
		end

		local left = lib.IsMouseButtonDown(0)
		local right = lib.IsMouseButtonDown(1)

		object.MouseButton1Click:FireOncePerPress("LeftMouse", left)
		object.MouseButton2Click:FireOncePerPress("RightMouse", right)

		if left == 1 then
			object.Focused = true
			object.CaretPosition = #object.Text
		end
	else
		local left = lib.IsMouseButtonDown(0)

		if object.Focused == true and left == 1 then
			object.Focused = false
		end

		if object.ChangeCursorOnHover then
			MouseCursor.request(Enum.KinemiumMouseCursor.MOUSE_CURSOR_DEFAULT.Value)
		end

		if callbackLeave then
			callbackLeave()
		end
	end
end

function logic:SetupSignals(propTable)
	local MouseButton1Click = signal.new()
	local MouseButton2Click = signal.new()
	local MouseButton1Down = signal.new()
	local MouseButton1Up = signal.new()
	local MouseButton2Down = signal.new()
	local MouseButton2Up = signal.new()

	propTable.MouseButton1Click = MouseButton1Click
	propTable.MouseButton2Click = MouseButton2Click
	propTable.MouseButton1Down = MouseButton1Down
	propTable.MouseButton1Up = MouseButton1Up
	propTable.MouseButton2Down = MouseButton2Down
	propTable.MouseButton2Up = MouseButton2Up
end

return logic
