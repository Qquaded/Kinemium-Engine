local RunService = game:GetService("RunService")
local StudioThemeService = game:GetService("StudioThemeService")
local Immco = require("@Immco")
local theme = StudioThemeService.SelectedTheme
local Argon = require("@Argon")

local Guis = Instance.new("ScreenGui")
Guis.Name = "Studio"
Guis.Parent = game.CoreGui

renderer.Pool.new("2d", function()
	local dt = renderer.RuntimeLibrary.dt

	Argon:DrawRectangle(renderer.Window, {
		x = 0,
		y = 0,
		width = renderer.Width,
		height = renderer.Height,
		Color = theme.BaseColor,
	})
end, -99999)
