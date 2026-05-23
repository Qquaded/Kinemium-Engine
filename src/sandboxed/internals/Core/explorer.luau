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
local rl = KinemiumRaylib.GetLib()
local structs = KinemiumRaylib.GetStructs()
local addMenuOpenBool = false
local EngineSignal = game.EngineSignal
local hoverspring = spring.new(2, 5)

local notfound_tex = KinemiumIconLoader.ToTexture(KinemiumIconLoader.Get("NotFound.png"))

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
local addMenuScrollTarget = {}
local addMenuSearch = {}
local addMenuExpandedCategories = {}
local addMenuHoverAnim = {}
local lastClickTime = {}
local lastClicked = nil
local activeAddMenu = nil
local yOffset = 0
local windowObject = nil
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

	cornerRadius = 0.5,
	BorderTransparency = 1,
	TextColor = ThemeColors.text,
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
	TextColor = ThemeColors.text,
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
		0.2,
		26,
		Theme.SecondaryBackgroundColor:ToRaylib(0)
	)

	-- Draw title
	rl.DrawTextEx(
		vend,
		"Add Object",
		vector.create(menuX + MENU_PADDING, menuY + MENU_PADDING),
		18,
		1,
		ThemeColors.text
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
			Theme.SecondaryTextColor:ToRaylib(0.4)
		)
		rl.DrawTextEx(
			boldFont,
			labelText,
			vector.create(blockX + indicatorSize.x + gap, centerY - 6),
			11,
			1.5,
			Theme.SecondaryTextColor:ToRaylib(0)
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
						ThemeColors.image
					)
				end

				-- Draw text
				rl.DrawTextEx(
					vend,
					class,
					vector.create(menuX + ADD_MENU_ITEM_HEIGHT + 4, itemY + 3),
					17,
					1,
					ThemeColors.text
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
local function DrawTree(instance, indent, winX, winY, winWidth, isLastChild)
	if instance.Destroyed or instance.ExplorerHidden then
		return
	end
	if isSearching and not matchesSearch(instance, searchQuery, searchFilterMode) then
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
		local transparency = isSelected and 0 or (isHovered and 0.5 or 1)
		local color = isSelected and Color3.new(0, 0.533333, 1) or Color3.new()

		-- Draw node background
		rl.DrawRectangleRounded(structs.Rectangle:new(rectData), 0.5, 20, color:ToRaylib(transparency))

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
				or ThemeColors.image
		)

		-- Draw text
		rl.DrawTextEx(vend, instance.Name, vector.create(btnX + 28, btnY + 5), 18, 1, ThemeColors.text)

		if isHovered then
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
explorerWindow._contentHeight = 0

local renderer = KinemiumRaylib.GetRenderer()
local StudioThemeService = game:GetService("StudioThemeService")

renderer.Pool.new("2d", function(data)
	local dt = rl.GetFrameTime()
	local mainTheme = StudioThemeService.SelectedTheme

	if game.Context == Enum.GameContext.Editor then
		window.update(dt)
		window.draw(dt, mainTheme.aereon)
	end

	if rl.IsWindowResized() == 1 then
		explorerWindow.x = frame.AbsolutePosition.X
		explorerWindow.y = frame.AbsolutePosition.Y
		explorerWindow.width = frame.AbsoluteSize.X
		explorerWindow.height = frame.AbsoluteSize.Y
	end
end)

explorerWindow.stepped = function(windowData)
	if windowData.title ~= "Explorer" then
		return
	end

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
		windowData._scrollArea.set("enabled", not addMenuOpenBool)
	end

	local mousePos = rl.GetMousePosition()
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

	windowData._contentHeight = yOffset + 100

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

	if searchFilterMenuVisible then
		searchFilterMenu.render(dt)
	end
end
