-- devcell

local KinemiumRaylib = game:GetService("KinemiumRaylib")
local StudioThemeService = game:GetService("StudioThemeService")
local aereon = require("@Aereon")
local raylib = require("@raylibadapter")
local rl = raylib.lib
local renderer = KinemiumRaylib.GetRenderer()

local RunService = game:GetService("RunService")
if RunService:IsServer() then
	return
end

--[[
	Game Settings

	General
	- Game Name
	- Game Description
	- Version
	- Starting Scene / Map
	- Icon
	- Splash Screen
	- Company / Creator Name

	Engine
	- Target FPS
	- VSync
	- Fixed Timestep
	- Physics Rate
	- Gravity
	- Collision Layers
	- Auto Save Interval

	Rendering
	- MSAA Level
	- Shadow Quality
	- Render Distance
	- Ambient Lighting
	- Bloom
	- Motion Blur
	- SSAO

	Networking
	- Enable Networking
	- Default Port
	- Max Players
	- Tick Rate
	- Replication Distance
	- Compression Enabled

	HTTP Requests
	- Enable HTTP Requests
	- Allowed Domains
	- Request Timeout
	- Max Requests Per Minute
	- Enable WebSockets

	Security
	- Enable Client Scripts
	- Enable Native Plugins
	- Sandbox Level
	- Allow File Access
	- Allow Process Launching

	Export Settings
	- Game Title
	- Executable Name
	- Package Identifier
	- Target Platform
	- Build Configuration (Debug / Release)
	- Include Symbols
	- Compression Level
	- Startup Scene

	Scripting
	- Script Timeout
	- Enable FFI
	- Enable JIT
	- Enable Hot Reloading
	- Warning Level

	Physics
	- Solver Iterations
	- Sleep Threshold
	- Continuous Collision Detection
]]

local Players = game.Players
local LocalPlayer = Players.LocalPlayer

local window = aereon.window(game)

local main_window = window.create({
	title = "Game Settings",
	x = 0,
	y = 0,
	width = 900,
	height = 800,
	Resizable = false,
	Draggable = false,

	tabs = {},
})

ishared.gsettings_window = main_window

local Theme = game:GetService("StudioThemeService").SelectedTheme
local enabled = false

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
	if prop == "EnableGameSettingsMenu" then
		main_window:Open()
		main_window.Closed = false
		main_window.Resizable = false
		main_window.Draggable = false
		enabled = true
	elseif prop == "CreateGameSettingsTab" then
		table.insert(main_window.tabs, data)
	end
end)

renderer.Hook.new("After2D", function(data)
	if game.Context ~= Enum.GameContext.Editor then
		return
	end
	local dt = rl.GetFrameTime()
	local mainTheme = StudioThemeService.SelectedTheme
	if not frame.AbsolutePosition then
		return
	end
	main_window.x = frame.AbsolutePosition.X
	main_window.y = frame.AbsolutePosition.Y
	main_window.width = frame.AbsoluteSize.X
	main_window.height = frame.AbsoluteSize.Y

	if not enabled then
		return
	end
	window.update(dt)
	window.draw(dt, mainTheme, renderer.Lib2d)
end)
