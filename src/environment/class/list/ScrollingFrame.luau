-- description: "A container that displays a scrollable area of content."
local Color3 = require("@Color3")
local GuiObject = require("@GuiObject")
local adapter = require("@RaylibAdapter")
local structs = adapter.structs
local UDim = require("@UDim")
local MouseCursor = require("@Kinemium.MouseCursor")

local aereon = require("@Aereon")
local arect = aereon.rect()

local propTable = {
	Name = "ScrollingFrame",

	-- layout
	AbsoluteSize = nil,
	AbsolutePosition = nil,

	-- appearance
	ScrollBarTransparency = 0,
	ScrollBarColor3 = Color3.new(0.5, 0.5, 0.5),
	ScrollBarCornerRadius = UDim.new(0, 0),
	ScrollBarBackgroundTransparency = 1,
	ScrollBarBackgroundColor3 = Color3.new(1, 1, 1),
	ScrollBarHoverColor3 = Color3.new(0.6, 0.6, 0.6),

	-- scrolling state
	Scroll = 0, -- normalized 0–1 (thumb position)
	ScrollOffset = 0.08, -- wheel step

	-- lerping
	ScrollTarget = 0, -- where input writes to
	ScrollLerpSpeed = 18, -- higher = snappier

	-- content
	ContentSize = 0, -- total content height (pixels)
	CanvasPosition = 0, -- pixel offset derived from Scroll
	AutoScrollSize = true,
	CanvasSize = 0,

	-- behavior
	ScrollBarThickness = 8,
	ScrollBarVisible = true,
	ScrollBarAutoHide = true, -- auto-hide when not scrolling
	ScrollBarFadeSpeed = 4, -- fade speed
	ScrollBarPadding = 2, -- padding from edge

	ElasticEnabled = true,
	ElasticStrength = 0.8, -- how far you can overscroll (0-1, relative to viewport)
	ElasticSnapSpeed = 12, -- how fast it snaps back

	-- momentum scrolling
	MomentumEnabled = true,
	MomentumFriction = 0.92, -- 0-1, higher = scrolls longer
	MomentumMinVelocity = 0.001, -- minimum velocity before stopping

	-- track clicking
	TrackClickEnabled = true, -- click scrollbar track to jump
	TrackClickSmooth = true, -- smooth scroll to position instead of instant

	_draggingThumb = false,
	_dragOffsetY = 0,
	_scrollBarAlpha = 0, -- for fade in/out
	_timeSinceLastScroll = 999, -- accumulated dt since last scroll
	_velocity = 0, -- for momentum
	_isOverscrolled = false,
	_lastScroll = 0, -- for velocity calculation
	_isHoveringThumb = false,
	_isHoveringTrack = false,
}

local function c3tr(c, transparency)
	local r, g, b = c:ToRGB()
	return structs.Color:new({
		r = r,
		g = g,
		b = b,
		a = math.floor(255 * (1 - transparency)),
	})
end

GuiObject.inherit(propTable)

return {
	class = "ScrollingFrame",

	callback = function(instance, renderer, game)
		propTable.render = function(lib, object, dt, structs, renderer)
			if not object.Visible then
				return
			end
			if rawget(object, "_draggingThumb") == nil then
				rawset(object, "_draggingThumb", false)
			end
			if rawget(object, "_dragOffsetY") == nil then
				rawset(object, "_dragOffsetY", 0)
			end
			if rawget(object, "_scrollBarAlpha") == nil then
				rawset(object, "_scrollBarAlpha", object.ScrollBarAutoHide and 0 or 1)
			end
			if rawget(object, "_timeSinceLastScroll") == nil then
				rawset(object, "_timeSinceLastScroll", 999)
			end
			if rawget(object, "_velocity") == nil then
				rawset(object, "_velocity", 0)
			end
			if rawget(object, "_isOverscrolled") == nil then
				rawset(object, "_isOverscrolled", false)
			end
			if rawget(object, "_lastScroll") == nil then
				rawset(object, "_lastScroll", object.Scroll)
			end
			if rawget(object, "_isHoveringThumb") == nil then
				rawset(object, "_isHoveringThumb", false)
			end
			if rawget(object, "_isHoveringTrack") == nil then
				rawset(object, "_isHoveringTrack", false)
			end

			-- Accumulate time since last scroll
			object._timeSinceLastScroll = object._timeSinceLastScroll + dt

			local pos, size = GuiObject.render(lib, object, dt, structs, renderer)
			rawset(object, "AbsolutePosition", pos)
			rawset(object, "AbsoluteSize", size)

			local backgroundRect = arect.new(pos.X, pos.Y, size.X, size.Y)

			local contentHeight = 0
			for _, child in pairs(object:GetChildren()) do
				if not child then
					continue
				end
				if not child.Position then
					continue
				end
				local childOffset = child.Position.Y.Offset
				local childHeight = child.Size.Y.Offset
				local childRelativeBottom = childOffset + childHeight
				contentHeight = math.max(contentHeight, childRelativeBottom)
			end
			object.ContentSize = object.AutoScrollSize and contentHeight or object.CanvasSize

			local maxScroll = math.max(0, object.ContentSize - object.AbsoluteSize.Y)
			local canScroll = maxScroll > 0

			if object.ScrollBarAutoHide then
				local fadeDelay = 0.5 -- seconds before fading

				if object._draggingThumb or object._isHoveringTrack or object._timeSinceLastScroll < fadeDelay then
					object._scrollBarAlpha = math.min(1, object._scrollBarAlpha + dt * object.ScrollBarFadeSpeed)
				else
					object._scrollBarAlpha = math.max(0, object._scrollBarAlpha - dt * object.ScrollBarFadeSpeed)
				end
			else
				object._scrollBarAlpha = 1
			end

			-- Only render scrollbar if visible and there's content to scroll
			local scrollbarWidth = object.ScrollBarThickness
			local scrollbarRect =
				arect.new(pos.X + size.X - scrollbarWidth - object.ScrollBarPadding, pos.Y, scrollbarWidth, size.Y)

			if object.ScrollBarVisible and canScroll and object._scrollBarAlpha > 0 then
				-- Background track
				lib.DrawRectangleRec(
					arect:translate(scrollbarRect),
					c3tr(
						object.ScrollBarBackgroundColor3,
						1 - (1 - object.ScrollBarBackgroundTransparency) * object._scrollBarAlpha
					)
				)

				-- Thumb
				local thumbMinHeight = 16
				local viewportRatio = math.min(1, size.Y / object.ContentSize)
				local thumbHeight = math.max(size.Y * viewportRatio, thumbMinHeight)
				thumbHeight = math.min(thumbHeight, size.Y)

				local scroll = object.Scroll or 0
				local scrollableRange = size.Y - thumbHeight
				local thumbY = pos.Y + scrollableRange * math.clamp(scroll, 0, 1)
				local thumbRect = arect.new(
					pos.X + size.X - scrollbarWidth - object.ScrollBarPadding,
					thumbY,
					scrollbarWidth,
					thumbHeight
				)

				-- Determine thumb color (hover effect)
				local thumbColor = object._isHoveringThumb and object.ScrollBarHoverColor3 or object.ScrollBarColor3
				lib.DrawRectangleRec(
					arect:translate(thumbRect),
					c3tr(thumbColor, 1 - (1 - object.ScrollBarTransparency) * object._scrollBarAlpha)
				)

				-- Mouse interaction
				local mousePos = lib.GetMousePosition()
				object._isHoveringThumb = arect.MouseIsInRect(thumbRect)
				object._isHoveringTrack = arect.MouseIsInRect(scrollbarRect)

				-- Start dragging thumb
				if lib.IsMouseButtonPressed(0) == 1 and object._isHoveringThumb then
					object._draggingThumb = true
					object._dragOffsetY = mousePos.y - thumbY
					object._velocity = 0 -- stop momentum when dragging
					object._timeSinceLastScroll = 0
					MouseCursor.request(adapter.const.MouseCursor.MOUSE_CURSOR_RESIZE_ALL)
				end

				-- Click on track to jump (if not clicking thumb)
				if
					object.TrackClickEnabled
					and lib.IsMouseButtonPressed(0) == 1
					and object._isHoveringTrack
					and not object._isHoveringThumb
				then
					local clickY = mousePos.y
					local targetScroll = math.clamp((clickY - pos.Y - thumbHeight / 2) / scrollableRange, 0, 1)

					if object.TrackClickSmooth then
						object.ScrollTarget = targetScroll
					else
						object.Scroll = targetScroll
						object.ScrollTarget = targetScroll
					end
					object._timeSinceLastScroll = 0
				end

				-- Stop dragging
				if lib.IsMouseButtonReleased(0) == 1 then
					object._draggingThumb = false
					MouseCursor.request(adapter.const.MouseCursor.MOUSE_CURSOR_DEFAULT)
				end

				-- Drag update
				if object._draggingThumb then
					local minY = pos.Y
					local maxY = pos.Y + scrollableRange

					local newThumbY = mousePos.y - object._dragOffsetY
					newThumbY = math.clamp(newThumbY, minY, maxY)

					local newScroll = (newThumbY - minY) / scrollableRange
					object.ScrollTarget = newScroll
					object._timeSinceLastScroll = 0
				end
			end

			if arect.MouseIsInRect(backgroundRect) and canScroll then
				local wheel = lib.GetMouseWheelMove()

				if wheel ~= 0 then
					local currentTarget = object.ScrollTarget or object.Scroll
					object.ScrollTarget = currentTarget - wheel * object.ScrollOffset
					object._velocity = -wheel * object.ScrollOffset * 0.5 -- add some momentum
					object._timeSinceLastScroll = 0
				end
			end

			if object.ElasticEnabled then
				if object.ScrollTarget < 0 or object.ScrollTarget > 1 then
					object._isOverscrolled = true
				end

				if object.ScrollTarget < 0 then
					local overshoot = -object.ScrollTarget
					object.ScrollTarget = -overshoot * object.ElasticStrength
				elseif object.ScrollTarget > 1 then
					local overshoot = object.ScrollTarget - 1
					object.ScrollTarget = 1 + overshoot * object.ElasticStrength
				end

				if object._isOverscrolled and not object._draggingThumb then
					if object._timeSinceLastScroll > 0.1 then -- small delay before snapping
						if object.ScrollTarget < 0 then
							object.ScrollTarget = object.ScrollTarget
								+ (0 - object.ScrollTarget) * dt * object.ElasticSnapSpeed
							if math.abs(object.ScrollTarget) < 0.001 then
								object.ScrollTarget = 0
								object._isOverscrolled = false
							end
						elseif object.ScrollTarget > 1 then
							object.ScrollTarget = object.ScrollTarget
								+ (1 - object.ScrollTarget) * dt * object.ElasticSnapSpeed
							if math.abs(object.ScrollTarget - 1) < 0.001 then
								object.ScrollTarget = 1
								object._isOverscrolled = false
							end
						end
					end
				end
			else
				-- Hard clamp if elastic is disabled
				object.ScrollTarget = math.clamp(object.ScrollTarget or object.Scroll, 0, 1)
			end

			-- Calculate velocity for momentum
			if object.MomentumEnabled and not object._draggingThumb then
				local scrollDelta = object.Scroll - object._lastScroll
				object._velocity = scrollDelta / dt

				-- Apply momentum when not actively scrolling
				if object._timeSinceLastScroll > 0.05 and math.abs(object._velocity) > object.MomentumMinVelocity then
					object.ScrollTarget = object.ScrollTarget + object._velocity * dt
					object._velocity = object._velocity * object.MomentumFriction

					-- Stop momentum if velocity is too low
					if math.abs(object._velocity) < object.MomentumMinVelocity then
						object._velocity = 0
					end
				end
			end

			object.Scroll = object.Scroll
				+ (object.ScrollTarget - object.Scroll) * math.clamp(dt * object.ScrollLerpSpeed, 0, 1)

			object._lastScroll = object.Scroll

			object.CanvasPosition = object.Scroll * maxScroll

			GuiObject.renderChildren(lib, object, dt, structs, renderer)
		end

		instance:SetProperties(propTable)
		return instance
	end,
	inherit = function(tble)
		GuiObject.inherit(tble)
	end,
}
