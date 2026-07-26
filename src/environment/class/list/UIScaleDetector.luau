-- description: "A modifier class that detects scale changes on a GUI element."
local Vector2 = require("@Vector2")
local Vector3 = require("@Vector3")
local UDim2 = require("@UDim2")
local adapter = require("@RaylibAdapter")
local MouseCursor = require("@Kinemium.MouseCursor")

local aereon = require("@Aereon")
local arect = aereon.rect()

local ZERO_V2 = Vector2.new(0, 0)
local HANDLE_SZ = 10 -- half-size of each hit region in pixels

local HANDLES = {
	TL = { l = true, r = false, t = true, b = false },
	T = { l = false, r = false, t = true, b = false },
	TR = { l = false, r = true, t = true, b = false },
	L = { l = true, r = false, t = false, b = false },
	R = { l = false, r = true, t = false, b = false },
	BL = { l = true, r = false, t = false, b = true },
	B = { l = false, r = false, t = false, b = true },
	BR = { l = false, r = true, t = false, b = true },
}

local CURSORS = {
	TL = adapter.const.MouseCursor.MOUSE_CURSOR_RESIZE_NWSE,
	BR = adapter.const.MouseCursor.MOUSE_CURSOR_RESIZE_NWSE,
	TR = adapter.const.MouseCursor.MOUSE_CURSOR_RESIZE_NESW,
	BL = adapter.const.MouseCursor.MOUSE_CURSOR_RESIZE_NESW,
	T = adapter.const.MouseCursor.MOUSE_CURSOR_RESIZE_NS,
	B = adapter.const.MouseCursor.MOUSE_CURSOR_RESIZE_NS,
	L = adapter.const.MouseCursor.MOUSE_CURSOR_RESIZE_EW,
	R = adapter.const.MouseCursor.MOUSE_CURSOR_RESIZE_EW,
}

local function getParentMetrics(parent)
	local parentAbsPos = ZERO_V2
	local parentSize = ZERO_V2
	if not parent then
		return parentAbsPos, parentSize
	end

	if parent.AbsolutePosition then
		parentAbsPos = parent.AbsolutePosition
	elseif parent.RenderOffset then
		parentAbsPos = parent.RenderOffset
	end

	if parent.AbsoluteSize then
		parentSize = parent.AbsoluteSize
	elseif parent.Size and parent.Size.ToPixels then
		local dpiScale = adapter.lib.GetWindowScaleDPI()
		parentSize = parent.Size:ToPixels(
			Vector2.new(adapter.lib.GetRenderWidth() / dpiScale.x, adapter.lib.GetRenderHeight() / dpiScale.y)
		)
	end

	return parentAbsPos, parentSize
end

local function getHandleRect(key, absPos, absSize)
	local cx, cy

	if key == "TL" then
		cx = absPos.X
		cy = absPos.Y
	elseif key == "T" then
		cx = absPos.X + absSize.X * 0.5
		cy = absPos.Y
	elseif key == "TR" then
		cx = absPos.X + absSize.X
		cy = absPos.Y
	elseif key == "L" then
		cx = absPos.X
		cy = absPos.Y + absSize.Y * 0.5
	elseif key == "R" then
		cx = absPos.X + absSize.X
		cy = absPos.Y + absSize.Y * 0.5
	elseif key == "BL" then
		cx = absPos.X
		cy = absPos.Y + absSize.Y
	elseif key == "B" then
		cx = absPos.X + absSize.X * 0.5
		cy = absPos.Y + absSize.Y
	elseif key == "BR" then
		cx = absPos.X + absSize.X
		cy = absPos.Y + absSize.Y
	end

	return arect.new(cx - HANDLE_SZ, cy - HANDLE_SZ, HANDLE_SZ * 2, HANDLE_SZ * 2)
end

local propTable = {
	Name = "UIScaleDetector",
	isResizing = false,
	activeHandle = nil, -- key into HANDLES
	MinSize = Vector2.new(40, 40),
	RespectScreenBounds = true,

	newSizeCallback = nil, -- function(newSize: Vector2)

	_startMouse = Vector3.new(0, 0, 0),
	_startAbsPos = Vector2.new(0, 0),
	_startAbsSz = Vector2.new(0, 0),
}

return {
	class = "UIScaleDetector",

	callback = function(instance)
		propTable.render = function(lib, object, dt, structs, renderer)
			if not object.Parent then
				return
			end
			local adornee = object.Parent
			if adornee.BaseClass ~= "GuiObject" then
				return
			end

			local absPos = adornee.AbsolutePosition
			local absSize = adornee.AbsoluteSize
			if not absPos or not absSize then
				return
			end

			local parentAbsPos, parentSize = getParentMetrics(adornee.Parent)
			local anchor = adornee.AnchorPoint or ZERO_V2
			local mousePos = adapter.lib.GetMousePosition()
			local mx, my = mousePos.x, mousePos.y

			--  Active resize
			if instance.isResizing and instance.activeHandle then
				local hDef = HANDLES[instance.activeHandle]
				local dx = mx - instance._startMouse.X
				local dy = my - instance._startMouse.Y

				-- New absolute rect edges
				local left = instance._startAbsPos.X
				local top = instance._startAbsPos.Y
				local right = left + instance._startAbsSz.X
				local bottom = top + instance._startAbsSz.Y

				if hDef.l then
					left = left + dx
				end
				if hDef.r then
					right = right + dx
				end
				if hDef.t then
					top = top + dy
				end
				if hDef.b then
					bottom = bottom + dy
				end

				-- Enforce min size
				if right - left < instance.MinSize.X then
					if hDef.l then
						left = right - instance.MinSize.X
					else
						right = left + instance.MinSize.X
					end
				end
				if bottom - top < instance.MinSize.Y then
					if hDef.t then
						top = bottom - instance.MinSize.Y
					else
						bottom = top + instance.MinSize.Y
					end
				end

				-- Clamp to screen
				if instance.RespectScreenBounds then
					local dpiScale = adapter.lib.GetWindowScaleDPI()
					local screenW = adapter.lib.GetScreenWidth() / dpiScale.x
					local screenH = adapter.lib.GetScreenHeight() / dpiScale.y
					left = math.clamp(left, 0, screenW)
					top = math.clamp(top, 0, screenH)
					right = math.clamp(right, 0, screenW)
					bottom = math.clamp(bottom, 0, screenH)
				end

				local newAbsW = right - left
				local newAbsH = bottom - top

				local newRelX = (left - parentAbsPos.X) + newAbsW * anchor.X
				local newRelY = (top - parentAbsPos.Y) + newAbsH * anchor.Y
				local scaleXOff = parentSize.X * adornee.Position.X.Scale
				local scaleYOff = parentSize.Y * adornee.Position.Y.Scale

				local sScaleXOff = parentSize.X * adornee.Size.X.Scale
				local sScaleYOff = parentSize.Y * adornee.Size.Y.Scale

				local newPos = UDim2.new(
					adornee.Position.X.Scale,
					newRelX - scaleXOff,
					adornee.Position.Y.Scale,
					newRelY - scaleYOff
				)
				local newSize =
					UDim2.new(adornee.Size.X.Scale, newAbsW - sScaleXOff, adornee.Size.Y.Scale, newAbsH - sScaleYOff)
				if instance.newSizeCallback then
					instance.newSizeCallback(newSize, newPos)
				else
					adornee.Position = newPos
					adornee.Size = newSize
				end

				MouseCursor.request(CURSORS[instance.activeHandle])

				if adapter.lib.IsMouseButtonReleased(0) == 1 then
					instance.isResizing = false
					instance.activeHandle = nil
					MouseCursor.request(adapter.const.MouseCursor.MOUSE_CURSOR_DEFAULT)
				end

				return
			end

			local hoveredHandle = nil

			for key, _ in pairs(HANDLES) do
				local hr = getHandleRect(key, absPos, absSize)
				if arect.MouseIsInRect(hr) then
					hoveredHandle = key
					MouseCursor.request(CURSORS[key])

					if adapter.lib.IsMouseButtonDown(0) == 1 and not instance.isResizing then
						instance.isResizing = true
						instance.activeHandle = key
						instance._startMouse = Vector3.new(mx, my, 0)
						instance._startAbsPos = Vector2.new(absPos.X, absPos.Y)
						instance._startAbsSz = Vector2.new(absSize.X, absSize.Y)
					end

					break
				end
			end

			if not hoveredHandle then
				MouseCursor.request(adapter.const.MouseCursor.MOUSE_CURSOR_DEFAULT)
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
