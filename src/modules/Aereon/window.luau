return function(raylib: typeof(require("@raylib").lib), structs, game, theme)
	local windowRegistry = {}
	local module = {}
	local draggedWindow = nil
	local dragOffset = { x = 0, y = 0 }
	local Color3 = require("@Color3")
	local Enum = require("@EnumMap")
	local const = require("@raylib").const

	local resizingWindow = nil
	local resizeSide = nil
	local resizeStart = vector.create(0, 0)
	local resizeMinSize = vector.create(100, 60)
	local resizeThreshold = 15

	local function getResizeSide(window, mousePos)
		local sides = {}

		if math.abs(mousePos.x - window.x) <= resizeThreshold then
			table.insert(sides, "left")
		elseif math.abs(mousePos.x - (window.x + window.width)) <= resizeThreshold then
			table.insert(sides, "right")
		end

		if math.abs(mousePos.y - window.y) <= resizeThreshold then
			table.insert(sides, "top")
		elseif math.abs(mousePos.y - (window.y + window.height)) <= resizeThreshold then
			table.insert(sides, "bottom")
		end

		if #sides > 0 then
			return sides
		end
	end

	local spring = require("@kispring")

	local dragSpring = spring.new(1, 5)

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
	module.backgroundDrawed = function() end

	function module.create(data: {
		headerRender: boolean?,
		step: () -> (),
		title: string,
		x: number,
		y: number,
		width: number,
		height: number,
		enabled: boolean?,
	})
		local window = {
			title = data.title,
			x = data.x,
			y = data.y,
			width = data.width,
			headerRender = data.headerRender,
			height = data.height,
			id = #windowRegistry + 1,
			rounded = 0,
			stepped = data.step,
			enabled = data.enabled or true,
			scrollOffset = vector.create(0, 0),
		}
		table.insert(windowRegistry, window)

		function window:MoveTo(x, y)
			dragSpring:target(window, {
				x = x,
				y = y,
			})
		end

		function window:Resize(x, y)
			dragSpring:target(window, {
				width = x,
				height = y,
			})
		end

		return window
	end

	function module.update()
		local window_theme_config = theme().window

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

			dragSpring:target(draggedWindow, {
				x = targetX,
				y = targetY,
			})

			draggedWindow.IsDragging = true
			module.dragged(draggedWindow)
		end

		if mousePressed == 1 and not draggedWindow then
			for i = #windowRegistry, 1, -1 do
				local window = windowRegistry[i]
				local sides = getResizeSide(window, mousePos)
				if sides then
					resizingWindow = window
					resizeSide = sides
					resizeStart = vector.create(mousePos.x, mousePos.y)
					break
				end
			end
		end

		if mouseDown == 1 and resizingWindow then
			local dx = mousePos.x - resizeStart.x
			local dy = mousePos.y - resizeStart.y

			for _, side in ipairs(resizeSide) do
				if side == "left" then
					resizingWindow.x = resizingWindow.x + dx
					resizingWindow.width = resizingWindow.width - dx
					raylib.SetMouseCursor(Enum.KinemiumMouseCursor.MOUSE_CURSOR_RESIZE_EW.Value)
				elseif side == "right" then
					resizingWindow.width = resizingWindow.width + dx
					raylib.SetMouseCursor(Enum.KinemiumMouseCursor.MOUSE_CURSOR_RESIZE_EW.Value)
				elseif side == "top" then
					resizingWindow.y = resizingWindow.y + dy
					resizingWindow.height = resizingWindow.height - dy
					raylib.SetMouseCursor(Enum.KinemiumMouseCursor.MOUSE_CURSOR_RESIZE_NS.Value)
				elseif side == "bottom" then
					resizingWindow.height = resizingWindow.height + dy
					raylib.SetMouseCursor(Enum.KinemiumMouseCursor.MOUSE_CURSOR_RESIZE_NS.Value)
				end
			end

			-- clamp minimum size
			resizingWindow.width = math.max(resizingWindow.width, resizeMinSize.x)
			resizingWindow.height = math.max(resizingWindow.height, resizeMinSize.y)

			resizeStart = vector.create(mousePos.x, mousePos.y)
		end

		if mouseReleased == 1 then
			raylib.SetMouseCursor(Enum.KinemiumMouseCursor.MOUSE_CURSOR_DEFAULT.Value)

			if draggedWindow then
				draggedWindow.IsDragging = false

				module.dragEnd(draggedWindow)
			end

			draggedWindow = nil
			resizingWindow = nil
			resizeSide = nil
		end
	end

	function module.draw(dt)
		dragSpring:step(dt)

		local window_theme_config = theme().window

		for _, windowData in pairs(windowRegistry) do
			if windowData.Closed then
				continue
			end
			if windowData.enabled then
				local rect = structs.Rectangle:new({
					x = windowData.x,
					y = windowData.y,
					width = windowData.width,
					height = windowData.height,
				})

				local contentBounds = structs.Rectangle:new({
					x = windowData.x,
					y = windowData.y + 24,
					width = windowData.width,
					height = windowData.height - 24,
				})

				local contentRect = structs.Rectangle:new({
					x = windowData.x,
					y = windowData.y + 24,
					width = windowData.width,
					height = windowData.height * 4,
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
						x = windowData.x - shadowOffset * 15,
						y = windowData.y - shadowOffset * 15,
						width = windowData.width + shadowOffset * 30,
						height = windowData.height + shadowOffset * 30,
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

				raylib.DrawRectangleRounded(
					rect,
					windowData.rounded,
					30,
					Color3ToRaylib(
						window_theme_config.BackgroundColor,
						windowData.transparency or window_theme_config.BackgroundTransparency
					)
				)
				module.backgroundDrawed(windowData)
				raylib.DrawRectangleRoundedLinesEx(
					rect,
					windowData.rounded,
					30,
					1,
					Color3ToRaylib(Color3.new(1, 1, 1), 0.9)
				)

				-- title
				if windowData.headerRender ~= false then
					local titleRect = structs.Rectangle:new({
						x = windowData.x,
						y = windowData.y,
						width = windowData.width,
						height = 28,
					})
					local titleColor = windowData.IsDragging and window_theme_config.DragColor
						or window_theme_config.SecondaryBackgroundColor
					raylib.DrawRectangleRec(
						titleRect,
						Color3ToRaylib(titleColor, window_theme_config.TitleBackgroundTransparency)
					)

					local textColor = Color3ToRaylib(window_theme_config.TitleColor, 0)
					raylib.DrawTextEx(
						vend,
						windowData.title,
						vector.create(windowData.x + 8, windowData.y + 6),
						window_theme_config.TitleTextSize,
						1,
						textColor
					)

					windowData.titleRect = { height = 28, width = windowData.width, x = windowData.x, y = windowData.y }
				end

				if windowData.IsDragging == true then
					local borderColor = window_theme_config.DragColor
					raylib.DrawRectangleLines(
						windowData.x,
						windowData.y,
						windowData.width,
						windowData.height,
						Color3ToRaylib(borderColor, window_theme_config.DragOutlineTransparency)
					)
				end

				raylib.BeginScissorMode(windowData.x, windowData.y, windowData.width, windowData.height)

				module.stepped(windowData)
				raylib.EndScissorMode()
			end

			if windowData["stepped"] then
				windowData.stepped(windowData)
			end
		end
	end

	module.dragspring = dragSpring

	return module
end
