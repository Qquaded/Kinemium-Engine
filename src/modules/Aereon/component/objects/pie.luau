local raylib = require("@raylib")
local structs = raylib.structs

local rect = require("@arect")
local color3 = require("@Color3")

return function(objects, data)
	local config = {
		centerX = data.centerX or data[1] or 400,
		centerY = data.centerY or data[2] or 300,
		radius = data.radius or 80,
		innerRadius = data.innerRadius or 25,
		modifiers = {},

		-- Colors
		backgroundColor = color3.new(0.15, 0.15, 0.17),
		hoverColor = color3.new(0.25, 0.25, 0.28),
		selectedColor = color3.new(0.35, 0.45, 0.65),
		centerColor = color3.new(0.90, 0.30, 0.50),
		centerHoverColor = color3.new(1.0, 0.35, 0.55),
		dividerColor = color3.new(0.25, 0.25, 0.27),

		-- Menu items - each item should have a texture
		items = data.items or {},

		-- Interaction
		hoveredIndex = -1,
		centerHovered = false,
		visible = data.visible or true,
		iconSize = 24,

		onItemClick = data.onItemClick,
		onCenterClick = data.onCenterClick,
	}

	local wrapper = {}

	wrapper.set = function(prop, value)
		if type(config[prop]) == "function" then
			return wrapper
		end
		config[prop] = value
		return wrapper
	end

	wrapper.addItem = function(texture, label)
		table.insert(config.items, {
			texture = texture,
			label = label,
		})
		return wrapper
	end

	wrapper.setPosition = function(x, y)
		config.centerX = x
		config.centerY = y
		return wrapper
	end

	wrapper.show = function()
		config.visible = true
		return wrapper
	end

	wrapper.hide = function()
		config.visible = false
		return wrapper
	end

	wrapper.render = function(dt)
		if not config.visible then
			return
		end

		local mousePos = raylib.lib.GetMousePosition()
		local mousePressed = raylib.lib.IsMouseButtonPressed(0) == 1

		local numItems = #config.items
		if numItems == 0 then
			return
		end

		local angleStep = (2 * math.pi) / numItems
		local startAngle = -math.pi / 2

		config.hoveredIndex = -1
		config.centerHovered = false

		-- Check center hover
		local distToCenter = math.sqrt((mousePos.x - config.centerX) ^ 2 + (mousePos.y - config.centerY) ^ 2)
		if distToCenter <= config.innerRadius then
			config.centerHovered = true
		end

		-- Draw pie segments
		for i = 1, numItems do
			local angle1 = startAngle + (i - 1) * angleStep
			local angle2 = startAngle + i * angleStep
			local midAngle = (angle1 + angle2) / 2

			-- Check if mouse is in this segment
			local isHovered = false
			if distToCenter > config.innerRadius and distToCenter <= config.radius then
				local mouseAngle = math.atan2(mousePos.y - config.centerY, mousePos.x - config.centerX)

				-- Normalize angles
				local normalizedMouseAngle = mouseAngle
				local normalizedAngle1 = angle1
				local normalizedAngle2 = angle2

				-- Check if mouse angle is between angle1 and angle2
				if normalizedAngle2 < normalizedAngle1 then
					normalizedAngle2 = normalizedAngle2 + 2 * math.pi
				end
				if normalizedMouseAngle < normalizedAngle1 then
					normalizedMouseAngle = normalizedMouseAngle + 2 * math.pi
				end

				if normalizedMouseAngle >= normalizedAngle1 and normalizedMouseAngle <= normalizedAngle2 then
					isHovered = true
					config.hoveredIndex = i
				end
			end

			-- Segment color
			local segmentColor = config.backgroundColor
			if isHovered then
				segmentColor = config.hoverColor
			end

			-- Draw segment
			local segments = 32
			local segmentAngleStep = (angle2 - angle1) / segments

			for j = 0, segments - 1 do
				local a1 = angle1 + j * segmentAngleStep
				local a2 = angle1 + (j + 1) * segmentAngleStep

				local x1_outer = config.centerX + math.cos(a1) * config.radius
				local y1_outer = config.centerY + math.sin(a1) * config.radius
				local x2_outer = config.centerX + math.cos(a2) * config.radius
				local y2_outer = config.centerY + math.sin(a2) * config.radius

				local x1_inner = config.centerX + math.cos(a1) * config.innerRadius
				local y1_inner = config.centerY + math.sin(a1) * config.innerRadius
				local x2_inner = config.centerX + math.cos(a2) * config.innerRadius
				local y2_inner = config.centerY + math.sin(a2) * config.innerRadius

				raylib.lib.DrawTriangle(
					vector.create(x1_outer, y1_outer),
					vector.create(x2_outer, y2_outer),
					vector.create(x1_inner, y1_inner),
					segmentColor:ToRaylib(0)
				)
				raylib.lib.DrawTriangle(
					vector.create(x2_outer, y2_outer),
					vector.create(x2_inner, y2_inner),
					vector.create(x1_inner, y1_inner),
					segmentColor:ToRaylib(0)
				)
			end

			-- Draw divider line
			local divX1 = config.centerX + math.cos(angle2) * config.innerRadius
			local divY1 = config.centerY + math.sin(angle2) * config.innerRadius
			local divX2 = config.centerX + math.cos(angle2) * config.radius
			local divY2 = config.centerY + math.sin(angle2) * config.radius
			raylib.lib.DrawLineEx(
				vector.create(divX1, divY1),
				vector.create(divX2, divY2),
				1,
				config.dividerColor:ToRaylib(0)
			)

			-- Draw texture icon
			if config.items[i].texture then
				local iconDistance = (config.radius + config.innerRadius) / 2
				local iconX = config.centerX + math.cos(midAngle) * iconDistance
				local iconY = config.centerY + math.sin(midAngle) * iconDistance

				raylib.lib.DrawTexturePro(
					config.items[i].texture.texture,
					structs.Rectangle:new({
						x = 0,
						y = 0,
						width = config.items[i].texture.x,
						height = config.items[i].texture.y,
					}),
					structs.Rectangle:new({
						x = iconX - config.iconSize / 2,
						y = iconY - config.iconSize / 2,
						width = config.iconSize,
						height = config.iconSize,
					}),
					vector.create(0, 0),
					0,
					raylib.const.WHITE
				)
			end

			-- Click handling
			if isHovered and mousePressed and config.onItemClick then
				config.onItemClick(config.items[i], i)
			end
		end

		-- Draw center circle
		local centerColor = config.centerHovered and config.centerHoverColor or config.centerColor
		raylib.lib.DrawCircle(config.centerX, config.centerY, config.innerRadius, centerColor:ToRaylib(0))

		-- Center click handling
		if config.centerHovered and mousePressed and config.onCenterClick then
			config.onCenterClick()
		end

		for _, m in pairs(config.modifiers) do
			m()
		end
	end

	table.insert(objects, wrapper)
	return wrapper
end
