-- devcell

local KinemiumRaylib = game:GetService("KinemiumRaylib")
local KinemiumIconLoader = game:GetService("KinemiumIconLoader")
local KinemiumFontService = game:GetService("KinemiumFontService")

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local renderer = KinemiumRaylib.renderer
local rl = KinemiumRaylib.lib
local Selection = game:GetService("Selection")
local structs = KinemiumRaylib.structs
local vend = KinemiumFontService.GetDefaultFont()

if game.Context ~= Enum.GameContext.Editor then
	return
end

print("This is properties.")

KinemiumIconLoader.new("Add", "./src/assets/images/icons/vanilla3/ui/16x/200/Add.png")

local png = KinemiumIconLoader.Get("Add")
local addIcon = KinemiumIconLoader.ToTexture(png)

local windowRegistry = {}

local aereon = import("@Kinemium.Aereon")
local window = aereon.window(game)

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

-- create explorer ingame
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "Properties"
screenGui.Parent = LocalPlayer.PlayerGui

local propback = create_window_back(screenGui, "Properties", Vector2.new(1, 1), UDim2.new(0, 400, 0.3, 0))

local function Color3ToRaylib(c, transparency)
	local r, g, b = c:ToRGB()
	return structs.Color:new({
		r = r,
		g = g,
		b = b,
		a = math.floor(255 * (1 - transparency)),
	})
end

-- Update window.stepped for Explorer tree
window.stepped = function(windowData)
	if windowData.title == "Properties" then
		local winX, winY = windowData.x, windowData.y + 30
		local winWidth = windowData.width
		local cellHeight = 25
		local padding = 5
		local mousePos = rl.GetMousePosition()

		local selected = Selection.Get()[1]

		if not selected then
			return
		end

		local i = 0
		for propName, propValue in pairs(selected._props) do
			if table.find(blacklisted, propName) then
				continue
			end
			if type(propValue) == "function" then
				continue
			end
			if type(propValue) == "table" then
				continue
			end
			i += 1
			local cellY = winY + (i - 1) * (cellHeight + padding)
			local rect = { x = winX + 5, y = cellY, width = winWidth - 25, height = cellHeight }
			local transparency = 1

			-- highlight on hover
			local col
			if i % 2 == 0 then
				col = Color3.new(0.15, 0.15, 0.15) -- dark gray
			else
				col = Color3.new(0.13, 0.13, 0.13) -- black
			end

			if
				mousePos.x >= rect.x
				and mousePos.x <= rect.x + rect.width
				and mousePos.y >= rect.y
				and mousePos.y <= rect.y + rect.height
			then
				col = Color3.new(0.25, 0.25, 0.25) -- lighter gray on hover
				transparency = 0.5
			end

			-- draw cell
			rl.DrawRectangleRounded(
				structs.Rectangle:new({
					x = rect.x,
					y = rect.y,
					width = rect.width,
					height = rect.height,
				}),
				0.2,
				6,
				Color3ToRaylib(col, transparency)
			)

			-- draw property name
			rl.DrawTextEx(vend, propName, vector.create(rect.x + 8, rect.y + 4), 22, 1, KinemiumRaylib.const.WHITE)

			local valueColor
			if propValue == true then
				valueColor = KinemiumRaylib.const.GREEN
			elseif propValue == false then
				valueColor = KinemiumRaylib.const.RED
			else
				valueColor = KinemiumRaylib.const.WHITE
			end

			local textboxX = rect.x + rect.width - 130
			local textboxWidth = 120
			rl.DrawRectangleRounded(
				structs.Rectangle:new({ x = textboxX, y = rect.y + 2, width = textboxWidth, height = cellHeight - 4 }),
				0.5,
				4,
				Color3ToRaylib(Color3.new(0.08, 0.08, 0.08), 1)
			)
			rl.DrawTextEx(vend, tostring(propValue), vector.create(textboxX + 4, rect.y + 4), 22, 1, valueColor)
		end
	end
end

renderer.Add2DStack(function(data)
	--aereon.step()
end)
