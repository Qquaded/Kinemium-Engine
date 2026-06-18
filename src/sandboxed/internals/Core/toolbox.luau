-- devcell

local KinemiumRaylib = game:GetService("KinemiumRaylib")
local StudioThemeService = game:GetService("StudioThemeService")
local aereon = require("@Aereon")
local raylib = require("@raylib")
local rl = raylib.lib
local renderer = KinemiumRaylib.GetRenderer()
local NewToolbarElement = ishared.NewToolbarElement
local arect = require("@Arect")

local KinemiumIconLoader = game:GetService("KinemiumIconLoader")

local RunService = game:GetService("RunService")
if RunService:IsServer() then
	return
end

local Players = game.Players
local LocalPlayer = Players.LocalPlayer

local window = aereon.window(game)
local gui = aereon.gui

local main_window = window.create({
	title = "Toolbox",
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
screenGui.Name = "Toolbox"
screenGui.Parent = LocalPlayer.PlayerGui

local frame = Instance.new("Frame")
frame.Position = Theme.WindowConfig.Toolbox.position
frame.AnchorPoint = Theme.WindowConfig.Toolbox.anchorPoint
frame.Size = Theme.WindowConfig.Toolbox.size
frame.BackgroundTransparency = 1
frame.Parent = screenGui

game.EngineSignal:Connect(function(prop, data)
	if prop == "EnableTo" then
	end
end)

NewToolbarElement:Fire("Tools", "MeshImporter", {
	type = "ImageButton",
	text = "toolbox",
	callback = function(element, rect)
		enabled = not enabled

		if enabled then
			main_window:Open()
			main_window.Closed = false
			main_window.Resizable = false
			main_window.Draggable = false
			enabled = true
		else
		end
	end,
	hoverTransparency = 0.5,
	hoverColor = Color3.new(0, 0, 0),
	roundness = 0.2,
	texture = KinemiumIconLoader.ToTexture("./src/assets/images/icons/EditableMesh.png"),
})

local PAD = 12
local TITLE_H = main_window._titleBarH or 28

-- Map of plugin ID -> detail window
local pluginWindows = {}

local function openPluginWindow(pluginId)
	-- If window already exists, focus it
	if pluginWindows[pluginId] then
		local win = pluginWindows[pluginId]
		if win.Closed then
			win:Open()
		end
		return
	end

	-- Wait for pages to be loaded
	local pages = ishared.marketplacePages
	if not pages or not pages[pluginId] then
		return
	end

	local page = pages[pluginId]
	local pluginName = page.get and page.get("title") or "Plugin"

	local detailWindow = window.create({
		title = pluginName,
		x = main_window.x + 80,
		y = main_window.y + 40,
		width = 900,
		height = 700,
		Resizable = true,
		Draggable = true,

		tabs = {},
	})

	local WIN_PAD = 12

	detailWindow.stepped = function(wd)
		local dt = rl.GetFrameTime()
		local titleBarH = wd._titleBarH or 28
		local contentX = wd.x + WIN_PAD
		local contentY = wd.y + titleBarH + WIN_PAD
		local contentW = wd.width - WIN_PAD * 2
		local contentH = wd.height - titleBarH - WIN_PAD * 2

		if contentW > 0 and contentH > 0 then
			page.set("obj_rect", arect.new(contentX, contentY, contentW, contentH))
			page.render(dt)
		end
	end

	-- Cleanup when window is closed
	window.windowClosed = function(w)
		pluginWindows[pluginId] = nil
	end

	detailWindow:Open()
	pluginWindows[pluginId] = detailWindow
end

-- Override the card click callback to open a new window instead of inline view
ishared.onPluginCardClick = function(pluginId)
	openPluginWindow(pluginId)
end

main_window.stepped = function(wd)
	if game.Context ~= Enum.GameContext.Editor then
		return
	end
	local dt = raylib.lib.GetFrameTime()
	game.EngineSignal:Fire("LoadPlugins")

	ishared.marketplacePage.set(
		"obj_rect",
		arect.new(
			wd.x + PAD,
			wd.y + (wd._titleBarH or 28) + PAD,
			wd.width - PAD * 2,
			wd.height - (wd._titleBarH or 28) - PAD * 2
		)
	)
	ishared.marketplacePage.render(dt)
end

renderer.Hook.new("After2D", function(data)
	if game.Context ~= Enum.GameContext.Editor then
		return
	end
	local dt = rl.GetFrameTime()
	local mainTheme = StudioThemeService.SelectedTheme
	main_window.x = frame.AbsolutePosition.X
	main_window.y = frame.AbsolutePosition.Y
	main_window.width = frame.AbsoluteSize.X
	main_window.height = frame.AbsoluteSize.Y

	if not enabled then
		return
	end
	window.update(dt)
	window.draw(dt, mainTheme.aereon)
end)
