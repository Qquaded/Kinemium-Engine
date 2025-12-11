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

if game.Context ~= Enum.GameContext.Editor then
	return
end

print("This is output.")

KinemiumIconLoader.new("Add", "./src/assets/images/icons/vanilla3/ui/16x/200/Add.png")

local png = KinemiumIconLoader.Get("Add")
local addIcon = KinemiumIconLoader.ToTexture(png)

local windowRegistry = {}

local aereon = import("@Kinemium.Aereon")
local window = aereon.window(game)
local aRect = aereon.rect()

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

	return create_window(title, frame)
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "Toolbar"
screenGui.Parent = LocalPlayer.PlayerGui

local propback = create_window_back(screenGui, "Toolbar", Vector2.new(0, 0), UDim2.new(0.78, 0, 0.1, 0))

local function Color3ToRaylib(c, transparency)
	local r, g, b = c:ToRGB()
	return structs.Color:new({
		r = r,
		g = g,
		b = b,
		a = math.floor(255 * (1 - transparency)),
	})
end

window.stepped = function(windowData)
	if windowData.title == "Toolbar" then
		local winX, winY = windowData.x, windowData.y + 30
		local winWidth = windowData.width
		local cellWidth = 50
		local cellHeight = 50
		local paddingLeft = 15
		local padding = 5

		for i = 0, 9 do
			local rectX = winX + paddingLeft + i * (cellWidth + padding)
			local rectY = winY
			local rectData = aRect.new(rectX, rectY, cellWidth, cellHeight)
			local mousePos = rl.GetMousePosition()

			local transparency = 1

			if aRect.MouseIsInRect(rectData) then
				transparency = 0.5
			end

			aRect.Button(rectData, function()
				print("hi")
			end)

			local bgColor = Color3ToRaylib(Color3.new(0.5, 0.5, 0.5), transparency)
			rl.DrawRectangleRec(aRect:translate(rectData), bgColor)
		end
	end
end

renderer.Add2DStack(function(data)
	aereon.step()
end)
