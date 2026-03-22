-- devcell

local KinemiumRaylib = game:GetService("KinemiumRaylib")
local KinemiumIconLoader = game:GetService("KinemiumIconLoader")
local KinemiumFontService = game:GetService("KinemiumFontService")
local Selection = game:GetService("Selection")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ScriptRunnerService = game:GetService("ScriptRunnerService")

-- Early returns
if game.Context ~= Enum.GameContext.Editor or FlagExists("cli") or FlagExists("headless") then
	return
end

-- Constants
local DOUBLE_CLICK_THRESHOLD = 0.3
local NODE_HEIGHT = 25
local NODE_WIDTH = 330
local PADDING = 10
local INDENT_SIZE = 12
local ADD_MENU_WIDTH = 200
local ADD_MENU_ITEM_HEIGHT = 22
local MAX_VISIBLE_ITEMS = 15
local MENU_PADDING = 4
local TOGGLE_SIZE = 20
local SCROLL_SPEED = 3
local SCROLLBAR_WIDTH = 8
local scrollTarget = 0

local SERVICE_ORDER = {
	"Workspace",
	"Players",
	"Lighting",
	"MaterialService",
	"ReplicatedFirst",
	"ReplicatedStorage",
	"ServerScriptService",
	"ServerStorage",
	"StarterGui",
	"StarterPack",
	"StarterPlayer",
	"Teams",
	"SoundService",
}

local spring = import("@kispring")
local aereon = import("@Aereon")
local gui = aereon.gui
local LocalPlayer = Players.LocalPlayer
local rl = KinemiumRaylib.lib
local structs = KinemiumRaylib.structs
local const = KinemiumRaylib.const
local renderer = KinemiumRaylib.renderer
local EngineSignal = game.EngineSignal
local vend = KinemiumFontService.GetDefaultFont()
local hoverspring = spring.new(2, 5)

local notfound_tex = KinemiumIconLoader.ToTexture(KinemiumIconLoader.Get("NotFound.svg"))

local Theme = game:GetService("StudioThemeService").SelectedTheme
local ThemeColors = {
	background = Theme.BackgroundColor:ToRaylib(Theme.BackgroundTransparency),
	text = Theme.TextColor:ToRaylib(Theme.TextTransparency),
	guiHandles = Theme.GuiHandlesColor:ToRaylib(Theme.GuiHandlesTransparency),
	secondaryBackground = Theme.SecondaryBackgroundColor:ToRaylib(Theme.SecondaryBackgroundColorTransparency),
	secondaryText = Theme.SecondaryTextColor:ToRaylib(Theme.SecondaryTextTransparency),
	image = Theme.ImageColor:ToRaylib(Theme.ImageTransparency),
	arrowImage = Theme.ArrowImageColor:ToRaylib(0),
}

local expanded = {}
local loadedIcon = {}
local addMenuOpen = {}
local addMenuScroll = {}
local lastClickTime = {}
local lastClicked = nil
local activeAddMenu = nil
local yOffset = 0
local windowObject = nil
local arect = require("@Arect")(rl)
local textbox = aereon.textbox(Theme, game)

local searchBox = textbox.new({
	multiline = false,
	placeholder = "Search..",
	fontSize = 16,
	font = vend,
	maxLength = 56,

	cornerRadius = 0.5,
	BorderTransparency = 1,
	TextColor = ThemeColors.text,
	padding = 5,
})

local searchQuery = searchBox:getText() or ""
local isSearching = #searchQuery > 0

local function matchesSearch(instance, query)
	if instance.Name:lower():find(query:lower(), 1, true) then
		return true
	end
	for _, child in ipairs(instance:GetChildren()) do
		if matchesSearch(child, query) then
			return true
		end
	end
	return false
end

-- Selection menu
local SelectionMenu = gui.menu({
	x = 0,
	y = 0,
	width = 200,
	height = 300,
	Font = vend,
	items = {
		{
			label = "Destroy",
			onClick = function()
				if Selection:Get()[1] then
					for _, v in pairs(Selection:Get()) do
						pcall(function()
							v:Destroy()
						end)
					end
				end
			end,
		},
		{
			label = "Duplicate",
			onClick = function()
				if Selection:Get()[1] then
					for _, v in pairs(Selection:Get()) do
						pcall(function()
							if v.BaseClass == "Singleton" then
								return
							end
							local new = v:Clone()
							new.Parent = v.Parent
						end)
					end
				end
			end,
		},
		{
			label = "Focus",
			onClick = function()
				EngineSignal:Fire("CameraFocus")
			end,
		},
		{
			label = "Toggle Anchor",
			onClick = function()
				local object = Selection:Get()[1]
				if object then
					if object.BaseClass == "BasePart" then
						object.Anchored = not object.Anchored
					end
				end
			end,
		},
		{
			label = "Open In",
			appearif = function()
				local object = Selection:Get()[1]
				if object.BaseClass == "ScriptContainer" then
					return true
				else
					return false
				end
			end,
			submenu = {
				{
					label = "VSCode",
					onClick = function()
						local object = Selection:Get()[1]

						if object.BaseClass == "ScriptContainer" then
							ScriptRunnerService.OpenInExternalEditor(object, "vscode", ishared.FolderPath)
						end
					end,
				},

				{
					label = "Notepad",
					onClick = function() end,
				},

				{
					label = "Let my OS choose",
					onClick = function() end,
				},
			},
		},
		{
			label = "Select",
			submenu = {
				{
					label = "Children",
					onClick = function()
						local object = Selection:Get()[1]
						Selection:Set(object:GetChildren())
					end,
				},
				{
					label = "Descendants",
					onClick = function()
						local object = Selection:Get()[1]
						Selection:Set(object:GetDescendants())
					end,
				},
			},
		},
		{
			label = "Hide",
			onClick = function()
				local object = Selection:Get()[1]
				if object then
					if object.BaseClass == "BasePart" then
						object.Transparency = 1
						object.CanCollide = false
					end
				end
			end,
		},
		{
			label = "Export",
			submenu = {
				{
					label = "as .KINEOBJ",
					onClick = function() end,
				},
			},
		},
	},
})
SelectionMenu:hide()

-- Scrolling state
local scrollOffset = 0
local contentHeight = 0
local maxScroll = 0

KinemiumIconLoader.new("Add", "./src/assets/images/icons/Add.svg")
KinemiumIconLoader.new("ArrowRight", "./src/assets/images/icons/ArrowRight.svg")
KinemiumIconLoader.new("ArrowDown", "./src/assets/images/icons/ArrowDown.svg")

local addIcon = KinemiumIconLoader.ToTexture(KinemiumIconLoader.Get("Add"))
local ArrowRight = KinemiumIconLoader.ToTexture(KinemiumIconLoader.Get("ArrowRight"))
local ArrowDown = KinemiumIconLoader.ToTexture(KinemiumIconLoader.Get("ArrowDown"))

local function isMouseInRect(rect, mousePos)
	return mousePos.x >= rect.x
		and mousePos.x <= rect.x + rect.width
		and mousePos.y >= rect.y
		and mousePos.y <= rect.y + rect.height
end

local function hasSelectedDescendant(instance)
	for _, child in ipairs(instance:GetChildren()) do
		if Selection.IsSelected(child) or hasSelectedDescendant(child) then
			return true
		end
	end
	return false
end

local function isRectVisible(rect, windowRect)
	return rect.x + rect.width >= windowRect.x
		and rect.x <= windowRect.x + windowRect.width
		and rect.y + rect.height >= windowRect.y
		and rect.y <= windowRect.y + windowRect.height
end

local function DoubleClicked(instance)
	local isScript = instance.BaseClass == "ScriptContainer"
	EngineSignal:Fire("idestate", isScript, instance)
end

local function getServicesInOrder()
	local services = {}
	local serviceSet = {}

	for _, name in ipairs(SERVICE_ORDER) do
		local success, svc = pcall(game.GetService, game, name)
		if success and svc then
			table.insert(services, svc)
			serviceSet[svc] = true
		end
	end

	for _, child in ipairs(game:GetChildren()) do
		if not serviceSet[child] then
			table.insert(services, child)
		end
	end

	return services
end

-- Selection handling
local function handleSelection(instance, rectData, mousePos)
	if not isMouseInRect(rectData, mousePos) or rl.IsMouseButtonPressed(0) ~= 1 then
		return
	end

	local currentTime = os.clock()
	local ctrl = rl.IsKeyDown(341) == 1 or rl.IsKeyDown(345) == 1
	local shift = rl.IsKeyDown(340) == 1 or rl.IsKeyDown(344) == 1

	if lastClickTime[instance] and (currentTime - lastClickTime[instance]) < DOUBLE_CLICK_THRESHOLD then
		DoubleClicked(instance)
		expanded[instance] = not expanded[instance]
		lastClickTime[instance] = nil
		return
	end

	lastClickTime[instance] = currentTime

	if shift and lastClicked and instance.Parent then
		local siblings = instance.Parent:GetChildren()
		local startIndex, endIndex

		for i, obj in ipairs(siblings) do
			if obj == lastClicked then
				startIndex = i
			end
			if obj == instance then
				endIndex = i
			end
		end

		if startIndex and endIndex then
			if startIndex > endIndex then
				startIndex, endIndex = endIndex, startIndex
			end

			for i = startIndex, endIndex do
				if not Selection.IsSelected(siblings[i]) then
					Selection.Add(siblings[i])
				end
			end
		end
	elseif ctrl then
		if Selection.IsSelected(instance) then
			Selection.Remove(instance)
		else
			Selection.Add(instance)
		end
	else
		Selection.Clear()
		Selection.Add(instance)
		lastClicked = instance
	end
end

local function drawAdditionMenu(instance, mousePos, btnY, toggleX)
	if not addMenuOpen[instance] then
		return
	end

	addMenuScroll[instance] = addMenuScroll[instance] or 0

	local instanceTypes = Instance.getClasses()
	local totalItems = 0
	for _ in pairs(instanceTypes) do
		totalItems = totalItems + 1
	end

	local menuHeight = math.min(totalItems, MAX_VISIBLE_ITEMS) * ADD_MENU_ITEM_HEIGHT + MENU_PADDING * 2
	local contentHeight = totalItems * ADD_MENU_ITEM_HEIGHT
	local menuX = toggleX - ADD_MENU_WIDTH - 10
	local menuY = btnY + 30

	-- Draw menu background
	rl.DrawRectangleRounded(
		structs.Rectangle:new({ x = menuX, y = menuY, width = ADD_MENU_WIDTH, height = menuHeight }),
		0.2,
		26,
		Theme.SecondaryBackgroundColor:ToRaylib(0)
	)

	-- Handle scrolling
	local menuRect = { x = menuX, y = menuY, width = ADD_MENU_WIDTH, height = menuHeight }
	if isMouseInRect(menuRect, mousePos) then
		local mouseWheel = rl.GetMouseWheelMove()
		if math.abs(mouseWheel) > 0.01 then
			addMenuScroll[instance] = addMenuScroll[instance] - (mouseWheel * ADD_MENU_ITEM_HEIGHT * 2)
			local maxScroll = math.max(0, contentHeight - (MAX_VISIBLE_ITEMS * ADD_MENU_ITEM_HEIGHT))
			addMenuScroll[instance] = math.max(0, math.min(addMenuScroll[instance], maxScroll))
		end
	end

	-- Draw items with scissor
	local scissorPadding = 2
	rl.BeginScissorMode(
		math.floor(menuX + scissorPadding),
		math.floor(menuY + MENU_PADDING),
		math.floor(ADD_MENU_WIDTH - scissorPadding * 2),
		math.floor(menuHeight - MENU_PADDING * 2)
	)

	local i = 0
	for class, _ in pairs(instanceTypes) do
		i = i + 1
		local itemY = menuY + MENU_PADDING + ((i - 1) * ADD_MENU_ITEM_HEIGHT) - addMenuScroll[instance]

		-- Skip items outside visible area
		if itemY + ADD_MENU_ITEM_HEIGHT < menuY or itemY > menuY + menuHeight then
			continue
		end

		local itemRect = { x = menuX, y = itemY, width = ADD_MENU_WIDTH, height = ADD_MENU_ITEM_HEIGHT }
		local isHovered = isMouseInRect(itemRect, mousePos)
			and mousePos.y >= menuY + MENU_PADDING
			and mousePos.y <= menuY + menuHeight - MENU_PADDING

		if isHovered then
			rl.DrawRectangle(menuX, itemY, ADD_MENU_WIDTH, ADD_MENU_ITEM_HEIGHT, Color3.new(0.2, 0.2, 0.2):ToRaylib(1))

			if rl.IsMouseButtonPressed(0) == 1 then
				local success, newObj = pcall(Instance.new, class)
				if success then
					newObj.Parent = instance
				end
				addMenuOpen[instance] = false
				addMenuScroll[instance] = 0
			end
		end

		-- Draw icon
		local iconTex = loadedIcon[class]
		if iconTex then
			local iconSize = ADD_MENU_ITEM_HEIGHT - 6
			rl.DrawTexturePro(
				iconTex.texture,
				structs.Rectangle:new({ x = 0, y = 0, width = iconTex.x, height = iconTex.y }),
				structs.Rectangle:new({ x = menuX + 4, y = itemY + 3, width = iconSize, height = iconSize }),
				vector.create(0, 0),
				0,
				ThemeColors.image
			)
		end

		-- Draw text
		rl.DrawTextEx(vend, class, vector.create(menuX + ADD_MENU_ITEM_HEIGHT + 4, itemY + 3), 17, 1, ThemeColors.text)
	end

	rl.EndScissorMode()

	-- Draw scrollbar
	if contentHeight > MAX_VISIBLE_ITEMS * ADD_MENU_ITEM_HEIGHT then
		local scrollbarWidth = 6
		local scrollbarX = menuX + ADD_MENU_WIDTH - scrollbarWidth - 2
		local scrollbarHeight = menuHeight - MENU_PADDING * 2
		local scrollbarTrackHeight = scrollbarHeight - 4

		local thumbHeight =
			math.max(20, (scrollbarTrackHeight * (MAX_VISIBLE_ITEMS * ADD_MENU_ITEM_HEIGHT)) / contentHeight)
		local maxScroll = contentHeight - (MAX_VISIBLE_ITEMS * ADD_MENU_ITEM_HEIGHT)
		local thumbY = menuY
			+ MENU_PADDING
			+ 2
			+ (addMenuScroll[instance] / maxScroll) * (scrollbarTrackHeight - thumbHeight)

		-- Track
		rl.DrawRectangleRounded(
			structs.Rectangle:new({
				x = scrollbarX,
				y = menuY + MENU_PADDING + 2,
				width = scrollbarWidth,
				height = scrollbarTrackHeight,
			}),
			0.5,
			4,
			Color3.new(0.08, 0.08, 0.08):ToRaylib(0)
		)

		-- Thumb
		rl.DrawRectangleRounded(
			structs.Rectangle:new({
				x = scrollbarX,
				y = thumbY,
				width = scrollbarWidth,
				height = thumbHeight,
			}),
			0.5,
			4,
			Color3.new(0.3, 0.3, 0.3):ToRaylib(0)
		)
	end
end

-- Tree drawing
local function DrawTree(instance, indent, winX, winY, winWidth)
	if instance.Destroyed or instance.ExplorerHidden then
		return
	end
	if isSearching and not matchesSearch(instance, searchQuery) then
		return
	end

	local children = instance:GetChildren()
	local hasChildren = #children > 0
	local ctrl = rl.IsKeyDown(341) == 1 or rl.IsKeyDown(345) == 1

	-- Load icon if needed
	if not loadedIcon[instance.ClassName] then
		local svg = KinemiumIconLoader.Get(instance.ClassName .. ".svg")
		if svg then
			loadedIcon[instance.ClassName] = KinemiumIconLoader.ToTexture(svg)
		end
	end

	local btnX = winX + 25 + winWidth - NODE_WIDTH - PADDING - (indent * -INDENT_SIZE)
	local btnY = winY + 10 + yOffset - scrollOffset
	local rectData = { x = btnX, y = btnY, width = NODE_WIDTH, height = NODE_HEIGHT }
	local toggleX = btnX + NODE_WIDTH

	local mousePos = rl.GetMousePosition()
	local windowRect = { x = winX, y = winY, width = winWidth, height = windowObject and windowObject.height or 600 }

	-- Early culling
	if not isRectVisible(rectData, windowRect) then
		yOffset = yOffset + NODE_HEIGHT + 2
		return
	end

	-- Determine visual state
	local isHovered = isMouseInRect(rectData, mousePos)
	local isSelected = Selection.IsSelected(instance)
	local transparency = isSelected and 0 or (isHovered and 0.5 or 1)
	local color = isSelected and Color3.new(0, 0.533333, 1) or Color3.new()

	-- Draw node background
	rl.DrawRectangleRounded(structs.Rectangle:new(rectData), 0.5, 20, color:ToRaylib(transparency))

	-- Draw icon
	local icon = loadedIcon[instance.ClassName] or notfound_tex
	local iconSize = instance.IconSize or NODE_HEIGHT - 4
	rl.DrawTexturePro(
		icon.texture,
		structs.Rectangle:new({ x = 0, y = 0, width = icon.x, height = icon.y }),
		structs.Rectangle:new({ x = btnX + 2, y = btnY + 2, width = iconSize, height = iconSize }),
		vector.create(0, 0),
		0,
		instance:GetMetadata("ExplorerIconColor")
				and instance:GetMetadata("ExplorerIconColor"):ToRaylib(instance:GetMetadata("ExplorerIconTransparency"))
			or ThemeColors.image
	)

	-- Draw text
	rl.DrawTextEx(vend, instance.Name, vector.create(btnX + 28, btnY + 5), 18, 1, ThemeColors.text)

	if isHovered then
		local iconSize = NODE_HEIGHT - 4
		local addData = { x = toggleX - 50, y = btnY + 2, width = iconSize, height = iconSize }

		rl.DrawTexturePro(
			addIcon.texture,
			structs.Rectangle:new({ x = 0, y = 0, width = addIcon.x, height = addIcon.y }),
			structs.Rectangle:new(addData),
			vector.create(0, 0),
			0,
			ThemeColors.arrowImage
		)

		if isMouseInRect(addData, mousePos) and rl.IsMouseButtonReleased(0) == 1 then
			-- Close all other menus
			for key in pairs(addMenuOpen) do
				addMenuOpen[key] = false
			end
			addMenuOpen[instance] = not addMenuOpen[instance]
			activeAddMenu = addMenuOpen[instance]
					and {
						instance = instance,
						btnY = btnY,
						toggleX = toggleX,
					}
				or nil
		end

		-- Selection Menu
		if rl.IsMouseButtonReleased(1) == 1 then
			if isSelected then
				SelectionMenu.set("obj_rect", arect.new(mousePos.x, mousePos.y, 200, 400))
				SelectionMenu:show()
			else
				SelectionMenu:hide()
			end
		end
	end

	-- Handle selection
	handleSelection(instance, rectData, mousePos)

	if hasChildren then
		local toggleTexture = expanded[instance] and ArrowDown or ArrowRight
		local buttonData = { x = rectData.x - 25, y = rectData.y, width = TOGGLE_SIZE, height = TOGGLE_SIZE }

		rl.DrawTexturePro(
			toggleTexture.texture,
			structs.Rectangle:new({ x = 0, y = 0, width = toggleTexture.x, height = toggleTexture.y }),
			structs.Rectangle:new(buttonData),
			vector.create(0, 0),
			0,
			ThemeColors.arrowImage
		)

		if isMouseInRect(buttonData, mousePos) and rl.IsMouseButtonReleased(0) == 1 then
			expanded[instance] = not expanded[instance]
		end
	end

	yOffset = yOffset + NODE_HEIGHT + 2

	local shouldExpand = expanded[instance]
		or (isSearching and matchesSearch(instance, searchQuery))
		or hasSelectedDescendant(instance)

	if hasChildren and shouldExpand then
		for _, child in ipairs(children) do
			DrawTree(child, indent + 1, winX, winY, winWidth)
		end
	end
end

local function drawScrollbar(windowData)
	local scrollbarX = windowData.x + windowData.width - SCROLLBAR_WIDTH - 4
	local scrollbarY = windowData.y + 30
	local scrollbarHeight = windowData.height - 40
	local trackHeight = scrollbarHeight - 8

	local thumbHeight = math.max(30, (scrollbarHeight * scrollbarHeight) / contentHeight)
	local thumbY = scrollbarY + 4 + (scrollOffset / maxScroll) * (trackHeight - thumbHeight)

	-- Track
	rl.DrawRectangleRounded(
		structs.Rectangle:new({
			x = scrollbarX,
			y = scrollbarY + 4,
			width = SCROLLBAR_WIDTH,
			height = trackHeight,
		}),
		0.5,
		4,
		Color3.new(0.1, 0.1, 0.1):ToRaylib(0)
	)

	-- Thumb
	rl.DrawRectangleRounded(
		structs.Rectangle:new({
			x = scrollbarX,
			y = thumbY,
			width = SCROLLBAR_WIDTH,
			height = thumbHeight,
		}),
		0.5,
		4,
		Color3.new(0.4, 0.4, 0.4):ToRaylib(0)
	)
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "Explorer"
screenGui.Parent = LocalPlayer.PlayerGui

local frame = Instance.new("Frame")
frame.Position = Theme.WindowConfig.Explorer.position
frame.AnchorPoint = Theme.WindowConfig.Explorer.anchorPoint
frame.Size = Theme.WindowConfig.Explorer.size
frame.BackgroundTransparency = 1
frame.Parent = screenGui

repeat
	task.wait()
until frame.AbsolutePosition and frame.AbsoluteSize

local window = aereon.window(game)
local explorerWindow = window.create({
	title = "Explorer",
	x = frame.AbsolutePosition.X,
	y = frame.AbsolutePosition.Y,
	width = frame.AbsoluteSize.X,
	height = frame.AbsoluteSize.Y,
})

task.spawn(function()
	local classes = Instance.getClasses()
	for class, _ in pairs(classes) do
		if not loadedIcon[class] then
			local png = KinemiumIconLoader.Get(class .. ".png")
			if png then
				loadedIcon[class] = KinemiumIconLoader.ToTexture(png)
			end
		end
	end
end)

explorerWindow.stepped = function(windowData)
	if windowData.title ~= "Explorer" then
		return
	end

	searchQuery = searchBox:getText() or ""
	isSearching = #searchQuery > 0

	local dt = rl.GetFrameTime()

	hoverspring:step(dt)

	windowObject = windowData
	yOffset = 0

	if rl.IsWindowResized() == 1 then
		windowData.x = frame.AbsolutePosition.X
		windowData.y = frame.AbsolutePosition.Y
		windowData.width = frame.AbsoluteSize.X
		windowData.height = frame.AbsoluteSize.Y
	end

	local mousePos = rl.GetMousePosition()
	local windowRect = {
		x = windowData.x,
		y = windowData.y,
		width = windowData.width,
		height = windowData.height,
	}

	local boxWidth = windowRect.width * 0.95
	local boxX = windowRect.x + (windowRect.width - boxWidth) * 0.5

	searchBox:drawWithExtras(boxX, windowRect.y + 35, boxWidth, 30)

	if isMouseInRect(windowRect, mousePos) and not activeAddMenu then
		local mouseWheel = rl.GetMouseWheelMove()
		if math.abs(mouseWheel) > 0.01 then
			scrollTarget -= mouseWheel * NODE_HEIGHT * SCROLL_SPEED
		end
	end

	rl.BeginScissorMode(
		math.floor(windowData.x),
		math.floor(windowData.y + 30),
		math.floor(windowData.width),
		math.floor(windowData.height - 30)
	)

	local services = getServicesInOrder()
	for _, child in ipairs(services) do
		DrawTree(child, 0, windowData.x - 50, windowData.y + 60, windowData.width)
	end

	rl.EndScissorMode()

	contentHeight = yOffset
	maxScroll = math.max(0, contentHeight - (windowData.height - 40))

	scrollTarget = math.clamp(scrollTarget, 0, maxScroll)
	scrollOffset = scrollOffset + (scrollTarget - scrollOffset) * math.min(dt * 18, 1)

	drawScrollbar(windowData)

	if activeAddMenu then
		drawAdditionMenu(activeAddMenu.instance, rl.GetMousePosition(), activeAddMenu.btnY, activeAddMenu.toggleX)
	end
	SelectionMenu.render(dt)

	local ctrl = rl.IsKeyDown(341) == 1 or rl.IsKeyDown(345) == 1

	if rl.IsKeyReleased(261) == 1 then
		Selection.Clear()
	end

	-- Handle cloning
	if ctrl then
		if rl.IsKeyReleased(68) == 1 then
			local selected = Selection.Get()
			for _, v in pairs(selected) do
				if v.BaseClass == "Singleton" then
					continue
				end
				local clone = v:Clone()
				clone.Parent = v.Parent
			end
		end
	end
end
