local raylib = require("@raylib")
local structs = raylib.structs

local rect = require("@arect")
local color3 = require("@Color3")

local defaultFont = raylib.lib.GetFontDefault()

return function(objects, data)
	local CAP = data.capacity or 120

	local config = {
		obj_rect = rect.new(data.x or data[1], data.y or data[2], data.width or data[3], data.height or data[4]),

		values = table.create(CAP, 0),
		head = 1,
		count = 0,
		capacity = CAP,
		maxPoints = 5,
		backgroundColor = color3.new(0, 0, 0),
		bgTransparency = 0,

		lineColor = data.lineColor or color3.new(0.02, 0.5, 1),
		bgColor = data.bgColor or color3.new(0.1, 0.1, 0.1),
		tooltipTextColor = data.tooltipTextColor or color3.new(1, 1, 1),
		tooltipBackgroundColor = data.tooltipBackgroundColor or color3.new(0, 0, 0),
		tooltipFontSize = data.tooltipFontSize or 14,
		gridColor = data.gridColor or color3.new(0.25, 0.25, 0.25),

		min = data.min, -- optional fixed scale
		max = data.max,
		drawGrid = data.drawGrid ~= false,
	}

	local wrapper = {}

	-- push new value
	function wrapper.push(v)
		config.values[config.head] = v
		config.head = (config.head % config.capacity) + 1
		if config.count < config.capacity then
			config.count += 1
		end
	end

	function wrapper.clear()
		config.head = 1
		config.count = 0
	end

	wrapper.set = function(prop, value)
		config[prop] = value
		return wrapper
	end

	local function getMinMax()
		if config.min and config.max then
			return config.min, config.max
		end

		local min = config.values[1]
		local max = min

		for i = 2, config.count do
			local v = config.values[i]
			if v < min then
				min = v
			end
			if v > max then
				max = v
			end
		end

		if min == max then
			max = min + 0.0001
		end

		return min, max
	end

	wrapper.render = function(dt)
		if not config.obj_rect then
			return
		end
		local r = config.obj_rect
		local count = config.count
		if count == 0 then
			return
		end

		local minVal, maxVal = getMinMax()
		local widthPerValue = r.width / math.max(count - 1, 1)
		local values = config.values

		raylib.lib.DrawRectangleRec(
			rect:translate(r),
			(config.bgColor or config.backgroundColor):ToRaylib(config.bgTransparency)
		)

		for i = 2, count do
			local x1 = r.x + (i - 2) * widthPerValue
			local y1 = r.y + r.height - ((values[i - 1] - minVal) / (maxVal - minVal)) * r.height
			local x2 = r.x + (i - 1) * widthPerValue
			local y2 = r.y + r.height - ((values[i] - minVal) / (maxVal - minVal)) * r.height
			raylib.lib.DrawLine(x1, y1, x2, y2, config.lineColor:ToRaylib(0))
		end

		local mouse = raylib.lib.GetMousePosition()
		local nearestIndex = nil
		local nearestDist = math.huge

		for i = 1, count do
			local px = r.x + (i - 1) * widthPerValue
			local py = r.y + r.height - ((values[i] - minVal) / (maxVal - minVal)) * r.height

			local dx = mouse.x - px
			local dy = mouse.y - py
			local dist = math.sqrt(dx * dx + dy * dy)
			if dist < nearestDist then
				nearestDist = dist
				nearestIndex = i
			end
		end

		if nearestIndex and nearestDist < 10 then
			local tooltipText = tostring(values[nearestIndex])
			local fontSize = config.tooltipFontSize or 14
			local textWidth = raylib.lib.MeasureText(tooltipText, fontSize)
			local textHeight = fontSize
			local px = r.x + (nearestIndex - 1) * widthPerValue
			local py = r.y
				+ r.height
				- ((values[nearestIndex] - minVal) / (maxVal - minVal)) * r.height
				- textHeight
				- 4

			local tooltipRect = rect.new(px - textWidth / 2 - 4, py - 2, textWidth + 8, textHeight + 4)
			raylib.lib.DrawRectangleRec(
				rect:translate(tooltipRect),
				(config.tooltipBackgroundColor or color3.new(0, 0, 0)):ToRaylib(0.8)
			)
			raylib.lib.DrawText(
				tooltipText,
				tooltipRect.x + 4,
				tooltipRect.y + 2,
				textHeight,
				(config.tooltipTextColor or color3.new(1, 1, 1)):ToRaylib(0)
			)
		end
	end

	table.insert(objects, wrapper)
	return wrapper
end
