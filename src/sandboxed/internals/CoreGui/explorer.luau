-- devcell

local KinemiumRaylib = game:GetService("KinemiumRaylib")
local KinemiumIconLoader = game:GetService("KinemiumIconLoader")
local KinemiumFontService = game:GetService("KinemiumFontService")

local Selection = game:GetService("Selection")

local Smooth = import("@RayguiLerp")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local rl = KinemiumRaylib.lib
local structs = KinemiumRaylib.structs
local vend = KinemiumFontService.GetDefaultFont()
local classes = Instance.getClasses()

print("This is explorer.")

if game.Context ~= Enum.GameContext.Editor then
	return
end

local serviceOrder = {
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

local instanceTypes = {}

for class, _ in pairs(classes) do
	table.insert(instanceTypes, class)
end

local addMenuOpen = {}
local addMenuWidth = 150
local addMenuItemHeight = 22

local lastClicked = nil

local function getServicesInOrder()
	local services = {}
	for _, name in ipairs(serviceOrder) do
		local success, svc = pcall(game.GetService, game, name)
		if success and svc then
			table.insert(services, svc)
		end
	end

	-- optionally add any remaining children that are not in the list
	for _, child in ipairs(game:GetChildren()) do
		local found = false
		for _, svc in ipairs(services) do
			if child == svc then
				found = true
				break
			end
		end
		if not found then
			table.insert(services, child)
		end
	end

	return services
end

KinemiumIconLoader.new("Add", "./src/assets/images/icons/vanilla3/ui/16x/200/Add.png")
KinemiumIconLoader.new("ArrowRight", "./src/assets/images/icons/vanilla3/ui/16x/200/ArrowRight.png")
KinemiumIconLoader.new("ArrowDown", "./src/assets/images/icons/vanilla3/ui/16x/200/ArrowDown.png")

local png = KinemiumIconLoader.Get("Add")

local ArrowRight, ArrowDown =
	KinemiumIconLoader.ToTexture(KinemiumIconLoader.Get("ArrowRight")),
	KinemiumIconLoader.ToTexture(KinemiumIconLoader.Get("ArrowDown"))

local addIcon = KinemiumIconLoader.ToTexture(png)

local windowRegistry = {}

local aereon = import("@Kinemium.Aereon")
local window = aereon.window(game)

local function create_window(title, frame)
	repeat
		task.wait()
	until frame.AbsolutePosition and frame.AbsoluteSize
	local myWindow = window.create({
		title = title,
		x = frame.AbsolutePosition.X,
		y = frame.AbsolutePosition.Y,
		width = frame.AbsoluteSize.X,
		height = frame.AbsoluteSize.Y,
	})
	return myWindow
end

local function create_window_back(screenGui, title, AnchorPoint, size)
	local frame = Instance.new("Frame")
	frame.Position = UDim2.new(AnchorPoint.X, 0, AnchorPoint.Y, 0)
	frame.AnchorPoint = AnchorPoint
	frame.Size = size or UDim2.new(0, 400, 0.5, 0)
	frame.BackgroundColor3 = Color3.new(1, 1, 1)
	frame.BackgroundTransparency = 1
	frame.Parent = screenGui

	return create_window(title, frame)
end

-- create explorer ingame
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "Explorer"
screenGui.Parent = LocalPlayer.PlayerGui

local explorerback = create_window_back(screenGui, "Explorer", Vector2.new(1, 0), UDim2.new(0, 400, 0.7, 0))

local expanded = {}
local yOffset = 0
local selected = nil

local loadedIcon = {}

local function lerp(a, b, t)
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

local function isMouseInRect(rect, mousePos)
	return mousePos.x >= rect.x
		and mousePos.x <= rect.x + rect.width
		and mousePos.y >= rect.y
		and mousePos.y <= rect.y + rect.height
end

local function handleSelection(instance, rectData, mousePos)
	if isMouseInRect(rectData, mousePos) then
		if rl.IsMouseButtonPressed(0) == 1 then
			local ctrl = rl.IsKeyDown(341) == 1 or rl.IsKeyDown(345) == 1
			local shift = rl.IsKeyDown(340) == 1 or rl.IsKeyDown(344) == 1

			if shift and lastClicked then
				-- range select
				local parent = instance.Parent
				if parent then
					local siblings = parent:GetChildren()

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
				end
			elseif ctrl then
				-- ctrl
				if not Selection.IsSelected(instance) then
					Selection.Add(instance)
				else
					Selection.Remove(instance)
				end
			else
				-- normal selection
				Selection.Clear()

				Selection.Add(instance)

				lastClicked = instance
			end
		end
	end
end

local function drawAdditionMenu(instance, mousePos, btnY, toggleX)
	local columns = 5
	local itemW = addMenuItemHeight * 5
	local itemH = addMenuItemHeight

	if addMenuOpen[instance] then
		local rows = math.ceil(#instanceTypes / columns)
		local menuWidth = columns * itemW
		local menuHeight = rows * itemH

		local menuX = toggleX - menuWidth + 20
		local menuY = btnY + 25 + 4

		rl.DrawRectangleRounded(
			structs.Rectangle:new({
				x = menuX - (menuWidth - itemW),
				y = menuY,
				width = menuWidth,
				height = menuHeight,
			}),
			0.2,
			6,
			Color3ToRaylib(Color3.new(0.12, 0.12, 0.12), 0)
		)

		for i, class in ipairs(instanceTypes) do
			local col = (i - 1) % columns
			local row = math.floor((i - 1) / columns)

			local itemX = menuX - (col * itemW)
			local itemY = menuY + row * itemH
			local itemRect = { x = itemX, y = itemY, width = itemW, height = itemH }

			if not loadedIcon[class] then
				local png = KinemiumIconLoader.Get(class .. ".png")
				if png then
					loadedIcon[class] = KinemiumIconLoader.ToTexture(png)
				end
			end

			local iconTex = loadedIcon[class]
			if iconTex then
				local iconSize = itemH - 6
				rl.DrawTexturePro(
					iconTex.texture,
					structs.Rectangle:new({ x = 0, y = 0, width = iconTex.x, height = iconTex.y }),
					structs.Rectangle:new({
						x = itemX + 4,
						y = itemY + 3,
						width = iconSize,
						height = iconSize,
					}),
					vector.create(0, 0),
					0,
					KinemiumRaylib.const.WHITE
				)
			end

			if isMouseInRect(itemRect, mousePos) then
				rl.DrawRectangle(itemX, itemY, itemW, itemH, Color3ToRaylib(Color3.new(0.2, 0.2, 0.2), 0))

				if rl.IsMouseButtonPressed(0) == 1 then
					local newObj = Instance.new(class)
					newObj.Parent = instance
					addMenuOpen[instance] = false
				end
			end

			rl.DrawTextEx(vend, class, vector.create(itemX + 8 + 18, itemY + 3), 17, 1, KinemiumRaylib.const.WHITE)
		end
	end
end

local function DrawTree(instance, indent, winX, winY, winWidth)
	indent = indent or 0
	winX = winX or 0
	winY = winY or 0
	winWidth = winWidth or 350 -- fallback if not provided

	if instance.Destroyed == true then
		return
	end

	local children = instance:GetChildren()
	local hasChildren = #children > 0
	local isExpanded = expanded[instance]

	local nodeWidth = 330 -- width of the text button
	local nodeHeight = 25
	local padding = 10

	if not loadedIcon[instance.ClassName] then
		loadedIcon[instance.ClassName] =
			KinemiumIconLoader.ToTexture(KinemiumIconLoader.Get(instance.ClassName .. ".png"))
	end
	local icon = loadedIcon[instance.ClassName]

	local btnX = winX + 25 + winWidth - nodeWidth - padding - (indent * -12)
	local btnY = winY + 10 + yOffset
	local rectData = {
		x = btnX,
		y = btnY,
		width = nodeWidth,
		height = nodeHeight,
	}
	local rect = structs.Rectangle:new(rectData)
	local toggleX = btnX + nodeWidth

	local transparency = 1
	local color = Color3.new()

	local mousePos = rl.GetMousePosition() -- returns vector {x, y}

	local DisplayAddIcon = false

	drawAdditionMenu(instance, mousePos, btnY, toggleX)

	if isMouseInRect(rectData, mousePos) then
		Smooth:To(instance, 0.5)
		DisplayAddIcon = true
	else
		Smooth:To(instance, 1)
		DisplayAddIcon = false
	end

	transparency = Smooth:Get(instance) or 1

	if Selection.IsSelected(instance) then
		color = Color3.new(0, 0.533333, 1)
		transparency = 0
	end

	rl.DrawRectangleRounded(rect, 0.5, 8, Color3ToRaylib(color, transparency))
	rl.DrawTextEx(vend, instance.Name, vector.create(btnX + 28, btnY + 5), 18, 1, KinemiumRaylib.const.WHITE)

	if DisplayAddIcon then
		local iconSize = nodeHeight - 4 -- scale icon to fit the button height
		local data = { x = toggleX - 50, y = winY + 10 + yOffset, width = iconSize, height = iconSize }
		rl.DrawTexturePro(
			addIcon.texture,
			structs.Rectangle:new({ x = 0, y = 0, width = addIcon.x, height = addIcon.y }), -- source rect
			structs.Rectangle:new(data), -- destination
			vector.create(0, 0),
			0,
			KinemiumRaylib.const.WHITE
		)
		if isMouseInRect(data, mousePos) and rl.IsMouseButtonReleased(0) == 1 then
			addMenuOpen[instance] = not addMenuOpen[instance]
		end
	end

	-- selection
	handleSelection(instance, rectData, mousePos)

	if icon then
		local iconSize = nodeHeight - 4 -- scale icon to fit the button height
		rl.DrawTexturePro(
			icon.texture,
			structs.Rectangle:new({ x = 0, y = 0, width = icon.x, height = icon.y }), -- source rect
			structs.Rectangle:new({ x = btnX + 2, y = btnY + 2, width = iconSize, height = iconSize }), -- destination
			vector.create(0, 0),
			0,
			KinemiumRaylib.const.WHITE
		)
	end

	-- 261 is delete key (yes i dont care)
	if rl.IsKeyDown(261) == 1 then
		if Selection.Get()[1] then
			for _, v in pairs(Selection.Get()) do
				v:Destroy()
			end
		end
	end

	if hasChildren then
		-- place the toggle button on the left side
		local toggleSize = 20

		local toggleTexture = expanded[instance] and ArrowDown or ArrowRight
		local buttonData = { x = rectData.x - 25, y = rectData.y, width = toggleSize, height = toggleSize }
		local toggleSourceRect =
			structs.Rectangle:new({ x = 0, y = 0, width = toggleTexture.x, height = toggleTexture.y })
		local toggleDestRect = structs.Rectangle:new(buttonData)

		rl.DrawTexturePro(
			toggleTexture.texture,
			toggleSourceRect,
			toggleDestRect,
			vector.create(0, 0),
			0,
			KinemiumRaylib.const.WHITE
		)

		if isMouseInRect(buttonData, rl.GetMousePosition()) and rl.IsMouseButtonReleased(0) == 1 then
			expanded[instance] = not expanded[instance]
		end

		-- shift icon and text right to account for toggle button
		btnX = btnX + toggleSize + 5
	end

	yOffset = yOffset + nodeHeight + 2

	if expanded[instance] then
		for _, child in ipairs(children) do
			DrawTree(child, indent + 1, winX, winY, winWidth)
		end
	end
end

window.stepped = function(windowData)
	if windowData.title == "Explorer" then
		yOffset = 0
		local services = getServicesInOrder()
		for _, child in ipairs(services) do
			DrawTree(child, 0, windowData.x, windowData.y + 20)
		end
	end
end

RunService.RenderStepped:Connect(function(a0: number)
	Smooth.Step()
	--aereon.step()
end)
