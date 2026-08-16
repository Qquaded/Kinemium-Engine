local typedefs = require("../typedefs")
local argon = require("@Argon")
local Image = require("./Image")

return function(params: typedefs.ImageButtonParams, dt: number)
	local window = params.engine_window
	local theme = params.theme
	local cornerRadius = theme.ButtonCornerRadius or 12

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

	local padding = params.padding or 8

	local maxImageWidth = params.width - padding * 2
	local maxImageHeight = params.height - padding * 2

	local imageWidth = params.imageWidth or maxImageWidth
	local imageHeight = params.imageHeight or maxImageHeight

	if params.preserveAspectRatio and params.imageAspectRatio then
		local aspect = params.imageAspectRatio
		if imageWidth / aspect > imageHeight then
			imageWidth = imageHeight * aspect
		else
			imageHeight = imageWidth / aspect
		end
	end

	imageWidth = math.min(imageWidth, maxImageWidth)
	imageHeight = math.min(imageHeight, maxImageHeight)

	local imageX = params.x + (params.width / 2) - (imageWidth / 2)
	local imageY = params.y + (params.height / 2) - (imageHeight / 2)

	Image({
		x = imageX,
		y = imageY,
		width = imageWidth,
		height = imageHeight,
		Image = params.Image,
		engine_window = window,
	}, dt)

	argon:Restore(window)
end
