local typedefs = require("../typedefs")
local argon = require("@Argon")

return function(params: typedefs.TextParams, dt: number)
	local window = params.engine_window

	argon:DrawText(window, params.text or "Text", {
		X = params.x,
		Y = params.y,
		TextSize = params.TextSize,
		Font = params.Font or argon:CreateFont(params.theme.Font),
		Color = params.Color or params.theme.TextColor,
	})
end
