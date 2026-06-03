local raylib = require("@raylib")
local color3 = require("@Color3")
local rect = require("@arect")
local textButton = require("./textButton")
local imageButton = require("./imageButton")
local zembed = require("@zembed")

local pathIcon = nil
local function getPathIcon()
	if not pathIcon then
		local tex = raylib.lib.LoadTexture(zembed.AssetPath("kineasset://images/icons/Folder.png"))
		if tex then
			pathIcon = {
				texture = tex,
				x = buffer.readi32(tex, 4),
				y = buffer.readi32(tex, 8),
			}
		end
	end
	return pathIcon
end

return function(objects, data)
	local config = {
		obj_rect = rect.new(
			data.x or data[1] or 0,
			data.y or data[2] or 0,
			data.width or data[3] or 200,
			data.height or data[4] or 32
		),
		path = data.path or "No file selected",
		font = data.font,
		fontSize = data.fontSize or 18,
		backgroundColor = data.backgroundColor or color3.new(0.2, 0.2, 0.2),
		hoverColor = data.hoverColor or color3.new(0.3, 0.3, 0.3),
		pressColor = data.pressColor or color3.new(0.15, 0.15, 0.15),
		textColor = data.textColor or color3.new(1, 1, 1),
		textTransparency = data.textTransparency or 0,
		rounded = data.rounded or { 0.3, 8 },
		onPathSelected = data.onPathSelected,
		extensions = data.extensions or { { name = "All Files", extensions = { "*" } } },
		buttonWidth = data.buttonWidth or 24,
		gap = data.gap or 4,
	}

	game = data.game

	local textBtn = textButton({}, {
		text = config.path,
		backgroundColor = config.backgroundColor,
		hoverColor = config.hoverColor,
		pressColor = config.pressColor,
		textColor = config.textColor,
		textTransparency = config.textTransparency,
		fontSize = config.fontSize,
		font = config.font,
		rounded = config.rounded,
		onClick = function()
			local FileDialogService = game:GetService("FileDialogService")
			local path = FileDialogService.RequestFile(config.extensions)
			if path then
				config.path = path
				if config.onPathSelected then
					config.onPathSelected(path)
				end
			end
		end,
	})

	local imgBtn = imageButton({}, {
		image = getPathIcon(),
		imageScale = 0.6,
		backgroundColor = config.backgroundColor,
		hoverColor = config.hoverColor,
		pressColor = config.pressColor,
		rounded = config.rounded,
		onClick = function()
			local FileDialogService = game:GetService("FileDialogService")
			local path = FileDialogService.RequestFile(config.extensions)
			if path then
				config.path = path
				if config.onPathSelected then
					config.onPathSelected(path)
				end
			end
		end,
	})

	local wrapper = {}

	wrapper.set = function(prop, value)
		config[prop] = value
		if prop == "path" then
			textBtn.set("text", value)
		elseif
			prop == "backgroundColor"
			or prop == "hoverColor"
			or prop == "pressColor"
			or prop == "textColor"
			or prop == "textTransparency"
		then
			textBtn.set(prop, value)
			imgBtn.set(prop, value)
		end
		return wrapper
	end

	wrapper.get = function(prop)
		return config[prop]
	end

	wrapper.get_rect = function()
		return config.obj_rect
	end

	local function measureText(font, text, size)
		if font then
			return raylib.lib.MeasureTextEx(font, text, size, 1).x
		else
			return raylib.lib.MeasureText(text, size)
		end
	end

	local function truncatePath(font, text, maxW, size)
		if measureText(font, text, size) <= maxW then return text end
		local ew = measureText(font, "...", size)
		if ew >= maxW then return "" end
		
		local out = ""
		for i = #text, 1, -1 do
			local c = string.sub(text, i, i)
			if measureText(font, c .. out, size) + ew > maxW then break end
			out = c .. out
		end
		return "..." .. out
	end

	wrapper.render = function(dt)
		local r = config.obj_rect

		local textWidth = r.width - config.buttonWidth - config.gap
		local displayPath = truncatePath(config.font, config.path, textWidth - (config.paddingX or 32), config.fontSize)
		
		textBtn.set("text", displayPath)
		textBtn.set("obj_rect", rect.new(r.x, r.y, textWidth, r.height))
		textBtn.render(dt)

		imgBtn.set("obj_rect", rect.new(r.x + textWidth + config.gap, r.y, config.buttonWidth, r.height))
		imgBtn.render(dt)
	end

	table.insert(objects, wrapper)
	return wrapper
end
