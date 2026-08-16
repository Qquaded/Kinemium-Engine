local StudioThemeService = game:GetService("StudioThemeService")
local Immco = require("@Immco")
local theme = StudioThemeService.SelectedTheme
local Argon = require("@Argon")

repeat
	task.wait()
until game.CoreGui:FindFirstChild("Studio")

local Inspector = Instance.new("Frame")
Inspector.Name = "Inspector"
Inspector.Size = theme.InspectorCoordinates.Size
Inspector.Position = theme.InspectorCoordinates.Position
Inspector.Parent = game.CoreGui:FindFirstChild("Studio")
Inspector.BackgroundTransparency = 1

renderer.Pool.new("2d", function()
	local dt = renderer.RuntimeLibrary.dt
	local absolutePosition = Inspector.AbsolutePosition
	local absoluteSize = Inspector.AbsoluteSize

	Inspector.Size = theme.InspectorCoordinates.Size
	Inspector.Position = theme.InspectorCoordinates.Position

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
		title = "Inspector",
		theme = theme,
		engine_window = renderer.Window,

		callback = function(params) end,
	}, dt)
end)
