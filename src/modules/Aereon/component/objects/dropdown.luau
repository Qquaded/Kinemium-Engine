return function(objects, data, raylib)
	local structs = raylib.structs

	local rect = require("@arect")
	local color3 = require("@Color3")
	local MouseCursor = require("@Kinemium.MouseCursor")

	local defaultFont = raylib.lib.GetFontDefault()

	local config = {
		obj_rect = rect.new(data.x or data[1], data.y or data[2], data.width or data[3], data.height or data[4] or 36),
		options = data.options or { "Option 1", "Option 2", "Option 3" },
		selectedIndex = data.selectedIndex or 1,
		expanded = false,
		font = data.font or defaultFont,
		backgroundColor = data.backgroundColor or color3.new(0.15, 0.15, 0.18),
		hoverColor = data.hoverColor or color3.new(0.25, 0.35, 0.55),
		selectedColor = data.selectedColor or color3.new(0.2, 0.3, 0.5),
		borderColor = data.borderColor or color3.new(0.3, 0.3, 0.35),
		textColor = data.textColor or color3.new(0.95, 0.95, 0.97),
		secondaryTextColor = data.secondaryTextColor or color3.new(0.7, 0.7, 0.75),
		fontSize = data.fontSize or 16,
		spacing = data.spacing or 1,
		backgroundTransparency = data.backgroundTransparency or 0,
		borderTransparency = data.borderTransparency or 0,
		onSelect = data.onSelect,
		onExpand = data.onExpand,
		onCollapse = data.onCollapse,
		animProgress = 0,
	}

	local function drawText(text, x, y, fontSize, spacing, color)
		if config.font then
			raylib.lib.DrawTextEx(
				config.font,
				text,
				vector.create(x, y),
				fontSize,
				spacing,
				config.textColor:ToRaylib(0)
			)
		else
			raylib.lib.DrawText(text, x, y, fontSize, config.textColor:ToRaylib(0))
		end
	end

	local wrapper = {}

	wrapper.get = function(prop)
		return config[prop]
	end

	wrapper.set = function(prop, value)
		if type(config[prop]) == "function" then
			return wrapper
		end
		config[prop] = value
		return wrapper
	end

	wrapper.setSelected = function(index)
		config.selectedIndex = math.clamp(index, 1, #config.options)
	end

	wrapper.getSelected = function()
		return config.selectedIndex, config.options[config.selectedIndex]
	end

	wrapper.render = function(dt)
		local r = config.obj_rect

		if config.expanded then
			config.animProgress = math.min(config.animProgress + dt * 8, 1)
		else
			config.animProgress = math.max(config.animProgress - dt * 8, 0)
		end

		raylib.lib.DrawRectangleRounded(
			rect:translate(r),
			0.15,
			10,
			config.borderColor:ToRaylib(config.borderTransparency)
		)
		raylib.lib.DrawRectangleRounded(
			structs.Rectangle:new({
				x = r.x + 1,
				y = r.y + 1,
				width = r.width - 2,
				height = r.height - 2,
			}),
			0.15,
			10,
			config.backgroundColor:ToRaylib(config.backgroundTransparency)
		)

		if rect.MouseIsInRect(r) and not config.expanded then
			raylib.lib.DrawRectangleRounded(
				structs.Rectangle:new({
					x = r.x + 1,
					y = r.y + 1,
					width = r.width - 2,
					height = r.height - 2,
				}),
				0.15,
				10,
				config.hoverColor:ToRaylib(0.7)
			)
		end

		local selectedText = config.options[config.selectedIndex] or "Select..."
		local textX = r.x + 12
		local textY = r.y + (r.height - config.fontSize) / 2

		-- Clip button text to button inner bounds (intersect with parent scissor if any)
		local textClipX = r.x + 12
		local textClipY = r.y
		local textClipW = r.width - 24 - config.fontSize
		local textClipH = r.height
		local parentScissor = _G.__aereon_scissorStack and _G.__aereon_scissorStack[#_G.__aereon_scissorStack]
		if parentScissor then
			textClipX = math.max(textClipX, parentScissor.x)
			textClipY = math.max(textClipY, parentScissor.y)
			textClipW = math.max(0, math.min(textClipW, parentScissor.x + parentScissor.width - textClipX))
			textClipH = math.max(0, math.min(textClipH, parentScissor.y + parentScissor.height - textClipY))
		end
		local wasScissorActive = parentScissor ~= nil
		raylib.lib.BeginScissorMode(textClipX, textClipY, textClipW, textClipH)
		drawText(selectedText, textX, textY, config.fontSize, config.spacing, config.textColor)
		raylib.lib.EndScissorMode()
		-- Restore parent scissor if it was active
		if wasScissorActive then
			raylib.lib.BeginScissorMode(parentScissor.x, parentScissor.y, parentScissor.width, parentScissor.height)
		end

		local arrowSize = 6
		local arrowX = r.x + r.width - arrowSize - 12
		local arrowY = r.y + r.height / 2
		local arrowRotation = config.animProgress * 180

		if config.expanded then
			raylib.lib.DrawTriangle(
				vector.create(arrowX, arrowY + arrowSize / 2),
				vector.create(arrowX + arrowSize, arrowY + arrowSize / 2),
				vector.create(arrowX + arrowSize / 2, arrowY - arrowSize / 2),
				config.secondaryTextColor:ToRaylib(0)
			)
		else
			raylib.lib.DrawTriangle(
				vector.create(arrowX, arrowY - arrowSize / 2),
				vector.create(arrowX + arrowSize, arrowY - arrowSize / 2),
				vector.create(arrowX + arrowSize / 2, arrowY + arrowSize / 2),
				config.secondaryTextColor:ToRaylib(0)
			)
		end

		if rect.MouseIsInRect(r) and not _G.__aereon_blockInput then
			if raylib.lib.IsMouseButtonReleased(0) == 1 then
				config.expanded = not config.expanded
				if config.expanded then
					if config.onExpand then
						config.onExpand()
					end
				else
					if config.onCollapse then
						config.onCollapse()
					end
				end
			end
			MouseCursor.request(raylib.const.MouseCursor.MOUSE_CURSOR_POINTING_HAND)
		else
			MouseCursor.request(raylib.const.MouseCursor.MOUSE_CURSOR_DEFAULT)
		end

		if config.animProgress > 0.01 then
			local itemHeight = r.height
			local listHeight = itemHeight * #config.options
			local actualHeight = listHeight * config.animProgress

			local screenWidth = raylib.lib.GetScreenWidth()
			local screenHeight = raylib.lib.GetScreenHeight()

			local margin = 4
			local spaceBelow = screenHeight - (r.y + r.height + margin)
			local spaceAbove = r.y - margin

			local openUpward = spaceBelow < listHeight and spaceAbove > spaceBelow

			local maxListHeight = openUpward and math.max(spaceAbove, 1) or math.max(spaceBelow, 1)
			listHeight = math.min(listHeight, maxListHeight)

			local listY = openUpward and math.max(r.y - listHeight - margin, margin) or (r.y + r.height + margin)

			listY = math.clamp(listY, margin, screenHeight - listHeight - margin)

			local listX = math.clamp(r.x, margin, math.max(screenWidth - r.width - margin, margin))

			-- Temporarily disable parent scissor so dropdown list is not clipped by scrollables/containers
			local savedScissor = _G.__aereon_scissorStack and _G.__aereon_scissorStack[#_G.__aereon_scissorStack]
			if savedScissor then
				raylib.lib.EndScissorMode()
			end

			raylib.lib.DrawRectangleRounded(
				structs.Rectangle:new({
					x = listX + 2,
					y = listY + 2,
					width = r.width,
					height = actualHeight,
				}),
				0.15,
				10,
				color3.new(0, 0, 0):ToRaylib(0.3)
			)

			raylib.lib.DrawRectangleRounded(
				structs.Rectangle:new({
					x = listX,
					y = listY,
					width = r.width,
					height = actualHeight,
				}),
				0.15,
				10,
				config.borderColor:ToRaylib(0)
			)
			raylib.lib.DrawRectangleRounded(
				structs.Rectangle:new({
					x = listX + 1,
					y = listY + 1,
					width = r.width - 2,
					height = actualHeight - 2,
				}),
				0.15,
				10,
				config.backgroundColor:ToRaylib(0)
			)

			for i, option in ipairs(config.options) do
				local itemY = listY + (i - 1) * itemHeight
				local itemRect = rect.new(listX + 2, itemY + 2, r.width - 4, itemHeight - 2)

				local itemVisible = openUpward and (itemY + itemHeight > listY) or (itemY < listY + actualHeight)
				if itemVisible then
					local isSelected = i == config.selectedIndex

					if isSelected then
						raylib.lib.DrawRectangleRounded(
							structs.Rectangle:new({
								x = itemRect.x,
								y = itemRect.y,
								width = itemRect.width,
								height = itemRect.height,
							}),
							0.12,
							8,
							config.selectedColor:ToRaylib(0.5)
						)
					end

					if rect.MouseIsInRect(itemRect) and config.expanded and not _G.__aereon_blockInput then
						raylib.lib.DrawRectangleRounded(
							structs.Rectangle:new({
								x = itemRect.x,
								y = itemRect.y,
								width = itemRect.width,
								height = itemRect.height,
							}),
							0.12,
							8,
							config.hoverColor:ToRaylib(0)
						)

						if raylib.lib.IsMouseButtonReleased(0) == 1 then
							config.selectedIndex = i
							config.expanded = false
							if config.onCollapse then
								config.onCollapse()
							end
							if config.onSelect then
								config.onSelect(i, option)
							end
						end
					end

					drawText(
						option,
						listX + 12,
						itemY + (itemHeight - config.fontSize) / 2,
						config.fontSize,
						config.spacing,
						config.textColor
					)
				end
			end

			-- Restore parent scissor after drawing expanded dropdown list
			if savedScissor then
				raylib.lib.BeginScissorMode(savedScissor.x, savedScissor.y, savedScissor.width, savedScissor.height)
			end
		end
	end

	table.insert(objects, wrapper)
	return wrapper
end
