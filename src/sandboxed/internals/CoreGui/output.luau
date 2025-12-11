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
local window = aereon.window(game, nil, 1)

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
screenGui.Name = "Output"
screenGui.Parent = LocalPlayer.PlayerGui

local propback, frame = create_window_back(screenGui, "Output", Vector2.new(0.5, 1), UDim2.new(1, 0, 0.2, 0))

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
	if windowData.title == "Output" then
		local winX, winY = windowData.x, windowData.y + 30
		local winWidth = windowData.width
		local cellHeight = 25
		local padding = 0
		local mousePos = rl.GetMousePosition()

		if not windowData.IsDragging then
			windowData.x = frame.AbsolutePosition.X
			windowData.y = frame.AbsolutePosition.Y
			windowData.width = frame.AbsoluteSize.X
			windowData.height = frame.AbsoluteSize.Y
		end

		local logs = LogService.GetLogHistory()
		for i, log in ipairs(logs) do
			local cellY = winY + (i - 1) * (cellHeight + padding)
			local rect = { x = winX + 5, y = cellY, width = winWidth - 10, height = cellHeight }

			-- alternating background color
			local bgColor = (i % 2 == 0) and structs.Color:new({ r = 30, g = 30, b = 30, a = 255 })
				or structs.Color:new({ r = 20, g = 20, b = 20, a = 255 })
			rl.DrawRectangle(rect.x, rect.y, rect.width, rect.height, bgColor)

			-- log type color
			local logColor = KinemiumRaylib.const.WHITE
			if log.type == "print" then
				logColor = structs.Color:new({ r = 200, g = 200, b = 200, a = 255 })
			elseif log.type == "warn" then
				logColor = structs.Color:new({ r = 255, g = 200, b = 0, a = 255 })
			elseif log.type == "error" then
				logColor = structs.Color:new({ r = 255, g = 50, b = 50, a = 255 })
			end

			local ts = os.date("%H:%M:%S", log.time)
			local text = string.format("[%s] %s", ts, log.message)

			rl.DrawTextEx(vend, text, vector.create(rect.x + 8, rect.y + 4), 22, 1, logColor)
		end
	end
end

renderer.Add2DStack(function(data)
	--aereon.step()
end)
