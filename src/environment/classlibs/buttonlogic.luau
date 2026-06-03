local logic = {}

local Enum = require("@EnumMap")
local MouseCursor = require("@Kinemium.MouseCursor")
local signal = require("@Kinemium.signal")

function logic:Step(object, lib, callbackHover, callbackLeave)
	if object.MouseIsInObject == true then
		if object.ChangeCursorOnHover then
			MouseCursor.request(Enum.KinemiumMouseCursor.MOUSE_CURSOR_POINTING_HAND.Value)
		end

		if object.AutoButtonColor then
			object.BackgroundTransparency = 0.5
		end

		if callbackHover then
			callbackHover()
		end

		local left = lib.IsMouseButtonDown(0)
		local right = lib.IsMouseButtonDown(1)

		object.MouseButton1Click:FireOncePerPress("LeftMouse", left)
		object.MouseButton2Click:FireOncePerPress("RightMouse", right)
	else
		if object.ChangeCursorOnHover then
			MouseCursor.request(Enum.KinemiumMouseCursor.MOUSE_CURSOR_DEFAULT.Value)
		end

		if object.AutoButtonColor then
			object.BackgroundTransparency = 0
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
