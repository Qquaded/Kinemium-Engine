-- devcell

local KinemiumRaylib = game:GetService("KinemiumRaylib")
local KinemiumIconLoader = game:GetService("KinemiumIconLoader")
local KinemiumFontService = game:GetService("KinemiumFontService")

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local renderer = KinemiumRaylib.renderer
local rl = KinemiumRaylib.lib
local Selection = game:GetService("Selection")
local LogService = game:GetService("LogService")
local structs = KinemiumRaylib.structs
local vend = KinemiumFontService.GetDefaultFont()

export type ButtonTitle = string

export type RibbonBarCategory = {
	title: string,
	buttons: {
		[ButtonTitle]: {
			type: "ImageButton" | "TextButton" | "TextLabel" | "Custom",
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

KinemiumIconLoader.new("Play", "src/assets/images/icons/vanilla3/general/32x/200/Play.png")

local png = KinemiumIconLoader.Get("Play")
local PlayIcon = KinemiumIconLoader.ToTexture(png)

local categoryRegistry = {
	Category = {
		buttons = {
			["skibidi"] = {
				callback = function()
					print("hello world")
				end,
				hoverTransparency = 0.5,
				hoverColor = Color3.new(0, 0, 0),
				roundness = 0.2,
				texture = PlayIcon,
			},
		},
	},
}

local aereon = import("@Kinemium.Aereon")
local window = aereon.window(game, nil, 1)
local aRect = aereon.rect()
local buttons = {}

local blacklisted = {
	"Children",
}

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

local propback, frame = create_window_back(screenGui, "Toolbar", Vector2.new(0, 0), UDim2.new(1, 0, 0, 122))

local function Color3ToRaylib(c, transparency)
	local r, g, b = c:ToRGB()
	return structs.Color:new({
		r = r,
		g = g,
		b = b,
		a = math.floor(255 * (1 - transparency)),
	})
end

local function renderSubButton(i, button, windowData)
	local winX, winY = windowData.x, windowData.y + 30
	local winWidth = windowData.width
	local cellWidth = button.width or 50
	local cellHeight = button.height or 50
	local paddingLeft = 15
	local padding = button.padding or 5
	local rectX = winX + paddingLeft + i * (cellWidth + padding)
	local rectY = winY
	local rectData = aRect.new(rectX, rectY, cellWidth, cellHeight)
	local mousePos = rl.GetMousePosition()

	local transparency = 1
	local color = Color3.new(0.5, 0.5, 0.5)

	if aRect.MouseIsInRect(rectData) then
		color = button.hoverColor
		transparency = button.hoverTransparency
	end

	aRect.Button(rectData, function()
		button.callback(rectData)
	end)

	local bgColor = Color3ToRaylib(color, transparency)
	rl.DrawRectangleRounded(aRect:translate(rectData), button.roundness, 8, bgColor)

	if button.texture then
		rl.DrawTexturePro(
			button.texture.texture, -- wow
			structs.Rectangle:new({ x = 0, y = 0, width = button.texture.x, height = button.texture.y }), -- source rect
			aRect:translate(rectData), -- destination
			vector.create(0, 0),
			button.rotation or 0,
			KinemiumRaylib.const.WHITE
		)
	end

	if button.render then
		button.render(aRect)
	end
end

window.stepped = function(windowData)
	if windowData.title == "Toolbar" then
		windowData.x = frame.AbsolutePosition.X
		windowData.y = frame.AbsolutePosition.Y
		windowData.width = frame.AbsoluteSize.X
		windowData.height = frame.AbsoluteSize.Y

		local i = 0
		for _, category in pairs(categoryRegistry) do
			local buttons = category.buttons
			for _, button in pairs(buttons) do
				renderSubButton(i, button, windowData)
				i += 1
			end
		end
	end
end

renderer.Add2DStack(function(data)
	aereon.step()
end)
