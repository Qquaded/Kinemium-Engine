repeat
	task.wait()
until ishared.CoreGuiSignal

repeat
	task.wait()
until ishared.ReactPointer

local CoreGui = game:GetService("CoreGui")
local KinemiumRaylib = game:GetService("KinemiumRaylib")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local KinemiumFontService = game:GetService("KinemiumFontService")
local UserInputService = game:GetService("UserInputService")

repeat
	task.wait()
until CoreGui:FindFirstChild("KinemiumCoreGui")

if not RunService:IsClient() then
	return
end

local screenGui = CoreGui.KinemiumCoreGui

local sign = ishared.CoreGuiSignal
local manager = ishared.ReactPointer
local renderer = KinemiumRaylib.renderer

local vend = KinemiumFontService.GetDefaultFontSmall()

local function runtime(key, fallback)
	local value = manager:get("#runtime", key)
	if value == nil then
		return fallback
	end
	return value
end

local function bindRuntime(object, props)
	for property, key in pairs(props) do
		manager:bind(object, property, "#runtime." .. key)
	end
end

local function bindCorner(corner, radiusKey)
	radiusKey = radiusKey or "corner"
	bindRuntime(corner, {
		CornerRadius = radiusKey,
		TopLeftRadius = radiusKey,
		TopRightRadius = radiusKey,
		BottomLeftRadius = radiusKey,
		BottomRightRadius = radiusKey,
	})
end

local function springTarget(object, props)
	Spring.target(object, runtime("damping", 2), runtime("frequency", 5), props)
end

local function runtimeCellFont(fallback)
	local runtimeFont = runtime("font", Enum.Font.DefaultEngineFont)
	if type(runtimeFont) == "table" and runtimeFont.Value and renderer and renderer.Font and renderer.Font.Get then
		local resolvedFont = renderer.Font.Get(runtimeFont.Value)
		if resolvedFont then
			return resolvedFont
		end
	end
	return fallback
end

local function newPlayerCell(playerObject: Player)
	return {
		name = playerObject.Name,
		description = tostring(playerObject.UserId),
		font = runtimeCellFont(vend),
		backgroundColor = runtime("secondarybackground", Color3.new(0, 0, 0)),
		textColor = runtime("text", Color3.new(1, 1, 1)),
		descriptionColor = runtime("mutedtext", Color3.new(0.85, 0.85, 0.85)),
		value = true,
	}
end

local function applyCellTheme(sections)
	for _, entries in pairs(sections) do
		if type(entries) ~= "table" then
			continue
		end
		entries.titleFont = runtimeCellFont(vend)
		for _, cell in ipairs(entries) do
			if type(cell) ~= "table" then
				continue
			end
			cell.font = runtimeCellFont(vend)
			cell.backgroundColor = runtime("secondarybackground", Color3.new(0, 0, 0))
			cell.textColor = runtime("text", Color3.new(1, 1, 1))
			cell.descriptionColor = runtime("mutedtext", Color3.new(0.85, 0.85, 0.85))
		end
	end
end

local function cloneSections(sections)
	local cloned = {}
	for name, entries in pairs(sections) do
		cloned[name] = entries
	end
	return cloned
end

sign:Fire("MakeWindow", "Players", function(window)
	local cellList = Instance.new("UICellList")
	cellList.Parent = window
	cellList.Size = UDim2.new(1, -20, 1, 0)
	cellList.Sections = {
		Players = {},
	}
	applyCellTheme(cellList.Sections)

	local localSections = {
		Players = {},
	}

	local function rebuildLocalSections()
		local playerCells = localSections.Players
		applyCellTheme(localSections)
		cellList.Sections = cloneSections(localSections)
	end

	Players.ChildAdded:Connect(function(new)
		if new:IsA("Player") then
			table.insert(localSections.Players, newPlayerCell(new))
			rebuildLocalSections()
		end
	end)

	Players.ChildRemoved:Connect(function(old)
		if old:IsA("Player") then
			for i, cell in ipairs(localSections.Players) do
				if cell.description == tostring(old.UserId) then
					table.remove(localSections.Players, i)
					break
				end
			end
			rebuildLocalSections()
		end
	end)

	for _, player in pairs(Players:GetChildren()) do
		table.insert(localSections.Players, newPlayerCell(player))
	end

	rebuildLocalSections()

	manager:subscribe("#runtime", "background", rebuildLocalSections)
	manager:subscribe("#runtime", "secondarybackground", rebuildLocalSections)
	manager:subscribe("#runtime", "text", rebuildLocalSections)
	manager:subscribe("#runtime", "mutedtext", rebuildLocalSections)
	manager:subscribe("#runtime", "font", rebuildLocalSections)
end)

local tabToggle = true

local canvasGroup = Instance.new("CanvasGroup")
canvasGroup.Size = UDim2.new(0, 250, 0, 400)
canvasGroup.AnchorPoint = Vector2.new(1, 0)
canvasGroup.Position = UDim2.new(1, -10, 0, 10)
canvasGroup.BackgroundTransparency = 1
canvasGroup.Parent = screenGui

local scrollList = Instance.new("ScrollingFrame")
scrollList.Size = UDim2.new(1, 0, 1, 0)
scrollList.AnchorPoint = Vector2.new(0.5, 0.5)
scrollList.Position = UDim2.new(0.5, 0, 0.5, 0)
scrollList.BackgroundColor3 = Color3.new(0, 0, 0)
scrollList.BackgroundTransparency = 1
scrollList.Parent = canvasGroup
bindRuntime(scrollList, {
	BackgroundColor3 = "background",
})

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 15)
corner.Parent = scrollList
bindCorner(corner, "corner")

local shadow = Instance.new("UIShadow")
shadow.Transparency = 1
shadow.Parent = scrollList
bindRuntime(shadow, {
	Color = "shadow",
})

local padding = Instance.new("UIPadding")
padding.Padding = UDim2.new(0, 10, 0, 10)
padding.Parent = scrollList

local cellList = Instance.new("UICellList")
cellList.Size = UDim2.new(0.95, 0, 0.95, 0)
cellList.AnchorPoint = Vector2.new(0.5, 0.5)
cellList.Position = UDim2.new(0.5, 0, 0.5, 0)
cellList.Sections = {
	Players = {},
}
cellList.Parent = scrollList

local function refreshSidebarSections()
	applyCellTheme(cellList.Sections)
	cellList.Sections = cloneSections(cellList.Sections)
end

local function showPlayerList()
	springTarget(scrollList, {
		BackgroundTransparency = runtime("bgtransparency", 0.3),
	})
	springTarget(shadow, {
		Transparency = runtime("shadowtransparency", 0.9),
	})
end

local function hidePlayerList()
	springTarget(scrollList, {
		BackgroundTransparency = runtime("windowhiddentransparency", 1),
	})
	springTarget(shadow, {
		Transparency = 1,
	})
end

local playerListHovered = false

scrollList.MouseEnter:Connect(function(a0: number, a1: number)
	playerListHovered = true
	showPlayerList()
end)

scrollList.MouseLeave:Connect(function(a0: number, a1: number)
	playerListHovered = false
	hidePlayerList()
end)

local inMenu = false

sign:Connect(function(arg, window)
	if arg == "OpenedSettings" then
		inMenu = true
		springTarget(canvasGroup, { Position = UDim2.new(1, -25, 0, 25), GroupTransparency = 1 })
	elseif arg == "ClosedSettings" then
		inMenu = false
		springTarget(canvasGroup, { Position = UDim2.new(1, -10, 0, 10), GroupTransparency = 0 })
	end
end)

Players.ChildAdded:Connect(function(new)
	if new:IsA("Player") then
		table.insert(cellList.Sections.Players, newPlayerCell(new))
		scrollList.CanvasSize += 100
		refreshSidebarSections()
	end
end)

Players.ChildRemoved:Connect(function(old)
	if old:IsA("Player") then
		for i, cell in pairs(cellList.Sections.Players) do
			if cell.description == tostring(old.UserId) then
				table.remove(cellList.Sections.Players, i)
				break
			end
		end
	end
	scrollList.CanvasSize -= 100
	refreshSidebarSections()
end)

for _, player in pairs(Players:GetChildren()) do
	table.insert(cellList.Sections.Players, newPlayerCell(player))
end

refreshSidebarSections()

manager:subscribe("#runtime", "background", refreshSidebarSections)
manager:subscribe("#runtime", "secondarybackground", refreshSidebarSections)
manager:subscribe("#runtime", "text", refreshSidebarSections)
manager:subscribe("#runtime", "mutedtext", refreshSidebarSections)
manager:subscribe("#runtime", "font", refreshSidebarSections)
manager:subscribe("#runtime", "bgtransparency", function()
	if playerListHovered then
		showPlayerList()
	end
end)
manager:subscribe("#runtime", "shadowtransparency", function()
	if playerListHovered then
		showPlayerList()
	end
end)
manager:subscribe("#runtime", "damping", function()
	if playerListHovered then
		showPlayerList()
	else
		hidePlayerList()
	end
end)
manager:subscribe("#runtime", "frequency", function()
	if playerListHovered then
		showPlayerList()
	else
		hidePlayerList()
	end
end)

RunService.RenderStepped:Connect(function(a0: number)
	if UserInputService:IsKeyReleased(Enum.KeyCode.Tab) then
		tabToggle = not tabToggle
		if tabToggle then
			if inMenu then
				return
			end
			springTarget(canvasGroup, { Position = UDim2.new(1, -10, 0, 10), GroupTransparency = 0 })
		else
			springTarget(canvasGroup, { Position = UDim2.new(1, -25, 0, 25), GroupTransparency = 1 })
		end
	end
end)
