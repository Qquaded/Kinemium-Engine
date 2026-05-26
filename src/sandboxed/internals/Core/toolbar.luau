local KinemiumRaylib = game:GetService("KinemiumRaylib")

local RunService = game:GetService("RunService")
if RunService:IsServer() then
	return
end

local KinemiumFontService = game:GetService("KinemiumFontService")

local ProjectLoaderService = game:GetService("ProjectLoaderService")

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local rl = KinemiumRaylib.GetLib()
local renderer = KinemiumRaylib.GetRenderer()

local structs = KinemiumRaylib.GetStructs()
local vend = KinemiumFontService.GetDefaultFont()
local currentlySelected = ""
local Theme = game:GetService("StudioThemeService").SelectedTheme
local renderFileMenu = false
local fileService = game:GetService("KineFileService")

if FlagExists("client") then
	return
end

if FlagExists("cli") then
	return
end

if FlagExists("headless") then
	return
end

local backgroundColor = Theme.BackgroundColor:ToRaylib(Theme.BackgroundTransparency)
local TextColor = Theme.TextColor:ToRaylib(Theme.TextTransparency)
local ImageColor = Theme.ImageColor:ToRaylib(Theme.ImageTransparency)

export type elementTitle = string

export type RibbonBarCategory = {
	title: string,
	elements: {
		[elementTitle]: {
			type: "Imageelement" | "Textelement" | "TextLabel" | "DropdownButton" | "ToggleButton" | "Custom",
			callback: () -> (),
			render: () -> (),

			imagePath: string?,
			text: string?,
			tooltip: string?,
		},
	},
}

if game.Context ~= Enum.GameContext.Editor then
	return
end

local categoryRegistry = {}

local NewCategoryToolbar = Signal.new()
ishared.NewCategoryToolbar = NewCategoryToolbar
NewCategoryToolbar:Connect(function(category, data)
	categoryRegistry[category] = data
end)

local aereon = import("@Aereon")
local window = aereon.window(game, nil, 1)
local arectlib = require("@arect")
local aRect = arectlib
local scrollableToolbar
local gui = aereon.gui
local componentCache = {}

local tooltipState = {
	hoveredKey = nil,
	hoverTimer = 0,
	showDelay = 0.5,
	visible = false,
	text = "",
	x = 0,
	y = 0,
}

local toggleStates = {}

local fileMenu = gui.menu({
	x = 0,
	y = 0,
	width = 200,
	height = 300,
	Font = vend,
	items = {
		{ type = "category", label = "PROJECT" },
		{
			label = "Open Project",
			submenu = ProjectLoaderService.GetGamesAsSubmenu(function(project) end),
		},

		{ type = "separator" },

		{ type = "category", label = "STUDIO" },

		{
			label = "Studio Settings",
			onClick = function()
				print("Studio Settings")
			end,
		},
		{
			label = "Input Bindings",
			onClick = function()
				print("Input Bindings")
			end,
		},

		{ type = "separator" },

		{ type = "category", label = "GAME" },

		{
			label = "Game Settings",
			onClick = function()
				print("Game Settings")
			end,
		},
		{
			label = "Export Game",
			submenu = {
				{
					label = "Export as Executable",
					onClick = function()
						fileService.ExportGameAsExecutable(ishared.GameName or "KinemiumProject")
					end,
				},

				{
					label = "Export as .KINE",
					onClick = function()
						fileService.ExportGameAsFile(ishared.GameName or "KinemiumProject")
					end,
				},
			},
		},

		{ type = "separator" },

		{ type = "category", label = "HELP" },

		{
			label = "Documentation",
			onClick = function()
				rl.OpenURL("https://deepwiki.com/Qquaded/Kinemium-Engine")
			end,
		},
		{
			label = "About Engine",
			onClick = function()
				game.EngineSignal:Fire("EnableAboutMenu")
			end,
		},

		{ type = "separator" },

		{
			label = "Exit to Menu",
			onClick = function()
				ishared.GameName = "Not in a game"
				ishared.FolderPath = ""
				ishared.GameIcon = ""
				ishared.EnableHomescreen = true
				renderer:SetDimension("2D")
			end,
		},

		{
			label = "Exit",
			shortcut = "Alt+F4",
			onClick = function()
				KinemiumRaylib.GetLib().CloseWindow()
			end,
		},
	},
})

local function create_window(title, frame)
	local initialPos = frame.AbsolutePosition or vector.create(0, 0)
	local initialSize = frame.AbsoluteSize or vector.create(800, 170)

	local myWindow = window.create({
		title = title,
		x = initialPos.X,
		y = initialPos.Y,
		width = initialSize.X,
		DisableClipping = true,
		height = initialSize.Y,
		headerRender = true,
		Draggable = false,
		Resizable = false,
		Minimized = true,

		tabs = {
			{
				name = "File",
				render = function(windowData)
					local menuRect = aRect.new(windowData.x, windowData.y + 60, 200, 300)

					fileMenu:show()
					fileMenu.set("backgroundColor", Theme.aereon.window.BackgroundColor)
					fileMenu.set("textColor", Theme.TextColor)
					fileMenu.set("obj_rect", menuRect)
					renderFileMenu = true
				end,
			},
		},
	})
	myWindow:SetTab(nil)
	return myWindow
end

local function create_window_back(screenGui, title, AnchorPoint, size)
	local frame = Instance.new("Frame")
	frame.Position = Theme.WindowConfig.Toolbar.position
	frame.AnchorPoint = AnchorPoint
	frame.Size = size or UDim2.new(0, 400, 0.5, 0)
	frame.BackgroundColor3 = Color3.new(1, 1, 1)
	frame.BackgroundTransparency = 1
	frame.Parent = screenGui

	return create_window(title, frame), frame
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "Toolbar"
screenGui.Parent = LocalPlayer.PlayerGui

local propback, frame =
	create_window_back(screenGui, "Toolbar", Theme.WindowConfig.Toolbar.anchorPoint, Theme.WindowConfig.Toolbar.size)

local function measureTextWidth(text)
	if rl.MeasureTextEx then
		local vec = rl.MeasureTextEx(vend, text, 18, 1)
		return vec.x
	end
	return #text * 9
end

local function drawTooltip(text, x, y)
	local padding = 8
	local textW = measureTextWidth(text)
	local textH = 18
	local boxW = textW + padding * 2
	local boxH = textH + padding * 2

	local screenW = rl.GetScreenWidth and rl.GetScreenWidth() or 1920
	if x + boxW > screenW - 4 then
		x = screenW - boxW - 4
	end

	local bgColor = Color3.new(0.08, 0.08, 0.08):ToRaylib(0.1)
	local borderColor = Color3.new(0.4, 0.4, 0.4):ToRaylib(0)
	rl.DrawRectangleRounded({ x = x, y = y, width = boxW, height = boxH }, 0.4, 8, bgColor)
	rl.DrawRectangleRoundedLines({ x = x, y = y, width = boxW, height = boxH }, 0.4, 8, 1, borderColor)
	rl.DrawTextEx(vend, text, vector.create(x + padding, y + padding), 18, 1, TextColor)
end

local function updateTooltip(dt, hoveredKey, hoveredText, mouseX, mouseY)
	if hoveredKey ~= nil then
		if tooltipState.hoveredKey == hoveredKey then
			tooltipState.hoverTimer = tooltipState.hoverTimer + dt
		else
			tooltipState.hoveredKey = hoveredKey
			tooltipState.hoverTimer = 0
			tooltipState.visible = false
		end

		if tooltipState.hoverTimer >= tooltipState.showDelay then
			tooltipState.visible = true
			tooltipState.text = hoveredText
			tooltipState.x = mouseX + 12
			tooltipState.y = mouseY + 20
		end
	else
		if tooltipState.hoveredKey == nil then
			tooltipState.hoverTimer = 0
			tooltipState.visible = false
		end
	end
end

local function renderButton(xPos, name, element, windowData, dt)
	local winX, winY = windowData.x, windowData.y + 80
	local cellWidth = element.width or 50
	local cellHeight = element.height or 80
	local labelWidth = name and measureTextWidth(name) or 0
	local effectiveWidth = math.max(cellWidth, labelWidth + 10)

	local key = element
	local aereonElement = componentCache[key]
	if not aereonElement then
		aereonElement = gui.button({
			x = winX + xPos,
			y = winY,
			width = effectiveWidth,
			height = cellHeight,
			text = "",
			backgroundTransparency = 1,
			backgroundColor = element.backgroundColor or Color3.new(0.18, 0.18, 0.18),
			hoverColor = element.hoverColor or Color3.new(0.35, 0.35, 0.35),
			onClick = function()
				element.callback(element, aRect.new(winX + xPos, winY, effectiveWidth, cellHeight))
			end,
		})
		componentCache[key] = aereonElement
	end

	local currentRect = aRect.new(winX + xPos, winY, effectiveWidth, cellHeight)
	aereonElement.set("obj_rect", currentRect)
	aereonElement.render(dt)

	if element.texture then
		local scale = element.scale or 2.0
		local texW = element.texture.x * scale
		local texH = element.texture.y * scale

		local iconX = currentRect.x + effectiveWidth / 2 - texW / 2
		local iconY = currentRect.y + (name and (cellHeight / 2 - texH / 2 - 8) or (cellHeight / 2 - texH / 2))

		local iconRect = aRect.new(iconX, iconY, texW, texH)

		rl.DrawTexturePro(
			element.texture.texture,
			structs.Rectangle:new({
				x = 0,
				y = 0,
				width = element.texture.x,
				height = element.texture.y,
			}),
			aRect:translate(iconRect),
			vector.create(0, 0),
			element.rotation or 0,
			ImageColor
		)
	end

	if name then
		local textX = currentRect.x + effectiveWidth / 2 - labelWidth / 2
		local textY = currentRect.y + cellHeight - 18
		rl.DrawTextEx(vend, name, vector.create(textX, textY), 16, 1, TextColor)
	end

	if aRect.MouseIsInRect(currentRect) and element.tooltip then
		local mx = rl.GetMouseX and rl.GetMouseX() or currentRect.x
		local my = rl.GetMouseY and rl.GetMouseY() or currentRect.y
		updateTooltip(dt, tostring(element), element.tooltip, mx, my)
	end

	return effectiveWidth + (element.padding or 5)
end

local function renderToggleButton(xPos, name, element, windowData, dt)
	local winX, winY = windowData.x, windowData.y + 80
	local cellWidth = element.width or 50
	local cellHeight = element.height or 60
	local labelWidth = name and measureTextWidth(name) or 0
	local effectiveWidth = math.max(cellWidth, labelWidth + 10)

	local key = element
	if toggleStates[key] == nil then
		toggleStates[key] = element.defaultOn or false
	end
	local isOn = toggleStates[key]

	local aereonElement = componentCache[key]
	if not aereonElement then
		aereonElement = gui.button({
			x = winX + xPos,
			y = winY,
			width = effectiveWidth,
			height = cellHeight,
			text = "",
			backgroundTransparency = 1,
			onClick = function()
				toggleStates[key] = not toggleStates[key]
				if element.callback then
					element.callback(
						element,
						aRect.new(winX + xPos, winY, effectiveWidth, cellHeight),
						toggleStates[key]
					)
				end
			end,
		})
		componentCache[key] = aereonElement
	end

	local currentRect = aRect.new(winX + xPos, winY, effectiveWidth, cellHeight)
	aereonElement.set("obj_rect", currentRect)

	if isOn then
		aereonElement.set("backgroundColor", element.activeColor or Color3.new(0.2, 0.5, 0.9))
		aereonElement.set("hoverColor", element.activeColor or Color3.new(0.2, 0.5, 0.9))
	else
		aereonElement.set("backgroundColor", element.backgroundColor or Color3.new(0.18, 0.18, 0.18))
		aereonElement.set("hoverColor", element.hoverColor or Color3.new(0.35, 0.35, 0.35))
	end

	aereonElement.render(dt)

	if element.texture then
		local scale = element.scale or 2.0
		local texW = element.texture.x * scale
		local texH = element.texture.y * scale

		local iconX = currentRect.x + effectiveWidth / 2 - texW / 2
		local iconY = currentRect.y + (name and (cellHeight / 2 - texH / 2 - 8) or (cellHeight / 2 - texH / 2))

		local iconRect = aRect.new(iconX, iconY, texW, texH)

		rl.DrawTexturePro(
			element.texture.texture,
			structs.Rectangle:new({
				x = 0,
				y = 0,
				width = element.texture.x,
				height = element.texture.y,
			}),
			aRect:translate(iconRect),
			vector.create(0, 0),
			element.rotation or 0,
			ImageColor
		)
	end

	if name then
		local textX = currentRect.x + effectiveWidth / 2 - labelWidth / 2
		local textY = currentRect.y + cellHeight - 18
		rl.DrawTextEx(vend, name, vector.create(textX, textY), 16, 1, TextColor)
	end

	if isOn then
		local dotR = 3
		local dotX = math.floor(currentRect.x + effectiveWidth / 2)
		local dotY = math.floor(currentRect.y + cellHeight - dotR - 3)
		rl.DrawCircle(dotX, dotY, dotR, (element.activeColor or Color3.new(0.2, 0.5, 0.9)):ToRaylib(0))
	end

	if aRect.MouseIsInRect(currentRect) and element.tooltip then
		local mx = rl.GetMouseX and rl.GetMouseX() or currentRect.x
		local my = rl.GetMouseY and rl.GetMouseY() or currentRect.y
		updateTooltip(dt, tostring(element) .. "_toggle", element.tooltip, mx, my)
	end

	return effectiveWidth + (element.padding or 5)
end

local function renderDropdownButton(xPos, name, element, windowData, dt)
	local winX, winY = windowData.x, windowData.y + 80
	local maxItemWidth = 0
	if element.options then
		for _, opt in ipairs(element.options) do
			local itemWidth = measureTextWidth(opt.label or "")
			maxItemWidth = math.max(maxItemWidth, itemWidth)
		end
	end
	local labelWidth = name and measureTextWidth(name) or 0
	local cellWidth = element.width or math.max(maxItemWidth, labelWidth) + 20
	local cellHeight = element.height or 30

	local key = element
	local aereonElement = componentCache[key]
	if not aereonElement then
		local opts = {}
		for _, opt in ipairs(element.options or {}) do
			table.insert(opts, opt.label)
		end

		aereonElement = gui.dropdown({
			x = winX + xPos,
			y = winY,
			width = cellWidth,
			height = cellHeight,
			options = opts,
			selectedIndex = 1,
			backgroundColor = Color3.new(0.18, 0.18, 0.18),
			hoverColor = element.hoverColor or Color3.new(0.3, 0.3, 0.3),
			textColor = Theme.TextColor,
			onSelect = function(idx, optLabel)
				local opt
				for _, o in ipairs(element.options or {}) do
					if o.label == optLabel then
						opt = o
						break
					end
				end
				if opt then
					element._selected = opt.label
					if opt.onClick then
						opt.onClick(opt)
					end
					if element.onSelect then
						element.onSelect(opt)
					elseif element.callback then
						element.callback(opt)
					end
				end
			end,
		})
		componentCache[key] = aereonElement
	end

	local currentRect = aRect.new(winX + xPos, winY, cellWidth, cellHeight)
	aereonElement.set("obj_rect", currentRect)

	if element._selected then
		local idx = 1
		for i, o in ipairs(element.options or {}) do
			if o.label == element._selected then
				idx = i
				break
			end
		end
		aereonElement.set("selectedIndex", idx)
	end

	aereonElement.render(dt)

	local labelWidth = 0
	if name and name ~= (element._selected or "") then
		labelWidth = measureTextWidth(name)
		local lx = currentRect.x + cellWidth / 2 - labelWidth / 2
		rl.DrawTextEx(vend, name, vector.create(lx, currentRect.y + cellHeight + 5), 18, 1, TextColor)
	end

	if aRect.MouseIsInRect(currentRect) and element.tooltip then
		local mx = rl.GetMouseX and rl.GetMouseX() or currentRect.x
		local my = rl.GetMouseY and rl.GetMouseY() or currentRect.y
		updateTooltip(dt, tostring(element) .. "_dropdown", element.tooltip, mx, my)
	end

	local leftOverhang = math.max(0, (labelWidth - cellWidth) / 2)
	return cellWidth + leftOverhang + (element.padding or 10)
end

local function renderSeperator(xPos, windowData, element, dt)
	local winX, winY = windowData.x, windowData.y + 80
	local key = element
	local aereonElement = componentCache[key]
	if not aereonElement then
		aereonElement = gui.divider({
			x = winX + xPos,
			y = winY + 5,
			width = element.width or 2,
			height = element.height or 70,
			color = element.color or Color3.new(0.2, 0.2, 0.2),
			vertical = false,
		})
		componentCache[key] = aereonElement
	end

	aereonElement.set("x", winX + xPos)
	aereonElement.set("y", winY + 5)
	aereonElement.render(dt)

	return (element.width or 2) + (element.padding or 20)
end

local NewToolbarElement = Signal.new()
ishared.NewToolbarElement = NewToolbarElement

NewToolbarElement:Connect(function(categoryName, elementName, element)
	if not categoryRegistry[categoryName] then
		categoryRegistry[categoryName] = {
			title = categoryName,
			elements = {},
		}
	end

	categoryRegistry[categoryName].elements[elementName] = element
end)

game.EngineSignal:Connect(function(route, name, data)
	if route == "NewToolbarCategory" then
		categoryRegistry[name] = data
	end
end)

local function drawCategories(windowData, dt)
	local buttonWidth = 100
	local buttonHeight = 30
	local padding = 5

	local categoryCount = 0
	for _ in pairs(categoryRegistry) do
		categoryCount += 1
	end

	local extraPadding = 5
	local totalWidth = categoryCount * buttonWidth + math.max(0, (categoryCount - 1) * padding)
	local width = totalWidth + extraPadding

	local height = 35
	local x = windowData.x + (windowData.width - width) / 2
	local y = windowData.y + 35

	local Categories = aRect.new(x, y, width, height)
	rl.DrawRectangleRounded(aRect:translate(Categories), 0.5, 18, backgroundColor)

	local startX = x + extraPadding / 2
	local i = 0
	for name, category in pairs(categoryRegistry) do
		local key = "CategoryTab_" .. name
		local aereonElement = componentCache[key]
		if not aereonElement then
			aereonElement = gui.textButton({
				x = startX + i * (buttonWidth + padding),
				y = y + (height - buttonHeight) / 2,
				width = buttonWidth,
				height = buttonHeight,
				text = name,
				backgroundColor = Color3.new(0.12549, 0.12549, 0.12549),
				hoverColor = Theme.SecondaryBackgroundColor,
				pressColor = Theme.SecondaryBackgroundColor,
				textColor = Theme.TextColor,
				rounded = { 0.5, 5 },
				onClick = function()
					currentlySelected = name
				end,
			})
			componentCache[key] = aereonElement
		end

		aereonElement.set(
			"obj_rect",
			aRect.new(startX + i * (buttonWidth + padding), y + (height - buttonHeight) / 2, buttonWidth, buttonHeight)
		)
		if currentlySelected == name then
			aereonElement.set("backgroundColor", Theme.SecondaryBackgroundColor)
		else
			aereonElement.set("backgroundColor", Color3.new(0.12549, 0.12549, 0.12549))
		end
		aereonElement.render(dt)

		i += 1
	end
end

fileMenu:hide()

-- propback:Minimize()

RunService.RenderStepped:Connect(function(a0: number)
	if frame.AbsolutePosition and frame.AbsoluteSize then
		propback.x = frame.AbsolutePosition.X
		propback.y = frame.AbsolutePosition.Y
		propback.width = frame.AbsoluteSize.X
		propback.height = frame.AbsoluteSize.Y
	end
end)

local StudioThemeService = game:GetService("StudioThemeService")
renderer.Pool.new("2d", function(data)
	if game.Context ~= Enum.GameContext.Editor then
		return
	end

	local dt = rl.GetFrameTime()
	local mainTheme = StudioThemeService.SelectedTheme

	window.update(dt)
	window.draw(dt, mainTheme.aereon)
end)

local function renderImageDropdownButton(xPos, name, element, windowData, dt)
	local winX, winY = windowData.x, windowData.y + 80
	local cellWidth = element.width or 60
	local cellHeight = element.height or 60
	local dropHeight = element.dropHeight or 22
	local totalHeight = cellHeight + dropHeight
	local labelWidth = name and measureTextWidth(name) or 0
	local effectiveWidth = math.max(cellWidth, labelWidth + 10)

	local btnKey = element
	local aereonElement = componentCache[btnKey]
	if not aereonElement then
		aereonElement = gui.button({
			x = winX + xPos,
			y = winY,
			width = effectiveWidth,
			height = cellHeight,
			text = "",
			backgroundTransparency = 1,
			backgroundColor = element.backgroundColor or Color3.new(0.18, 0.18, 0.18),
			hoverColor = element.hoverColor or Color3.new(0.35, 0.35, 0.35),
			onClick = function()
				if element.callback then
					element.callback(element, aRect.new(winX + xPos, winY, effectiveWidth, cellHeight))
				end
			end,
		})
		componentCache[btnKey] = aereonElement
	end

	local btnRect = aRect.new(winX + xPos, winY, effectiveWidth, cellHeight)
	aereonElement.set("obj_rect", btnRect)
	aereonElement.render(dt)

	if element.texture then
		local scale = element.scale or 2.0
		local texW = element.texture.x * scale
		local texH = element.texture.y * scale
		local iconX = btnRect.x + effectiveWidth / 2 - texW / 2
		local iconY = btnRect.y + cellHeight / 2 - texH / 2
		rl.DrawTexturePro(
			element.texture.texture,
			structs.Rectangle:new({ x = 0, y = 0, width = element.texture.x, height = element.texture.y }),
			aRect:translate(aRect.new(iconX, iconY, texW, texH)),
			vector.create(0, 0),
			element.rotation or 0,
			ImageColor
		)
	end

	local dropKey = tostring(element) .. "_idd_drop"
	local dropElement = componentCache[dropKey]
	if not dropElement then
		local opts = {}
		local maxItemWidth = 0
		for _, opt in ipairs(element.options or {}) do
			table.insert(opts, opt.label)
			local itemWidth = measureTextWidth(opt.label or "")
			maxItemWidth = math.max(maxItemWidth, itemWidth)
		end
		effectiveWidth = math.max(effectiveWidth, maxItemWidth + 20)

		dropElement = gui.dropdown({
			x = winX + xPos,
			y = winY + cellHeight,
			width = effectiveWidth,
			height = dropHeight,
			options = opts,
			selectedIndex = element.defaultIndex or 1,
			backgroundColor = element.dropBackgroundColor or Color3.new(0.13, 0.13, 0.13),
			hoverColor = element.hoverColor or Color3.new(0.3, 0.3, 0.3),
			textColor = Theme.TextColor,
			backgroundTransparency = 1,
			borderTransparency = 1,
			onSelect = function(idx, optLabel)
				local opt
				for _, o in ipairs(element.options or {}) do
					if o.label == optLabel then
						opt = o
						break
					end
				end
				if opt then
					element._selected = opt.label
					if opt.onClick then
						opt.onClick(opt)
					end
					if element.onSelect then
						element.onSelect(opt)
					elseif element.callback then
						element.callback(opt)
					end
				end
			end,
		})
		componentCache[dropKey] = dropElement
	end

	local dropRect = aRect.new(winX + xPos, winY + cellHeight, effectiveWidth + 100, dropHeight)
	dropElement.set("obj_rect", dropRect)

	if element._selected then
		local idx = 1
		for i, o in ipairs(element.options or {}) do
			if o.label == element._selected then
				idx = i
				break
			end
		end
		dropElement.set("selectedIndex", idx)
	end

	dropElement.render(dt)

	local fullRect = aRect.new(winX + xPos, winY, effectiveWidth, totalHeight)
	if aRect.MouseIsInRect(fullRect) and element.tooltip then
		local mx = rl.GetMouseX and rl.GetMouseX() or winX + xPos
		local my = rl.GetMouseY and rl.GetMouseY() or winY
		updateTooltip(dt, tostring(element) .. "_idd", element.tooltip, mx, my)
	end

	return effectiveWidth + (element.padding or 5)
end

propback.stepped = function(propback)
	if propback.title == "Toolbar" then
		local dt = KinemiumRaylib.GetLib().GetFrameTime()
		tooltipState.hoveredKey = nil
		local totalElementsWidth = 0
		local category = categoryRegistry[currentlySelected]
		if category then
			for _, element in pairs(category.elements) do
				if element.type == "Separator" then
					totalElementsWidth = totalElementsWidth + 20
				elseif element.type == "Custom" then
					totalElementsWidth = totalElementsWidth + (element.width or 50) + (element.padding or 20)
				else
					totalElementsWidth = totalElementsWidth + (element.width or 100) + (element.padding or 5)
				end
			end
		end

		drawCategories(propback, dt)

		local toolbarContent
		toolbarContent = {
			get_rect = function()
				return aRect.new(0, 0, totalElementsWidth + 30, 50)
			end,
			set = function(prop, value)
				if prop == "obj_rect" then
					toolbarContent.rect = value
				end
			end,
			render = function(dt)
				local r = toolbarContent.rect
				local renderX = r.x
				local winY = propback.y + 80

				if category then
					local elements = category.elements
					for _, element in pairs(elements) do
						if element.type == "ImageButton" then
							local width = renderButton(renderX - propback.x, element.text, element, propback, dt)
							renderX = renderX + width
						elseif element.type == "ToggleButton" then
							local width = renderToggleButton(renderX - propback.x, element.text, element, propback, dt)
							renderX = renderX + width
						elseif element.type == "DropdownButton" then
							local width =
								renderDropdownButton(renderX - propback.x, element.text, element, propback, dt)
							renderX = renderX + width
						elseif element.type == "ImageDropdownButton" then
							local width =
								renderImageDropdownButton(renderX - propback.x, element.text, element, propback, dt)
							renderX = renderX + width
						elseif element.type == "Separator" then
							local width = renderSeperator(renderX - propback.x, propback, element, dt)
							renderX = renderX + width
						elseif element.type == "Custom" then
							if element.render then
								local cellWidth = element.width or 50
								local cellHeight = element.height or 50
								local padding = element.padding or 20
								element.render(aRect, {
									x = renderX,
									y = winY,
									width = cellWidth,
									height = cellHeight,
									window = propback,
								})
								renderX = renderX + cellWidth + padding
							end
						end
					end
				end
			end,
		}

		if not scrollableToolbar then
			scrollableToolbar = gui.scrollable({
				child = toolbarContent,
				direction = "horizontal",
				scrollbarWidth = 4,
				scrollbarColor = Theme.Accent,
				scrollbarHoverColor = Theme.Accent,
				scrollbarBackgroundTransparency = 1,
			})
		end

		scrollableToolbar.set("child", toolbarContent)
		local toolbarWidth = propback.width - 30
		scrollableToolbar.set("obj_rect", aRect.new(propback.x + 15, propback.y + 80, toolbarWidth, 100))
		scrollableToolbar.set("contentWidth", totalElementsWidth + 30)
		scrollableToolbar.render(dt)

		if tooltipState.hoveredKey == nil then
			tooltipState.hoverTimer = 0
			tooltipState.visible = false
		end

		if tooltipState.visible then
			drawTooltip(tooltipState.text, tooltipState.x, tooltipState.y)
		end

		if renderFileMenu then
			fileMenu.render(dt)
			renderFileMenu = false
		end
	end
end
