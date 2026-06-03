local raylib = require("@raylib")
local structs = raylib.structs

local rect = require("@arect")
local color3 = require("@Color3")

return function(objects, data)
	local config = {
		obj_rect = rect.new(data.x or data[1], data.y or data[2], data.width or data[3], data.height or data[4]),
		rounded = data.rounded or { 0.1, 8 },
		modifiers = {},

		-- Styling
		backgroundColor = color3.new(0.04, 0.04, 0.05),
		backgroundTransparency = 0,
		hoverColor = color3.new(0.12, 0.12, 0.14),
		activeColor = color3.new(0.08, 0.35, 0.22),
		separatorColor = color3.new(0.15, 0.15, 0.18),
		iconColor = color3.new(0.65, 0.65, 0.70),
		activeIconColor = color3.new(0.12, 0.75, 0.45),

		-- Button configuration
		buttons = data.buttons or {},
		activeButton = data.activeButton or nil,
		buttonSize = data.buttonSize or 40,
		padding = data.padding or 8,
		spacing = data.spacing or 4,

		-- Font configuration
		font = data.font, -- Custom font for tooltips
		tooltipFontSize = data.tooltipFontSize or 11,
		tooltipSpacing = data.tooltipSpacing or 0.5,

		-- State
		hoveredButton = nil,

		-- Callbacks
		onButtonClick = data.onButtonClick,
	}

	-- Default buttons if none provided
	if #config.buttons == 0 then
		config.buttons = {
			{ id = "select", icon = nil, tooltip = "Select" },
			{ id = "move", icon = nil, tooltip = "Move" },
			{ type = "separator" },
			{ id = "camera", icon = nil, tooltip = "User Perspective" },
			{ id = "view", icon = nil, tooltip = "View" },
			{ type = "separator" },
			{ id = "cube", icon = nil, tooltip = "Add Cube" },
			{ id = "light", icon = nil, tooltip = "Add Light" },
			{ id = "camera2", icon = nil, tooltip = "Add Camera" },
			{ type = "separator" },
			{ id = "brush", icon = nil, tooltip = "Paint" },
			{ id = "eraser", icon = nil, tooltip = "Erase" },
			{ type = "separator" },
			{ id = "material", icon = nil, tooltip = "Material" },
			{ id = "world", icon = nil, tooltip = "World" },
			{ type = "separator" },
			{ id = "tree", icon = nil, tooltip = "Scene" },
			{ id = "settings", icon = nil, tooltip = "Settings" },
		}
	end

	local wrapper = {}

	wrapper.set = function(prop, value)
		if type(config[prop]) == "function" then
			return wrapper
		end
		config[prop] = value
		return wrapper
	end

	wrapper.setActiveButton = function(buttonId)
		config.activeButton = buttonId
		return wrapper
	end

	wrapper.getActiveButton = function()
		return config.activeButton
	end

	-- Draw a simple icon placeholder
	local function drawIconPlaceholder(x, y, size, iconType, color)
		local centerX = x + size / 2
		local centerY = y + size / 2
		local iconSize = size * 0.5

		if iconType == "select" then
			-- Arrow cursor
			raylib.lib.DrawTriangle(
				vector.create(centerX - iconSize / 2, centerY - iconSize / 2),
				vector.create(centerX - iconSize / 2, centerY + iconSize / 2),
				vector.create(centerX + iconSize / 2, centerY),
				color
			)
		elseif iconType == "move" then
			-- Cross arrows
			raylib.lib.DrawLine(centerX - iconSize / 2, centerY, centerX + iconSize / 2, centerY, color)
			raylib.lib.DrawLine(centerX, centerY - iconSize / 2, centerX, centerY + iconSize / 2, color)
			raylib.lib.DrawTriangle(
				vector.create(centerX, centerY - iconSize / 2 - 3),
				vector.create(centerX - 3, centerY - iconSize / 2 + 3),
				vector.create(centerX + 3, centerY - iconSize / 2 + 3),
				color
			)
			raylib.lib.DrawTriangle(
				vector.create(centerX + iconSize / 2 + 3, centerY),
				vector.create(centerX + iconSize / 2 - 3, centerY - 3),
				vector.create(centerX + iconSize / 2 - 3, centerY + 3),
				color
			)
		elseif iconType == "camera" then
			-- Camera icon
			local camSize = iconSize * 0.6
			raylib.lib.DrawRectangle(centerX - camSize / 2, centerY - camSize / 2, camSize, camSize, color)
			raylib.lib.DrawCircle(centerX, centerY, camSize / 3, color)
		elseif iconType == "view" then
			-- Eye icon
			raylib.lib.DrawEllipse(centerX, centerY, iconSize / 2, iconSize / 3, color)
			raylib.lib.DrawCircle(centerX, centerY, iconSize / 4, color)
		elseif iconType == "cube" then
			-- Cube icon
			local cubeSize = iconSize * 0.5
			raylib.lib.DrawRectangle(centerX - cubeSize / 2, centerY - cubeSize / 2, cubeSize, cubeSize, color)
			raylib.lib.DrawRectangleLines(
				centerX - cubeSize / 2 - 2,
				centerY - cubeSize / 2 - 2,
				cubeSize,
				cubeSize,
				color
			)
		elseif iconType == "light" then
			-- Light bulb
			raylib.lib.DrawCircle(centerX, centerY - 2, iconSize / 3, color)
			raylib.lib.DrawRectangle(centerX - 2, centerY + iconSize / 4, 4, iconSize / 5, color)
		elseif iconType == "brush" then
			-- Brush icon
			raylib.lib.DrawCircle(centerX, centerY - iconSize / 4, iconSize / 3, color)
			raylib.lib.DrawTriangle(
				vector.create(centerX - iconSize / 4, centerY),
				vector.create(centerX + iconSize / 4, centerY),
				vector.create(centerX, centerY + iconSize / 2),
				color
			)
		elseif iconType == "eraser" then
			-- Eraser icon
			raylib.lib.DrawRectangle(
				centerX - iconSize / 3,
				centerY - iconSize / 4,
				iconSize * 0.66,
				iconSize / 2,
				color
			)
		elseif iconType == "material" then
			-- Sphere with shading
			raylib.lib.DrawCircle(centerX, centerY, iconSize / 2.5, color)
			raylib.lib.DrawCircle(centerX - iconSize / 6, centerY - iconSize / 6, iconSize / 6, color)
		elseif iconType == "tree" then
			-- Hierarchy tree
			raylib.lib.DrawRectangle(centerX - iconSize / 4, centerY - iconSize / 2, 2, iconSize, color)
			raylib.lib.DrawLine(
				centerX - iconSize / 4,
				centerY - iconSize / 4,
				centerX + iconSize / 4,
				centerY - iconSize / 4,
				color
			)
			raylib.lib.DrawLine(
				centerX - iconSize / 4,
				centerY + iconSize / 4,
				centerX + iconSize / 4,
				centerY + iconSize / 4,
				color
			)
		elseif iconType == "settings" then
			-- Gear icon
			raylib.lib.DrawPoly(vector.create(centerX, centerY), 6, iconSize / 2, 0, color)
			raylib.lib.DrawCircle(centerX, centerY, iconSize / 4, color)
		else
			-- Default: filled circle
			raylib.lib.DrawCircle(centerX, centerY, iconSize / 3, color)
		end
	end

	wrapper.render = function(dt)
		local r = config.obj_rect
		local mousePos = raylib.lib.GetMousePosition()
		local mousePressed = raylib.lib.IsMouseButtonPressed(0) == 1

		-- Background
		raylib.lib.DrawRectangleRounded(
			rect:translate(r),
			config.rounded[1],
			config.rounded[2],
			config.backgroundColor:ToRaylib(config.backgroundTransparency)
		)

		local currentY = r.y + config.padding
		config.hoveredButton = nil

		for i, button in ipairs(config.buttons) do
			if button.type == "separator" then
				-- Draw separator line
				local separatorY = currentY + config.spacing
				raylib.lib.DrawRectangle(
					r.x + config.padding,
					separatorY,
					r.width - config.padding * 2,
					1,
					config.separatorColor:ToRaylib(0)
				)
				currentY = separatorY + config.spacing * 2
			else
				local btnRect = rect.new(r.x, currentY, r.width, config.buttonSize)
				local isActive = config.activeButton == button.id
				local isHovered = rect.MouseIsInRect(btnRect)

				if isHovered then
					config.hoveredButton = button
				end

				-- Button background (draw centered in the sidebar)
				local centeredBtnRect =
					rect.new(r.x + (r.width - config.buttonSize) / 2, currentY, config.buttonSize, config.buttonSize)
				if isActive then
					raylib.lib.DrawRectangleRounded(
						rect:translate(centeredBtnRect),
						0.1,
						4,
						config.activeColor:ToRaylib(0.3)
					)
					raylib.lib.DrawRectangle(
						centeredBtnRect.x - 4,
						centeredBtnRect.y + 4,
						3,
						centeredBtnRect.height - 8,
						config.activeIconColor:ToRaylib(0)
					)
				elseif isHovered then
					raylib.lib.DrawRectangleRounded(
						rect:translate(centeredBtnRect),
						0.15,
						4,
						config.hoverColor:ToRaylib(0)
					)
				end

				-- Icon
				local iconColor = isActive and config.activeIconColor or config.iconColor
				local iconColorStruct = iconColor:ToRaylib(0)

				if button.icon then
					-- Draw texture icon if provided
					local iconPadding = 8
					local iconRect = rect.new(
						centeredBtnRect.x + iconPadding,
						centeredBtnRect.y + iconPadding,
						config.buttonSize - iconPadding * 2,
						config.buttonSize - iconPadding * 2
					)

					raylib.lib.DrawTexturePro(
						button.icon.texture,
						structs.Rectangle:new({
							x = 0,
							y = 0,
							width = button.icon.x,
							height = button.icon.y,
						}),
						rect:translate(iconRect),
						vector.create(0, 0),
						0,
						iconColorStruct
					)
				else
					-- Draw placeholder icon
					drawIconPlaceholder(
						centeredBtnRect.x,
						centeredBtnRect.y,
						config.buttonSize,
						button.id,
						iconColorStruct
					)
				end

				-- Handle click
				if isHovered and mousePressed then
					config.activeButton = button.id
					if config.onButtonClick then
						config.onButtonClick(button.id, button)
					end
				end

				currentY = currentY + config.buttonSize + config.spacing
			end
		end

		if config.hoveredButton and config.hoveredButton.tooltip then
			local tooltipText = config.hoveredButton.tooltip
			local tooltipPadding = 8
			local tooltipWidth
			local tooltipHeight

			if config.font then
				local textSize =
					raylib.lib.MeasureTextEx(config.font, tooltipText, config.tooltipFontSize, config.tooltipSpacing)
				tooltipWidth = textSize.x + tooltipPadding * 2
				tooltipHeight = textSize.y + tooltipPadding * 2
			else
				tooltipWidth = raylib.lib.MeasureText(tooltipText, config.tooltipFontSize) + tooltipPadding * 2
				tooltipHeight = config.tooltipFontSize + tooltipPadding * 2
			end

			local tooltipX = r.x + r.width + 8
			local tooltipY = mousePos.y - tooltipHeight / 2

			raylib.lib.DrawRectangleRounded(
				structs.Rectangle:new({
					x = tooltipX,
					y = tooltipY,
					width = tooltipWidth,
					height = tooltipHeight,
				}),
				0.15,
				4,
				color3.new(0.12, 0.12, 0.14):ToRaylib(0)
			)

			if config.font then
				raylib.lib.DrawTextEx(
					config.font,
					tooltipText,
					vector.create(tooltipX + tooltipPadding, tooltipY + tooltipPadding),
					config.tooltipFontSize,
					config.tooltipSpacing,
					color3.new(0.85, 0.85, 0.87):ToRaylib(0)
				)
			else
				raylib.lib.DrawText(
					tooltipText,
					tooltipX + tooltipPadding,
					tooltipY + tooltipPadding,
					config.tooltipFontSize,
					color3.new(0.85, 0.85, 0.87):ToRaylib(0)
				)
			end
		end

		for _, m in pairs(config.modifiers) do
			m()
		end
	end

	table.insert(objects, wrapper)
	return wrapper
end
