local rect = require("@arect")
local color3 = require("@Color3")

return function(objects, data, raylib)
	local config = {
		obj_rect = rect.new(data.x or data[1], data.y or data[2], data.width or data[3], data.height or data[4] or 60),

		-- Property data
		propertyName = data.propertyName or "Property",
		propertyDescription = data.propertyDescription, -- Optional description text
		propertyValue = data.propertyValue,

		-- Visual settings
		backgroundColor = data.backgroundColor or color3.new(0.15, 0.15, 0.15),
		hoverColor = data.hoverColor or color3.new(0.18, 0.18, 0.18),
		separatorColor = data.separatorColor or color3.new(0.25, 0.25, 0.25),
		textColor = data.textColor or color3.new(0.9, 0.9, 0.9),
		descriptionColor = data.descriptionColor or color3.new(0.6, 0.6, 0.6),
		backgroundTransparency = data.backgroundTransparency or 0,

		-- Position in list
		position = data.position or "middle", -- "first", "middle", "last", "single"
		showSeparator = data.showSeparator ~= false, -- Show separator line at bottom

		-- Layout
		padding = data.padding or 16,
		nameFontSize = data.nameFontSize or 19,
		descFontSize = data.descFontSize or 14,
		fontSpacing = data.fontSpacing or 1,
		roundness = data.roundness or 0.08,
		segments = data.segments or 8,
		separatorHeight = data.separatorHeight or 1,

		-- State
		isHovered = false,
		font = data.font or raylib.lib.GetFontDefault(),

		-- Editor component (placed on the right side)
		editorComponent = data.editorComponent,
		editorWidth = data.editorWidth or 200, -- Width of the editor area

		-- Callbacks
		onValueChange = data.onValueChange,
		onClick = data.onClick,
	}

	local wrapper = {}

	wrapper.set = function(prop, value)
		if type(config[prop]) == "function" then
			return wrapper
		end
		config[prop] = value
		return wrapper
	end

	wrapper.get = function(prop)
		return config[prop]
	end

	wrapper.setPropertyValue = function(value)
		config.propertyValue = value
		if config.editorComponent and config.editorComponent.setText then
			config.editorComponent:setText(tostring(value))
		elseif config.editorComponent and config.editorComponent.set then
			config.editorComponent.set("value", value)
		end

		if config.onValueChange then
			config.onValueChange(value)
		end
	end

	wrapper.setEditorComponent = function(component)
		config.editorComponent = component
	end

	wrapper.getPropertyValue = function()
		return config.propertyValue
	end

	wrapper.setPosition = function(pos)
		config.position = pos
	end

	wrapper.getRect = function()
		return config.obj_rect
	end

	local function drawRoundedCellBackground(r, bgColor, position, roundness, segments)
		local col = bgColor:ToRaylib(config.backgroundTransparency)

		if position == "single" then
			raylib.lib.DrawRectangleRounded(rect:translate(r), roundness, segments, col)
		elseif position == "first" then
			raylib.lib.DrawRectangleRounded(rect:translate(r), roundness, segments, col)
			raylib.lib.DrawRectangle(r.x, r.y + r.height / 2, r.width, r.height / 2, col)
		elseif position == "last" then
			raylib.lib.DrawRectangleRounded(rect:translate(r), roundness, segments, col)
			raylib.lib.DrawRectangle(r.x, r.y, r.width, r.height / 2, col)
		else -- "middle"
			raylib.lib.DrawRectangle(r.x, r.y, r.width, r.height, col)
		end
	end

	wrapper.render = function(dt)
		local r = config.obj_rect
		local mousePos = raylib.lib.GetMousePosition()
		local mousePressed = raylib.lib.IsMouseButtonPressed(0) == 1

		config.isHovered = rect.MouseIsInRect(r)

		local bgColor = config.isHovered and config.hoverColor or config.backgroundColor

		drawRoundedCellBackground(r, bgColor, config.position, config.roundness, config.segments)

		if config.showSeparator and config.position ~= "last" and config.position ~= "single" then
			raylib.lib.DrawRectangle(
				r.x + config.padding,
				r.y + r.height - config.separatorHeight,
				r.width - config.padding * 2,
				config.separatorHeight,
				config.separatorColor:ToRaylib(0)
			)
		end

		-- Calculate text layout
		local nameX = r.x + config.padding
		local nameY = r.y + config.padding

		-- If there's a description, adjust name positioning
		if config.propertyDescription then
			nameY = r.y + (r.height - config.nameFontSize - config.descFontSize - 4) / 2
		else
			nameY = r.y + (r.height - config.nameFontSize) / 2
		end

		-- Draw property name
		raylib.lib.DrawTextEx(
			config.font,
			config.propertyName,
			vector.create(nameX, nameY),
			config.nameFontSize,
			config.fontSpacing,
			config.textColor:ToRaylib(0)
		)

		-- Draw description if provided
		if config.propertyDescription then
			local descY = nameY + config.nameFontSize + 4
			raylib.lib.DrawTextEx(
				config.font,
				config.propertyDescription,
				vector.create(nameX, descY),
				config.descFontSize,
				config.fontSpacing,
				config.descriptionColor:ToRaylib(0)
			)
		end

		-- Handle click
		if config.isHovered and mousePressed and config.onClick then
			config.onClick()
		end
	end

	table.insert(objects, wrapper)
	return wrapper
end
