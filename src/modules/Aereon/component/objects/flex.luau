local raylib = require("@raylib")
local structs = raylib.structs
local color3 = require("@Color3")
local rect = require("@arect")
local LayoutEngine = require("../../../LayoutEngine")

return function(objects, data)
	local config = {
		obj_rect = rect.new(data.x or 0, data.y or 0, data.width or 100, data.height or 100),
		direction = data.direction or LayoutEngine.Direction.Vertical,
		justifyContent = data.justifyContent or LayoutEngine.JustifyContent.Start,
		alignItems = data.alignItems or LayoutEngine.AlignItems.Start,
		flexWrap = data.flexWrap or LayoutEngine.FlexWrap.NoWrap,
		gap = data.gap or 5,
		padding = data.padding or { left = 5, right = 5, top = 5, bottom = 5 },
		children = {},
		autoWidth = data.autoWidth or false,
		autoHeight = data.autoHeight or false,
		backgroundColor = data.backgroundColor or color3.new(0, 0, 0),
		backgroundTransparency = data.backgroundTransparency or 1,
	}

	local wrapper = {}

	wrapper.add = function(component)
		table.insert(config.children, component)
		return component
	end

	wrapper.set = function(prop, value)
		if prop == "width" then
			config.obj_rect = rect.new(config.obj_rect.x, config.obj_rect.y, value, config.obj_rect.height)
		elseif prop == "height" then
			config.obj_rect = rect.new(config.obj_rect.x, config.obj_rect.y, config.obj_rect.width, value)
		elseif prop == "obj_rect" then
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
		if config.backgroundTransparency < 1 then
			local r, g, b = config.backgroundColor:ToRGB()
			raylib.lib.DrawRectangleRec(
				rect:translate(config.obj_rect),
				structs.Color:new({ r = r, g = g, b = b, a = math.floor(255 * (1 - config.backgroundTransparency)) })
			)
		end

		local layoutItems = {}
		local itemMap = {}

		for _, child in ipairs(config.children) do
			local childRect = child.get_rect and child.get_rect()
			if not childRect and child.get then
				childRect = child.get("obj_rect")
			end

			if childRect then
				local item = LayoutEngine.createItem(child, childRect.width, childRect.height, {
					flexGrow = child.get and child.get("flexGrow") or 0,
					flexShrink = child.get and child.get("flexShrink") or 1,
					alignSelf = child.get and child.get("alignSelf") or nil,
					layoutOrder = child.get and child.get("layoutOrder") or 0,
					minWidth = child.get and child.get("minWidth") or 0,
					minHeight = child.get and child.get("minHeight") or 0,
					maxWidth = child.get and child.get("maxWidth") or math.huge,
					maxHeight = child.get and child.get("maxHeight") or math.huge,
					aspectRatio = child.get and child.get("aspectRatio") or nil,
				})
				table.insert(layoutItems, item)
				itemMap[child] = item
			end
		end

		local containerData = {
			width = config.obj_rect.width,
			height = config.obj_rect.height,
			direction = config.direction,
			justifyContent = config.justifyContent,
			alignItems = config.alignItems,
			flexWrap = config.flexWrap,
			gap = config.gap,
			padding = config.padding,
			autoWidth = config.autoWidth,
			autoHeight = config.autoHeight,
		}

		local finalWidth, finalHeight = LayoutEngine.calculate(containerData, layoutItems)

		if config.autoWidth then
			config.obj_rect.width = finalWidth
		end
		if config.autoHeight then
			config.obj_rect.height = finalHeight
		end

		for child, item in pairs(itemMap) do
			if child.set then
				child.set(
					"obj_rect",
					rect.new(
						config.obj_rect.x + item._x,
						config.obj_rect.y + item._y,
						item._actualWidth,
						item._actualHeight
					)
				)
			end
			if child.render then
				child.render(dt)
			end
		end
	end

	table.insert(objects, wrapper)
	return wrapper
end
