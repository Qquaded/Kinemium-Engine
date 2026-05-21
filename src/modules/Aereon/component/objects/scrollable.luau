local raylib = require("@raylib")
local structs = raylib.structs
local color3 = require("@Color3")
local rect = require("@arect")

return function(objects, data)
	local config = {
		obj_rect = data.obj_rect or rect.new(
			data.x or data[1] or 0,
			data.y or data[2] or 0,
			data.width or data[3] or 100,
			data.height or data[4] or 100
		),
		scrollOffset = data.scrollOffset or 0,
		scrollTarget = data.scrollOffset or 0,
		direction = data.direction or "vertical", -- "vertical" or "horizontal"
		contentHeight = data.contentHeight or 0,
		contentWidth = data.contentWidth or 0,
		padding = data.padding or 0,
		scrollbarWidth = data.scrollbarWidth or 8,
		scrollbarColor = data.scrollbarColor or color3.new(0.3, 0.3, 0.3),
		scrollbarHoverColor = data.scrollbarHoverColor or color3.new(0.5, 0.5, 0.5),
		scrollbarBackground = data.scrollbarBackground or color3.new(0.1, 0.1, 0.1),
		scrollbarBackgroundTransparency = data.scrollbarBackgroundTransparency or 0.8,
		child = data.child,
		input = data.input or raylib.lib,
		enabled = data.enabled or true,
		inputButtons = data.inputButtons,
		disableClipping = data.disableClipping or false,
		debug = data.debug or false,
		lerpSpeed = data.lerpSpeed or 18,
		wheelSpeed = data.wheelSpeed or 40,
		scrollbarDrag = { active = false, offset = 0 },
	}

	local wrapper = {}

	wrapper.set = function(prop, value)
		if prop == "obj_rect" then
			config.obj_rect = value
		else
			config[prop] = value
		end
		return wrapper
	end

	wrapper.get = function(prop)
		return config[prop]
	end

	wrapper.get_rect = function()
		return config.obj_rect
	end

	wrapper.render = function(dt)
		dt = dt or 0
		local input = config.input or raylib.lib
		local mousePos = input.GetMousePosition()
		local function isInRect(r)
			return mousePos.x >= r.x
				and mousePos.x <= r.x + r.width
				and mousePos.y >= r.y
				and mousePos.y <= r.y + r.height
		end
		-- Mouse wheel
		local isEnabled = config.enabled ~= false

		local wheel = input.GetMouseWheelMove()
		if isEnabled and isInRect(config.obj_rect) and wheel ~= 0 then
			config.scrollTarget = config.scrollTarget - wheel * config.wheelSpeed
		end

		local maxScroll
		if config.direction == "horizontal" then
			maxScroll = math.max(0, config.contentWidth - config.obj_rect.width)
		else
			maxScroll = math.max(0, config.contentHeight - config.obj_rect.height)
		end

		config.scrollTarget = math.clamp(config.scrollTarget, 0, maxScroll)

		-- Smooth scroll
		config.scrollOffset = config.scrollOffset
			+ (config.scrollTarget - config.scrollOffset) * math.min(dt * config.lerpSpeed, 1)
		config.scrollOffset = math.clamp(config.scrollOffset, 0, maxScroll)

		-- Begin Clipping
		if not config.disableClipping then
			raylib.lib.BeginScissorMode(
				config.obj_rect.x,
				config.obj_rect.y,
				config.obj_rect.width,
				config.obj_rect.height
			)
		end

		-- Update child position
		if config.child then
			local childRect = config.child.get_rect and config.child.get_rect()
			if not childRect and config.child.get then
				childRect = config.child.get("obj_rect")
			end

			if childRect then
				local newX = config.obj_rect.x
				local newY = config.obj_rect.y

				if config.direction == "horizontal" then
					newX = config.obj_rect.x - config.scrollOffset
				else
					newY = config.obj_rect.y - config.scrollOffset
				end

				config.child.set("obj_rect", rect.new(newX, newY, childRect.width, childRect.height))
				config.child.render(dt)

				-- Update content size if child is autoSized stack/flex
				if config.child.get then
					local h = config.child.get("obj_rect").height
					local w = config.child.get("obj_rect").width
					if h ~= config.contentHeight then
						config.contentHeight = h
					end
					if w ~= config.contentWidth then
						config.contentWidth = w
					end
				elseif childRect then
					if childRect.height ~= config.contentHeight then
						config.contentHeight = childRect.height
					end
					if childRect.width ~= config.contentWidth then
						config.contentWidth = childRect.width
					end
				end
			end
		end

		if not config.disableClipping then
			raylib.lib.EndScissorMode()
		end

		-- Render scrollbar
		if maxScroll > 0 then
			local visibleSize = (config.direction == "horizontal") and config.obj_rect.width or config.obj_rect.height
			local totalSize = (config.direction == "horizontal") and config.contentWidth or config.contentHeight
			if totalSize <= 0 then
				totalSize = 1
			end

			local thumbSize = math.max(30, (visibleSize / totalSize) * visibleSize)
			local scrollbarRange = visibleSize - thumbSize

			local thumbPos = (config.scrollOffset / maxScroll) * scrollbarRange

			local buttonInput = config.inputButtons or input
			local mousePressedRawA = input.IsMouseButtonPressed(0)
			local mouseDownRawA = input.IsMouseButtonDown(0)
			local mousePressedRawB = buttonInput.IsMouseButtonPressed(0)
			local mouseDownRawB = buttonInput.IsMouseButtonDown(0)
			local mousePressed = (mousePressedRawA == 1)
				or (mousePressedRawA == true)
				or (mousePressedRawB == 1)
				or (mousePressedRawB == true)
			local mouseDown = (mouseDownRawA == 1)
				or (mouseDownRawA == true)
				or (mouseDownRawB == 1)
				or (mouseDownRawB == true)

			local thumbRect, trackRect
			if config.direction == "horizontal" then
				local scrollbarY = config.obj_rect.y + config.obj_rect.height - config.scrollbarWidth - 2
				thumbRect = rect.new(config.obj_rect.x + thumbPos, scrollbarY, thumbSize, config.scrollbarWidth)
				trackRect = rect.new(config.obj_rect.x, scrollbarY, visibleSize, config.scrollbarWidth)
			else
				local scrollbarX = config.obj_rect.x + config.obj_rect.width - config.scrollbarWidth - 2
				thumbRect = rect.new(scrollbarX, config.obj_rect.y + thumbPos, config.scrollbarWidth, thumbSize)
				trackRect = rect.new(scrollbarX, config.obj_rect.y, config.scrollbarWidth, visibleSize)
			end

			local hitPad = 6
			local expandedThumb = rect.new(
				thumbRect.x - hitPad,
				thumbRect.y - hitPad,
				thumbRect.width + hitPad * 2,
				thumbRect.height + hitPad * 2
			)
			local expandedTrack =
				rect.new(trackRect.x - hitPad, trackRect.y, trackRect.width + hitPad * 2, trackRect.height)
			local isThumbHovered = isInRect(expandedThumb)
			local isTrackHovered = isInRect(expandedTrack)

			if (mousePressed or mouseDown) and isThumbHovered and not config.scrollbarDrag.active then
				config.scrollbarDrag.active = true
				config.scrollbarDrag.offset = (config.direction == "horizontal")
						and (mousePos.x - (config.obj_rect.x + thumbPos))
					or (mousePos.y - (config.obj_rect.y + thumbPos))
			elseif (mousePressed or mouseDown) and isTrackHovered and not config.scrollbarDrag.active then
				local mouseVal = (config.direction == "horizontal") and mousePos.x or mousePos.y
				local startVal = (config.direction == "horizontal") and config.obj_rect.x or config.obj_rect.y

				local newThumbPos = math.clamp(mouseVal - thumbSize / 2, startVal, startVal + scrollbarRange)
				local percent = scrollbarRange > 0 and ((newThumbPos - startVal) / scrollbarRange) or 0
				config.scrollTarget = percent * maxScroll
				config.scrollbarDrag.active = true
				config.scrollbarDrag.offset = mouseVal - newThumbPos
			end

			if config.scrollbarDrag.active then
				if mouseDown then
					local mouseVal = (config.direction == "horizontal") and mousePos.x or mousePos.y
					local startVal = (config.direction == "horizontal") and config.obj_rect.x or config.obj_rect.y

					local newThumbPos =
						math.clamp(mouseVal - config.scrollbarDrag.offset, startVal, startVal + scrollbarRange)
					local percent = scrollbarRange > 0 and ((newThumbPos - startVal) / scrollbarRange) or 0
					config.scrollTarget = percent * maxScroll
				else
					config.scrollbarDrag.active = false
				end
			end

			-- Draw Track
			raylib.lib.DrawRectangleRec(
				rect:translate(trackRect),
				config.scrollbarBackground:ToRaylib(1 - config.scrollbarBackgroundTransparency)
			)

			-- Draw Thumb
			local thumbColor = (isThumbHovered or config.scrollbarDrag.active) and config.scrollbarHoverColor
				or config.scrollbarColor
			raylib.lib.DrawRectangleRounded(rect:translate(thumbRect), 0.5, 4, thumbColor:ToRaylib(0))
		end
	end

	table.insert(objects, wrapper)
	return wrapper
end
