-- devcell

local RunService = game:GetService("RunService")
if RunService:IsServer() then
	return
end

local KinemiumRaylib = game:GetService("KinemiumRaylib")
local KinemiumIconLoader = game:GetService("KinemiumIconLoader")
local KinemiumFontService = game:GetService("KinemiumFontService")
local vend = KinemiumFontService.GetDefaultFont()
local boldFont = KinemiumFontService.GetBoldFont()
local Players = game:GetService("Players")
local FileDialogService = game:GetService("FileDialogService")
local KineFileService = game:GetService("KineFileService")
local RBXModelImporter = game:GetService("RBXModelImporter")
local Selection = game:GetService("Selection")
local StudioThemeService = game:GetService("StudioThemeService")

if game.Context ~= Enum.GameContext.Editor or FlagExists("cli") or FlagExists("headless") then
	return
end

-- Constants
local DOUBLE_CLICK_THRESHOLD = 0.3
local NODE_HEIGHT = 25
local NODE_WIDTH = 330
local PADDING = 10
local INDENT_SIZE = 20
local ADD_MENU_WIDTH = 300
local ADD_MENU_ITEM_HEIGHT = 24
local MAX_VISIBLE_ITEMS = 20
local ADD_MENU_TITLE_HEIGHT = 30
local MENU_PADDING = 4
local TOGGLE_SIZE = 20

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
local interface = require("@RaylibAdapter")
local rl = interface.lib
local structs = interface.structs
local addMenuOpenBool = false
local EngineSignal = game.EngineSignal
local hoverspring = spring.new(2, 5)

local notfound_tex = KinemiumIconLoader.ToTexture(KinemiumIconLoader.Get("NotFound.png"))

local Theme = game:GetService("StudioThemeService").SelectedTheme

local expanded = {}
local loadedIcon = {}
local addMenuOpen = {}
local addMenuScroll = {}
local addMenuScrollTarget = {}
local addMenuSearch = {}
local addMenuExpandedCategories = {}
local addMenuHoverAnim = {}
local lastClickTime = {}
local lastClicked = nil
local activeAddMenu = nil
local addMenuRect = nil
local yOffset = 0
local windowObject = nil
local dragInstance = nil
local isDragging = false
local dragMouseStart = nil
local dragTargetInstance = nil
local DRAG_THRESHOLD = 20
local dropAnimInstance = nil
local dropAnimStart = 0
local dropAnimFromX = 0
local dropAnimFromY = 0
local dropAnimToX = nil
local dropAnimToY = nil
local DROP_ANIM_DURATION = 0.3
local arect = require("@arect")
local textbox = aereon.textbox(Theme, game)

local ContextMenuOpen = false

local ADD_MENU_SEARCH_HEIGHT = 30
local CATEGORY_HEADER_HEIGHT = 24

local function getClassCategory(className)
	local lowerName = className:lower()

	-- Services
	if lowerName:find("service") then
		return "Services"
	end

	-- UI
	if
		lowerName:find("gui")
		or lowerName:find("screen")
		or lowerName:find("frame")
		or lowerName:find("text")
		or lowerName:find("button")
		or lowerName:find("scroll")
		or lowerName:find("image")
		or lowerName:find("textbox")
		or lowerName:find("viewport")
		or lowerName:find("billboard")
		or lowerName:find("surface")
	then
		return "UI"
	end

	-- Effects
	if
		lowerName:find("particle")
		or lowerName:find("light")
		or lowerName:find("beam")
		or lowerName:find("trail")
		or lowerName:find("fire")
		or lowerName:find("smoke")
		or lowerName:find("sparkles")
		or lowerName:find("constraint")
	then
		return "Effects"
	end

	-- Scripting
	if
		lowerName:find("script")
		or lowerName:find("module")
		or lowerName:find("bindable")
		or lowerName:find("remote")
	then
		return "Scripting"
	end

	-- Objects
	if
		lowerName:find("part")
		or lowerName:find("mesh")
		or lowerName:find("model")
		or lowerName:find("attachment")
		or lowerName:find("motor")
		or lowerName:find("weld")
	then
		return "Objects"
	end

	-- Data
	if
		lowerName:find("value")
		or lowerName:find("object")
		or lowerName:find("bool")
		or lowerName:find("number")
		or lowerName:find("string")
		or lowerName:find("vector")
		or lowerName:find("color")
		or lowerName:find("cframe")
		or lowerName:find("udim")
		or lowerName:find("brick")
	then
		return "Data"
	end

	-- Audio
	if
		lowerName:find("sound")
		or lowerName:find("audio")
		or lowerName:find("reverb")
		or lowerName:find("echo")
		or lowerName:find("distortion")
		or lowerName:find("flange")
		or lowerName:find("chorus")
		or lowerName:find("equalizer")
	then
		return "Audio"
	end

	-- Animation
	if
		lowerName:find("animation")
		or lowerName:find("animator")
		or lowerName:find("humanoid")
		or lowerName:find("character")
	then
		return "Animation"
	end

	-- Camera
	if lowerName:find("camera") then
		return "Camera"
	end

	return "Other"
end

local searchBox = textbox.new({
	multiline = false,
	placeholder = "Search..",
	fontSize = 16,
	font = vend,
	maxLength = 56,
	cornerRadius = StudioThemeService.SelectedTheme.CornerRadius,

	BorderTransparency = 1,
	TextColor = StudioThemeService.SelectedTheme.TextColor:ToRaylib(StudioThemeService.SelectedTheme.TextTransparency),
	padding = 5,
})

KinemiumIconLoader.new("Filter", "./src/assets/images/icons/Configuration.png")

local filterIcon = KinemiumIconLoader.ToTexture(KinemiumIconLoader.Get("Filter"))

local addMenuSearchBox = textbox.new({
	multiline = false,
	placeholder = "Search classes..",
	fontSize = 14,
	font = vend,
	maxLength = 56,

	cornerRadius = 0.3,
	BorderTransparency = 1,
	TextColor = StudioThemeService.SelectedTheme.TextColor:ToRaylib(StudioThemeService.SelectedTheme.TextTransparency),
	padding = 4,
})

local searchQuery = searchBox:getText() or ""
local isSearching = #searchQuery > 0

local searchFilterOptions = { "Name", "ClassName", "Property", "Tags", "Attributes", "All" }
local searchFilterMode = "Name"
local searchFilterButton
local searchFilterMenu
local searchFilterMenuVisible = false

local function getTagsForInstance(instance)
	local ok, tags = pcall(function()
		if instance.GetTags then
			return instance:GetTags()
		end
		local CollectionService = game:GetService("CollectionService")
		return CollectionService:GetTags(instance)
	end)
	if ok and type(tags) == "table" then
		return tags
	end
	return {}
end

local function getAttributesForInstance(instance)
	local ok, attrs = pcall(function()
		return instance:GetAttributes()
	end)
	if ok and type(attrs) == "table" then
		return attrs
	end
	return {}
end

local function instanceMatches(instance, query, mode)
	local q = string.lower(query or "")
	if q == "" then
		return true
	end

	if mode == "Name" then
		return string.find(instance.Name:lower(), q, 1, true) ~= nil
	elseif mode == "ClassName" then
		return string.find((instance.ClassName or ""):lower(), q, 1, true) ~= nil
	elseif mode == "Property" then
		local propName, propValue = q:match("^%s*([^:]+)%s*:%s*(.+)%s*$")
		if not propName then
			propName = q
		end
		local ok, value = pcall(function()
			return instance[propName]
		end)
		if ok then
			if propValue then
				return string.find(tostring(value):lower(), propValue, 1, true) ~= nil
			end
			return true
		end
		return false
	elseif mode == "Tags" then
		for _, tag in ipairs(getTagsForInstance(instance)) do
			if string.find(string.lower(tag), q, 1, true) then
				return true
			end
		end
		return false
	elseif mode == "Attributes" then
		local attrName, attrValue = q:match("^%s*([^:]+)%s*:%s*(.+)%s*$")
		local attrs = getAttributesForInstance(instance)
		if attrName then
			local value = attrs[attrName]
			if value == nil then
				return false
			end
			return string.find(tostring(value):lower(), attrValue, 1, true) ~= nil
		end
		for key, value in pairs(attrs) do
			if string.find(string.lower(key), q, 1, true) or string.find(tostring(value):lower(), q, 1, true) then
				return true
			end
		end
		return false
	elseif mode == "All" then
		if string.find(instance.Name:lower(), q, 1, true) then
			return true
		end
		if string.find((instance.ClassName or ""):lower(), q, 1, true) then
			return true
		end
		if instanceMatches(instance, query, "Property") then
			return true
		end
		if instanceMatches(instance, query, "Tags") then
			return true
		end
		if instanceMatches(instance, query, "Attributes") then
			return true
		end
		return false
	end

	return string.find(instance.Name:lower(), q, 1, true) ~= nil
end

local function matchesSearch(instance, query, mode)
	if instanceMatches(instance, query, mode) then
		return true
	end
	for _, child in ipairs(instance:GetChildren()) do
		if matchesSearch(child, query, mode) then
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
	Font = vend,
	backgroundColor = Theme.SecondaryBackgroundColor,
	textColor = Theme.TextColor,
	rounded = { 0, StudioThemeService.SelectedTheme.CornerRadius },
	hoverColor = Theme.BackgroundColor,
	items = {
		{
			label = "Destroy",
			onClick = function()
				if Selection:Get()[1] then
					for _, v in pairs(Selection:Get()) do
						if v.BaseClass == "Singleton" then
							return
						end
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
						end
					end,
				},

				{
					label = "Notepad",
					onClick = function()
						local object = Selection:Get()[1]

						if object.BaseClass == "ScriptContainer" then
						end
					end,
				},

				{
					label = "Let my OS choose",
					onClick = function()
						local object = Selection:Get()[1]

						if object.BaseClass == "ScriptContainer" then
						end
					end,
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
					elseif object.BaseClass == "GuiObject" then
						object.Visible = false
					end
				end
			end,
		},
		{
			label = "Export",
			submenu = {
				{
					label = "as .KINEOBJ",
					onClick = function()
						local object = Selection:Get()[1]
						if object then
							local path = FileDialogService.RequestSaveFile(object.Name)

							if path then
								local dir = path:match("^(.*)[\\/][^\\/]+$")
								local name = path:match("[^\\/]+$")

								KineFileService.ExportObject(object, dir, name)
							end
						end
					end,
				},
			},
		},
		{
			label = "Import",
			submenu = {
				{
					label = ".KINEOBJ",
					onClick = function()
						task.spawn(function()
							local path = FileDialogService.RequestFile({
								{ name = "Kinemium Object File", extensions = { "kineobj" } },
							})

							if not path then
								return
							end
							if path == "" then
								return
							end
							if not string.find(path, ".kineobj") then
								return
							end

							local ins = KineFileService.DecodeFile(path)

							local object = Selection:Get()[1]
							if object and ins then
								ins.Parent = object
							end
						end)
					end,
				},

				{
					label = ".RBXM, .RBXMX",
					onClick = function()
						task.spawn(function()
							local path = FileDialogService.RequestFile({
								{ name = "Model", extensions = { "rbxm", "rbxmx" } },
							})

							if not path then
								return
							end
							if path == "" then
								return
							end
							if not string.find(path, ".rbxm") then
								return
							end

							local read = Filesystem.readFile(path, true)
							if not read then
								return
							end

							local new = RBXModelImporter.ImportModel(read)
							if new then
								local selected = Selection:Get()[1]
								if selected then
									new.Parent = selected
								else
									new.Parent = workspace
								end
							end
						end)
					end,
				},
			},
		},
	},
})
SelectionMenu:hide()

-- Scrolling state
local scrollOffset = 0

KinemiumIconLoader.new("Add", "./src/assets/images/icons/Add.png")
KinemiumIconLoader.new("ArrowRight", "./src/assets/images/icons/ArrowRight.png")
KinemiumIconLoader.new("ArrowDown", "./src/assets/images/icons/ArrowDown.png")

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

local function canReparent(instance, newParent)
	if instance == newParent then
		return false
	end
	if instance.BaseClass == "Singleton" then
		return false
	end
	local ok, result = pcall(function()
		return newParent:IsDescendantOf(instance)
	end)
	if ok and result then
		return false
	end
	return true
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

local function handleSelection(instance, rectData, mousePos)
	if
		not isMouseInRect(rectData, mousePos)
		or rl.IsMouseButtonPressed(0) ~= 1
		or ContextMenuOpen
		or addMenuOpenBool
		or isDragging
	then
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
	addMenuScrollTarget[instance] = addMenuScrollTarget[instance] or 0
	addMenuSearch[instance] = addMenuSearch[instance] or ""

	local instanceTypes = Instance.getClasses()

	local sortedClasses = {}
	for class in pairs(instanceTypes) do
		table.insert(sortedClasses, class)
	end

	table.sort(sortedClasses, function(a, b)
		return a < b -- alphabetical
	end)

	-- Filter classes based on search query
	local filteredClasses = {}
	local searchQuery = addMenuSearch[instance]:lower()
	for _, class in ipairs(sortedClasses) do
		if searchQuery == "" or class:lower():find(searchQuery, 1, true) then
			table.insert(filteredClasses, class)
		end
	end

	-- Group classes by category
	local categoryBuckets = {}
	local categoryOrder = {}
	for _, class in ipairs(filteredClasses) do
		local category = getClassCategory(class)
		if not categoryBuckets[category] then
			categoryBuckets[category] = {}
			table.insert(categoryOrder, category)
		end
		table.insert(categoryBuckets[category], class)
	end

	table.sort(categoryOrder, function(a, b)
		return a < b
	end)

	-- Initialize category expansion state
	if not addMenuExpandedCategories[instance] then
		addMenuExpandedCategories[instance] = {}
	end

	-- Calculate total visible items (only count expanded categories)
	local totalVisibleItems = 0
	for _, category in ipairs(categoryOrder) do
		if addMenuExpandedCategories[instance][category] ~= false then
			totalVisibleItems = totalVisibleItems + #categoryBuckets[category]
		end
		totalVisibleItems = totalVisibleItems + 1 -- +1 for category header
	end

	local totalItems = totalVisibleItems

	local menuHeight = math.min(totalItems, MAX_VISIBLE_ITEMS) * ADD_MENU_ITEM_HEIGHT
		+ MENU_PADDING * 2
		+ ADD_MENU_SEARCH_HEIGHT
		+ ADD_MENU_TITLE_HEIGHT
	local contentHeight = totalItems * ADD_MENU_ITEM_HEIGHT + #categoryOrder * CATEGORY_HEADER_HEIGHT
	local menuX = toggleX - ADD_MENU_WIDTH - 10
	local menuY = btnY + 30

	-- Draw menu background
	rl.DrawRectangleRounded(
		structs.Rectangle:new({ x = menuX, y = menuY, width = ADD_MENU_WIDTH, height = menuHeight }),
		StudioThemeService.SelectedTheme.CornerRadius,
		StudioThemeService.SelectedTheme.CornerRadius,
		Theme.SecondaryBackgroundColor:ToRaylib(0)
	)

	-- Draw title
	rl.DrawTextEx(
		vend,
		"Add Object",
		vector.create(menuX + MENU_PADDING, menuY + MENU_PADDING),
		18,
		StudioThemeService.SelectedTheme.CornerRadius,
		StudioThemeService.SelectedTheme.TextColor:ToRaylib(StudioThemeService.SelectedTheme.TextTransparency)
	)

	local menuRect = { x = menuX, y = menuY, width = ADD_MENU_WIDTH, height = menuHeight }
	local itemsRect = {
		x = menuX,
		y = menuY + MENU_PADDING + ADD_MENU_SEARCH_HEIGHT + ADD_MENU_TITLE_HEIGHT,
		width = ADD_MENU_WIDTH,
		height = menuHeight - MENU_PADDING * 2 - ADD_MENU_SEARCH_HEIGHT - ADD_MENU_TITLE_HEIGHT,
	}

	-- Handle mouse wheel scrolling on items area
	if isMouseInRect(itemsRect, mousePos) then
		local mouseWheel = rl.GetMouseWheelMove()
		if math.abs(mouseWheel) > 0.01 then
			addMenuScrollTarget[instance] = addMenuScrollTarget[instance] - (mouseWheel * ADD_MENU_ITEM_HEIGHT * 2)
			local maxScroll = math.max(0, contentHeight - (MAX_VISIBLE_ITEMS * ADD_MENU_ITEM_HEIGHT))
			addMenuScrollTarget[instance] = math.max(0, math.min(addMenuScrollTarget[instance], maxScroll))
		end
	end

	-- Smooth interpolation for scroll
	local dt = rl.GetFrameTime()
	local maxScroll = math.max(0, contentHeight - (MAX_VISIBLE_ITEMS * ADD_MENU_ITEM_HEIGHT))
	addMenuScrollTarget[instance] = math.clamp(addMenuScrollTarget[instance], 0, maxScroll)
	addMenuScroll[instance] = addMenuScroll[instance]
		+ (addMenuScrollTarget[instance] - addMenuScroll[instance]) * math.min(dt * 18, 1)

	-- Draw search textbox
	local searchBoxX = menuX + MENU_PADDING
	local searchBoxY = menuY + MENU_PADDING + ADD_MENU_TITLE_HEIGHT
	local searchBoxW = ADD_MENU_WIDTH - MENU_PADDING * 2
	addMenuSearchBox:drawWithExtras(searchBoxX, searchBoxY, searchBoxW, ADD_MENU_SEARCH_HEIGHT - 6)

	-- Update search query from textbox
	local currentSearchText = addMenuSearchBox:getText() or ""
	if currentSearchText ~= addMenuSearch[instance] then
		addMenuSearch[instance] = currentSearchText
		addMenuScroll[instance] = 0 -- Reset scroll when search changes
		addMenuScrollTarget[instance] = 0
	end

	-- Draw items with scissor
	local scissorPadding = 2
	rl.BeginScissorMode(
		math.floor(menuX + scissorPadding),
		math.floor(menuY + MENU_PADDING + ADD_MENU_SEARCH_HEIGHT + ADD_MENU_TITLE_HEIGHT),
		math.floor(ADD_MENU_WIDTH - scissorPadding * 2),
		math.floor(menuHeight - MENU_PADDING * 2 - ADD_MENU_SEARCH_HEIGHT - ADD_MENU_TITLE_HEIGHT)
	)

	local cursorY = menuY + MENU_PADDING + ADD_MENU_SEARCH_HEIGHT + ADD_MENU_TITLE_HEIGHT - addMenuScroll[instance]

	for _, category in ipairs(categoryOrder) do
		local categoryY = cursorY
		cursorY = cursorY + CATEGORY_HEADER_HEIGHT

		-- Draw category header in inspector style
		local labelText = string.upper(category)
		local labelSize = rl.MeasureTextEx(vend, labelText, 11, 1.5)
		local indicatorText = addMenuExpandedCategories[instance][category] ~= false and "v" or ">"
		local indicatorSize = rl.MeasureTextEx(vend, indicatorText, 11, 1)

		local gap = 5
		local blockW = indicatorSize.x + gap + labelSize.x
		local blockX = menuX + MENU_PADDING
		local centerY = categoryY + (CATEGORY_HEADER_HEIGHT / 2)
		local lineColor = Theme.SecondaryBackgroundColor:ToRaylib(0)

		rl.DrawRectangle(menuX, centerY, MENU_PADDING - 4, 1, lineColor)
		rl.DrawTextEx(
			boldFont,
			indicatorText,
			vector.create(blockX, centerY - 6),
			11,
			1,
			StudioThemeService.SelectedTheme.TextColor:ToRaylib(StudioThemeService.SelectedTheme.TextTransparency)
		)
		rl.DrawTextEx(
			boldFont,
			labelText,
			vector.create(blockX + indicatorSize.x + gap, centerY - 6),
			11,
			1.5,
			StudioThemeService.SelectedTheme.TextColor:ToRaylib(StudioThemeService.SelectedTheme.TextTransparency)
		)
		local lineStartX = blockX + blockW + MENU_PADDING - 4
		rl.DrawRectangle(lineStartX, centerY, ADD_MENU_WIDTH - lineStartX + menuX, 1, lineColor)

		-- Handle category click
		local categoryRect = { x = menuX, y = categoryY, width = ADD_MENU_WIDTH, height = CATEGORY_HEADER_HEIGHT }
		local isCategoryHovered = isMouseInRect(categoryRect, mousePos)
			and mousePos.y >= menuY + MENU_PADDING + ADD_MENU_SEARCH_HEIGHT + ADD_MENU_TITLE_HEIGHT
			and mousePos.y <= menuY + menuHeight - MENU_PADDING

		if isCategoryHovered and rl.IsMouseButtonPressed(0) == 1 then
			addMenuExpandedCategories[instance][category] = not addMenuExpandedCategories[instance][category]
		end

		-- Draw items in this category if expanded
		local isExpanded = addMenuExpandedCategories[instance][category] ~= false
		if isExpanded then
			for _, class in ipairs(categoryBuckets[category]) do
				local itemY = cursorY
				cursorY = cursorY + ADD_MENU_ITEM_HEIGHT

				if itemY + ADD_MENU_ITEM_HEIGHT < menuY or itemY > menuY + menuHeight then
					continue
				end

				local itemRect = { x = menuX, y = itemY, width = ADD_MENU_WIDTH, height = ADD_MENU_ITEM_HEIGHT }
				local isHovered = isMouseInRect(itemRect, mousePos)
					and mousePos.y >= menuY + MENU_PADDING + ADD_MENU_SEARCH_HEIGHT + ADD_MENU_TITLE_HEIGHT
					and mousePos.y <= menuY + menuHeight - MENU_PADDING

				-- Initialize and animate hover state
				local itemKey = instance.UniqueId .. class
				addMenuHoverAnim[itemKey] = addMenuHoverAnim[itemKey] or 0
				local hoverTarget = isHovered and 1 or 0
				addMenuHoverAnim[itemKey] = addMenuHoverAnim[itemKey]
					+ (hoverTarget - addMenuHoverAnim[itemKey]) * math.min(dt * 15, 1)

				if addMenuHoverAnim[itemKey] > 0.01 then
					rl.DrawRectangle(
						menuX,
						itemY,
						ADD_MENU_WIDTH,
						ADD_MENU_ITEM_HEIGHT,
						Color3.new(0.2, 0.2, 0.2):ToRaylib(addMenuHoverAnim[itemKey])
					)
				end

				if isHovered and rl.IsMouseButtonPressed(0) == 1 and not addMenuSearchBox.isFocused then
					local success, newObj = pcall(Instance.new, class)
					if success then
						newObj.Parent = instance
					end
					addMenuOpen[instance] = false
					addMenuOpenBool = false
					addMenuScroll[instance] = 0
					addMenuScrollTarget[instance] = 0
					addMenuSearch[instance] = ""
					addMenuSearchBox:setText("")
				end

				local iconTex = loadedIcon[class]
				if not iconTex then
					local svg = KinemiumIconLoader.Get(class .. ".png") or KinemiumIconLoader.Get(class .. ".svg")
					if svg then
						iconTex = KinemiumIconLoader.ToTexture(svg)
						loadedIcon[class] = iconTex
					else
						iconTex = notfound_tex
					end
				end
				if iconTex and iconTex.texture then
					local iconSize = ADD_MENU_ITEM_HEIGHT - 6
					rl.DrawTexturePro(
						iconTex.texture,
						structs.Rectangle:new({ x = 0, y = 0, width = iconTex.x, height = iconTex.y }),
						structs.Rectangle:new({ x = menuX + 4, y = itemY + 3, width = iconSize, height = iconSize }),
						vector.create(0, 0),
						0,
						StudioThemeService.SelectedTheme.ImageColor:ToRaylib(
							StudioThemeService.SelectedTheme.ImageTransparency
						)
					)
				end

				-- Draw text
				rl.DrawTextEx(
					vend,
					class,
					vector.create(menuX + ADD_MENU_ITEM_HEIGHT + 4, itemY + 3),
					17,
					1,
					StudioThemeService.SelectedTheme.TextColor:ToRaylib(
						StudioThemeService.SelectedTheme.TextTransparency
					)
				)
			end
		end
	end

	rl.EndScissorMode()

	-- Draw scrollbar
	if contentHeight > MAX_VISIBLE_ITEMS * ADD_MENU_ITEM_HEIGHT then
		local scrollbarWidth = 8
		local scrollbarX = menuX + ADD_MENU_WIDTH - scrollbarWidth - 2
		local scrollbarHeight = menuHeight - MENU_PADDING * 2 - ADD_MENU_SEARCH_HEIGHT - ADD_MENU_TITLE_HEIGHT
		local scrollbarTrackHeight = scrollbarHeight - 4
		local scrollbarY = menuY + MENU_PADDING + ADD_MENU_SEARCH_HEIGHT + ADD_MENU_TITLE_HEIGHT

		local thumbHeight =
			math.max(20, (scrollbarTrackHeight * (MAX_VISIBLE_ITEMS * ADD_MENU_ITEM_HEIGHT)) / contentHeight)
		local maxScroll = contentHeight - (MAX_VISIBLE_ITEMS * ADD_MENU_ITEM_HEIGHT)
		local thumbY = scrollbarY + 2 + (addMenuScroll[instance] / maxScroll) * (scrollbarTrackHeight - thumbHeight)

		-- Track
		rl.DrawRectangleRounded(
			structs.Rectangle:new({
				x = scrollbarX,
				y = scrollbarY + 2,
				width = scrollbarWidth,
				height = scrollbarTrackHeight,
			}),
			StudioThemeService.SelectedTheme.CornerRadius,
			StudioThemeService.SelectedTheme.CornerRadius,
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
			StudioThemeService.SelectedTheme.CornerRadius,
			StudioThemeService.SelectedTheme.CornerRadius,
			Color3.new(0.3, 0.3, 0.3):ToRaylib(0)
		)
	end

	addMenuRect = menuRect
end

-- Tree drawing
local function DrawTree(instance, indent, winX, winY, winWidth, isLastChild)
	if instance.Destroyed or instance.ExplorerHidden then
		return
	end
	if isSearching and not matchesSearch(instance, searchQuery, searchFilterMode) then
		return
	end
	if isDragging and instance == dragInstance then
		return
	end

	local children = instance:GetChildren()
	local hasChildren = #children > 0

	local btnX = winX + 25 + winWidth - NODE_WIDTH - PADDING - (indent * -INDENT_SIZE)
	local btnY = winY + 10 + yOffset - scrollOffset
	local rectData = { x = btnX, y = btnY, width = NODE_WIDTH, height = NODE_HEIGHT }
	local toggleX = btnX + NODE_WIDTH

	local mousePos = rl.GetMousePosition()
	local treeTop = winY + 10
	local treeHeight = (windowObject and windowObject.height or 600) - 80
	local windowRect = { x = winX, y = treeTop, width = winWidth, height = treeHeight }

	-- Early culling check (only skip drawing, still process height/children)
	local isVisible = isRectVisible(rectData, windowRect)

	-- While dragging, detect drop target
	if isDragging and dragInstance ~= instance and canReparent(dragInstance, instance) then
		if isMouseInRect(rectData, mousePos) then
			dragTargetInstance = instance
		end
	end

	if isVisible then
		-- Draw simple vertical guide line for hierarchy
		if indent > 0 then
			local lineX = btnX - INDENT_SIZE / 2
			local lineColor = Theme.SecondaryTextColor
			lineColor = Color3.new(lineColor.R * 0.5, lineColor.G * 0.5, lineColor.B * 0.5)

			-- Vertical line - only go up to the middle for last child, otherwise go through entire node
			local lineEndY = isLastChild and (btnY + NODE_HEIGHT / 2) or (btnY + NODE_HEIGHT)
			rl.DrawLine(lineX, btnY, lineX, lineEndY, lineColor:ToRaylib(0.3))

			-- Horizontal line connecting to node
			rl.DrawLine(lineX, btnY + NODE_HEIGHT / 2, btnX - 2, btnY + NODE_HEIGHT / 2, lineColor:ToRaylib(0.3))
		end
		-- Determine visual state
		local isHovered = isMouseInRect(rectData, mousePos)
		local isSelected = Selection.IsSelected(instance)
		local isDragSource = isDragging and dragInstance == instance
		local isDropTarget = isDragging and dragTargetInstance == instance
		local transparency = isSelected and 0 or (isDragSource and 0.6 or (isHovered and 0.5 or 1))
		local color = isSelected and Color3.new(0, 0.533333, 1)
			or (isDropTarget and Color3.new(0, 0.7, 0.3))
			or Color3.new()

		-- Draw node background
		rl.DrawRectangleRounded(
			structs.Rectangle:new(rectData),
			StudioThemeService.SelectedTheme.CornerRadius,
			StudioThemeService.SelectedTheme.CornerRadius,
			color:ToRaylib(transparency)
		)

		-- Record drop animation target position
		if dropAnimInstance == instance and dropAnimStart > 0 then
			dropAnimToX = rectData.x
			dropAnimToY = rectData.y
		end

		if not loadedIcon[instance.ClassName] then
			local svg = KinemiumIconLoader.Get(instance.ClassName .. ".png")
			if svg then
				loadedIcon[instance.ClassName] = KinemiumIconLoader.ToTexture(svg)
			else
				loadedIcon[instance.ClassName] = notfound_tex
			end
		end

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
					and instance
						:GetMetadata("ExplorerIconColor")
						:ToRaylib(instance:GetMetadata("ExplorerIconTransparency"))
				or StudioThemeService.SelectedTheme.ImageColor:ToRaylib(
					StudioThemeService.SelectedTheme.ImageTransparency
				)
		)

		-- Draw text
		rl.DrawTextEx(
			vend,
			instance.Name,
			vector.create(btnX + 28, btnY + 1),
			18,
			1,
			StudioThemeService.SelectedTheme.TextColor:ToRaylib(StudioThemeService.SelectedTheme.TextTransparency)
		)

		if isHovered and not isDragging then
			local addData = { x = toggleX - 50, y = btnY + 2, width = iconSize, height = iconSize }

			rl.DrawTexturePro(
				addIcon.texture,
				structs.Rectangle:new({ x = 0, y = 0, width = addIcon.x, height = addIcon.y }),
				structs.Rectangle:new(addData),
				vector.create(0, 0),
				0,
				StudioThemeService.SelectedTheme.ImageColor:ToRaylib(StudioThemeService.SelectedTheme.ImageTransparency)
			)

			if isMouseInRect(addData, mousePos) and rl.IsMouseButtonReleased(0) == 1 then
				-- Close all other menus
				for key in pairs(addMenuOpen) do
					addMenuOpen[key] = false
				end
				addMenuOpenBool = true
				addMenuOpen[instance] = not addMenuOpen[instance]

				if addMenuOpen[instance] then
					-- Initialize search textbox when menu opens
					addMenuSearchBox:setText(addMenuSearch[instance] or "")
					addMenuScroll[instance] = 0
					addMenuScrollTarget[instance] = 0
				else
					-- Reset search when menu closes
					addMenuSearch[instance] = ""
					addMenuScroll[instance] = 0
					addMenuScrollTarget[instance] = 0
				end

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
					SelectionMenu.set("obj_rect", arect.new(mousePos.x, mousePos.y, 200, 0))
					SelectionMenu:show()
					ContextMenuOpen = true
				else
					SelectionMenu:hide()
					ContextMenuOpen = false
				end
			end
		end

		-- Record drag source on mouse press
		if isHovered and rl.IsMouseButtonPressed(0) == 1 and not addMenuOpenBool and not ContextMenuOpen then
			dragInstance = instance
			dragMouseStart = mousePos
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
				StudioThemeService.SelectedTheme.ImageColor:ToRaylib(StudioThemeService.SelectedTheme.ImageTransparency)
			)

			if isMouseInRect(buttonData, mousePos) and rl.IsMouseButtonReleased(0) == 1 then
				expanded[instance] = not expanded[instance]
			end
		end
	end

	yOffset = yOffset + NODE_HEIGHT + 2

	local shouldExpand = expanded[instance]
		or (isSearching and matchesSearch(instance, searchQuery, searchFilterMode))
		or hasSelectedDescendant(instance)

	if hasChildren and shouldExpand then
		for i, child in ipairs(children) do
			local isLastChild = i == #children
			DrawTree(child, indent + 1, winX, winY, winWidth, isLastChild)
		end
	end
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

window.focused = function(window)
	_G.IsHoveringOnWindow = true
end

window.unfocused = function(window)
	_G.IsHoveringOnWindow = false
end

local renderer = KinemiumRaylib.GetRenderer()

renderer.Pool.new("2d", function(data)
	local dt = rl.GetFrameTime()

	if game.Context == Enum.GameContext.Editor then
		window.update(dt)
		window.draw(dt, StudioThemeService.SelectedTheme, renderer.Lib2d)
	end

	if rl.IsWindowResized() == 1 then
		explorerWindow.x = frame.AbsolutePosition.X
		explorerWindow.y = frame.AbsolutePosition.Y
		explorerWindow.width = frame.AbsoluteSize.X
		explorerWindow.height = frame.AbsoluteSize.Y
	end

	if activeAddMenu then
		drawAdditionMenu(activeAddMenu.instance, rl.GetMousePosition(), activeAddMenu.btnY, activeAddMenu.toggleX)
	end
end, 9999)

explorerWindow.stepped = function(windowData)
	if windowData.title ~= "Explorer" then
		return
	end

	frame.Position = Theme.WindowConfig.Explorer.position
	frame.AnchorPoint = Theme.WindowConfig.Explorer.anchorPoint
	frame.Size = Theme.WindowConfig.Explorer.size

	searchQuery = searchBox:getText() or ""
	isSearching = #searchQuery > 0

	local dt = rl.GetFrameTime()

	windowData.Scrollable = true

	hoverspring:step(dt)

	windowObject = windowData
	yOffset = 0
	if windowData._scrollArea and windowData._scrollArea.get then
		scrollOffset = windowData._scrollArea.get("scrollOffset") or 0
	else
		scrollOffset = 0
	end

	if windowData._scrollArea then
		windowData._scrollArea.set("enabled", not addMenuOpenBool and not isDragging)
	end

	-- Drag and drop lifecycle
	local mousePos = rl.GetMousePosition()

	-- Start drag when mouse moves beyond threshold while held
	if not isDragging and dragInstance and rl.IsMouseButtonDown(0) == 1 then
		local dx = mousePos.x - dragMouseStart.x
		local dy = mousePos.y - dragMouseStart.y
		if math.sqrt(dx * dx + dy * dy) > DRAG_THRESHOLD then
			if dragInstance.BaseClass ~= "Singleton" then
				isDragging = true
			end
		end
	end

	-- End drag on mouse release
	if isDragging and rl.IsMouseButtonReleased(0) == 1 then
		if dragInstance and dragTargetInstance then
			local ok = pcall(function()
				dragInstance.Parent = dragTargetInstance
			end)
			if ok then
				expanded[dragTargetInstance] = true
				dropAnimInstance = dragInstance
				dropAnimStart = os.clock()
				dropAnimFromX = mousePos.x - NODE_WIDTH / 2
				dropAnimFromY = mousePos.y - NODE_HEIGHT / 2
				dropAnimToX = nil
				dropAnimToY = nil
			end
		end
		isDragging = false
		dragInstance = nil
		dragMouseStart = nil
		dragTargetInstance = nil
	end

	-- Clear drag state if mouse button released without dragging
	if not isDragging and dragInstance and rl.IsMouseButtonReleased(0) == 1 then
		dragInstance = nil
		dragMouseStart = nil
	end

	-- Update drop animation
	if dropAnimStart > 0 then
		local elapsed = os.clock() - dropAnimStart
		if elapsed > DROP_ANIM_DURATION then
			dropAnimStart = 0
			dropAnimInstance = nil
		end
	end
	local titleBarH = windowData._titleBarH or 28
	local windowRect = {
		x = windowData.x,
		y = windowData.y,
		width = windowData.width,
		height = windowData.height,
	}

	local boxWidth = windowRect.width * 0.95
	local boxX = windowRect.x + (windowRect.width - boxWidth) * 0.5
	local filterBtnSize = 30
	local filterGap = 8
	local searchWidth = boxWidth - filterBtnSize - filterGap

	local contentY = windowData.y + titleBarH
	rl.BeginScissorMode(windowData.x, contentY, windowData.width, windowData.height - titleBarH)

	searchBox:drawWithExtras(boxX, windowRect.y + 35, searchWidth, 30)
	if not searchFilterButton then
		searchFilterButton = gui.imageButton({
			image = filterIcon,
			imageScale = 0.7,
			backgroundColor = Theme.SecondaryBackgroundColor,
			hoverColor = Theme.BackgroundColor,
			rounded = { 0, StudioThemeService.SelectedTheme.CornerRadius },
			pressColor = Theme.BackgroundColor,
			onClick = function()
				searchFilterMenuVisible = not searchFilterMenuVisible
				if searchFilterMenuVisible then
					local menuW = 180
					local itemH = 24
					local menuH = (#searchFilterOptions * itemH) + 8
					local menuX = boxX + searchWidth + filterGap
					local menuY = windowRect.y + 35 + filterBtnSize + 6
					local maxX = windowRect.x + windowRect.width - menuW - 4
					local maxY = windowRect.y + windowRect.height - menuH - 4
					menuX = math.max(windowRect.x + 4, math.min(menuX, maxX))
					menuY = math.max(windowRect.y + 4, math.min(menuY, maxY))
					searchFilterMenu.set("obj_rect", arect.new(menuX, menuY, menuW, 0))
					searchFilterMenu:show()
				else
					searchFilterMenu:hide()
				end
			end,
		})
	end
	searchFilterButton.set(
		"obj_rect",
		arect.new(boxX + searchWidth + filterGap, windowRect.y + 35, filterBtnSize, filterBtnSize)
	)
	searchFilterButton.render(dt)

	if not searchFilterMenu then
		local items = {}
		for _, opt in ipairs(searchFilterOptions) do
			table.insert(items, {
				label = opt,
				onClick = function()
					searchFilterMode = opt
					searchFilterMenuVisible = false
					searchFilterMenu:hide()
				end,
			})
		end
		searchFilterMenu = gui.menu({
			x = 0,
			y = 0,
			width = 180,
			Font = vend,
			backgroundColor = Theme.SecondaryBackgroundColor,
			textColor = Theme.TextColor,
			hoverColor = Theme.BackgroundColor,
			items = items,
		})
		searchFilterMenu:hide()
	end

	local services = getServicesInOrder()
	-- Switch scissor mode to tree region to prevent overlapping the search bar and going out of bounds
	local treeScissorY = windowData.y + 70
	local treeScissorH = windowData.height - 80
	rl.BeginScissorMode(windowData.x, treeScissorY, windowData.width, treeScissorH)

	for _, child in ipairs(services) do
		DrawTree(child, 0, windowData.x - 50, windowData.y + 60, windowData.width, false)
	end

	rl.EndScissorMode()

	-- Draw dragged item following mouse
	if isDragging and dragInstance then
		local dragW = NODE_WIDTH
		local dragH = NODE_HEIGHT
		local dragX = mousePos.x - dragW / 2
		local dragY = mousePos.y - dragH / 2

		rl.DrawRectangleRounded(
			structs.Rectangle:new({ x = dragX, y = dragY, width = dragW, height = dragH }),
			StudioThemeService.SelectedTheme.CornerRadius,
			StudioThemeService.SelectedTheme.CornerRadius,
			Color3.new(0, 0.533333, 1):ToRaylib(0.25)
		)

		local icon = loadedIcon[dragInstance.ClassName] or notfound_tex
		local iconSize = dragH - 4
		rl.DrawTexturePro(
			icon.texture,
			structs.Rectangle:new({ x = 0, y = 0, width = icon.x, height = icon.y }),
			structs.Rectangle:new({ x = dragX + 2, y = dragY + 2, width = iconSize, height = iconSize }),
			vector.create(0, 0),
			0,
			StudioThemeService.SelectedTheme.ImageColor:ToRaylib(StudioThemeService.SelectedTheme.ImageTransparency)
		)

		rl.DrawTextEx(
			vend,
			dragInstance.Name,
			vector.create(dragX + 28, dragY + 5),
			18,
			1,
			StudioThemeService.SelectedTheme.TextColor:ToRaylib(StudioThemeService.SelectedTheme.TextTransparency)
		)
	end

	-- Draw drop animation (lerp from drop position to tree position)
	if dropAnimStart > 0 and dropAnimToX and dropAnimToY and dropAnimInstance then
		local progress = math.min((os.clock() - dropAnimStart) / DROP_ANIM_DURATION, 1)
		local t = progress * progress * (3 - 2 * progress)
		local animW = NODE_WIDTH
		local animH = NODE_HEIGHT
		local animX = dropAnimFromX + (dropAnimToX - dropAnimFromX) * t
		local animY = dropAnimFromY + (dropAnimToY - dropAnimFromY) * t
		local bgAlpha = 0.3 + 0.7 * progress
		local fgAlpha = progress

		rl.DrawRectangleRounded(
			structs.Rectangle:new({ x = animX, y = animY, width = animW, height = animH }),
			StudioThemeService.SelectedTheme.CornerRadius,
			StudioThemeService.SelectedTheme.CornerRadius,
			Color3.new(0, 0.533333, 1):ToRaylib(bgAlpha)
		)

		local icon = loadedIcon[dropAnimInstance.ClassName] or notfound_tex
		local iconSize = animH - 4
		rl.DrawTexturePro(
			icon.texture,
			structs.Rectangle:new({ x = 0, y = 0, width = icon.x, height = icon.y }),
			structs.Rectangle:new({ x = animX + 2, y = animY + 2, width = iconSize, height = iconSize }),
			vector.create(0, 0),
			0,
			Color3.new(1, 1, 1):ToRaylib(fgAlpha)
		)

		rl.DrawTextEx(
			vend,
			dropAnimInstance.Name,
			vector.create(animX + 28, animY + 5),
			18,
			1,
			Color3.new(1, 1, 1):ToRaylib(fgAlpha)
		)
	end

	windowData._contentHeight = yOffset + 100

	SelectionMenu.render(dt)

	-- Close addition menu when clicking outside
	if addMenuOpenBool and rl.IsMouseButtonPressed(0) == 1 then
		local mousePos = rl.GetMousePosition()
		if addMenuRect and not isMouseInRect(addMenuRect, mousePos) then
			for key in pairs(addMenuOpen) do
				addMenuOpen[key] = false
			end
			addMenuOpenBool = false
			addMenuRect = nil
			activeAddMenu = nil
		end
	end

	-- Close selection/context menu when clicking outside
	if ContextMenuOpen and rl.IsMouseButtonReleased(0) == 1 then
		local obj_rect = SelectionMenu.get("obj_rect")
		if obj_rect and arect.MouseIsOutsideRect(obj_rect) then
			ContextMenuOpen = false
			SelectionMenu:hide()
		end
	end

	local ctrl = rl.IsKeyDown(341) == 1 or rl.IsKeyDown(345) == 1

	if rl.IsKeyReleased(261) == 1 then
		Selection.Clear()
	end

	-- Handle cloning
	if ctrl then
		game.Stop3DInput = true

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

	vend = KinemiumFontService.GetDefaultFont()

	if searchFilterMenuVisible then
		searchFilterMenu.render(dt)
	end
end
