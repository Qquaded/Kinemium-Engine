return function(objects, data, raylib)
	local structs = raylib.structs

	local rect = require("@arect")
	local color3 = require("@Color3")
	local defaultFont = raylib.lib.GetFontDefault()

	local function drawText(fnt, text, x, y, size, color)
		raylib.lib.DrawTextEx(fnt, text, vector.create(x, y), size, 1, color)
	end

	local function measureText(fnt, text, size)
		return raylib.lib.MeasureTextEx(fnt, text, size, 1).x
	end

	-- Small chevron, pointing down when collapsed / up when expanded.
	local function drawChevron(cx, cy, size, expanded, color)
		local half = size / 2
		if expanded then
			raylib.lib.DrawLineEx(vector.create(cx - half, cy + half / 2), vector.create(cx, cy - half / 2), 2, color)
			raylib.lib.DrawLineEx(vector.create(cx, cy - half / 2), vector.create(cx + half, cy + half / 2), 2, color)
		else
			raylib.lib.DrawLineEx(vector.create(cx - half, cy - half / 2), vector.create(cx, cy + half / 2), 2, color)
			raylib.lib.DrawLineEx(vector.create(cx, cy + half / 2), vector.create(cx + half, cy - half / 2), 2, color)
		end
	end

	local config = {
		obj_rect = rect.new(data.x or data[1], data.y or data[2], data.width or data[3], data.height or data[4]),
		rounded = data.rounded or { 0.2, 8 },
		modifiers = {},

		font = data.font or defaultFont,
		fontSize = data.fontSize or 13,
		labelFontSize = data.labelFontSize or 11,

		label = data.label or "Components",
		backgroundTransparency = data.backgroundTransparency or 0,

		headerColor = color3.new(0.15, 0.15, 0.17),
		headerHoverColor = color3.new(0.19, 0.19, 0.21),
		listColor = color3.new(0.13, 0.13, 0.15),
		itemHoverColor = color3.new(1, 1, 1),
		itemHoverAlpha = 0.06,
		borderColor = color3.new(1, 1, 1),
		textColor = color3.new(0.88, 0.88, 0.90),
		dimTextColor = color3.new(0.55, 0.55, 0.60),
		accentColor = data.accentColor or color3.new(0.35, 0.55, 0.95),
		trackOffColor = color3.new(0.30, 0.30, 0.33),

		-- items: { { name = "Git History", key = "githistory", visible = true }, ... }
		items = data.items or {},

		expanded = false,
		itemHeight = 30,
		padding = 10,
		maxListHeight = data.maxListHeight or 200,
		scrollOffset = 0,
		lerpSpeed = 14,

		onToggle = data.onToggle,
		onExpandChanged = data.onExpandChanged,
	}

	for _, item in ipairs(config.items) do
		item.t = item.visible and 1 or 0
		item.dt = item.t
	end

	local wrapper = {}

	wrapper.set = function(prop, value)
		if type(config[prop]) == "function" then
			return wrapper
		end
		config[prop] = value
		return wrapper
	end

	wrapper.addItem = function(name, key, visible)
		local isVisible = visible ~= false
		table.insert(config.items, {
			name = name,
			key = key or name,
			visible = isVisible,
			t = isVisible and 1 or 0,
			dt = isVisible and 1 or 0,
		})
		return wrapper
	end

	wrapper.removeItem = function(key)
		for i, item in ipairs(config.items) do
			if item.key == key then
				table.remove(config.items, i)
				break
			end
		end
		return wrapper
	end

	wrapper.setVisible = function(key, visible)
		for _, item in ipairs(config.items) do
			if item.key == key then
				item.visible = visible
				break
			end
		end
		return wrapper
	end

	wrapper.isVisible = function(key)
		for _, item in ipairs(config.items) do
			if item.key == key then
				return item.visible
			end
		end
		return false
	end

	wrapper.getVisibleItems = function()
		local out = {}
		for _, item in ipairs(config.items) do
			if item.visible then
				table.insert(out, item.key)
			end
		end
		return out
	end

	wrapper.setExpanded = function(value)
		config.expanded = value
		return wrapper
	end

	wrapper.render = function(dt)
		local r = config.obj_rect
		local fnt = config.font
		local fs = config.fontSize
		local lfs = config.labelFontSize
		local mousePos = raylib.lib.GetMousePosition()
		local mousePressed = raylib.lib.IsMouseButtonPressed(0) == 1

		local headerRect = rect.new(r.x, r.y, r.width, r.height)
		local headerHovered = rect.MouseIsInRect(headerRect)

		-- How many items are currently visible, for the header badge.
		local visibleCount = 0
		for _, item in ipairs(config.items) do
			if item.visible then
				visibleCount += 1
			end
		end

		-- === Header ===
		raylib.lib.DrawRectangleRounded(
			rect:translate(headerRect),
			config.rounded[1],
			config.rounded[2],
			(headerHovered and config.headerHoverColor or config.headerColor):ToRaylib(config.backgroundTransparency)
		)

		drawChevron(r.x + config.padding + 6, r.y + r.height / 2, 10, config.expanded, config.dimTextColor:ToRaylib(0))

		drawText(
			fnt,
			config.label,
			r.x + config.padding + 20,
			r.y + (r.height - fs) / 2,
			fs,
			config.textColor:ToRaylib(0)
		)

		local badgeText = string.format("%d/%d", visibleCount, #config.items)
		local badgeWidth = measureText(fnt, badgeText, lfs) + 14
		local badgeHeight = 18
		local badgeRect = rect.new(
			r.x + r.width - config.padding - badgeWidth,
			r.y + (r.height - badgeHeight) / 2,
			badgeWidth,
			badgeHeight
		)
		raylib.lib.DrawRectangleRounded(rect:translate(badgeRect), 0.5, 6, config.accentColor:ToRaylib(0.8))
		local badgeTextWidth = measureText(fnt, badgeText, lfs)
		drawText(
			fnt,
			badgeText,
			badgeRect.x + (badgeWidth - badgeTextWidth) / 2,
			badgeRect.y + (badgeHeight - lfs) / 2,
			lfs,
			color3.new(1, 1, 1):ToRaylib(0)
		)

		-- Toggle expansion on header click (edge-triggered, so holding the
		-- mouse down doesn't rapidly flicker it).
		if headerHovered and mousePressed then
			config.expanded = not config.expanded
			if config.onExpandChanged then
				config.onExpandChanged(config.expanded)
			end
		end

		-- === Dropdown list ===
		if config.expanded and #config.items > 0 then
			local contentHeight = #config.items * config.itemHeight
			local listHeight = math.min(contentHeight, config.maxListHeight)
			local listRect = rect.new(r.x, r.y + r.height + 4, r.width, listHeight)

			local scrollWheel = raylib.lib.GetMouseWheelMove()
			if rect.MouseIsInRect(listRect) then
				config.scrollOffset -= scrollWheel * config.itemHeight
			end
			local maxScroll = math.max(0, contentHeight - listHeight)
			config.scrollOffset = math.clamp(config.scrollOffset, 0, maxScroll)

			raylib.lib.DrawRectangleRounded(
				rect:translate(listRect),
				0.1,
				6,
				config.listColor:ToRaylib(config.backgroundTransparency)
			)

			raylib.lib.BeginScissorMode(listRect.x, listRect.y, listRect.width, listRect.height)

			for i, item in ipairs(config.items) do
				local itemY = listRect.y + (i - 1) * config.itemHeight - config.scrollOffset
				if itemY + config.itemHeight >= listRect.y and itemY <= listRect.y + listRect.height then
					local itemRect = rect.new(listRect.x + 2, itemY, listRect.width - 4, config.itemHeight)
					local isHovered = rect.MouseIsInRect(itemRect)

					if isHovered then
						raylib.lib.DrawRectangleRounded(
							rect:translate(itemRect),
							0.2,
							4,
							config.itemHoverColor:ToRaylib(1 - config.itemHoverAlpha)
						)
					end

					local midY = itemY + config.itemHeight / 2

					item.dt = item.dt + ((item.t or 0) - item.dt) * math.min(config.lerpSpeed * dt, 1)

					local trackWidth, trackHeight = 30, 16
					local trackX = listRect.x + listRect.width - config.padding - trackWidth
					local trackRect = rect.new(trackX, midY - trackHeight / 2, trackWidth, trackHeight)
					local trackColor = item.visible and config.accentColor or config.trackOffColor

					local nameMaxWidth = trackX - (listRect.x + config.padding) - 10
					local name = item.name
					if measureText(fnt, name, fs) > nameMaxWidth then
						while #name > 0 and measureText(fnt, name .. "...", fs) > nameMaxWidth do
							name = string.sub(name, 1, #name - 1)
						end
						name = name .. "..."
					end

					drawText(
						fnt,
						name,
						listRect.x + config.padding,
						midY - fs / 2,
						fs,
						(item.visible and config.textColor or config.dimTextColor):ToRaylib(0)
					)

					if isHovered and mousePressed then
						item.visible = not item.visible
						item.t = item.visible and 1 or 0
						if config.onToggle then
							config.onToggle(item, item.visible)
						end
					end
				end
			end

			raylib.lib.EndScissorMode()

			if mousePressed and not headerHovered and not rect.MouseIsInRect(listRect) then
				config.expanded = false
				if config.onExpandChanged then
					config.onExpandChanged(false)
				end
			end
		end

		for _, m in pairs(config.modifiers) do
			m()
		end
	end

	table.insert(objects, wrapper)
	return wrapper
end
