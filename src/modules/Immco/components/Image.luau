local typedefs = require("../typedefs")
local argon = require("@Argon")

return function(params: typedefs.ImageParams, dt: number)
	local window = params.engine_window

	argon:DrawImageSized(
		window,
		params.Image,
		{ width = params.width, height = params.height, x = params.x, y = params.y, Color = argon:RGBA(1, 1, 1) }
	)
end
