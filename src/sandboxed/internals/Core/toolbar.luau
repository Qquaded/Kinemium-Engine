local KinemiumRaylib = game:GetService("KinemiumRaylib")

local KinemiumFontService = game:GetService("KinemiumFontService")

local ProjectLoaderService = game:GetService("ProjectLoaderService")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local rl = KinemiumRaylib.lib
local renderer = KinemiumRaylib.renderer
local structs = KinemiumRaylib.structs
local vend = KinemiumFontService.GetDefaultFont()
local currentlySelected = ""
local Theme = game:GetService("StudioThemeService").SelectedTheme
local renderFileMenu = false

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
local SecondaryBackgroundColor = Theme.SecondaryBackgroundColor:ToRaylib(Theme.SecondaryBackgroundColorTransparency)
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
local aRect = require("@Arect")(KinemiumRaylib.lib)
local gui = aereon.gui

local tooltipState = {
	hoveredKey = nil,
	hoverTimer = 0,
	showDelay = 0.5,
	visible = false,
	text = "",
	x = 0,
	y = 0,
}

local dropdownState = {
	openKey = nil,
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
			label = "Editor Preferences",
			onClick = function()
				print("Editor Preferences")
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
			label = "Build Settings",
			onClick = function()
				print("Build Settings")
			end,
		},
		{
			label = "Export Game",
			submenu = {
				{
					label = "Export as .EXE",
					onClick = function()
						print("Export as EXE")
					end,
				},

				{
					label = "Export as .KINE",
					onClick = function()
						print("Export as KINE")
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
			label = "Exit",
			shortcut = "Alt+F4",
			onClick = function()
				KinemiumRaylib.lib.CloseWindow()
			end,
		},
	},
})

local function create_window(title, frame)
	repeat
		task.wait()
	until frame.AbsolutePosition and frame.AbsoluteSize
	local myWindow = window.create({
		title = title,
		x = frame.AbsolutePosition.X,
		y = frame.AbsolutePosition.Y,
		width = frame.AbsoluteSize.X,
		DisableClipping = true,
		height = frame.AbsoluteSize.Y,

		tabs = {
			{
				name = "File",
				render = function(windowData)
					local dt = KinemiumRaylib.lib.GetFrameTime()
					local menuRect = aRect.new(windowData.x, windowData.y + 60, 200, 300)

					fileMenu:show()
					fileMenu.set("backgroundColor", Theme.aereon.window.BackgroundColor)
					fileMenu.set("textColor", Theme.TextColor)
					fileMenu.set("obj_rect", menuRect)
					renderFileMenu = true
				end,
			},
			{
				name = "Plugins",
				render = function(windowData) end,
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
	local cellHeight = element.height or 50
	local rectX = winX + xPos
	local rectY = winY
	local rectData = aRect.new(rectX, rectY, cellWidth, cellHeight)

	local transparency = 1
	local color = Color3.new(0.5, 0.5, 0.5)

	local isHovered = aRect.MouseIsInRect(rectData)

	if isHovered then
		color = element.hoverColor
		transparency = element.hoverTransparency
	end

	aRect.Button(rectData, function()
		element.callback(element, rectData)
	end)

	local bgColor = color:ToRaylib(transparency)
	rl.DrawRectangleRounded(aRect:translate(rectData), element.roundness, 8, bgColor)

	if element.texture then
		rl.DrawTexturePro(
			element.texture.texture,
			structs.Rectangle:new({ x = 0, y = 0, width = element.texture.x, height = element.texture.y }),
			aRect:translate(rectData),
			vector.create(0, 0),
			element.rotation or 0,
			ImageColor
		)
	end

	local labelWidth = 0
	if name then
		labelWidth = measureTextWidth(name)
		local textX = rectData.x + cellWidth / 2 - labelWidth / 2
		local textY = rectData.y + cellHeight + 5
		rl.DrawTextEx(vend, name, vector.create(textX, textY), 18, 1, TextColor)
	end

	if element.render then
		element.render(aRect)
	end

	if isHovered and element.tooltip then
		local mx = rl.GetMouseX and rl.GetMouseX() or rectData.x
		local my = rl.GetMouseY and rl.GetMouseY() or rectData.y
		updateTooltip(dt, tostring(element), element.tooltip, mx, my)
	end

	local leftOverhang = math.max(0, (labelWidth - cellWidth) / 2)
	local effectiveWidth = math.max(cellWidth, labelWidth) + leftOverhang
	return effectiveWidth + (element.padding or 10)
end

local function renderToggleButton(xPos, name, element, windowData, dt)
	local winX, winY = windowData.x, windowData.y + 80
	local cellWidth = element.width or 50
	local cellHeight = element.height or 50
	local rectX = winX + xPos
	local rectY = winY
	local rectData = aRect.new(rectX, rectY, cellWidth, cellHeight)

	local key = element.text or name or tostring(element)
	if toggleStates[key] == nil then
		toggleStates[key] = element.defaultOn or false
	end
	local isOn = toggleStates[key]
	local isHovered = aRect.MouseIsInRect(rectData)

	aRect.Button(rectData, function()
		toggleStates[key] = not toggleStates[key]
		if element.callback then
			element.callback(element, rectData, toggleStates[key])
		end
	end)

	local bgColor
	if isOn then
		bgColor = (element.activeColor or Color3.new(0.2, 0.5, 0.9)):ToRaylib(0)
	elseif isHovered then
		bgColor = (element.hoverColor or Color3.new(0.35, 0.35, 0.35)):ToRaylib(0)
	else
		bgColor = Color3.new(0.18, 0.18, 0.18):ToRaylib(0)
	end

	rl.DrawRectangleRounded(aRect:translate(rectData), element.roundness or 0.3, 8, bgColor)

	if isOn then
		local dotR = 3
		local dotX = math.floor(rectData.x + cellWidth / 2)
		local dotY = math.floor(rectData.y + cellHeight - dotR - 3)
		rl.DrawCircle(dotX, dotY, dotR, (element.activeColor or Color3.new(0.2, 0.5, 0.9)):ToRaylib(0))
	end

	if element.texture then
		rl.DrawTexturePro(
			element.texture.texture,
			structs.Rectangle:new({ x = 0, y = 0, width = element.texture.x, height = element.texture.y }),
			aRect:translate(rectData),
			vector.create(0, 0),
			element.rotation or 0,
			ImageColor
		)
	end

	local labelWidth = 0
	if name then
		labelWidth = measureTextWidth(name)
		local textX = rectData.x + cellWidth / 2 - labelWidth / 2
		local textY = rectData.y + cellHeight + 5
		rl.DrawTextEx(vend, name, vector.create(textX, textY), 18, 1, TextColor)
	end

	if isHovered and element.tooltip then
		local mx = rl.GetMouseX and rl.GetMouseX() or rectData.x
		local my = rl.GetMouseY and rl.GetMouseY() or rectData.y
		updateTooltip(dt, key .. "_toggle", element.tooltip, mx, my)
	end

	local leftOverhang = math.max(0, (labelWidth - cellWidth) / 2)
	local effectiveWidth = math.max(cellWidth, labelWidth) + leftOverhang
	return effectiveWidth + (element.padding or 10)
end

local function renderDropdownButton(xPos, name, element, windowData, dt)
	local winX, winY = windowData.x, windowData.y + 80
	local cellWidth = element.width or 80
	local cellHeight = element.height or 30
	local rectX = winX + xPos
	local rectY = winY
	local rectData = aRect.new(rectX, rectY, cellWidth, cellHeight)

	local key = element.text or name or tostring(element)
	local isOpen = dropdownState.openKey == key
	local isHovered = aRect.MouseIsInRect(rectData)

	aRect.Button(rectData, function()
		dropdownState.openKey = isOpen and nil or key
	end)

	local bgColor
	if isOpen or isHovered then
		bgColor = (element.hoverColor or Color3.new(0.3, 0.3, 0.3)):ToRaylib(0)
	else
		bgColor = Color3.new(0.18, 0.18, 0.18):ToRaylib(0)
	end
	rl.DrawRectangleRounded(aRect:translate(rectData), element.roundness or 0.3, 8, bgColor)

	local faceLabel = element._selected or element.text or name or "Select"
	local arrowChar = "v"
	local arrowW = measureTextWidth(arrowChar)
	local arrowPad = 6

	local textY = rectData.y + cellHeight / 2 - 9
	rl.DrawTextEx(vend, faceLabel, vector.create(rectData.x + 8, textY), 18, 1, TextColor)
	rl.DrawTextEx(vend, arrowChar, vector.create(rectData.x + cellWidth - arrowW - arrowPad, textY), 18, 1, TextColor)

	local labelWidth = 0
	if name and name ~= faceLabel then
		labelWidth = measureTextWidth(name)
		local lx = rectData.x + cellWidth / 2 - labelWidth / 2
		rl.DrawTextEx(vend, name, vector.create(lx, rectData.y + cellHeight + 5), 18, 1, TextColor)
	end

	if isOpen and element.options then
		local optionH = 28
		local panelPad = 4
		local panelW = cellWidth
		local panelH = #element.options * optionH + panelPad * 2
		local panelX = rectData.x
		local panelY = rectData.y + cellHeight + 2

		local panelBg = Color3.new(0.12, 0.12, 0.12):ToRaylib(0)
		rl.DrawRectangleRounded({ x = panelX, y = panelY, width = panelW, height = panelH }, 0.3, 8, panelBg)

		for i, option in ipairs(element.options) do
			local optRect =
				aRect.new(panelX + panelPad, panelY + panelPad + (i - 1) * optionH, panelW - panelPad * 2, optionH - 2)

			if aRect.MouseIsInRect(optRect) then
				rl.DrawRectangleRounded(aRect:translate(optRect), 0.3, 6, Color3.new(0.25, 0.25, 0.25):ToRaylib(0))
			end

			aRect.Button(optRect, function()
				element._selected = option.label
				dropdownState.openKey = nil
				if option.onClick then
					option.onClick(option)
				end
				if element.onSelect then
					element.onSelect(option)
				elseif element.callback then
					element.callback(option)
				end
			end)

			rl.DrawTextEx(
				vend,
				option.label,
				vector.create(optRect.x + 8, optRect.y + optionH / 2 - 9),
				18,
				1,
				TextColor
			)
		end
	end

	if isHovered and element.tooltip then
		local mx = rl.GetMouseX and rl.GetMouseX() or rectData.x
		local my = rl.GetMouseY and rl.GetMouseY() or rectData.y
		updateTooltip(dt, key .. "_dropdown", element.tooltip, mx, my)
	end

	local faceLabelW = measureTextWidth(faceLabel)
	local baseWidth = math.max(cellWidth, labelWidth, faceLabelW + arrowW + arrowPad * 2 + 16)
	local leftOverhang = math.max(0, (labelWidth - cellWidth) / 2)
	return baseWidth + leftOverhang + (element.padding or 10)
end

local function renderSeperator(xPos, windowData, element)
	local winX, winY = windowData.x, windowData.y + 80
	local rectX = winX + xPos
	local rectY = winY

	local sepColor = (element.color or Color3.new(0.7, 0.7, 0.7)):ToRaylib(0)
	rl.DrawRectangle(rectX, rectY, element.width or 2, element.height or 70, sepColor)

	return (element.width or 2) + (element.padding or 20)
end

game.EngineSignal:Connect(function(route, name, data)
	if route == "NewToolbarCategory" then
		categoryRegistry[name] = data
	end
end)

local function drawCategories(windowData)
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
		local rect =
			aRect.new(startX + i * (buttonWidth + padding), y + (height - buttonHeight) / 2, buttonWidth, buttonHeight)

		aRect.Button(rect, function()
			currentlySelected = name
		end)

		local bg = Color3.new(0.12549, 0.12549, 0.12549):ToRaylib(1)
		if currentlySelected == name then
			bg = SecondaryBackgroundColor
		end

		rl.DrawRectangleRounded(aRect:translate(rect), 0.5, 5, bg)

		local textX = rect.x + buttonWidth / 2 - measureTextWidth(name) / 2
		local textY = rect.y + buttonHeight / 2 - 9
		rl.DrawTextEx(vend, name, vector.create(textX, textY), 18, 1, TextColor)

		i += 1
	end
end

fileMenu:hide()

propback:Minimize()

RunService.RenderStepped:Connect(function(a0: number)
	propback.x = frame.AbsolutePosition.X
	propback.y = frame.AbsolutePosition.Y
	propback.width = frame.AbsoluteSize.X
	propback.height = frame.AbsoluteSize.Y
end)

propback.stepped = function(propback)
	if propback.title == "Toolbar" then
		local dt = KinemiumRaylib.lib.GetFrameTime()
		local currentX = 15
		local category = categoryRegistry[currentlySelected]

		local prevKey = tooltipState.hoveredKey
		tooltipState.hoveredKey = nil

		if category then
			local elements = category.elements
			for _, element in pairs(elements) do
				if element.type == "ImageButton" then
					local width = renderButton(currentX, element.text, element, propback, dt)
					currentX = currentX + width
				elseif element.type == "ToggleButton" then
					local width = renderToggleButton(currentX, element.text, element, propback, dt)
					currentX = currentX + width
				elseif element.type == "DropdownButton" then
					local width = renderDropdownButton(currentX, element.text, element, propback, dt)
					currentX = currentX + width
				elseif element.type == "Separator" then
					local width = renderSeperator(currentX, propback, element)
					currentX = currentX + width
				elseif element.type == "Custom" then
					if element.render then
						local cellWidth = element.width or 50
						local cellHeight = element.height or 50
						local padding = element.padding or 20

						local x = propback.x + currentX
						local y = propback.y + 80

						element.render(aRect, {
							x = x,
							y = y,
							width = cellWidth,
							height = cellHeight,
							window = propback,
						})

						currentX = currentX + cellWidth + padding
					end
				end
			end
		end

		if tooltipState.hoveredKey == nil then
			tooltipState.hoverTimer = 0
			tooltipState.visible = false
		end

		drawCategories(propback)

		if tooltipState.visible then
			drawTooltip(tooltipState.text, tooltipState.x, tooltipState.y)
		end

		if renderFileMenu then
			fileMenu.render(dt)
			renderFileMenu = false
		end
	end
end
