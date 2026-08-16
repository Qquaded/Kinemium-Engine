local RunService = game:GetService("RunService")
local StudioThemeService = game:GetService("StudioThemeService")
local Immco = require("@Immco")
local theme = StudioThemeService.SelectedTheme
local Argon = require("@Argon")

repeat
	task.wait()
until game.CoreGui:FindFirstChild("Studio")

local Output = Instance.new("Frame")
Output.Name = "Output"
Output.Size = theme.OutputCoordinates.Size
Output.Position = theme.OutputCoordinates.Position
Output.Parent = game.CoreGui:FindFirstChild("Studio")
Output.BackgroundTransparency = 1

local LogService = game:GetService("LogService")

renderer.Pool.new("2d", function()
	local dt = renderer.RuntimeLibrary.dt
	local absolutePosition = Output.AbsolutePosition
	local absoluteSize = Output.AbsoluteSize

	Output.Size = theme.OutputCoordinates.Size
	Output.Position = theme.OutputCoordinates.Position

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
		title = "Output",
		theme = theme,
		engine_window = renderer.Window,

		callback = function(params) end,
	}, dt)
end)
