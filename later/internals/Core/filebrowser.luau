local RunService = game:GetService("RunService")
if RunService:IsServer() then
	return
end

local KinemiumRaylib = game:GetService("KinemiumRaylib")
local KinemiumIconLoader = game:GetService("KinemiumIconLoader")
local KinemiumFontService = game:GetService("KinemiumFontService")
local Players = game:GetService("Players")
local StudioThemeService = game:GetService("StudioThemeService")

if game.Context ~= Enum.GameContext.Editor or FlagExists("cli") or FlagExists("headless") then
	return
end

local vend = KinemiumFontService.GetDefaultFont()
local boldFont = KinemiumFontService.GetBoldFont()
local LocalPlayer = Players.LocalPlayer
local Theme = StudioThemeService.SelectedTheme

local spring = import("@kispring")
local aereon = import("@Aereon")
local gui = aereon.gui
local arect = require("@arect")
local Filesystem = require("@filesystem")
local interface = require("@RaylibAdapter")
local rl = interface.lib
local structs = interface.structs

local EngineSignal = game.EngineSignal

local DOUBLE_CLICK_THRESHOLD = 0.3
local NODE_HEIGHT = 25
local NODE_WIDTH = 330
local PADDING = 10
local INDENT_SIZE = 20
local TOGGLE_SIZE = 20
local SEARCH_HEIGHT = 30
local INLINE_EDIT_HEIGHT = 25

KinemiumIconLoader.new("Folder", "./src/assets/images/icons/Folder.png")
KinemiumIconLoader.new("FolderOpen", "./src/assets/images/icons/FolderOpen.png")
KinemiumIconLoader.new("File", "./src/assets/images/icons/File.png")
KinemiumIconLoader.new("ArrowRight", "./src/assets/images/icons/ArrowRight.png")
KinemiumIconLoader.new("ArrowDown", "./src/assets/images/icons/ArrowDown.png")

local notfound_tex = KinemiumIconLoader.ToTexture(KinemiumIconLoader.Get("NotFound.png"))
local folderTex = KinemiumIconLoader.ToTexture(KinemiumIconLoader.Get("Folder")) or notfound_tex
local folderOpenTex = KinemiumIconLoader.ToTexture(KinemiumIconLoader.Get("FolderOpen")) or folderTex
local fileTex = KinemiumIconLoader.ToTexture(KinemiumIconLoader.Get("File")) or notfound_tex
local ArrowRight = KinemiumIconLoader.ToTexture(KinemiumIconLoader.Get("ArrowRight"))
local ArrowDown = KinemiumIconLoader.ToTexture(KinemiumIconLoader.Get("ArrowDown"))

local loadedExtIcon = {}
local function getFileIcon(name)
	local ext = name:match("%.([%w_]+)$")
	if not ext then
		return fileTex
	end
	ext = ext:lower()
	if loadedExtIcon[ext] == nil then
		local svg = KinemiumIconLoader.Get(ext .. ".png")
		loadedExtIcon[ext] = svg and KinemiumIconLoader.ToTexture(svg) or fileTex
	end
	return loadedExtIcon[ext] or fileTex
end

local function joinPath(a, b)
	if a:sub(-1) == "/" then
		return a .. b
	end
	return a .. "/" .. b
end

local function parentOf(path)
	local trimmed = path:gsub("/+$", "")
	local dir = trimmed:match("^(.*)[/]([^/]+)$")
	return dir or ""
end

local function nameOf(path)
	local trimmed = path:gsub("/+$", "")
	return trimmed:match("([^/]+)$") or trimmed
end

-- ============================== Filesystem access (cached) ==============================

local entriesCache = {} -- path -> { {name=, path=, kind=}, ... }
local kindCache = {}

local function getKind(path)
	if kindCache[path] then
		return kindCache[path]
	end
	local ok, kind = pcall(Filesystem.kind, path)
	kind = (ok and kind) or "file"
	kindCache[path] = kind
	return kind
end

local function getEntries(path)
	if entriesCache[path] then
		return entriesCache[path]
	end

	local ok, raw = pcall(Filesystem.entries, path)
	local result = {}
	if ok and raw then
		for _, e in ipairs(raw) do
			local full = joinPath(path, e.name)
			table.insert(result, { name = e.name, path = full, kind = getKind(full) })
		end
		table.sort(result, function(a, b)
			if a.kind ~= b.kind then
				return a.kind == "directory"
			end
			return a.name:lower() < b.name:lower()
		end)
	end

	entriesCache[path] = result
	return result
end

local function invalidate(path)
	entriesCache[path] = nil
	kindCache[path] = nil
end

local function refreshRecursive(path)
	invalidate(path)
	-- drop any cached children under this path too, so stale nested state
	-- doesn't linger after a rename/move/delete
	for cachedPath in pairs(entriesCache) do
		if cachedPath:sub(1, #path + 1) == path .. "/" then
			entriesCache[cachedPath] = nil
			kindCache[cachedPath] = nil
		end
	end
end

-- ============================== Root setup ==============================

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "File Browser"
screenGui.Parent = LocalPlayer.PlayerGui

local frame = Instance.new("Frame")
frame.Position = Theme.WindowConfig.FileBrowser.position
frame.AnchorPoint = Theme.WindowConfig.FileBrowser.anchorPoint
frame.Size = Theme.WindowConfig.FileBrowser.size
frame.BackgroundTransparency = 1
frame.Parent = screenGui

repeat
	task.wait()
until frame.AbsolutePosition and frame.AbsoluteSize

local window = aereon.window(game)
local fileBrowserWindow = window.create({
	title = "File Browser",
	x = frame.AbsolutePosition.X,
	y = frame.AbsolutePosition.Y,
	width = frame.AbsoluteSize.X,
	height = frame.AbsoluteSize.Y,
})

window.focused = function()
	_G.IsHoveringOnWindow = true
end

window.unfocused = function()
	_G.IsHoveringOnWindow = false
end

local textbox = aereon.textbox(Theme, game)

local searchBox = textbox.new({
	multiline = false,
	placeholder = "Search files..",
	fontSize = 16,
	font = vend,
	maxLength = 64,
	cornerRadius = Theme.CornerRadius,
	BorderTransparency = 1,
	TextColor = Theme.TextColor:ToRaylib(Theme.TextTransparency),
	padding = 5,
})

local renameBox = textbox.new({
	multiline = false,
	placeholder = "",
	fontSize = 16,
	font = vend,
	maxLength = 128,
	cornerRadius = Theme.CornerRadius,
	BorderTransparency = 1,
	TextColor = Theme.TextColor:ToRaylib(Theme.TextTransparency),
	padding = 4,
})

local expanded = {} -- path -> bool
local hoverAnim = {} -- path -> 0..1
local lastClickTime = {} -- path -> os.clock()
local selectedPaths = {} -- path -> true
local lastClickedPath = nil

local isDragging = false
local dragPath = nil
local dragMouseStart = nil
local dragTargetPath = nil
local DRAG_THRESHOLD = 20

local ContextMenuOpen = false
local contextTargetPath = nil
local contextTargetKind = nil

-- inline rename / create state
local renamingPath = nil -- path currently being renamed
local creatingIn = nil -- directory path a new entry is being created in
local creatingKind = nil -- "file" | "directory"

local yOffset = 0
local scrollOffset = 0
local windowObject = nil

local searchQuery = ""
local isSearching = false

local function commitRename()
	if renamingPath then
		local newName = renameBox:getText() or ""
		newName = newName:gsub("^%s+", ""):gsub("%s+$", "")
		if newName ~= "" and newName ~= nameOf(renamingPath) then
			local newPath = joinPath(parentOf(renamingPath), newName)
			pcall(Filesystem.rename, renamingPath, newPath)
			refreshRecursive(parentOf(renamingPath))
			if selectedPaths[renamingPath] then
				selectedPaths[renamingPath] = nil
				selectedPaths[newPath] = true
			end
		end
	end
	renamingPath = nil
	renameBox:setText("")
end

local function commitCreate()
	if creatingIn then
		local newName = renameBox:getText() or ""
		newName = newName:gsub("^%s+", ""):gsub("%s+$", "")
		if newName ~= "" then
			local newPath = joinPath(creatingIn, newName)
			if creatingKind == "directory" then
				pcall(Filesystem.makeDir, newPath)
			else
				pcall(Filesystem.writeFile, newPath, "")
			end
			refreshRecursive(creatingIn)
			expanded[creatingIn] = true
		end
	end
	creatingIn = nil
	creatingKind = nil
	renameBox:setText("")
end

local function deleteSelection()
	for path in pairs(selectedPaths) do
		local kind = getKind(path)
		if kind == "directory" then
			pcall(Filesystem.removeDir, path)
		else
			pcall(Filesystem.remove, path)
		end
		refreshRecursive(parentOf(path))
	end
	selectedPaths = {}
end

local ContextMenu = gui.menu({
	x = 0,
	y = 0,
	width = 200,
	Font = vend,
	backgroundColor = Theme.SecondaryBackgroundColor,
	textColor = Theme.TextColor,
	rounded = { 0, Theme.CornerRadius },
	hoverColor = Theme.BackgroundColor,
	items = {
		{
			label = "New File",
			appearif = function()
				return contextTargetKind == "directory"
			end,
			onClick = function()
				creatingIn = contextTargetPath
				creatingKind = "file"
				expanded[contextTargetPath] = true
				renameBox:setText("")
			end,
		},
		{
			label = "New Folder",
			appearif = function()
				return contextTargetKind == "directory"
			end,
			onClick = function()
				creatingIn = contextTargetPath
				creatingKind = "directory"
				expanded[contextTargetPath] = true
				renameBox:setText("")
			end,
		},
		{
			label = "Rename",
			appearif = function()
				return contextTargetPath ~= nil
			end,
			onClick = function()
				renamingPath = contextTargetPath
				renameBox:setText(nameOf(contextTargetPath))
			end,
		},
		{
			label = "Delete",
			appearif = function()
				return contextTargetPath ~= nil
			end,
			onClick = function()
				if not selectedPaths[contextTargetPath] then
					selectedPaths = { [contextTargetPath] = true }
				end
				deleteSelection()
			end,
		},
		{
			label = "Refresh",
			appearif = function()
				return contextTargetKind == "directory"
			end,
			onClick = function()
				refreshRecursive(contextTargetPath)
			end,
		},
		{
			label = "Copy Path",
			appearif = function()
				return contextTargetPath ~= nil
			end,
			onClick = function()
				pcall(function()
					rl.SetClipboardText(contextTargetPath)
				end)
			end,
		},
		{
			label = "Reveal in File Explorer",
			appearif = function()
				return contextTargetPath ~= nil
			end,
			onClick = function()
				EngineSignal:Fire("RevealInOS", contextTargetPath)
			end,
		},
	},
})
ContextMenu:hide()

local function openContextMenu(path, kind, mousePos)
	contextTargetPath = path
	contextTargetKind = kind
	ContextMenu.set("obj_rect", arect.new(mousePos.x, mousePos.y, 200, 0))
	ContextMenu:show()
	ContextMenuOpen = true
end

local function isMouseInRect(rect, mousePos)
	return mousePos.x >= rect.x
		and mousePos.x <= rect.x + rect.width
		and mousePos.y >= rect.y
		and mousePos.y <= rect.y + rect.height
end

local function isRectVisible(rect, windowRect)
	return rect.x + rect.width >= windowRect.x
		and rect.x <= windowRect.x + windowRect.width
		and rect.y + rect.height >= windowRect.y
		and rect.y <= windowRect.y + windowRect.height
end

-- ============================== Search ==============================

local function matchesSearch(path, kind, query)
	if kind == "directory" then
		for _, child in ipairs(getEntries(path)) do
			if matchesSearch(child.path, child.kind, query) then
				return true
			end
		end
		return false
	end
	return string.find(nameOf(path):lower(), query, 1, true) ~= nil
end

-- ============================== Selection handling ==============================

local function handleSelection(path, rectData, mousePos)
	if
		not isMouseInRect(rectData, mousePos)
		or rl.IsMouseButtonPressed(0) ~= 1
		or ContextMenuOpen
		or isDragging
		or renamingPath
		or creatingIn
	then
		return
	end

	local currentTime = os.clock()
	local ctrl = rl.IsKeyDown(341) == 1 or rl.IsKeyDown(345) == 1
	local shift = rl.IsKeyDown(340) == 1 or rl.IsKeyDown(344) == 1

	if lastClickTime[path] and (currentTime - lastClickTime[path]) < DOUBLE_CLICK_THRESHOLD then
		lastClickTime[path] = nil
		if getKind(path) == "directory" then
			expanded[path] = not expanded[path]
		else
			EngineSignal:Fire("OpenFile", path)
		end
		return
	end
	lastClickTime[path] = currentTime

	if shift and lastClickedPath and parentOf(path) == parentOf(lastClickedPath) then
		local siblings = getEntries(parentOf(path))
		local startIndex, endIndex
		for i, s in ipairs(siblings) do
			if s.path == lastClickedPath then
				startIndex = i
			end
			if s.path == path then
				endIndex = i
			end
		end
		if startIndex and endIndex then
			if startIndex > endIndex then
				startIndex, endIndex = endIndex, startIndex
			end
			for i = startIndex, endIndex do
				selectedPaths[siblings[i].path] = true
			end
		end
	elseif ctrl then
		selectedPaths[path] = not selectedPaths[path] or nil
	else
		selectedPaths = { [path] = true }
		lastClickedPath = path
	end
end

local function DrawFileTree(path, kind, indent, winX, winY, winWidth, isLastChild)
	if isSearching and not matchesSearch(path, kind, searchQuery) then
		return
	end
	if isDragging and path == dragPath then
		return
	end

	local hasChildren = kind == "directory"

	local btnX = winX + 25 + winWidth - NODE_WIDTH - PADDING + (indent * INDENT_SIZE)
	local btnY = winY + 10 + yOffset - scrollOffset
	local rectData = { x = btnX, y = btnY, width = NODE_WIDTH, height = NODE_HEIGHT }

	local mousePos = rl.GetMousePosition()
	local treeTop = winY + 10
	local treeHeight = (windowObject and windowObject.height or 600) - 80
	local windowRect = { x = winX, y = treeTop, width = winWidth, height = treeHeight }
	local isVisible = isRectVisible(rectData, windowRect)

	if isDragging and dragPath ~= path and kind == "directory" and path ~= dragPath then
		-- disallow dropping a folder into its own descendant
		local isDescendant = path:sub(1, #dragPath + 1) == dragPath .. "/"
		if not isDescendant and isMouseInRect(rectData, mousePos) then
			dragTargetPath = path
		end
	end

	local isRenamingThis = renamingPath == path
	local dt = rl.GetFrameTime()

	if isVisible then
		if indent > 0 then
			local lineX = btnX - INDENT_SIZE / 2
			local lineColor = Theme.SecondaryTextColor
			lineColor = Color3.new(lineColor.R * 0.5, lineColor.G * 0.5, lineColor.B * 0.5)
			local lineEndY = isLastChild and (btnY + NODE_HEIGHT / 2) or (btnY + NODE_HEIGHT)
			rl.DrawLine(lineX, btnY, lineX, lineEndY, lineColor:ToRaylib(0.3))
			rl.DrawLine(lineX, btnY + NODE_HEIGHT / 2, btnX - 2, btnY + NODE_HEIGHT / 2, lineColor:ToRaylib(0.3))
		end

		local isHovered = isMouseInRect(rectData, mousePos)
		local isSelected = selectedPaths[path] == true
		local isDragSource = isDragging and dragPath == path
		local isDropTarget = isDragging and dragTargetPath == path

		hoverAnim[path] = hoverAnim[path] or 0
		local hoverTarget = isHovered and 1 or 0
		hoverAnim[path] = hoverAnim[path] + (hoverTarget - hoverAnim[path]) * math.min(dt * 15, 1)

		local transparency = isSelected and 0 or (isDragSource and 0.6 or (1 - hoverAnim[path] * 0.5))
		local color = isSelected and Color3.new(0, 0.533333, 1)
			or (isDropTarget and Color3.new(0, 0.7, 0.3))
			or Color3.new()

		rl.DrawRectangleRounded(
			structs.Rectangle:new(rectData),
			Theme.CornerRadius,
			Theme.CornerRadius,
			color:ToRaylib(transparency)
		)

		local icon
		if kind == "directory" then
			icon = expanded[path] and folderOpenTex or folderTex
		else
			icon = getFileIcon(path)
		end
		local iconSize = NODE_HEIGHT - 4
		if icon and icon.texture then
			rl.DrawTexturePro(
				icon.texture,
				structs.Rectangle:new({ x = 0, y = 0, width = icon.x, height = icon.y }),
				structs.Rectangle:new({ x = btnX + 2, y = btnY + 2, width = iconSize, height = iconSize }),
				vector.create(0, 0),
				0,
				Theme.ImageColor:ToRaylib(Theme.ImageTransparency)
			)
		end

		if isRenamingThis then
			renameBox:drawWithExtras(btnX + 28, btnY, NODE_WIDTH - 32, INLINE_EDIT_HEIGHT)
			if rl.IsKeyReleased(257) == 1 then -- Enter
				commitRename()
			elseif rl.IsKeyReleased(256) == 1 then -- Escape
				renamingPath = nil
				renameBox:setText("")
			end
		else
			rl.DrawTextEx(
				vend,
				nameOf(path),
				vector.create(btnX + 28, btnY + 1),
				18,
				1,
				Theme.TextColor:ToRaylib(Theme.TextTransparency)
			)
		end

		if isHovered and not isDragging and not isRenamingThis then
			if rl.IsMouseButtonReleased(1) == 1 then
				if not selectedPaths[path] then
					selectedPaths = { [path] = true }
				end
				openContextMenu(path, kind, mousePos)
			end
		end

		if
			isHovered
			and rl.IsMouseButtonPressed(0) == 1
			and not ContextMenuOpen
			and not isRenamingThis
			and not creatingIn
		then
			dragPath = path
			dragMouseStart = mousePos
		end

		handleSelection(path, rectData, mousePos)

		if hasChildren then
			local toggleTexture = expanded[path] and ArrowDown or ArrowRight
			local buttonData = { x = rectData.x - 25, y = rectData.y, width = TOGGLE_SIZE, height = TOGGLE_SIZE }
			if toggleTexture and toggleTexture.texture then
				rl.DrawTexturePro(
					toggleTexture.texture,
					structs.Rectangle:new({ x = 0, y = 0, width = toggleTexture.x, height = toggleTexture.y }),
					structs.Rectangle:new(buttonData),
					vector.create(0, 0),
					0,
					Theme.ImageColor:ToRaylib(Theme.ImageTransparency)
				)
			end
			if isMouseInRect(buttonData, mousePos) and rl.IsMouseButtonReleased(0) == 1 then
				expanded[path] = not expanded[path]
			end
		end
	end

	yOffset = yOffset + NODE_HEIGHT + 2

	-- inline "creating new file/folder" row, drawn as a child of this directory
	if kind == "directory" and creatingIn == path then
		local rowY = winY + 10 + yOffset - scrollOffset
		local rowX = winX + 25 + winWidth - NODE_WIDTH - PADDING + ((indent + 1) * INDENT_SIZE)
		local icon = creatingKind == "directory" and folderTex or fileTex
		if icon and icon.texture then
			rl.DrawTexturePro(
				icon.texture,
				structs.Rectangle:new({ x = 0, y = 0, width = icon.x, height = icon.y }),
				structs.Rectangle:new({ x = rowX + 2, y = rowY + 2, width = NODE_HEIGHT - 4, height = NODE_HEIGHT - 4 }),
				vector.create(0, 0),
				0,
				Theme.ImageColor:ToRaylib(Theme.ImageTransparency)
			)
		end
		renameBox:drawWithExtras(rowX + 28, rowY, NODE_WIDTH - 32, INLINE_EDIT_HEIGHT)
		if rl.IsKeyReleased(257) == 1 then
			commitCreate()
		elseif rl.IsKeyReleased(256) == 1 then
			creatingIn = nil
			creatingKind = nil
			renameBox:setText("")
		end
		yOffset = yOffset + NODE_HEIGHT + 2
	end

	local shouldExpand = expanded[path] or (isSearching and matchesSearch(path, kind, searchQuery))

	if hasChildren and shouldExpand then
		local children = getEntries(path)
		for i, child in ipairs(children) do
			DrawFileTree(child.path, child.kind, indent + 1, winX, winY, winWidth, i == #children)
		end
	end
end

local renderer = KinemiumRaylib.GetRenderer()

renderer.Pool.new("2d", function(data)
	local dt = rl.GetFrameTime()

	if game.Context == Enum.GameContext.Editor then
		window.update(dt)
		--window.draw(dt, StudioThemeService.SelectedTheme, renderer.Lib2d)
	end

	if rl.IsWindowResized() == 1 then
		fileBrowserWindow.x = frame.AbsolutePosition.X
		fileBrowserWindow.y = frame.AbsolutePosition.Y
		fileBrowserWindow.width = frame.AbsoluteSize.X
		fileBrowserWindow.height = frame.AbsoluteSize.Y
	end
end, 9999)

fileBrowserWindow.stepped = function(windowData)
	if windowData.title ~= "File Browser" then
		return
	end

	Theme = StudioThemeService.SelectedTheme
	vend = KinemiumFontService.GetDefaultFont()

	frame.Position = Theme.WindowConfig.FileBrowser.position
	frame.AnchorPoint = Theme.WindowConfig.FileBrowser.anchorPoint
	frame.Size = Theme.WindowConfig.FileBrowser.size

	local dt = rl.GetFrameTime()
	windowData.Scrollable = true
	windowObject = windowData
	yOffset = 0

	if windowData._scrollArea and windowData._scrollArea.get then
		scrollOffset = windowData._scrollArea.get("scrollOffset") or 0
	else
		scrollOffset = 0
	end
	if windowData._scrollArea then
		windowData._scrollArea.set("enabled", not isDragging and not ContextMenuOpen)
	end

	searchQuery = (searchBox:getText() or ""):lower()
	isSearching = #searchQuery > 0

	local mousePos = rl.GetMousePosition()

	-- drag lifecycle (reorder / move between folders)
	if not isDragging and dragPath and rl.IsMouseButtonDown(0) == 1 then
		local dx = mousePos.x - dragMouseStart.x
		local dy = mousePos.y - dragMouseStart.y
		if math.sqrt(dx * dx + dy * dy) > DRAG_THRESHOLD then
			isDragging = true
		end
	end

	if isDragging and rl.IsMouseButtonReleased(0) == 1 then
		if dragPath and dragTargetPath and dragTargetPath ~= parentOf(dragPath) then
			local newPath = joinPath(dragTargetPath, nameOf(dragPath))
			local ok = pcall(Filesystem.rename, dragPath, newPath)
			if ok then
				refreshRecursive(parentOf(dragPath))
				refreshRecursive(dragTargetPath)
				expanded[dragTargetPath] = true
			end
		end
		isDragging = false
		dragPath = nil
		dragMouseStart = nil
		dragTargetPath = nil
	end

	if not isDragging and dragPath and rl.IsMouseButtonReleased(0) == 1 then
		dragPath = nil
		dragMouseStart = nil
	end

	local titleBarH = windowData._titleBarH or 28
	local windowRect = { x = windowData.x, y = windowData.y, width = windowData.width, height = windowData.height }

	local boxWidth = windowRect.width * 0.95
	local boxX = windowRect.x + (windowRect.width - boxWidth) * 0.5

	local contentY = windowData.y + titleBarH
	rl.BeginScissorMode(windowData.x, contentY, windowData.width, windowData.height - titleBarH)

	searchBox:drawWithExtras(boxX, windowRect.y + 35, boxWidth, SEARCH_HEIGHT)

	local treeScissorY = windowData.y + 80
	local treeScissorH = windowData.height - 90
	rl.BeginScissorMode(windowData.x, treeScissorY, windowData.width, treeScissorH)

	local rootPath = ishared.FolderPath
	if rootPath then
		local rootEntries = getEntries(rootPath)
		for i, entry in ipairs(rootEntries) do
			DrawFileTree(
				entry.path,
				entry.kind,
				0,
				windowData.x + 10,
				windowData.y + 80,
				windowData.width,
				i == #rootEntries
			)
		end
	end

	rl.EndScissorMode()

	if isDragging and dragPath then
		local dragW, dragH = NODE_WIDTH, NODE_HEIGHT
		local dragX = mousePos.x - dragW / 2
		local dragY = mousePos.y - dragH / 2
		rl.DrawRectangleRounded(
			structs.Rectangle:new({ x = dragX, y = dragY, width = dragW, height = dragH }),
			Theme.CornerRadius,
			Theme.CornerRadius,
			Color3.new(0, 0.533333, 1):ToRaylib(0.25)
		)
		local icon = getKind(dragPath) == "directory" and folderTex or getFileIcon(dragPath)
		if icon and icon.texture then
			rl.DrawTexturePro(
				icon.texture,
				structs.Rectangle:new({ x = 0, y = 0, width = icon.x, height = icon.y }),
				structs.Rectangle:new({ x = dragX + 2, y = dragY + 2, width = dragH - 4, height = dragH - 4 }),
				vector.create(0, 0),
				0,
				Theme.ImageColor:ToRaylib(Theme.ImageTransparency)
			)
		end
		rl.DrawTextEx(
			vend,
			nameOf(dragPath),
			vector.create(dragX + 28, dragY + 5),
			18,
			1,
			Theme.TextColor:ToRaylib(Theme.TextTransparency)
		)
	end

	windowData._contentHeight = yOffset + 100

	ContextMenu.render(dt)

	if ContextMenuOpen and rl.IsMouseButtonReleased(0) == 1 then
		local obj_rect = ContextMenu.get("obj_rect")
		if obj_rect and arect.MouseIsOutsideRect(obj_rect) then
			ContextMenuOpen = false
			ContextMenu:hide()
		end
	end

	if rl.IsKeyReleased(261) == 1 then -- Delete key
		if not renamingPath and not creatingIn then
			deleteSelection()
		end
	end

	if rl.IsKeyReleased(292) == 1 then -- F5, refresh everything visible
		invalidate(ishared.FolderPath or "")
		entriesCache = {}
		kindCache = {}
	end
end
