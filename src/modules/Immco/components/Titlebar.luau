local typedefs = require("../typedefs")
local Rectangle = require("./Rectangle")
local Text = require("./Text")
local argon = require("@Argon")

return function(params: typedefs.WidgetParams, dt: number)
	local window = params.engine_window
	local theme = params.theme

	Rectangle({
		x = params.x,
		y = params.y,
		width = params.width,
		height = params.height,
		Color = params.Color,
		theme = theme,
		engine_window = window,
	}, dt)

	Text({
		x = params.x + 10,
		y = params.y + 21,
		TextSize = 16,
		theme = theme,
		Font = argon:CreateFont(theme.Font),
		text = params.title or "Titlebar",
		Color = theme.TextColor,
		engine_window = window,
	}, dt)
end
