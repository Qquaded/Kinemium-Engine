local raylib = require("@raylib")
local rect = require("@arect")
local color3 = require("@Color3")

local DEFAULT_FONT = raylib.lib.GetFontDefault()

--
-- Constants
--

local SHADOW_LAYERS = 3
local SHADOW_ALPHA_BASE = 0.06
local SHADOW_ALPHA_STEP = 0.015
local ANIM_SPEED = 12
local HOVER_SPEED = 15

--
-- Default config
--

local function buildConfig(data)
	return {
		obj_rect = rect.new(
			data.x or data[1],
			data.y or data[2],
			data.width or data[3] or 220,
			data.height or data[4] or 400
		),

		Font = data.Font or DEFAULT_FONT,
		items = data.items or {},
		visible = data.visible ~= false,

		-- Colors
		backgroundColor = data.backgroundColor or color3.new(0.97, 0.97, 0.96),
		hoverColor = data.hoverColor or color3.new(0.15, 0.15, 0.15),
		textColor = data.textColor or color3.new(0.10, 0.10, 0.10),
		disabledColor = data.disabledColor or color3.new(0.65, 0.65, 0.63),
		shortcutColor = data.shortcutColor or color3.new(0.50, 0.50, 0.48),
		separatorColor = data.separatorColor or color3.new(0.86, 0.86, 0.85),
		categoryColor = data.categoryColor or color3.new(0.48, 0.48, 0.46),
		dangerColor = data.dangerColor or color3.new(0.78, 0.18, 0.16),
		dangerHoverColor = data.dangerHoverColor or color3.new(0.97, 0.92, 0.92),
		checkColor = data.checkColor or color3.new(0.18, 0.44, 0.92),

		-- Sizing
		fontSize = data.fontSize or 13,
		categoryFontSize = data.categoryFontSize or 10,
		itemHeight = data.itemHeight or 30,
		categoryHeight = data.categoryHeight or 22,
		padding = data.padding or 4,
		leftPadding = data.leftPadding or 8,
		rightPadding = data.rightPadding or 8,
		iconWidth = data.iconWidth or 20,

		-- Shape
		rounded = data.rounded or { 0.06, 8 },
		itemRounded = data.itemRounded or { 0.10, 6 },

		-- State
		openSubmenuPath = {},
		animAlpha = 0,
		hoverAlpha = {}, -- [itemId] = lerp t in [0, 1]
		submenuRects = {},
	}
end

--
-- Helpers
--

local function lerpf(a, b, t)
	return a + (b - a) * t
end

local function calculateMenuHeight(items, config)
	local h = config.padding * 2
	for _, item in ipairs(items) do
		if item.type == "separator" then
			h = h + 7
		elseif item.type == "category" then
			h = h + config.categoryHeight
		else
			h = h + config.itemHeight
		end
	end
	return h
end

local function drawPanel(config, x, y, w, h)
	for i = 1, SHADOW_LAYERS do
		local alpha = SHADOW_ALPHA_BASE - i * SHADOW_ALPHA_STEP
		raylib.lib.DrawRectangleRounded(
			rect:translate(rect.new(x + i, y + i * 2, w, h)),
			config.rounded[1],
			config.rounded[2],
			color3.new(0, 0, 0):ToRaylib(alpha)
		)
	end

	raylib.lib.DrawRectangleRounded(
		rect:translate(rect.new(x, y, w, h)),
		config.rounded[1],
		config.rounded[2],
		config.backgroundColor:ToRaylib(0)
	)
end

-- Draw a single non-special menu item; returns whether a click was consumed.
local function drawRegularItem(config, item, itemId, x, itemY, menuW, depth, dt, openSubmenuPath)
	if item.appearif and not item.appearif() then
		return false, false
	end

	local isDanger = item.danger == true
	local isDisabled = item.disabled == true

	-- Hover lerp
	local itemRect = rect.new(x + 4, itemY, menuW - 8, config.itemHeight)
	local isHovered = rect.MouseIsInRect(itemRect) and not isDisabled

	local prev = config.hoverAlpha[itemId] or 0
	local target = isHovered and 1 or 0
	config.hoverAlpha[itemId] = lerpf(prev, target, 1 - math.exp(-HOVER_SPEED * dt))
	local ht = config.hoverAlpha[itemId]

	if ht > 0.01 then
		local baseColor = isDanger and config.dangerHoverColor or config.hoverColor
		raylib.lib.DrawRectangleRounded(rect:translate(itemRect), 0.35, 4, baseColor:ToRaylib(1 - ht))
	end
	-- Colors
	local textColor = isDisabled and config.disabledColor or (isDanger and config.dangerColor) or config.textColor

	local iconX = x + config.leftPadding
	local labelX = iconX + config.iconWidth
	local midY = itemY + (config.itemHeight - config.fontSize) / 2

	-- Icon / checkmark
	if item.checked then
		local checkAlpha = lerpf(-0.3, 0, ht)
		raylib.lib.DrawTextEx(
			config.Font,
			"✓",
			vector.create(iconX, midY),
			config.fontSize,
			1,
			config.checkColor:ToRaylib(checkAlpha)
		)
	elseif item.icon then
		local iconAlpha = lerpf(isDisabled and 0.4 or 0.3, 0, ht * 0.4)
		raylib.lib.DrawTextEx(
			config.Font,
			item.icon,
			vector.create(iconX, midY),
			config.fontSize,
			1,
			textColor:ToRaylib(iconAlpha)
		)
	end

	-- Label
	raylib.lib.DrawTextEx(
		config.Font,
		item.label,
		vector.create(labelX, midY),
		config.fontSize,
		1,
		textColor:ToRaylib(0)
	)

	-- Shortcut
	if item.shortcut then
		local sw = raylib.lib.MeasureTextEx(config.Font, item.shortcut, config.fontSize, 1)
		local shortcutX = x + menuW - config.rightPadding - sw.x - (item.submenu and 16 or 0)
		raylib.lib.DrawTextEx(
			config.Font,
			item.shortcut,
			vector.create(shortcutX, midY),
			config.fontSize,
			1,
			config.shortcutColor:ToRaylib(0)
		)
	end

	-- Submenu arrow
	if item.submenu then
		raylib.lib.DrawTextEx(
			config.Font,
			"›",
			vector.create(x + menuW - config.rightPadding - 10, midY),
			config.fontSize + 2,
			1,
			config.shortcutColor:ToRaylib(0)
		)
	end

	-- Submenu path tracking
	if isHovered and item.submenu then
		if depth <= #openSubmenuPath then
			if openSubmenuPath[depth] ~= itemId then
				for j = depth, #openSubmenuPath do
					openSubmenuPath[j] = nil
				end
				openSubmenuPath[depth] = itemId
			end
		else
			openSubmenuPath[depth] = itemId
		end
	elseif isHovered and not item.submenu then
		for j = depth, #openSubmenuPath do
			openSubmenuPath[j] = nil
		end
	end

	-- Click
	local clicked = isHovered and raylib.lib.IsMouseButtonReleased(0) == 1 and not isDisabled and not item.submenu

	return item.submenu and openSubmenuPath[depth] == itemId, clicked
end

--
-- Recursive item renderer
--

local function drawItems(config, items, x, y, menuW, depth, wrapper, dt)
	local itemY = y + config.padding
	local itemId = 0

	for i, item in ipairs(items) do
		if item.type == "separator" then
			raylib.lib.DrawRectangle(
				x + config.leftPadding,
				itemY + 3,
				menuW - config.leftPadding - config.rightPadding,
				1,
				config.separatorColor:ToRaylib(0.6)
			)
			itemY = itemY + 7
		elseif item.type == "category" then
			raylib.lib.DrawTextEx(
				config.Font,
				string.upper(item.label),
				vector.create(
					x + config.leftPadding + config.iconWidth,
					itemY + (config.categoryHeight - config.categoryFontSize) / 2
				),
				config.categoryFontSize,
				1,
				config.categoryColor:ToRaylib(0)
			)
			itemY = itemY + config.categoryHeight
		else
			itemId = itemId + 1
			local hoverKey = tostring(depth) .. "_" .. itemId

			local openSub, clicked =
				drawRegularItem(config, item, hoverKey, x, itemY, menuW, depth, dt, config.openSubmenuPath)

			if openSub then
				local subH = calculateMenuHeight(item.submenu, config)
				local subRect = rect.new(x + menuW - 2, itemY, menuW, subH)
				table.insert(config.submenuRects, subRect)
				drawPanel(config, subRect.x, subRect.y, subRect.width, subRect.height)
				drawItems(config, item.submenu, subRect.x, subRect.y, subRect.width, depth + 1, wrapper, dt)
			end

			if clicked then
				if item.onClick then
					item.onClick()
				end
				wrapper.hide()
			end

			itemY = itemY + config.itemHeight
		end
	end
end

--
-- Factory
--

return function(objects, data)
	local config = buildConfig(data)
	local wrapper = {}

	--  Getters / setters

	wrapper.get = function(prop)
		return config[prop]
	end

	wrapper.set = function(prop, value)
		if type(config[prop]) ~= "function" then
			config[prop] = value
		end
		return wrapper
	end

	--  Visibility

	wrapper.show = function()
		config.visible = true
		config.animAlpha = 0
		config.hoverAlpha = {}
		return wrapper
	end

	wrapper.hide = function()
		config.visible = false
		config.openSubmenuPath = {}
		config.submenuRects = {}
		return wrapper
	end

	wrapper.toggle = function()
		if config.visible then
			wrapper.hide()
		else
			wrapper.show()
		end
		return wrapper
	end

	--  Items

	wrapper.setItems = function(items)
		config.items = items
		config.hoverAlpha = {}
		return wrapper
	end

	local function findItem(k)
		for i, item in ipairs(config.items) do
			if i == k or item.label == k then
				return item
			end
		end
	end

	wrapper.enable = function(k)
		local it = findItem(k)
		if it then
			it.disabled = false
		end
		return wrapper
	end
	wrapper.disable = function(k)
		local it = findItem(k)
		if it then
			it.disabled = true
		end
		return wrapper
	end
	wrapper.check = function(k)
		local it = findItem(k)
		if it then
			it.checked = true
		end
		return wrapper
	end
	wrapper.uncheck = function(k)
		local it = findItem(k)
		if it then
			it.checked = false
		end
		return wrapper
	end

	--  Render

	wrapper.render = function(dt)
		if not config.visible then
			return
		end

		config.animAlpha = lerpf(config.animAlpha, 1, ANIM_SPEED)
		config.submenuRects = {}

		local menuH = calculateMenuHeight(config.items, config)
		local r = rect.new(config.obj_rect.x, config.obj_rect.y, config.obj_rect.width, menuH)
		table.insert(config.submenuRects, r)

		drawPanel(config, r.x, r.y, r.width, r.height)
		drawItems(config, config.items, r.x, r.y, r.width, 1, wrapper, dt)
	end

	table.insert(objects, wrapper)
	return wrapper
end
