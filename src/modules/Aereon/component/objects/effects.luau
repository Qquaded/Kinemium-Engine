local raylib = require("@raylib")
local rect = require("@arect")
local color3 = require("@Color3")

return function(config)
	config = config or {}

	local state = {
		currentColor = config.baseColor or color3.new(0.2, 0.2, 0.2),
		currentTransparency = config.baseTransparency or 0,
		hoverProgress = 0,
		pressProgress = 0,
		glowAlpha = 0,
		shadowOffsetAnim = config.shadowOffsetY or 4,
	}

	local LERP_SPEED = config.lerpSpeed or 12
	local HOVER_SPEED = config.hoverSpeed or 8
	local PRESS_SPEED = config.pressSpeed or 16

	local settings = {
		enableHover = config.enableHover ~= false,
		baseColor = config.baseColor or color3.new(0.2, 0.2, 0.2),
		hoverColor = config.hoverColor or color3.new(0.3, 0.3, 0.3),
		pressColor = config.pressColor or color3.new(0.15, 0.15, 0.15),
		baseTransparency = config.baseTransparency or 0,
		hoverTransparency = config.hoverTransparency or config.baseTransparency or 0,
		pressTransparency = config.pressTransparency or config.hoverTransparency or config.baseTransparency or 0,

		enableShadows = config.enableShadows ~= false,
		shadowColor = config.shadowColor or color3.new(0, 0, 0),
		shadowLayers = config.shadowLayers or 6,
		shadowOffsetX = config.shadowOffsetX or 0,
		shadowOffsetY = config.shadowOffsetY or 4,
		shadowSpread = config.shadowSpread or 3,

		enableGlow = false,
		glowColor = config.glowColor or config.hoverColor or color3.new(0.3, 0.3, 0.3),

		enablePress = config.enablePress ~= false,
		pressSquish = config.pressSquish or 2,
	}

	local isHovered = false
	local isPressed = false
	local objRect = rect.new(0, 0, 0, 0)

	local function lerp(a, b, t)
		return a + (b - a) * t
	end

	local function clamp(v, lo, hi)
		return math.max(lo, math.min(hi, v))
	end

	local wrapper = {}

	wrapper.setRect = function(rect)
		objRect = rect
		return wrapper
	end

	wrapper.update = function(dt)
		if not settings.enableHover and not settings.enablePress then
			return
		end

		isHovered = rect.MouseIsInRect(objRect)
		isPressed = isHovered and raylib.lib.IsMouseButtonDown(0) == 1

		local targetHover = isHovered and 1 or 0
		local targetPress = isPressed and 1 or 0

		state.hoverProgress = clamp(lerp(state.hoverProgress, targetHover, dt * HOVER_SPEED), 0, 1)
		state.pressProgress = clamp(lerp(state.pressProgress, targetPress, dt * PRESS_SPEED), 0, 1)

		if settings.enableGlow then
			state.glowAlpha = clamp(lerp(state.glowAlpha, isHovered and 0.35 or 0, dt * HOVER_SPEED), 0, 1)
		end

		if settings.enableShadows then
			local targetShadowOffset = lerp(
				settings.shadowOffsetY,
				lerp(settings.shadowOffsetY * 1.8, 1, state.pressProgress),
				state.hoverProgress
			)
			state.shadowOffsetAnim = lerp(state.shadowOffsetAnim, targetShadowOffset, dt * PRESS_SPEED)
		end

		local targetColor = settings.baseColor
		local targetTransparency = settings.baseTransparency
		if isPressed and settings.enablePress then
			targetColor = settings.pressColor
			targetTransparency = settings.pressTransparency
		elseif isHovered and settings.enableHover then
			targetColor = settings.hoverColor
			targetTransparency = settings.hoverTransparency
		end

		state.currentColor = color3.new(
			lerp(state.currentColor.R, targetColor.R, dt * LERP_SPEED),
			lerp(state.currentColor.G, targetColor.G, dt * LERP_SPEED),
			lerp(state.currentColor.B, targetColor.B, dt * LERP_SPEED)
		)
		state.currentTransparency = lerp(state.currentTransparency, targetTransparency, dt * LERP_SPEED)
	end

	wrapper.renderShadows = function(drawRect, rounded)
		if not settings.enableShadows then
			return
		end

		rounded = rounded or { 0.3, 8 }
		local layers = settings.shadowLayers
		local baseAlpha = lerp(0.32, 0.18, state.pressProgress)
		local shadowX = settings.shadowOffsetX
		local shadowY = state.shadowOffsetAnim

		for i = layers, 1, -1 do
			local t = (i - 1) / (layers - 1)
			local expand = t * settings.shadowSpread
			local alpha = baseAlpha * (1 - t * 0.85)
			local layerRect = rect.new(
				drawRect.x - expand + shadowX,
				drawRect.y - expand + shadowY,
				drawRect.width + expand * 2,
				drawRect.height + expand * 2
			)
			raylib.lib.DrawRectangleRounded(
				rect:translate(layerRect),
				rounded[1],
				rounded[2],
				settings.shadowColor:ToRaylib(1 - alpha)
			)
		end
	end

	wrapper.renderGlow = function(drawRect, rounded)
		if not settings.enableGlow or state.glowAlpha <= 0.01 then
			return
		end

		rounded = rounded or { 0.3, 8 }
		local glowExpand = lerp(0, 6, state.hoverProgress)
		local glowRect = rect.new(
			drawRect.x - glowExpand,
			drawRect.y - glowExpand,
			drawRect.width + glowExpand * 2,
			drawRect.height + glowExpand * 2
		)
		local glowColor = color3.new(settings.glowColor.R * 1.4, settings.glowColor.G * 1.4, settings.glowColor.B * 1.4)
		raylib.lib.DrawRectangleRounded(
			rect:translate(glowRect),
			rounded[1],
			rounded[2],
			glowColor:ToRaylib(1 - state.glowAlpha)
		)
	end

	wrapper.renderBackground = function(drawRect, rounded, transparency)
		rounded = rounded or { 0.3, 8 }

		local squish = 0
		if settings.enablePress then
			squish = state.pressProgress * settings.pressSquish
		end

		local renderRect = rect.new(drawRect.x, drawRect.y + squish, drawRect.width, drawRect.height - squish * 2)

		raylib.lib.DrawRectangleRounded(
			rect:translate(renderRect),
			rounded[1],
			rounded[2],
			state.currentColor:ToRaylib(transparency or state.currentTransparency)
		)

		return renderRect
	end

	wrapper.renderAll = function(drawRect, rounded)
		if settings.enableShadows then
			wrapper.renderShadows(drawRect, rounded)
		end
		if settings.enableGlow then
			wrapper.renderGlow(drawRect, rounded)
		end
		return wrapper.renderBackground(drawRect, rounded)
	end

	wrapper.isHovered = function()
		return isHovered
	end

	wrapper.isPressed = function()
		return isPressed
	end

	wrapper.getCurrentColor = function()
		return state.currentColor
	end

	wrapper.getHoverProgress = function()
		return state.hoverProgress
	end

	wrapper.getPressProgress = function()
		return state.pressProgress
	end

	wrapper.getSquishOffset = function()
		if settings.enablePress then
			return state.pressProgress * settings.pressSquish
		end
		return 0
	end

	wrapper.setBaseColor = function(color)
		settings.baseColor = color
		return wrapper
	end

	wrapper.setBaseTransparency = function(value)
		settings.baseTransparency = value
		return wrapper
	end

	wrapper.setHoverColor = function(color)
		settings.hoverColor = color
		settings.glowColor = color
		return wrapper
	end

	wrapper.setHoverTransparency = function(value)
		settings.hoverTransparency = value
		return wrapper
	end

	wrapper.setPressColor = function(color)
		settings.pressColor = color
		return wrapper
	end

	wrapper.setPressTransparency = function(value)
		settings.pressTransparency = value
		return wrapper
	end

	return wrapper
end
