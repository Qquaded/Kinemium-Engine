-- description: "Base class for 2D GUI elements with layout, rendering, input, and tween helpers."
local Color3 = require("@Color3")
local Enum = require("@EnumMap")
local TweenInfo = require("@TweenInfo")
local UDim2 = require("@UDim2")
local signal = require("@Kinemium.signal")
local Vector2 = require("@Vector2")
local adapter = require("@RaylibAdapter")

local SEGMENTS = 16
local CORNER_SEGMENTS = 8
local SQUIRCLE_SEGMENTS = 10
local ZERO_V = vector.create(0, 0, 0)
local MAX_AUTOMATIC_SIZE_DEPTH = 8

local function resolveUDim2(val, parentDim)
	if val then
		if val.ToPixels then
			return val:ToPixels(parentDim)
		elseif val.X and val.Y then
			local x = (type(val.X) == "table" and ((val.X.Scale or 0) * parentDim.X + (val.X.Offset or 0))) or 0
			local y = (type(val.Y) == "table" and ((val.Y.Scale or 0) * parentDim.Y + (val.Y.Offset or 0))) or 0
			return vector.create(x, y, 0)
		end
	end
	return ZERO_V
end

local function resolveBlendMode(raylib, value)
	if type(value) == "number" then
		return value
	end

	if type(value) ~= "string" then
		return adapter.const.BlendMode.BLEND_ALPHA
	end

	local normalized = string.lower(value)
	if normalized == "additive" or normalized == "add" then
		return adapter.const.BlendMode.BLEND_ADDITIVE
	elseif normalized == "multiply" or normalized == "multiplied" then
		return adapter.const.BlendMode.BLEND_MULTIPLIED
	elseif normalized == "premultiply" or normalized == "premultipliedalpha" or normalized == "premultiplied" then
		return adapter.const.BlendMode.BLEND_ALPHA_PREMULTIPLY
	elseif normalized == "addcolors" then
		return adapter.const.BlendMode.BLEND_ADD_COLORS
	elseif normalized == "subtract" or normalized == "subtractcolors" then
		return adapter.const.BlendMode.BLEND_SUBTRACT_COLORS
	end

	return adapter.const.BlendMode.BLEND_ALPHA
end

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

local function resolveAutomaticSizeAxes(mode)
	if mode == Enum.AutomaticSize.XY then
		return true, true
	elseif mode == Enum.AutomaticSize.X then
		return true, false
	elseif mode == Enum.AutomaticSize.Y then
		return false, true
	end

	local name = type(mode) == "table" and mode.Name or mode
	if name == "XY" then
		return true, true
	elseif name == "X" then
		return true, false
	elseif name == "Y" then
		return false, true
	end

	return false, false
end

local function resolvePaddingBounds(object, parentSize)
	local left, right, top, bottom = 0, 0, 0, 0

	for _, child in ipairs(object:GetChildren()) do
		if child.ClassName == "UIPadding" and child.GetResolvedPadding then
			local padding = child:GetResolvedPadding(parentSize)
			left += padding.Left or 0
			right += padding.Right or 0
			top += padding.Top or 0
			bottom += padding.Bottom or 0
		end
	end

	return left, right, top, bottom
end

local function getContentMetrics(object, size)
	if not object or object.BaseClass == "UIContainer" then
		return ZERO_V, size
	end

	local left, right, top, bottom = resolvePaddingBounds(object, size)
	return vector.create(left, top, 0),
		vector.create(math.max(0, size.X - left - right), math.max(0, size.Y - top - bottom), 0)
end

local function precomputeLayoutChildren(object, lib, dt, structs, renderer)
	if not lib then
		return
	end

	for _, child in ipairs(object:GetChildren()) do
		local className = child.ClassName
		local isLayout = type(className) == "string" and string.sub(className, -6) == "Layout"
		if isLayout and child.render and child.Enabled ~= false then
			child.render(lib, child, dt or 0, structs, renderer)
		end
	end
end

local function calculateResolvedSize(object, parentSize, lib, dt, structs, renderer, depth)
	local size = resolveUDim2(object.Size, parentSize)
	local autoX, autoY = resolveAutomaticSizeAxes(object.AutomaticSize)

	if (not autoX and not autoY) or (depth or 0) >= MAX_AUTOMATIC_SIZE_DEPTH then
		return size
	end

	precomputeLayoutChildren(object, lib, dt, structs, renderer)

	local left, right, top, bottom = resolvePaddingBounds(object, size)
	local contentSize = vector.create(math.max(0, size.X - left - right), math.max(0, size.Y - top - bottom), 0)
	local maxX, maxY = left, top
	local hasGuiChild = false

	for _, child in ipairs(object:GetChildren()) do
		if child.BaseClass == "GuiObject" and child.Visible ~= false and child.Size then
			hasGuiChild = true

			local childSize = calculateResolvedSize(child, contentSize, lib, dt, structs, renderer, (depth or 0) + 1)
			local anchor = child.AnchorPoint or ZERO_V
			local relX, relY

			if child._LayoutControlled and child._LayoutRelativePosition then
				relX = child._LayoutRelativePosition.X - childSize.X * anchor.X
				relY = child._LayoutRelativePosition.Y - childSize.Y * anchor.Y
			elseif child.Position then
				local childPos = resolveUDim2(child.Position, contentSize)
				relX = left + childPos.X - childSize.X * anchor.X
				relY = top + childPos.Y - childSize.Y * anchor.Y
			end

			if relX and relY then
				maxX = math.max(maxX, relX + childSize.X)
				maxY = math.max(maxY, relY + childSize.Y)
			end
		end
	end

	if hasGuiChild then
		maxX += right
		maxY += bottom
	else
		maxX = left + right
		maxY = top + bottom
	end

	return vector.create(autoX and math.max(0, maxX) or size.X, autoY and math.max(0, maxY) or size.Y, 0)
end

local function GetAbsoluteSize(object, lib, dt, structs, renderer, depth)
	if object.BaseClass == "UIContainer" then
		return vector.create(object.Size.X.Offset, object.Size.Y.Offset, 0)
	end

	local parentSize = GetAbsoluteSize(object.Parent, lib, dt, structs, renderer, (depth or 0) + 1)
	local _, parentContentSize = getContentMetrics(object.Parent, parentSize)
	return calculateResolvedSize(object, parentContentSize, lib, dt, structs, renderer, depth)
end

local function getAbsoluteDrawPos(object, lib, dt, structs, renderer, depth)
	if object.BaseClass == "UIContainer" then
		return object.RenderOffset
	end
	local parent = object.Parent
	local parentAbsPos = getAbsoluteDrawPos(parent, lib, dt, structs, renderer, (depth or 0) + 1)
	local parentSize = GetAbsoluteSize(parent, lib, dt, structs, renderer, (depth or 0) + 1)
	local parentPaddingOffset, parentContentSize = getContentMetrics(parent, parentSize)
	local size = calculateResolvedSize(object, parentContentSize, lib, dt, structs, renderer, depth)
	local anchor = object.AnchorPoint or ZERO_V
	local drawPos

	if object._LayoutControlled and object._LayoutRelativePosition then
		drawPos = vector.create(
			parentAbsPos.X + object._LayoutRelativePosition.X - size.X * anchor.X,
			parentAbsPos.Y + object._LayoutRelativePosition.Y - size.Y * anchor.Y,
			0
		)
	else
		local pos = resolveUDim2(object.Position, parentContentSize)
		drawPos = vector.create(
			parentAbsPos.X + parentPaddingOffset.X + pos.X - size.X * anchor.X,
			parentAbsPos.Y + parentPaddingOffset.Y + pos.Y - size.Y * anchor.Y,
			0
		)
	end

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

local function calculateDrawParams(object, lib, dt, structs, renderer, depth)
	local parentSize = GetAbsoluteSize(object.Parent, lib, dt, structs, renderer, (depth or 0) + 1)
	local _, parentContentSize = getContentMetrics(object.Parent, parentSize)
	local size, drawPos, anchor

	if object._EditorOverride then
		size = object.AbsoluteSize or ZERO_V
		drawPos = object.AbsolutePosition or ZERO_V
	elseif object._LayoutControlled and object._LayoutRelativePosition then
		size = calculateResolvedSize(object, parentContentSize, lib, dt, structs, renderer, depth)
		anchor = object.AnchorPoint or ZERO_V
		local parentDrawPos = getAbsoluteDrawPos(object.Parent, lib, dt, structs, renderer, (depth or 0) + 1)
		drawPos = vector.create(
			parentDrawPos.X + object._LayoutRelativePosition.X - size.X * anchor.X,
			parentDrawPos.Y + object._LayoutRelativePosition.Y - size.Y * anchor.Y,
			0
		)
		if object.Parent and object.Parent.ClassName == "ScrollingFrame" then
			drawPos = vector.create(drawPos.X, drawPos.Y - (object.Parent.CanvasPosition or 0), 0)
		end
	else
		size = calculateResolvedSize(object, parentContentSize, lib, dt, structs, renderer, depth)
		drawPos = getAbsoluteDrawPos(object, lib, dt, structs, renderer, depth)
	end

	return drawPos, size
end

local function resolveGuiPoint(point)
	if type(point) ~= "table" then
		return nil
	end

	local x = point.X
	if x == nil then
		x = point.x
	end

	local y = point.Y
	if y == nil then
		y = point.y
	end

	if type(x) ~= "number" or type(y) ~= "number" then
		return nil
	end

	return Vector2.new(x, y)
end

local function getGuiMetrics(object)
	if object.AbsolutePosition and object.AbsoluteSize then
		local pos = object.AbsolutePosition
		local size = object.AbsoluteSize
		return Vector2.new(pos.X, pos.Y), Vector2.new(size.X, size.Y)
	end

	if not object.Parent then
		return Vector2.Zero, Vector2.Zero
	end

	local drawPos, size = calculateDrawParams(object)
	return Vector2.new(drawPos.X, drawPos.Y), Vector2.new(size.X, size.Y)
end

local function getGuiTweenRegistry(object)
	local registry = rawget(object, "_GuiTweenRegistry")
	if not registry then
		registry = {}
		rawset(object, "_GuiTweenRegistry", registry)
	end
	return registry
end

local function isTweenBusy(tween)
	if not tween then
		return false
	end

	return tween.PlaybackState ~= Enum.PlaybackState.Completed and tween.PlaybackState ~= Enum.PlaybackState.Cancelled
end

local function playGuiTween(
	object,
	propertyNames,
	properties,
	easingDirection,
	easingStyle,
	duration,
	override,
	callback
)
	local tweenService = game and game.GetService and game:GetService("TweenService") or nil
	if not tweenService then
		return false, nil
	end

	local registry = getGuiTweenRegistry(object)
	for _, propertyName in ipairs(propertyNames) do
		local activeTween = registry[propertyName]
		if isTweenBusy(activeTween) then
			if not override then
				return false, activeTween
			end
			activeTween:Cancel()
		end
	end

	local tweenInfo =
		TweenInfo.new(duration or 1, easingStyle or Enum.EasingStyle.Quad, easingDirection or Enum.EasingDirection.Out)
	local tween = tweenService:Create(object, tweenInfo, properties)

	for _, propertyName in ipairs(propertyNames) do
		registry[propertyName] = tween
	end

	tween.Completed:Connect(function(playbackState)
		for _, propertyName in ipairs(propertyNames) do
			if registry[propertyName] == tween then
				registry[propertyName] = nil
			end
		end

		if callback then
			callback(playbackState)
		end
	end)

	tween:Play()
	return true, tween
end

local function resolveCornerRadii(corner, minDim)
	local base = corner.CornerRadius.Scale * minDim + corner.CornerRadius.Offset
	local function isDefaultCornerValue(prop)
		return prop and prop.Scale == 0 and prop.Offset == 15
	end

	local function resolve(prop)
		if prop and not isDefaultCornerValue(prop) then
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
		return prop and not isDefaultCornerValue(prop)
	end

	local useIndividual = isDifferent(corner.TopLeftRadius)
		or isDifferent(corner.TopRightRadius)
		or isDifferent(corner.BottomLeftRadius)
		or isDifferent(corner.BottomRightRadius)

	return tl, tr, bl, br, base, useIndividual
end

local function appendPoint(points, x, y)
	local last = points[#points]
	if last and math.abs(last.X - x) < 0.01 and math.abs(last.Y - y) < 0.01 then
		return
	end

	table.insert(points, vector.create(x, y, 0))
end

local function appendSquircleArc(points, cx, cy, radius, sx, sy, angleStart, angleEnd, exponent, skipFirst)
	if radius <= 0 then
		return
	end

	local power = 2 / math.max(2, exponent or 4)
	local startIndex = if skipFirst then 1 else 0

	for i = startIndex, SQUIRCLE_SEGMENTS do
		local alpha = i / SQUIRCLE_SEGMENTS
		local angle = angleStart + (angleEnd - angleStart) * alpha
		local cosValue = math.abs(math.cos(angle)) ^ power
		local sinValue = math.abs(math.sin(angle)) ^ power

		appendPoint(points, cx + sx * radius * cosValue, cy + sy * radius * sinValue)
	end
end

local function buildSquirclePoints(x, y, w, h, tl, tr, bl, br, exponent)
	local points = {}
	local maxR = math.min(w, h) / 2

	tl = math.min(tl, maxR)
	tr = math.min(tr, maxR)
	bl = math.min(bl, maxR)
	br = math.min(br, maxR)

	appendPoint(points, x + tl, y)
	appendPoint(points, x + w - tr, y)
	appendSquircleArc(points, x + w - tr, y + tr, tr, 1, -1, math.pi * 0.5, 0, exponent, true)

	appendPoint(points, x + w, y + h - br)
	appendSquircleArc(points, x + w - br, y + h - br, br, 1, 1, 0, math.pi * 0.5, exponent, true)

	appendPoint(points, x + bl, y + h)
	appendSquircleArc(points, x + bl, y + h - bl, bl, -1, 1, math.pi * 0.5, 0, exponent, true)

	appendPoint(points, x, y + tl)
	appendSquircleArc(points, x + tl, y + tl, tl, -1, -1, 0, math.pi * 0.5, exponent, true)

	return points
end

local function drawSquircleFilled(lib, x, y, w, h, tl, tr, bl, br, exponent, color)
	local points = buildSquirclePoints(x, y, w, h, tl, tr, bl, br, exponent)
	local center = vector.create(x + w * 0.5, y + h * 0.5, 0)

	for i = 1, #points do
		local nextIndex = if i == #points then 1 else i + 1
		lib.DrawTriangle(center, points[i], points[nextIndex], color)
	end
end

local function drawSquircleOutline(lib, x, y, w, h, tl, tr, bl, br, exponent, thickness, color)
	local points = buildSquirclePoints(x, y, w, h, tl, tr, bl, br, exponent)

	for i = 1, #points do
		local nextIndex = if i == #points then 1 else i + 1
		lib.DrawLineEx(points[i], points[nextIndex], thickness, color)
	end
end

local function getRoundedHorizontalInset(localY, height, radius, exponent)
	if radius <= 0 then
		return 0
	end

	local curveExponent = math.max(2, exponent or 2)
	local normalizedPower = 2 / curveExponent

	local function edgeInset(distanceToEdge)
		if distanceToEdge >= radius then
			return 0
		end

		local normalized = math.clamp((radius - distanceToEdge) / radius, 0, 1)
		return radius * (1 - (1 - normalized ^ curveExponent) ^ normalizedPower)
	end

	if localY < radius then
		return edgeInset(localY)
	end

	if localY > height - radius then
		return edgeInset(height - localY)
	end

	return 0
end

local function drawShadow(lib, structs, object, shadow, drawPos, size, corner, squircle)
	if not shadow or shadow.Enabled == false then
		return
	end

	local transparency = shadow.Transparency or 0
	if transparency >= 1 then
		return
	end

	local passes = math.max(1, math.floor(math.max(shadow.Blur or 0, 0)))
	local spread = math.max(0, shadow.Spread or 0)
	local offset = shadow.Offset or ZERO_V
	local minDim = math.min(size.X, size.Y)
	local tl, tr, bl, br, base, useIndividual = 0, 0, 0, 0, 0, false
	local squircleExponent = squircle and squircle.Exponent or 4

	if squircle then
		tl, tr, bl, br = resolveCornerRadii(squircle, minDim)
	elseif corner then
		tl, tr, bl, br, base, useIndividual = resolveCornerRadii(corner, minDim)
	end

	local isCircleShadow = corner
		and not useIndividual
		and math.abs(size.X - size.Y) < 0.01
		and base >= (minDim * 0.5 - 0.01)

	for i = 1, passes do
		local expansion = spread + (passes - i)
		local alphaScale = i / passes
		local layerTransparency = 1 - ((1 - transparency) * alphaScale)
		local layerColor = shadow.Color:ToRaylib(layerTransparency)
		local shadowX = drawPos.X + offset.X - expansion
		local shadowY = drawPos.Y + offset.Y - expansion
		local shadowW = size.X + expansion * 2
		local shadowH = size.Y + expansion * 2

		if shadowW <= 0 or shadowH <= 0 then
			continue
		end

		local rec = structs.Rectangle:new({
			x = shadowX,
			y = shadowY,
			width = shadowW,
			height = shadowH,
		})
		local layerMinDim = math.max(1, math.min(shadowW, shadowH))

		if object.Rotation ~= 0 then
			lib.DrawRectanglePro(rec, ZERO_V, object.Rotation, layerColor)
		elseif isCircleShadow then
			lib.DrawCircleV(
				vector.create(shadowX + shadowW * 0.5, shadowY + shadowH * 0.5, 0),
				math.max(0, math.min(shadowW, shadowH) * 0.5),
				layerColor
			)
		elseif squircle then
			drawSquircleFilled(
				lib,
				shadowX,
				shadowY,
				shadowW,
				shadowH,
				tl + expansion,
				tr + expansion,
				bl + expansion,
				br + expansion,
				squircleExponent,
				layerColor
			)
		elseif corner then
			drawRoundedRectangleEx(
				lib,
				shadowX,
				shadowY,
				shadowW,
				shadowH,
				(tl > 0 and tl or base) + expansion,
				(tr > 0 and tr or base) + expansion,
				(bl > 0 and bl or base) + expansion,
				(br > 0 and br or base) + expansion,
				layerColor
			)
		else
			lib.DrawRectangleRec(rec, layerColor)
		end
	end
end

local function drawShapeFill(lib, structs, object, modifier, x, y, w, h, color)
	if w <= 0 or h <= 0 then
		return
	end

	local rec = structs.Rectangle:new({ x = x, y = y, width = w, height = h })
	local minDim = math.min(w, h)

	if object.Rotation ~= 0 then
		lib.DrawRectanglePro(rec, ZERO_V, object.Rotation, color)
		return
	end

	if modifier and modifier.ClassName == "UISquircle" then
		local tl, tr, bl, br = resolveCornerRadii(modifier, minDim)
		drawSquircleFilled(lib, x, y, w, h, tl, tr, bl, br, modifier.Exponent or 4, color)
	elseif modifier and modifier.ClassName == "UICorner" then
		local tl, tr, bl, br, base, useIndividual = resolveCornerRadii(modifier, minDim)
		if useIndividual then
			drawRoundedRectangleEx(lib, x, y, w, h, tl, tr, bl, br, color)
		else
			lib.DrawRectangleRounded(rec, base / minDim, SEGMENTS, color)
		end
	else
		lib.DrawRectangleRec(rec, color)
	end
end

local function drawShapeOutline(lib, structs, object, modifier, x, y, w, h, thickness, color)
	if w <= 0 or h <= 0 then
		return
	end

	local rec = structs.Rectangle:new({ x = x, y = y, width = w, height = h })
	local minDim = math.min(w, h)

	if object.Rotation ~= 0 then
		lib.DrawRectangleLinesEx(rec, thickness, color)
		return
	end

	if modifier and modifier.ClassName == "UISquircle" then
		local tl, tr, bl, br = resolveCornerRadii(modifier, minDim)
		drawSquircleOutline(lib, x, y, w, h, tl, tr, bl, br, modifier.Exponent or 4, thickness, color)
	elseif modifier and modifier.ClassName == "UICorner" then
		local _, _, _, _, base = resolveCornerRadii(modifier, minDim)
		lib.DrawRectangleRoundedLinesEx(rec, base / minDim, SEGMENTS, thickness, color)
	else
		lib.DrawRectangleLinesEx(rec, thickness, color)
	end
end

local function drawGlow(lib, structs, object, glow, drawPos, size, shapeModifier)
	if not glow or glow.Enabled == false then
		return
	end

	local transparency = glow.Transparency or 0
	if transparency >= 1 then
		return
	end

	local passes = math.max(1, math.floor(math.max(glow.Blur or 0, 0)))
	local spread = math.max(0, glow.Spread or 0)
	local blendMode = resolveBlendMode(raylib, glow.BlendMode or "Additive")
	lib.BeginBlendMode(blendMode)

	for i = 1, passes do
		local expansion = spread + (passes - i)
		local alphaScale = i / passes
		local layerTransparency = 1 - ((1 - transparency) * alphaScale)
		local layerColor = glow.Color:ToRaylib(layerTransparency)
		drawShapeFill(
			lib,
			structs,
			object,
			shapeModifier,
			drawPos.X - expansion,
			drawPos.Y - expansion,
			size.X + expansion * 2,
			size.Y + expansion * 2,
			layerColor
		)
	end

	lib.EndBlendMode()
end

local function drawVignette(lib, structs, object, vignette, drawPos, size, shapeModifier)
	if not vignette or vignette.Enabled == false then
		return
	end

	local transparency = vignette.Transparency or 0
	if transparency >= 1 then
		return
	end

	local steps = math.max(1, math.floor(vignette.Steps or 8))
	local thickness = math.max(1, vignette.Thickness or 18)

	for i = 1, steps do
		local alphaScale = i / steps
		local layerTransparency = 1 - ((1 - transparency) * alphaScale)
		local inset = ((i - 1) / steps) * thickness
		local width = size.X - inset * 2
		local height = size.Y - inset * 2
		if width <= 0 or height <= 0 then
			break
		end

		drawShapeOutline(
			lib,
			structs,
			object,
			shapeModifier,
			drawPos.X + inset,
			drawPos.Y + inset,
			width,
			height,
			1,
			vignette.Color:ToRaylib(layerTransparency)
		)
	end
end

local function drawBevel(lib, structs, object, bevel, drawPos, size, shapeModifier)
	if not bevel or bevel.Enabled == false then
		return
	end

	local thickness = math.max(1, math.floor(bevel.Thickness or 2))
	local lightColor = bevel.LightColor:ToRaylib(bevel.LightTransparency or 0)
	local shadowColor = bevel.ShadowColor:ToRaylib(bevel.ShadowTransparency or 0)
	local isInset = type(bevel.Style) == "string" and string.lower(bevel.Style) == "inset"

	if isInset then
		lightColor, shadowColor = shadowColor, lightColor
	end

	for i = 0, thickness - 1 do
		local inset = i
		local width = size.X - inset * 2
		local height = size.Y - inset * 2
		if width <= 0 or height <= 0 then
			break
		end

		local x = drawPos.X + inset
		local y = drawPos.Y + inset

		lib.BeginScissorMode(x, y, math.max(1, math.floor(width * 0.5)), math.max(1, math.floor(height * 0.5)))
		drawShapeOutline(lib, structs, object, shapeModifier, x, y, width, height, 1, lightColor)
		lib.EndScissorMode()

		lib.BeginScissorMode(
			x + math.floor(width * 0.5),
			y + math.floor(height * 0.5),
			math.max(1, math.ceil(width * 0.5)),
			math.max(1, math.ceil(height * 0.5))
		)
		drawShapeOutline(lib, structs, object, shapeModifier, x, y, width, height, 1, shadowColor)
		lib.EndScissorMode()
	end
end

local function drawRipple(lib, raylib, ripple, object, drawPos, size, dt)
	if not ripple or ripple.Enabled == false then
		return
	end

	if ripple._state == nil then
		ripple._state = {}
	end

	if object.MouseIsInObject and lib.IsMouseButtonPressed(0) == 1 then
		table.insert(ripple._state, {
			x = lib.GetMouseX(),
			y = lib.GetMouseY(),
			time = 0,
		})
	end

	local duration = math.max(0.01, ripple.Duration or 0.6)
	local maxRadius = math.max(size.X, size.Y) * (ripple.MaxRadiusScale or 1.2)
	local color3 = ripple.Color
	local blendMode = resolveBlendMode(raylib, ripple.BlendMode or "Alpha")

	lib.BeginScissorMode(drawPos.X, drawPos.Y, math.max(1, size.X), math.max(1, size.Y))
	lib.BeginBlendMode(blendMode)

	for i = #ripple._state, 1, -1 do
		local pulse = ripple._state[i]
		pulse.time += dt

		local progress = pulse.time / duration
		if progress >= 1 then
			table.remove(ripple._state, i)
		else
			local radius = maxRadius * progress
			local alpha = (1 - progress) * (1 - (ripple.Transparency or 0))
			local color = structs.Color:new({
				r = color3.R * 255,
				g = color3.G * 255,
				b = color3.B * 255,
				a = math.floor(255 * math.clamp(alpha, 0, 1)),
			})

			if ripple.Fill == false then
				local inner = math.max(0, radius - (ripple.Thickness or 2))
				lib.DrawRing(vector.create(pulse.x, pulse.y, 0), inner, radius, 0, 360, 32, color)
			else
				lib.DrawCircleV(vector.create(pulse.x, pulse.y, 0), radius, color)
			end
		end
	end

	lib.EndBlendMode()
	lib.EndScissorMode()
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
	AutomaticSize = Enum.AutomaticSize.None,
	ClipsDescendants = false,
	ZIndex = 1,
	AnchorPoint = ZERO_V,
	MouseIsInObject = false,
	-- description: "Returns the absolute top-left position and size of the GUI object."
	-- args: "self: table"
	-- returns: "Vector2, Vector2"
	GetBounds = function(self)
		return getGuiMetrics(self)
	end,
	-- description: "Returns the absolute center point of the GUI object."
	-- args: "self: table"
	-- returns: "Vector2"
	GetCenter = function(self)
		local pos, size = getGuiMetrics(self)
		return Vector2.new(pos.X + size.X * 0.5, pos.Y + size.Y * 0.5)
	end,
	-- description: "Returns whether a screen-space point is inside the GUI object bounds."
	-- args: "self: table, point: Vector2"
	-- returns: "boolean"
	IsPointInside = function(self, point)
		local resolvedPoint = resolveGuiPoint(point)
		if not resolvedPoint then
			return false
		end

		local pos, size = getGuiMetrics(self)
		return resolvedPoint.X >= pos.X
			and resolvedPoint.X <= pos.X + size.X
			and resolvedPoint.Y >= pos.Y
			and resolvedPoint.Y <= pos.Y + size.Y
	end,
	-- description: "Converts a screen-space point into coordinates relative to the GUI object."
	-- args: "self: table, point: Vector2"
	-- returns: "Vector2?"
	GetRelativePoint = function(self, point)
		local resolvedPoint = resolveGuiPoint(point)
		if not resolvedPoint then
			return nil
		end

		local pos = getGuiMetrics(self)
		return Vector2.new(resolvedPoint.X - pos.X, resolvedPoint.Y - pos.Y)
	end,
	-- description: "Cancels active GUI tweens started by this object."
	-- args: "self: table"
	CancelGuiTweens = function(self)
		local registry = rawget(self, "_GuiTweenRegistry")
		if not registry then
			return
		end

		local cancelled = {}
		for _, tween in pairs(registry) do
			if tween and not cancelled[tween] and isTweenBusy(tween) then
				cancelled[tween] = true
				tween:Cancel()
			end
		end
	end,
	-- description: "Tweens the Position property to a target value."
	-- args: "self: table, endPosition: UDim2, easingDirection: string, easingStyle: string, time: number, override: boolean?, callback: function?"
	-- returns: "boolean, any"
	TweenPosition = function(self, endPosition, easingDirection, easingStyle, time, override, callback)
		return playGuiTween(
			self,
			{ "Position" },
			{ Position = endPosition },
			easingDirection,
			easingStyle,
			time,
			override,
			callback
		)
	end,
	-- description: "Tweens the Size property to a target value."
	-- args: "self: table, endSize: UDim2, easingDirection: string, easingStyle: string, time: number, override: boolean?, callback: function?"
	-- returns: "boolean, any"
	TweenSize = function(self, endSize, easingDirection, easingStyle, time, override, callback)
		return playGuiTween(
			self,
			{ "Size" },
			{ Size = endSize },
			easingDirection,
			easingStyle,
			time,
			override,
			callback
		)
	end,
	-- description: "Tweens Size and Position together."
	-- args: "self: table, endSize: UDim2, endPosition: UDim2, easingDirection: string, easingStyle: string, time: number, override: boolean?, callback: function?"
	-- returns: "boolean, any"
	TweenSizeAndPosition = function(self, endSize, endPosition, easingDirection, easingStyle, time, override, callback)
		return playGuiTween(
			self,
			{ "Size", "Position" },
			{ Size = endSize, Position = endPosition },
			easingDirection,
			easingStyle,
			time,
			override,
			callback
		)
	end,
	-- description: "Renders this GUI object and updates absolute bounds and hover state."
	-- args: "lib: number, object: table, dt: number, structs: table, renderer: number"
	-- returns: "Vector3?, Vector3?"
	render = function(lib, object, dt, structs, renderer)
		if not object.Visible then
			return
		end

		lib = renderer.Lib2d

		local drawPos, size = calculateDrawParams(object, lib, dt, structs, renderer)
		local mousePos = vector.create(lib.GetMouseX(), lib.GetMouseY(), 0)
		local mouseIsInObject = isMouseInRect(mousePos, drawPos, size)

		local tilt, corner, stroke, gradient, shadow, glow, ripple, vignette, bevel, squircle, blend, blur
		for _, child in ipairs(object.Children) do
			local cls = child.ClassName
			if cls == "UITilt" then
				tilt = child
			elseif cls == "UICorner" then
				corner = child
			elseif cls == "UIStroke" then
				stroke = child
			elseif cls == "UIGradient" then
				gradient = child
			elseif cls == "UIShadow" then
				shadow = child
			elseif cls == "UIGlow" then
				glow = child
			elseif cls == "UIRipple" then
				ripple = child
			elseif cls == "UIVignette" then
				vignette = child
			elseif cls == "UIBevel" then
				bevel = child
			elseif cls == "UISquircle" then
				squircle = child
			elseif cls == "UIBlend" then
				blend = child
			elseif cls == "BlurEffect" then
				blur = child
			end
		end

		if tilt and tilt.Enabled ~= false and mouseIsInObject then
			local maxOffset = tilt.MaxOffset or Vector2.new(6, 6)
			local nx = (((mousePos.X - drawPos.X) / math.max(size.X, 1)) - 0.5) * 2
			local ny = (((mousePos.Y - drawPos.Y) / math.max(size.Y, 1)) - 0.5) * 2
			drawPos = vector.create(drawPos.X + nx * maxOffset.X, drawPos.Y + ny * maxOffset.Y, 0)
		end

		rawset(object, "MouseIsInObject", mouseIsInObject)
		object.MouseEnter:FireOncePerPress("MouseEnter", mouseIsInObject)
		object.MouseLeave:FireOncePerPress("MouseLeave", not mouseIsInObject)

		local color = object.BackgroundColor3:ToRaylib(object.BackgroundTransparency)
		local shapeModifier = squircle or corner
		local shapeExponent = squircle and squircle.Exponent or 2

		local minDim = math.min(size.X, size.Y)

		local selfBlendActive = false
		if blend and blend.Enabled ~= false and blend.AffectSelf ~= false then
			lib.BeginBlendMode(resolveBlendMode(raylib, blend.Mode))
			selfBlendActive = true
		end

		drawShadow(lib, structs, object, shadow, drawPos, size, corner, squircle)
		drawGlow(lib, structs, object, glow, drawPos, size, shapeModifier)

		if blur then
			renderer.Blur.blurRadius = blur.Size
			renderer.Blur:DrawBlurredRegion(drawPos.X, drawPos.Y, size.X, size.Y, Color3.new(1, 1, 1):ToRaylib(0))
		end

		if gradient and gradient.ColorSequence then
			local steps = 50
			local stepHeight = size.Y / steps
			local cornerRadius = shapeModifier
					and (shapeModifier.CornerRadius.Scale * minDim + shapeModifier.CornerRadius.Offset)
				or 0
			cornerRadius = math.min(cornerRadius, minDim / 2)

			local gradRec = structs.Rectangle:new({ x = 0, y = 0, width = 0, height = 0 })

			for i = 0, steps - 1 do
				local t1, t2 = i / steps, (i + 1) / steps
				local color1 = gradient.ColorSequence:Evaluate(t1)
				local color2 = gradient.ColorSequence:Evaluate(t2)
				local offsetLeft, offsetRight = 0, 0

				if cornerRadius > 0 then
					local yPos1, yPos2 = i * stepHeight, (i + 1) * stepHeight
					offsetLeft = math.max(
						getRoundedHorizontalInset(yPos1, size.Y, cornerRadius, shapeExponent),
						getRoundedHorizontalInset(yPos2, size.Y, cornerRadius, shapeExponent)
					)
					offsetRight = offsetLeft
				end

				gradRec.x = drawPos.X + offsetLeft
				gradRec.y = drawPos.Y + i * stepHeight
				gradRec.width = size.X - offsetLeft - offsetRight
				gradRec.height = stepHeight

				lib.DrawRectangleGradientEx(
					gradRec,
					color1:ToRaylib(0),
					color1:ToRaylib(0),
					color2:ToRaylib(0),
					color2:ToRaylib(0)
				)
			end

			if stroke and stroke.Transparency ~= 1 then
				drawShapeOutline(
					lib,
					structs,
					object,
					shapeModifier,
					drawPos.X,
					drawPos.Y,
					size.X,
					size.Y,
					stroke.Thickness,
					stroke.Color:ToRaylib(stroke.Transparency)
				)
			end
		else
			if object.BackgroundTransparency ~= 1 then
				drawShapeFill(lib, structs, object, shapeModifier, drawPos.X, drawPos.Y, size.X, size.Y, color)
			end

			if stroke and stroke.Transparency ~= 1 then
				drawShapeOutline(
					lib,
					structs,
					object,
					shapeModifier,
					drawPos.X,
					drawPos.Y,
					size.X,
					size.Y,
					stroke.Thickness,
					stroke.Color:ToRaylib(stroke.Transparency)
				)
			end
		end

		drawBevel(lib, structs, object, bevel, drawPos, size, shapeModifier)
		drawVignette(lib, structs, object, vignette, drawPos, size, shapeModifier)
		drawRipple(lib, raylib, ripple, object, drawPos, size, dt)

		if selfBlendActive then
			lib.EndBlendMode()
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
	resolveBlendMode = resolveBlendMode,
	render = propTable.render,

	-- description: "Returns whether an object is parented directly under a GUI container."
	-- args: "object: table"
	-- returns: "boolean"
	IsParentGuiContainer = function(object)
		return object.Parent.BaseClass == "UIContainer"
	end,

	-- description: "Renders visible GUI children with clipping and blend modifiers applied."
	-- args: "lib: number, object: table, dt: number, structs: table, renderer: number"
	renderChildren = function(lib, object, dt, structs, renderer)
		local mask = object:FindFirstChildOfClass("UIMask")
		local blend = object:FindFirstChildOfClass("UIBlend")
		local didClip = false
		local didBlend = false

		if blend and blend.Enabled ~= false and blend.AffectChildren ~= false then
			lib.BeginBlendMode(resolveBlendMode(raylib, blend.Mode))
			didBlend = true
		end

		if object.ClipsDescendants or (mask and mask.Enabled ~= false and mask.AffectChildren ~= false) then
			local pos = object.AbsolutePosition or ZERO_V
			local size = object.AbsoluteSize or ZERO_V
			local insetX, insetY = 0, 0

			if mask and mask.Inset and object.AbsoluteSize then
				local inset = resolveUDim2(mask.Inset, object.AbsoluteSize)
				insetX = inset.X
				insetY = inset.Y
			end

			local clipX = pos.X + insetX
			local clipY = pos.Y + insetY
			local clipW = math.max(1, size.X - insetX * 2)
			local clipH = math.max(1, size.Y - insetY * 2)

			lib.BeginScissorMode(clipX, clipY, clipW, clipH)
			didClip = true
		end

		for _, child in pairs(object:GetChildren()) do
			if child.render then
				child.render(lib, child, dt, structs, renderer)
			end
		end

		if didClip then
			lib.EndScissorMode()
		end

		if didBlend then
			lib.EndBlendMode()
		end
	end,

	-- description: "Updates absolute position, absolute size, and hover state without drawing."
	-- args: "lib: number, object: table, dt: number, structs: table, renderer: number"
	-- returns: "Vector3, Vector3"
	calculatePositions = function(lib, object, dt, structs, renderer)
		local drawPos, size = calculateDrawParams(object, lib, dt, structs, renderer)
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
		rawset(instance, "_GuiTweenRegistry", {})
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
