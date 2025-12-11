return function(raylib, structs, game, theme)
	local window_theme_config = theme.window
	local windowRegistry = {}
	local module = {}
	local draggedWindow = nil
	local dragOffset = { x = 0, y = 0 }
	local Color3 = require("@Color3")
	local Enum = require("@EnumMap")
	local KinemiumFontService = game:GetService("KinemiumFontService")
	local vend = KinemiumFontService.GetDefaultFont()

	local shadowTexture = raylib.LoadTexture("./src/assets/images/shadow.png")
	local size = vector.create(buffer.readi32(shadowTexture, 4), buffer.readi32(shadowTexture, 8))

	local lerp = function(a, b, t)
		return a + (b - a) * t
	end

	local function Color3ToRaylib(c, transparency)
		local r, g, b = c:ToRGB()
		return structs.Color:new({
			r = r,
			g = g,
			b = b,
			a = math.floor(255 * (1 - transparency)),
		})
	end

	module.OutlineColor = Color3.new(0, 0.517647, 1)
	module.OutlineTransparency = 1
	module.dragged = function() end
	module.stepped = function() end
	module.dragEnd = function() end

	function module.create(data: {
		headerRender: boolean?,
		step: () -> (),
		title: string,
		x: number,
		y: number,
		width: number,
		height: number,
	})
		local window = {
			title = data.title,
			x = data.x,
			y = data.y,
			width = data.width,
			headerRender = data.headerRender,
			height = data.height,
			id = #windowRegistry + 1,
			stepped = data.step,
			scrollOffset = vector.create(0, 0),
		}
		table.insert(windowRegistry, window)
		return window
	end

	function module.update()
		local mousePos = raylib.GetMousePosition()
		local mousePressed = raylib.IsMouseButtonPressed(0) -- Left mouse button
		local mouseDown = raylib.IsMouseButtonDown(0)
		local mouseReleased = raylib.IsMouseButtonReleased(0)

		if mousePressed == 1 and not draggedWindow then
			for i = #windowRegistry, 1, -1 do
				local window = windowRegistry[i]
				local titleBarHeight = 24

				if
					mousePos.x >= window.x
					and mousePos.x <= window.x + window.width
					and mousePos.y >= window.y
					and mousePos.y <= window.y + titleBarHeight
				then
					draggedWindow = window
					dragOffset.x = mousePos.x - window.x
					dragOffset.y = mousePos.y - window.y

					table.remove(windowRegistry, i)
					table.insert(windowRegistry, window)
					break
				end
			end
		end

		if mouseDown == 1 and draggedWindow then
			raylib.SetMouseCursor(Enum.KinemiumMouseCursor.MOUSE_CURSOR_RESIZE_ALL.Value)

			local targetX = mousePos.x - dragOffset.x
			local targetY = mousePos.y - dragOffset.y

			local smoothing = 0.5 -- 0 = instant, 1 = very slow
			draggedWindow.x = lerp(draggedWindow.x, targetX, smoothing)
			draggedWindow.y = lerp(draggedWindow.y, targetY, smoothing)

			draggedWindow.IsDragging = true
			module.dragged(draggedWindow)
		end

		if mouseReleased == 1 then
			if draggedWindow then
				raylib.SetMouseCursor(Enum.KinemiumMouseCursor.MOUSE_CURSOR_DEFAULT.Value)
				draggedWindow.IsDragging = false

				module.dragEnd(draggedWindow)
			end

			draggedWindow = nil
		end
	end

	function module.draw()
		for _, window in pairs(windowRegistry) do
			if window.Closed then
				continue
			end
			local rect = structs.Rectangle:new({
				x = window.x,
				y = window.y,
				width = window.width,
				height = window.height,
			})

			local contentBounds = structs.Rectangle:new({
				x = window.x,
				y = window.y + 24,
				width = window.width,
				height = window.height - 24,
			})

			local contentRect = structs.Rectangle:new({
				x = window.x,
				y = window.y + 24,
				width = window.width,
				height = window.height * 4,
			})

			local viewRect = structs.Rectangle:new({
				x = 0,
				y = 0,
				width = 0,
				height = 0,
			})

			--DrawRectangleRec: (rec: Rectangle, color: Color) -> (),

			if window_theme_config.ShadowsEnabled == true then
				local shadowOffset = 6

				local textureRect = structs.Rectangle:new({ x = 0, y = 0, width = size.x, height = size.y })
				local destination = structs.Rectangle:new({
					x = window.x - shadowOffset * 15,
					y = window.y - shadowOffset * 15,
					width = window.width + shadowOffset * 30,
					height = window.height + shadowOffset * 30,
				})

				raylib.DrawTexturePro(
					shadowTexture,
					textureRect,
					destination, -- destination rectangle
					vector.create(0, 0), -- origin for rotation/scaling
					0, -- rotation
					Color3ToRaylib(window_theme_config.ShadowColor, 0.9)
				)
			end

			raylib.DrawRectangleRec(
				rect,
				Color3ToRaylib(window_theme_config.BackgroundColor, window_theme_config.BackgroundTransparency)
			)

			-- title
			if window.headerRender ~= false then
				local titleRect = structs.Rectangle:new({
					x = window.x,
					y = window.y,
					width = window.width,
					height = 28,
				})
				local titleColor = window.IsDragging and window_theme_config.DragColor
					or window_theme_config.SecondaryBackgroundColor
				raylib.DrawRectangleRec(
					titleRect,
					Color3ToRaylib(titleColor, window_theme_config.TitleBackgroundTransparency)
				)

				local textColor = Color3ToRaylib(window_theme_config.TitleColor, 0)
				raylib.DrawTextEx(
					vend,
					window.title,
					vector.create(window.x + 8, window.y + 6),
					window_theme_config.TitleTextSize,
					1,
					textColor
				)
			end

			if window.IsDragging == true then
				local borderColor = window_theme_config.DragColor
				raylib.DrawRectangleLines(
					window.x,
					window.y,
					window.width,
					window.height,
					Color3ToRaylib(borderColor, window_theme_config.DragOutlineTransparency)
				)
			end

			raylib.BeginScissorMode(window.x, window.y, window.width, window.height)

			module.stepped(window)
			raylib.EndScissorMode()

			if window["stepped"] then
				window.stepped()
			end
		end
	end

	return module
end
