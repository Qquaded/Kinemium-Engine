local typedefs = require("../typedefs")
local argon = require("@Argon")

return function(params: typedefs.WidgetParams, dt: number)
	local window = params.engine_window

	argon:DrawRectangle(window, {
		x = params.x,
		y = params.y,
		width = params.width,
		height = params.height,
		Color = params.Color,
		isOutline = params.isOutline,
	})
end
