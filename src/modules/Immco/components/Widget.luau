local typedefs = require("../typedefs")
local Titlebar = require("./Titlebar")
local Rectangle = require("./Rectangle")
local argon = require("@Argon")

return function(params: typedefs.WidgetParams, dt: number)
	local window = params.engine_window
	local theme = params.theme

	local titleBarHeight = 32
	local cornerRadius = theme.CornerRadius or 12

	argon:Save(window)

	argon:ClipRoundRect(window, {
		x = params.x,
		y = params.y,
		width = params.width,
		height = params.height,
	}, cornerRadius, cornerRadius)

	Rectangle({
		x = params.x,
		y = params.y,
		width = params.width,
		height = params.height,
		Color = theme.ThirdColor,
		theme = theme,
		engine_window = window,
	}, dt)

	Rectangle({
		x = params.x,
		y = params.y,
		width = params.width,
		height = params.height,
		Color = theme.SecondaryColor,
		theme = theme,
		engine_window = window,
		isOutline = true,
	}, dt)

	if params.EnableTitlebar or params.title then
		Titlebar({
			engine_window = window,

			x = params.x,
			y = params.y,
			width = params.width,
			height = titleBarHeight,
			Color = theme.SecondaryColor,

			title = params.title,
			theme = theme,
		}, dt)
	end

	if params.callback then
		params.callback({
			x = params.x,
			y = params.y + titleBarHeight,
			width = params.width,
			height = params.height,
			window = window,
			theme = theme,
		})
	end
	argon:Restore(window)
end
