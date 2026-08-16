local RunService = game:GetService("RunService")
local StudioThemeService = game:GetService("StudioThemeService")
local Immco = require("@Immco")
local theme = StudioThemeService.SelectedTheme
local Argon = require("@Argon")

repeat
	task.wait()
until game.CoreGui:FindFirstChild("Studio")

local Topbar = Instance.new("Frame")
Topbar.Name = "Topbar"
Topbar.Size = theme.TopbarCoordinates.Size
Topbar.Position = theme.TopbarCoordinates.Position
Topbar.Parent = game.CoreGui:FindFirstChild("Studio")
Topbar.BackgroundTransparency = 1

local icon = Argon:CreateImageFromPath("./src/assets/images/kinemium/KinemiumWhite.png")

renderer.Pool.new("2d", function()
	local absolutePosition = Topbar.AbsolutePosition
	local absoluteSize = Topbar.AbsoluteSize

	Topbar.Size = theme.TopbarCoordinates.Size
	Topbar.Position = theme.TopbarCoordinates.Position

	if not absolutePosition then
		return
	end
	if not absoluteSize then
		return
	end

	Argon:Save(renderer.Window)

	Argon:ClipRoundRect(renderer.Window, {
		x = absolutePosition.X,
		y = absolutePosition.Y,
		width = absoluteSize.X,
		height = absoluteSize.Y,
	}, 6, 6)

	Argon:DrawRectangle(renderer.Window, {
		x = absolutePosition.X,
		y = absolutePosition.Y,
		width = absoluteSize.X,
		height = absoluteSize.Y,
		Color = theme.BgColor,
	})

	Immco.Image({
		x = absolutePosition.X + 3,
		y = absolutePosition.Y + 3,
		width = 23,
		height = 23,
		Image = icon,
		theme = theme,
		engine_window = renderer.Window,
	}, dt)

	Argon:Restore(renderer.Window)

	Immco.TextButton({
		x = absolutePosition.X + 30,
		y = absolutePosition.Y,
		width = 100,
		height = absoluteSize.Y,

		text = "Click Me",
		Color = theme.SecondaryColor,

		theme = theme,
		engine_window = renderer.Window,
	}, dt)
end)
