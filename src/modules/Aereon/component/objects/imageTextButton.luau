local raylib = require("@raylib")
local structs = raylib.structs
local color3 = require("@Color3")
local rect = require("@arect")
local textButton = require("./textButton")

return function(objects, data)
	local config = {
		obj_rect = rect.new(
			data.x or data[1] or 0,
			data.y or data[2] or 0,
			data.width or data[3] or 120,
			data.height or data[4] or 32
		),
		text = data.text or "Button",
		icon = data.icon,
		font = data.font,
		fontSize = data.fontSize or 16,
		iconPosition = data.iconPosition or "left",
		gap = data.gap or 8,
		iconPadding = data.iconPadding or 12,

		backgroundColor = data.backgroundColor or color3.new(0.2, 0.2, 0.2),
		hoverColor = data.hoverColor or color3.new(0.3, 0.3, 0.3),
		pressColor = data.pressColor or color3.new(0.15, 0.15, 0.15),
		textColor = data.textColor or color3.new(1, 1, 1),
		textTransparency = data.textTransparency or 0,
		rounded = data.rounded or { 0.3, 8 },

		onClick = data.onClick,
	}

	local textBtn = textButton({}, {
		x = data.x or data[1] or 0,
		y = data.y or data[2] or 0,
		width = data.width or data[3] or 120,
		height = data.height or data[4] or 32,
		text = data.text or "Button",
		backgroundColor = config.backgroundColor,
		hoverColor = config.hoverColor,
		pressColor = config.pressColor,
		textColor = config.textColor,
		textTransparency = config.textTransparency,
		fontSize = config.fontSize,
		font = config.font,
		rounded = config.rounded,
		onClick = data.onClick,
		shadowColor = data.shadowColor or color3.new(0, 0, 0),
		shadowLayers = data.shadowLayers or 6,
		shadowOffsetX = data.shadowOffsetX or 0,
		shadowOffsetY = data.shadowOffsetY or 4,
		shadowSpread = data.shadowSpread or 3,
	})

	local wrapper = {}

	wrapper.set = function(prop, value)
		config[prop] = value
		textBtn.set(prop, value)
		return wrapper
	end

	wrapper.get = function(prop)
		return config[prop]
	end

	wrapper.get_rect = function()
		return config.obj_rect
	end

	wrapper.render = function(dt)
		local r = config.obj_rect

		textBtn.set("obj_rect", r)
		textBtn.set("textTransparency", config.textTransparency)
		textBtn.render(dt)

		if config.icon then
			local iconSize = r.height * 0.6
			local textWidth
			if config.font then
				textWidth = raylib.lib.MeasureTextEx(config.font, config.text, config.fontSize, 1).x
			else
				textWidth = raylib.lib.MeasureText(config.text, config.fontSize)
			end

			local totalContentWidth = iconSize + config.gap + textWidth
			local startX = r.x + (r.width - totalContentWidth) / 2
			local iconX = startX

			if config.iconPosition == "right" then
				iconX = r.x + r.width - config.iconPadding - iconSize
			else
				iconX = r.x + config.iconPadding
			end

			local iconY = r.y + (r.height - iconSize) / 2

			raylib.lib.DrawTexturePro(
				config.icon.texture,
				structs.Rectangle:new({ x = 0, y = 0, width = config.icon.x, height = config.icon.y }),
				structs.Rectangle:new({ x = iconX, y = iconY, width = iconSize, height = iconSize }),
				vector.create(0, 0),
				0,
				raylib.const.WHITE
			)
		end
	end

	table.insert(objects, wrapper)
	return wrapper
end
