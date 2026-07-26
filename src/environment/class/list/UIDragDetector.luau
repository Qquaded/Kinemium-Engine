-- description: "A drag detection component for UI elements."
local Vector2 = require("@Vector2")
local Vector3 = require("@Vector3")
local UDim2 = require("@UDim2")
local adapter = require("@RaylibAdapter")
local MouseCursor = require("@Kinemium.MouseCursor")

local aereon = require("@Aereon")
local arect = aereon.rect()

local ZERO_V2 = Vector2.new(0, 0)

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

local propTable = {
	Name = "UIDragDetector",
	isDragging = false,
	RespectScreenBounds = true,
	dragOffset = Vector3.new(0, 0, 0), -- why is this a vector3? no idea
}

return {
	class = "UIDragDetector",

	callback = function(instance)
		propTable.render = function(lib, object, dt, structs, renderer)
			if object.Parent then
				local adornee = object.Parent
				if adornee.BaseClass == "GuiObject" then
					local absolutePosition, absoluteSize = adornee.AbsolutePosition, adornee.AbsoluteSize

					if not absolutePosition or not absoluteSize then
						return
					end

					if instance.isDragging == true then
						local mousePos = adapter.lib.GetMousePosition()
						local newAbsX = mousePos.x - instance.dragOffset.X
						local newAbsY = mousePos.y - instance.dragOffset.Y

						if instance.RespectScreenBounds then
							local dpiScale = adapter.lib.GetWindowScaleDPI()
							local screenW = adapter.lib.GetScreenWidth() / dpiScale.x
							local screenH = adapter.lib.GetScreenHeight() / dpiScale.y
							newAbsX = math.clamp(newAbsX, 0, screenW - absoluteSize.X)
							newAbsY = math.clamp(newAbsY, 0, screenH - absoluteSize.Y)
						end

						local parentAbsPos, parentSize = getParentMetrics(adornee.Parent)
						local anchor = adornee.AnchorPoint or ZERO_V2
						local relativeX = newAbsX - parentAbsPos.X + absoluteSize.X * anchor.X
						local relativeY = newAbsY - parentAbsPos.Y + absoluteSize.Y * anchor.Y
						local scaleXOffset = parentSize.X * adornee.Position.X.Scale
						local scaleYOffset = parentSize.Y * adornee.Position.Y.Scale

						adornee.Position = UDim2.new(
							adornee.Position.X.Scale,
							relativeX - scaleXOffset,
							adornee.Position.Y.Scale,
							relativeY - scaleYOffset
						)

						MouseCursor.request(adapter.const.MouseCursor.MOUSE_CURSOR_RESIZE_ALL)
					end

					local new = arect.new(absolutePosition.X, absolutePosition.Y, absoluteSize.X, absoluteSize.Y)
					if arect.MouseIsInRect(new) then
						if adapter.lib.IsMouseButtonDown(0) == 1 then
							if not instance.isDragging then
								local mousePos = adapter.lib.GetMousePosition()
								instance.dragOffset =
									Vector3.new(mousePos.x - absolutePosition.X, mousePos.y - absolutePosition.Y, 0)
							end
							instance.isDragging = true
						elseif adapter.lib.IsMouseButtonReleased(0) == 1 then
							instance.isDragging = false
							MouseCursor.request(adapter.const.MouseCursor.MOUSE_CURSOR_DEFAULT)
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
