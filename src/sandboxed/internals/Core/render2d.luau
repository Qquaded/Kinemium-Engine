-- devcell
local RunService = game:GetService("RunService")
if RunService:IsServer() then
	return
end

local KinemiumRaylib = game:GetService("KinemiumRaylib")
local EngineSignal = game.EngineSignal
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local renderer = KinemiumRaylib.GetRenderer()
local rl = KinemiumRaylib.GetLib()
local KinemiumFontService = game:GetService("KinemiumFontService")
local StudioThemeService = game:GetService("StudioThemeService")

local vend = KinemiumFontService.GetDefaultFont()

local function profileBegin(name)
	if ENGINE_PROFILER then
		ENGINE_PROFILER:Begin(name)
	end
end

local function profileSetCounter(name, value)
	if ENGINE_PROFILER then
		ENGINE_PROFILER:SetCounter(name, value)
	end
end

local function profileNextFrame()
	if ENGINE_PROFILER then
		ENGINE_PROFILER:NextFrame()
	end
end

local function profileEnd()
	if ENGINE_PROFILER then
		ENGINE_PROFILER:End()
	end
end

if FlagExists("cli") then
	return
end

if FlagExists("headless") then
	return
end

local aereon = import("@Aereon")
local gui = aereon.gui
local ide = aereon.ide(nil, game)

gui.SetFont(vend)

local Theme = game:GetService("StudioThemeService").SelectedTheme

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CodeEditor"
screenGui.Parent = LocalPlayer.PlayerGui

local frame = Instance.new("Frame")
frame.Position = Theme.WindowConfig.CodeEditor.position
frame.AnchorPoint = Theme.WindowConfig.CodeEditor.anchorPoint
frame.Size = Theme.WindowConfig.CodeEditor.size
frame.BackgroundTransparency = 1
frame.Parent = screenGui

local enableIDE = false
local currentObject

EngineSignal:Connect(function(route, value, Script)
	if route == "idestate" then
		if value == true then
			ide:openTab(Script.Name, Script.Source)

			enableIDE = true
			currentObject = Script
			game.Stop3DInput = true
		else
			enableIDE = false
			currentObject = nil

			game.Stop3DInput = false
		end
	end
end)

local window = aereon.window(game)

repeat
	task.wait()
until frame.AbsolutePosition and frame.AbsoluteSize

local initialPos = frame.AbsolutePosition or vector.create(0, 0)
local initialSize = frame.AbsoluteSize or vector.create(800, 600)

local ideWindow = window.create({
	title = "Script Editor",
	x = initialPos.X,
	y = initialPos.Y,
	width = initialSize.X,
	height = initialSize.Y,
	enabled = false,
})

--[[
local viewportWindow = window.create({
	title = "Viewport",
	x = x,
	y = y,
	width = width,
	height = height,
	backgroundTransparency = 1,
	enabled = false,
})
--]]

ideWindow.stepped = function(data)
	ideWindow.x = 0
	ideWindow.y = 30
	ideWindow.width = rl.GetRenderWidth()
	ideWindow.height = rl.GetRenderHeight() - 30
	ide.draw(0, 60, vector.create(rl.GetRenderWidth(), rl.GetRenderHeight() - 60), 50)

	if currentObject then
		if currentObject.IsOverridden then
			ide.text:clear()
			ide.text:insertString(currentObject.Source)
			ide.text:setCursor(1, 1)
			ide._highlightCache = {}
			return
		end
		currentObject.Source = ide:getCode()
	end
end

renderer.Pool.new("2d", function(data)
	if game.Context ~= Enum.GameContext.Editor then
		return
	end

	local dt = rl.GetFrameTime()
	local mainTheme = StudioThemeService.SelectedTheme

	profileBegin("Aereon render")
	ideWindow.enabled = enableIDE
	window.update(dt)
	window.draw(dt, mainTheme)
	profileEnd()
end)
