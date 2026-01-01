-- devcell

local KinemiumRaylib = game:GetService("KinemiumRaylib")
local KinemiumIconLoader = game:GetService("KinemiumIconLoader")
local KinemiumFontService = game:GetService("KinemiumFontService")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local rl = KinemiumRaylib.lib
local renderer = KinemiumRaylib.renderer
local structs = KinemiumRaylib.structs
local vend = KinemiumFontService.GetDefaultFont()
local currentlySelected = ""

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

if FlagExists("client") then
	return
end

KinemiumIconLoader.new("Play", "src/assets/images/icons/vanilla3/general/32x/200/Play.png")
KinemiumIconLoader.new("Stop", "src/assets/images/icons/vanilla3/general/32x/200/Stop.png")

local png = KinemiumIconLoader.Get("Play")
local stop = KinemiumIconLoader.Get("Stop")

local PlayIcon = KinemiumIconLoader.ToTexture(png)
local StopIcon = KinemiumIconLoader.ToTexture(stop)

local IsPlaytesting = false

local categoryRegistry = {
	Category = {
		elements = {
			{
				type = "ImageButton",
				text = "Playtest",
				callback = function()
					local playtestService = game:GetService("PlaytestService")
					if IsPlaytesting then
						return
					end
					print("playtesting..")

					playtestService.CreatePlaytestAsync()
					IsPlaytesting = true
				end,
				hoverTransparency = 0.5,
				hoverColor = Color3.new(0, 0, 0),
				roundness = 0.2,
				texture = KinemiumIconLoader.ToTexture("src/assets/images/icons/vanilla3/general/32x/200/Play.png"),
			},
			{
				type = "ImageButton",

				callback = function()
					local playtestService = game:GetService("PlaytestService")

					if not IsPlaytesting then
						return
					end
					print("Stopping the simulation")

					playtestService.StopCurrentPlaytest()
					IsPlaytesting = false
				end,
				hoverTransparency = 0.5,
				text = "Stop",
				hoverColor = Color3.new(1, 0, 0),
				roundness = 0.2,
				texture = KinemiumIconLoader.ToTexture("src/assets/images/icons/vanilla3/general/32x/200/Stop.png"),
			},
		},
	},
}

local aereon = import("@Kinemium.Aereon")
local window = aereon.window(game, nil, 1)
local aRect = aereon.rect()

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

	return create_window(title, frame), frame
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "Toolbar"
screenGui.Parent = LocalPlayer.PlayerGui

local propback, frame = create_window_back(screenGui, "Toolbar", Vector2.new(0, 0), UDim2.new(0.795, 0, 0, 160))

local function Color3ToRaylib(c, transparency)
	local r, g, b = c:ToRGB()
	return structs.Color:new({
		r = r,
		g = g,
		b = b,
		a = math.floor(255 * (1 - transparency)),
	})
end

local function renderButton(i, name, element, windowData)
	local winX, winY = windowData.x, windowData.y + 80
	local cellWidth = element.width or 50
	local cellHeight = element.height or 50
	local paddingLeft = 15
	local padding = element.padding or 20
	local rectX = winX + paddingLeft + i * (cellWidth + padding)
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
			element.texture.texture, -- wow
			structs.Rectangle:new({ x = 0, y = 0, width = element.texture.x, height = element.texture.y }), -- source rect
			aRect:translate(rectData), -- destination
			vector.create(0, 0),
			element.rotation or 0,
			KinemiumRaylib.const.WHITE
		)
	end

	-- text
	if name then
		local textX = rectData.x + cellWidth / 2 - (#name * 9) / 2 -- center text horizontally
		local textY = rectData.y + cellHeight + 5 -- below the element with 5px padding
		rl.DrawTextEx(vend, name, vector.create(textX, textY), 18, 1, KinemiumRaylib.const.WHITE)
	end

	if element.render then
		element.render(aRect)
	end
end

local function renderSeperator(i, windowData, element)
	local winX, winY = windowData.x, windowData.y + 30
	local paddingLeft = 15
	local padding = element.padding or 20
	local rectX = winX + paddingLeft + i * (50 + padding)
	local rectY = winY

	local sepColor = Color3ToRaylib(element.color or Color3.new(0.7, 0.7, 0.7), 0)
	rl.DrawRectangle(rectX, rectY, element.width or 2, element.height or 50, sepColor)
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
	rl.DrawRectangleRounded(aRect:translate(Categories), 0.5, 18, Color3ToRaylib(Color3.new(0.133, 0.133, 0.133), 0))

	local startX = x + extraPadding / 2
	local i = 0
	for name, category in pairs(categoryRegistry) do
		local rect =
			aRect.new(startX + i * (buttonWidth + padding), y + (height - buttonHeight) / 2, buttonWidth, buttonHeight)

		aRect.Button(rect, function()
			currentlySelected = name
		end)

		local bg = Color3ToRaylib(Color3.new(0.3, 0.3, 0.3), 1)
		if currentlySelected == name then
			bg = Color3ToRaylib(Color3.new(0.3, 0.3, 0.3), 0)
		end

		rl.DrawRectangleRounded(aRect:translate(rect), 0.5, 5, bg)

		local textX = rect.x + buttonWidth / 2 - (#name * 9) / 2
		local textY = rect.y + buttonHeight / 2 - 9
		rl.DrawTextEx(vend, name, vector.create(textX, textY), 18, 1, KinemiumRaylib.const.WHITE)

		i += 1
	end
end

local windowObject

RunService.GuiRender:Connect(function()
	if not windowObject then
		return
	end
	renderer.blur:DrawBlurredRegion(
		windowObject.x,
		windowObject.y,
		windowObject.width,
		windowObject.height,
		Color3ToRaylib(Color3.new(1, 1, 1), 0)
	)
end)

window.stepped = function(windowData)
	if windowData.title == "Toolbar" then
		windowObject = windowData
		if rl.IsWindowResized() == 1 then
			window.dragspring:target(windowData, {
				x = frame.AbsolutePosition.X,
				y = frame.AbsolutePosition.Y,
				width = frame.AbsoluteSize.X,
				height = frame.AbsoluteSize.Y,
			})
		end

		local i = 0
		local category = categoryRegistry[currentlySelected]

		if category then
			local elements = category.elements
			for _, element in pairs(elements) do
				if element.type == "ImageButton" then
					renderButton(i, element.text, element, windowData)
				elseif element.type == "Separator" then
					renderSeperator(i, windowData, element)
				elseif element.type == "Custom" then
					if element.render then
						element.render(aRect)
					end
				end
				i += 1
			end
		end
		drawCategories(windowData)
	end
end
