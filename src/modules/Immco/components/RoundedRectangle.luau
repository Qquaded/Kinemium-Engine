local typedefs = require("../typedefs")
local argon = require("@Argon")

return function(params: typedefs.WidgetParams, dt: number)
	local window = params.engine_window
	local cornerRadius = theme.CornerRadius or 12

	argon:Save(window)

	argon:ClipRoundRect(window, {
		x = params.x,
		y = params.y,
		width = params.width,
		height = params.height,
	}, cornerRadius, cornerRadius)

	argon:DrawRectangle(window, {
		x = params.x,
		y = params.y,
		width = params.width,
		height = params.height,
		Color = params.Color,
	})

	argon:Restore(window)
end
