-- devcell
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
local GuiHandlesColor = Theme.GuiHandlesColor:ToRaylib(Theme.GuiHandlesTransparency)
local SecondaryBackgroundColor = Theme.SecondaryBackgroundColor:ToRaylib(Theme.SecondaryBackgroundColorTransparency)
local SecondaryTextColor = Theme.SecondaryTextColor:ToRaylib(Theme.SecondaryTextTransparency)
local ImageColor = Theme.ImageColor:ToRaylib(Theme.ImageTransparency)

export type elementTitle = string

export type RibbonBarCategory = {
	title: string,
	elements: {
		[elementTitle]: {
			type: "Imageelement" | "Textelement" | "TextLabel" | "Custom",
			callback: () -> (),
			render: () -> (),

			imagePath: string?,
			text: string?,
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
					fileMenu.render(dt)
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

local function Color3ToRaylib(c, transparency)
	local r, g, b = c:ToRGB()
	return structs.Color:new({
		r = r,
		g = g,
		b = b,
		a = math.floor(255 * (1 - transparency)),
	})
end

local function renderButton(xPos, name, element, windowData)
	local winX, winY = windowData.x, windowData.y + 80
	local cellWidth = element.width or 50
	local cellHeight = element.height or 50
	local rectX = winX + xPos
	local rectY = winY
	local rectData = aRect.new(rectX, rectY, cellWidth, cellHeight)

	local transparency = 1
	local color = Color3.new(0.5, 0.5, 0.5)

	if aRect.MouseIsInRect(rectData) then
		color = element.hoverColor
		transparency = element.hoverTransparency
	end

	aRect.Button(rectData, function()
		element.callback(element, rectData)
	end)

	local bgColor = Color3ToRaylib(color, transparency)
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

	-- text
	if name then
		local textX = rectData.x + cellWidth / 2 - (#name * 9) / 2
		local textY = rectData.y + cellHeight + 5
		rl.DrawTextEx(vend, name, vector.create(textX, textY), 18, 1, TextColor)
	end

	if element.render then
		element.render(aRect)
	end

	return cellWidth + (element.padding or 20)
end

local function renderSeperator(xPos, windowData, element)
	local winX, winY = windowData.x, windowData.y + 80
	local rectX = winX + xPos
	local rectY = winY

	local sepColor = Color3ToRaylib(element.color or Color3.new(0.7, 0.7, 0.7), 0)
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
	local x = windowData.x + (windowData.width - width) / 2 -- center inside window
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

		local bg = Color3ToRaylib(Color3.new(0.12549, 0.12549, 0.12549), 1)
		if currentlySelected == name then
			bg = SecondaryBackgroundColor
		end

		rl.DrawRectangleRounded(aRect:translate(rect), 0.5, 5, bg)

		local textX = rect.x + buttonWidth / 2 - (#name * 9) / 2
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
		local currentX = 15
		local category = categoryRegistry[currentlySelected]

		if category then
			local elements = category.elements
			for _, element in pairs(elements) do
				if element.type == "ImageButton" then
					local width = renderButton(currentX, element.text, element, propback)
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

		drawCategories(propback)
	end
end
