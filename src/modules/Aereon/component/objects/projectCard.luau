local raylib = require("@raylib")
local structs = raylib.structs
local color3 = require("@Color3")
local rect = require("@arect")
local LayoutEngine = require("@LayoutEngine")
local MouseCursor = require("@Kinemium.MouseCursor")

return function(objects, data)
	local config = {
		obj_rect = rect.new(data.x or 0, data.y or 0, data.width or 800, data.height or 80),
		title = data.title or "Project Name",
		subtext = data.subtext or "Played recently",
		tags = data.tags or {},
		icon = data.icon,
		font = data.font,

		backgroundColor = data.backgroundColor or color3.new(0.12, 0.12, 0.14),
		hoverColor = data.hoverColor or color3.new(0.18, 0.18, 0.20),
		textColor = data.textColor or color3.new(1, 1, 1),
		dimTextColor = data.dimTextColor or color3.new(0.6, 0.6, 0.6),
		accentColor = data.accentColor or color3.new(0.2, 0.6, 1),

		visible = data.visible ~= false,
		lastSize = { width = data.width or 800, height = data.height or 80 },
		isHovered = false,
		onClick = data.onClick,
		children = {},
	}

	local wrapper = {}

	wrapper.add = function(component)
		table.insert(config.children, component)
		return component
	end

	wrapper.set = function(prop, value)
		if prop == "obj_rect" and value then
			config.obj_rect = value
			if value.width and value.height and value.width > 0 and value.height > 0 then
				config.lastSize = { width = value.width, height = value.height }
			end
			return wrapper
		end
		config[prop] = value
		return wrapper
	end

	wrapper.get = function(prop)
		return config[prop]
	end

	wrapper.get_rect = function()
		if not config.visible then
			return rect.new(config.obj_rect.x, config.obj_rect.y, 0, 0)
		end
		if (config.obj_rect.width == 0 or config.obj_rect.height == 0) and config.lastSize then
			return rect.new(config.obj_rect.x, config.obj_rect.y, config.lastSize.width, config.lastSize.height)
		end
		return config.obj_rect
	end

	wrapper.render = function(dt)
		if not config.visible then
			return
		end
		local r = config.obj_rect
		config.isHovered = rect.MouseIsInRect(r)

		local mousePressed = raylib.lib.IsMouseButtonPressed(0) == 1

		if config.isHovered then
			MouseCursor.request(raylib.const.MouseCursor.MOUSE_CURSOR_POINTING_HAND)
		else
			MouseCursor.request(raylib.const.MouseCursor.MOUSE_CURSOR_DEFAULT)
		end

		local bgColor = config.isHovered and config.hoverColor or config.backgroundColor
		local lift = config.isHovered and -1 or 0

		-- shadow
		raylib.lib.DrawRectangleRounded(
			rect:translate(rect.new(r.x, r.y + 2, r.width, r.height)),
			0.3,
			8,
			config.backgroundColor:ToRaylib(0.65)
		)

		-- accent bar
		raylib.lib.DrawRectangle(r.x, r.y + 10, 3, r.height - 20, config.accentColor:ToRaylib(0))

		raylib.lib.DrawRectangleRounded(
			rect:translate(rect.new(r.x, r.y + lift, r.width, r.height)),
			0.3,
			8,
			bgColor:ToRaylib(0)
		)

		local iconSize = r.height - 24
		local layoutItems = {
			LayoutEngine.createItem("icon", iconSize, iconSize, { layoutOrder = 1 }),
			LayoutEngine.createItem("info", 0, r.height - 24, { flexGrow = 1, layoutOrder = 2 }),
		}

		local childMap = {}
		for i, child in ipairs(config.children) do
			local childRect = child.get_rect and child.get_rect()
			if not childRect and child.get then
				childRect = child.get("obj_rect")
			end

			if childRect then
				local item = LayoutEngine.createItem(child, childRect.width, childRect.height, {
					layoutOrder = 10 + i,
					flexShrink = 0,
				})
				table.insert(layoutItems, item)
				childMap[child] = item
			end
		end

		local containerData = {
			width = r.width,
			height = r.height,
			direction = LayoutEngine.Direction.Row,
			justifyContent = LayoutEngine.JustifyContent.Start,
			alignItems = LayoutEngine.AlignItems.Center,
			gap = 16,
			padding = { left = 12, right = 12, top = 8, bottom = 8 },
		}

		LayoutEngine.calculate(containerData, layoutItems)

		local function get_item(id)
			for _, it in ipairs(layoutItems) do
				if it.id == id then
					return it
				end
			end
			return nil
		end

		local itIcon = get_item("icon")
		local iconRect = rect.new(r.x + itIcon._x, r.y + itIcon._y, itIcon._actualWidth, itIcon._actualHeight)
		raylib.lib.DrawRectangleRounded(rect:translate(iconRect), 0.25, 8, config.backgroundColor:ToRaylib(0.18))
		if config.icon then
			raylib.lib.DrawTexturePro(
				config.icon.texture,
				structs.Rectangle:new({ x = 0, y = 0, width = config.icon.x, height = config.icon.y }),
				rect:translate(iconRect),
				vector.create(0, 0),
				0,
				raylib.const.WHITE
			)
		end

		local itInfo = get_item("info")
		local titleX, titleY = r.x + itInfo._x, r.y + itInfo._y + 2

		if config.font then
			raylib.lib.DrawTextEx(
				config.font,
				config.title,
				vector.create(titleX, titleY),
				18,
				1,
				config.textColor:ToRaylib(0)
			)
		else
			raylib.lib.DrawText(config.title, titleX, titleY, 18, config.textColor:ToRaylib(0))
		end

		local subY = titleY + 22
		local tagString = config.subtext
		if #config.tags > 0 then
			tagString = tagString .. "  •  " .. table.concat(config.tags, "  •  ")
		end

		if config.font then
			raylib.lib.DrawTextEx(
				config.font,
				tagString,
				vector.create(titleX, subY),
				14,
				1,
				config.dimTextColor:ToRaylib(0)
			)
		else
			raylib.lib.DrawText(tagString, titleX, subY, 14, config.dimTextColor:ToRaylib(0))
		end

		for child, item in pairs(childMap) do
			if child.set then
				child.set("obj_rect", rect.new(r.x + item._x, r.y + item._y, item._actualWidth, item._actualHeight))
			end
		end

		if config.isHovered and mousePressed and config.onClick then
			config.onClick()
		end
	end

	table.insert(objects, wrapper)
	return wrapper
end
