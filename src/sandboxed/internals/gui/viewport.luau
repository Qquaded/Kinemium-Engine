local RunService = game:GetService("RunService")
local StudioThemeService = game:GetService("StudioThemeService")
local Immco = require("@Immco")
local theme = StudioThemeService.SelectedTheme
local Argon = require("@Argon")

repeat
	task.wait()
until game.CoreGui:FindFirstChild("Studio")

local Viewport = Instance.new("Frame")
Viewport.Name = "Viewport"
Viewport.Size = theme.ViewportCoordinates.Size
Viewport.Position = theme.ViewportCoordinates.Position
Viewport.Parent = game.CoreGui:FindFirstChild("Studio")
Viewport.BackgroundTransparency = 1

renderer.Pool.new("2d", function()
	local dt = renderer.RuntimeLibrary.dt
	local absolutePosition = Viewport.AbsolutePosition
	local absoluteSize = Viewport.AbsoluteSize

	Viewport.Size = theme.ViewportCoordinates.Size
	Viewport.Position = theme.ViewportCoordinates.Position

	if not absolutePosition then
		return
	end
	if not absoluteSize then
		return
	end

	Immco.Widget({
		x = absolutePosition.X,
		y = absolutePosition.Y + 5,
		width = absoluteSize.X,
		height = absoluteSize.Y,
		title = "Viewport",
		theme = theme,
		engine_window = renderer.Window,

		callback = function(params)
			renderer:Set3DTexProps(
				absolutePosition.X + 5,
				absolutePosition.Y + 35,
				absoluteSize.X - 10,
				absoluteSize.Y - 35
			)
		end,
	}, dt)
end)
