local Color3 = require("@Color3")
local UDim2 = require("@UDim2")
local signal = require("@Kinemium.signal")
local Vector2 = require("@Vector2")

local SEGMENTS = 16
local CORNER_SEGMENTS = 8
local ZERO_V = vector.create(0, 0, 0)

local function drawCornerArc(lib, cx, cy, radius, angleStart, angleEnd, color)
	for i = 0, CORNER_SEGMENTS - 1 do
		local a1 = angleStart + (angleEnd - angleStart) * (i / CORNER_SEGMENTS)
		local a2 = angleStart + (angleEnd - angleStart) * ((i + 1) / CORNER_SEGMENTS)
		lib.DrawTriangle(
			vector.create(cx, cy, 0),
			vector.create(cx + math.cos(a1) * radius, cy + math.sin(a1) * radius, 0),
			vector.create(cx + math.cos(a2) * radius, cy + math.sin(a2) * radius, 0),
			color
		)
	end
end

local function drawRoundedRectangleEx(lib, x, y, w, h, tl, tr, bl, br, color)
	local minDim = math.min(w, h)
	local maxR = minDim / 2

	tl = math.min(tl, maxR)
	tr = math.min(tr, maxR)
	bl = math.min(bl, maxR)
	br = math.min(br, maxR)

	local cw = w - tl - tr
	local ch = h - tl - bl

	if cw > 0 and ch > 0 then
		lib.DrawRectangle(x + tl, y + tl, cw, ch, color)
	end
	if w - tl - tr > 0 then
		lib.DrawRectangle(x + tl, y, w - tl - tr, math.max(tl, tr), color)
	end
	if w - bl - br > 0 then
		lib.DrawRectangle(x + bl, y + h - math.max(bl, br), w - bl - br, math.max(bl, br), color)
	end
	if h - tl - bl > 0 then
		lib.DrawRectangle(x, y + tl, math.max(tl, bl), h - tl - bl, color)
	end
	if h - tr - br > 0 then
		lib.DrawRectangle(x + w - math.max(tr, br), y + tr, math.max(tr, br), h - tr - br, color)
	end

	if tl > 0 then
		drawCornerArc(lib, x + tl, y + tl, tl, math.pi, math.pi * 1.5, color)
	end
	if tr > 0 then
		drawCornerArc(lib, x + w - tr, y + tr, tr, math.pi * 1.5, math.pi * 2, color)
	end
	if bl > 0 then
		drawCornerArc(lib, x + bl, y + h - bl, bl, math.pi * 0.5, math.pi, color)
	end
	if br > 0 then
		drawCornerArc(lib, x + w - br, y + h - br, br, 0, math.pi * 0.5, color)
	end
end

local function GetAbsoluteSize(object, lib)
	if object.BaseClass == "UIContainer" then
		return vector.create(object.Size.X.Offset, object.Size.Y.Offset, 0)
	end
	return object.Size:ToPixels(GetAbsoluteSize(object.Parent, lib))
end

local function getAbsoluteDrawPos(object, lib)
	if object.BaseClass == "UIContainer" then
		return object.RenderOffset
	end
	local parent = object.Parent
	local parentAbsPos = getAbsoluteDrawPos(parent, lib)
	local parentSize = GetAbsoluteSize(parent, lib)
	local pos = object.Position:ToPixels(parentSize)
	local size = object.Size:ToPixels(parentSize)
	local anchor = object.AnchorPoint or ZERO_V
	local drawPos =
		vector.create(parentAbsPos.X + pos.X - size.X * anchor.X, parentAbsPos.Y + pos.Y - size.Y * anchor.Y, 0)
	if parent and parent.ClassName == "ScrollingFrame" then
		drawPos = vector.create(drawPos.X, drawPos.Y - (parent.CanvasPosition or 0), 0)
	end
	return drawPos
end

local function isMouseInRect(mousePos, drawPos, size)
	return mousePos.X >= drawPos.X
		and mousePos.X <= drawPos.X + size.X
		and mousePos.Y >= drawPos.Y
		and mousePos.Y <= drawPos.Y + size.Y
end

local function calculateDrawParams(object, lib)
	local parentSize = GetAbsoluteSize(object.Parent, lib)
	local size, drawPos, anchor

	if object._EditorOverride then
		size = object.AbsoluteSize or ZERO_V
		drawPos = object.AbsolutePosition or ZERO_V
	elseif object._LayoutControlled and object._LayoutRelativePosition then
		size = object.Size:ToPixels(parentSize)
		anchor = object.AnchorPoint or ZERO_V
		local parentDrawPos = getAbsoluteDrawPos(object.Parent, lib)
		drawPos = vector.create(
			parentDrawPos.X + object._LayoutRelativePosition.X - size.X * anchor.X,
			parentDrawPos.Y + object._LayoutRelativePosition.Y - size.Y * anchor.Y,
			0
		)
		if object.Parent and object.Parent.ClassName == "ScrollingFrame" then
			drawPos = vector.create(drawPos.X, drawPos.Y - (object.Parent.CanvasPosition or 0), 0)
		end
	else
		size = object.Size:ToPixels(parentSize)
		drawPos = getAbsoluteDrawPos(object, lib)
	end

	return drawPos, size
end

local function resolveCornerRadii(corner, minDim)
	local base = corner.CornerRadius.Scale * minDim + corner.CornerRadius.Offset

	local function resolve(prop)
		if prop then
			local v = prop.Scale * minDim + prop.Offset
			return v > 0 and v or base
		end
		return base
	end

	local tl = resolve(corner.TopLeftRadius)
	local tr = resolve(corner.TopRightRadius)
	local bl = resolve(corner.BottomLeftRadius)
	local br = resolve(corner.BottomRightRadius)

	local uniform = tl == tr and tl == bl and tl == br

	local function isDifferent(prop)
		return prop and prop.Offset ~= 15
	end

	local useIndividual = isDifferent(corner.TopLeftRadius)
		or isDifferent(corner.TopRightRadius)
		or isDifferent(corner.BottomLeftRadius)
		or isDifferent(corner.BottomRightRadius)

	return tl, tr, bl, br, base, useIndividual
end

local propTable = {
	BaseClass = "GuiObject",
	Position = UDim2.new(0, 0, 0, 0),
	Size = UDim2.new(0, 100, 0, 100),
	BackgroundColor3 = Color3.new(1, 1, 1),
	BackgroundTransparency = 0,
	Visible = true,
	BorderSize = 0,
	BorderColor = Color3.new(0, 0, 0),
	BorderTransparency = 0,
	Rotation = 0,
	AbsolutePosition = nil,
	Anchored = true,
	AbsoluteSize = nil,
	ClipsDescendants = false,
	ZIndex = 1,
	AnchorPoint = ZERO_V,
	MouseIsInObject = false,

	render = function(lib, object, dt, structs, renderer)
		if not object.Visible then
			return
		end

		local drawPos, size = calculateDrawParams(object, lib)
		local mousePos = vector.create(lib.GetMouseX(), lib.GetMouseY(), 0)
		local mouseIsInObject = isMouseInRect(mousePos, drawPos, size)

		rawset(object, "MouseIsInObject", mouseIsInObject)
		object.MouseEnter:FireOncePerPress("MouseEnter", mouseIsInObject)
		object.MouseLeave:FireOncePerPress("MouseLeave", not mouseIsInObject)

		local color = object.BackgroundColor3:ToRaylib(object.BackgroundTransparency)
		local corner = object:FindFirstChildOfClass("UICorner")
		local stroke = object:FindFirstChildOfClass("UIStroke")
		local gradient = object:FindFirstChildOfClass("UIGradient")
		local blur = object:FindFirstChild("BlurEffect")

		local rec = structs.Rectangle:new({ x = drawPos.X, y = drawPos.Y, width = size.X, height = size.Y })
		local origin = vector.create(0, 0, 0)
		local minDim = math.min(size.X, size.Y)

		if blur then
			renderer.Blur.blurRadius = blur.Size
			renderer.Blur:DrawBlurredRegion(drawPos.X, drawPos.Y, size.X, size.Y, Color3.new(1, 1, 1):ToRaylib(0))
		end

		if gradient then
			local steps = 50
			local stepHeight = size.Y / steps
			local cornerRadius = corner and (corner.CornerRadius.Scale * minDim + corner.CornerRadius.Offset) or 0

			for i = 0, steps - 1 do
				local t1, t2 = i / steps, (i + 1) / steps
				local color1 = gradient.ColorSequence:Evaluate(t1)
				local color2 = gradient.ColorSequence:Evaluate(t2)
				local offsetLeft, offsetRight = 0, 0

				if cornerRadius > 0 then
					local yPos1, yPos2 = i * stepHeight, (i + 1) * stepHeight
					if yPos1 < cornerRadius then
						local ratio = (cornerRadius - yPos1) / cornerRadius
						offsetLeft = cornerRadius * (1 - math.sqrt(1 - ratio ^ 2))
						offsetRight = offsetLeft
					end
					if yPos2 > size.Y - cornerRadius then
						local ratio = (yPos2 - (size.Y - cornerRadius)) / cornerRadius
						local bottomOffset = cornerRadius * (1 - math.sqrt(1 - ratio ^ 2))
						offsetLeft = math.max(offsetLeft, bottomOffset)
						offsetRight = math.max(offsetRight, bottomOffset)
					end
				end

				lib.DrawRectangleGradientEx(
					structs.Rectangle:new({
						x = drawPos.X + offsetLeft,
						y = drawPos.Y + i * stepHeight,
						width = size.X - offsetLeft - offsetRight,
						height = stepHeight,
					}),
					color1:ToRaylib(0),
					color1:ToRaylib(0),
					color2:ToRaylib(0),
					color2:ToRaylib(0)
				)
			end

			if stroke and stroke.Transparency ~= 1 then
				if corner then
					local _, _, _, _, base = resolveCornerRadii(corner, minDim)
					lib.DrawRectangleRoundedLinesEx(
						rec,
						base / minDim,
						SEGMENTS,
						stroke.Thickness,
						stroke.Color:ToRaylib(stroke.Transparency)
					)
				else
					lib.DrawRectangleLinesEx(rec, stroke.Thickness, stroke.Color:ToRaylib(stroke.Transparency))
				end
			end
		elseif corner then
			local tl, tr, bl, br, base, useIndividual = resolveCornerRadii(corner, minDim)
			local roundness = base / minDim

			if object.BackgroundTransparency ~= 1 then
				if object.Rotation ~= 0 then
					lib.DrawRectanglePro(rec, origin, object.Rotation, color)
				elseif useIndividual then
					drawRoundedRectangleEx(lib, drawPos.X, drawPos.Y, size.X, size.Y, tl, tr, bl, br, color)
				else
					lib.DrawRectangleRounded(rec, roundness, SEGMENTS, color)
				end
			end

			if stroke and stroke.Transparency ~= 1 then
				if object.Rotation ~= 0 then
					lib.DrawRectangleLinesEx(rec, stroke.Thickness, stroke.Color:ToRaylib(stroke.Transparency))
				else
					lib.DrawRectangleRoundedLinesEx(
						rec,
						roundness,
						SEGMENTS,
						stroke.Thickness,
						stroke.Color:ToRaylib(stroke.Transparency)
					)
				end
			end
		elseif stroke then
			if object.BackgroundTransparency ~= 1 then
				if object.Rotation ~= 0 then
					lib.DrawRectanglePro(rec, origin, object.Rotation, color)
				else
					lib.DrawRectangleRec(rec, color)
				end
			end
			if stroke.Transparency ~= 1 then
				lib.DrawRectangleLinesEx(rec, stroke.Thickness, stroke.Color:ToRaylib(stroke.Transparency))
			end
		else
			if object.BackgroundTransparency ~= 1 then
				lib.DrawRectanglePro(rec, origin, object.Rotation, color)
			end
		end

		rawset(object, "AbsolutePosition", drawPos)
		rawset(object, "AbsoluteSize", size)

		return drawPos, size
	end,
}

local function createSignals()
	return {
		MouseEnter = signal.new(),
		MouseLeave = signal.new(),
		MouseMoved = signal.new(),
		MouseWheelForward = signal.new(),
		MouseWheelBackward = signal.new(),
		TouchTap = signal.new(),
		TouchLongPress = signal.new(),
		InputBegan = signal.new(),
		InputChanged = signal.new(),
		InputEnded = signal.new(),
	}
end

return {
	class = "GuiObject",
	non_creatable = true,
	render = propTable.render,

	IsParentGuiContainer = function(object)
		return object.Parent.BaseClass == "UIContainer"
	end,

	renderChildren = function(lib, object, dt, structs, renderer)
		for _, child in pairs(object:GetChildren()) do
			if child.render then
				child.render(lib, child, dt, structs, renderer)
			end
		end
	end,

	calculatePositions = function(lib, object, dt, structs, renderer)
		local drawPos, size = calculateDrawParams(object, lib)
		local mousePos = vector.create(lib.GetMouseX(), lib.GetMouseY(), 0)
		local mouseIsInObject = isMouseInRect(mousePos, drawPos, size)

		rawset(object, "MouseIsInObject", mouseIsInObject)

		if object.MouseEnter then
			object.MouseEnter:FireOncePerPress("MouseEnter", mouseIsInObject)
		end
		if object.MouseLeave then
			object.MouseLeave:FireOncePerPress("MouseLeave", not mouseIsInObject)
		end

		rawset(object, "AbsolutePosition", drawPos)
		rawset(object, "AbsoluteSize", size)

		return drawPos, size
	end,

	callback = function(instance, renderer)
		local signals = createSignals()
		for k, v in pairs(signals) do
			propTable[k] = v
		end
		instance:SetProperties(propTable)
		return instance
	end,

	inherit = function(tble)
		local signals = createSignals()
		for k, v in pairs(signals) do
			tble[k] = v
		end
		for prop, val in pairs(propTable) do
			if not tble[prop] then
				tble[prop] = val
			end
		end
	end,
}
