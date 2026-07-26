-- devcell

local aereon = require("@Aereon")
local Theme = game:GetService("StudioThemeService").SelectedTheme
local KinemiumFontService = game:GetService("KinemiumFontService")
local StudioThemeService = game:GetService("StudioThemeService")
local vend = KinemiumFontService.GetDefaultFontSmall()
local rect = require("@arect")
local renderer = game:GetService("KinemiumRaylib").GetRenderer()
local adapter = require("@RaylibAdapter")
local rl = adapter.lib
local RunService = game:GetService("RunService")

if RunService:IsServer() then
	return
end

local Players = game.Players
local LocalPlayer = Players.LocalPlayer
local enabled = false

local window = aereon.window(game)

local main_window = window.create({
	title = "Studio Settings",
	x = 0,
	y = 0,
	width = 900,
	height = 800,
	Resizable = false,
	Draggable = false,
})

window.focused = function(window)
	_G.IsHoveringOnWindow = true
end

window.unfocused = function(window)
	_G.IsHoveringOnWindow = false
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "GameSettings"
screenGui.Parent = LocalPlayer.PlayerGui

local frame = Instance.new("Frame")
frame.Position = Theme.WindowConfig.GameSettings.position
frame.AnchorPoint = Theme.WindowConfig.GameSettings.anchorPoint
frame.Size = Theme.WindowConfig.GameSettings.size
frame.BackgroundTransparency = 1
frame.Parent = screenGui

game.EngineSignal:Connect(function(prop, data)
	if prop == "EnableStudioSettingsMenu" then
		main_window:Open()
		main_window.Closed = false
		main_window.Resizable = false
		main_window.Draggable = false
		enabled = true
	end
end)

local cells = ishared.settings_cells

local scrollArea = ishared.settings_scrollArea

local PADDING = 12

renderer.Hook.new("After2D", function(data)
	if game.Context ~= Enum.GameContext.Editor then
		return
	end
	local dt = rl.GetFrameTime()
	main_window.x = frame.AbsolutePosition.X
	main_window.y = frame.AbsolutePosition.Y
	main_window.width = frame.AbsoluteSize.X
	main_window.height = frame.AbsoluteSize.Y
	if not enabled then
		return
	end
	window.update(dt)
	window.draw(dt, StudioThemeService.SelectedTheme, renderer.Lib2d)
end)

main_window.stepped = function(wd)
	if game.Context ~= Enum.GameContext.Editor then
		return
	end
	local contentOffsetY = wd._titleBarH + wd._tabBarH
	local contentH = wd.height - contentOffsetY

	local clipX = wd.x + PADDING
	local clipY = wd.y + contentOffsetY
	local clipW = wd.width - PADDING * 2
	local clipH = contentH - PADDING * 2

	vend = KinemiumFontService.GetDefaultFont()
	scrollArea.set("obj_rect", rect.new(clipX, clipY, clipW, clipH))
	cells.setWidth(clipW)
	cells.SetAllCellProp("font", vend)

	scrollArea.render(wd._dt or 0)
end
