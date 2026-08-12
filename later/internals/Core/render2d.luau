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
local const = KinemiumRaylib.GetConst()
local KinemiumFontService = game:GetService("KinemiumFontService")
local StudioThemeService = game:GetService("StudioThemeService")
local Filesystem = require("@filesystem")

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
local currentFile = nil -- { path, uniqueId } when editing a plain file from filebrowser
local activeTabs = {}
local activeFileTabs = {} -- uniqueId -> path

EngineSignal:Connect(function(route, value, Script)
	if route == "idestate" then
		if value == true then
			currentFile = nil
			if activeTabs[Script.UniqueId] then
				for i, tab in ipairs(ide.buffers) do
					if tab.name == Script.Name then
						ide:activateBuffer(i)
						break
					end
				end
				enableIDE = true
				currentObject = Script
				ide.text:clear()
				ide.text:insertString(currentObject.Source)
				ide.text:setCursor(1, 1)
				ide._highlightCache = {}

				game.Stop3DInput = true
				return
			end
			ide:openTab(Script.Name, Script.Source)
			activeTabs[Script.UniqueId] = true
			-- activateBuffer is already called inside openTab via #self.buffers
			enableIDE = true
			currentObject = Script
			game.Stop3DInput = true
		else
			enableIDE = false
			currentObject = nil
			game.Stop3DInput = false
		end
	elseif route == "OpenFile" then
		local path = value
		if not path then
			return
		end

		local filename = path:match("([^/\\]+)$") or path

		local fileUniqueId = "__file__" .. path

		if activeFileTabs[fileUniqueId] then
			for i, tab in ipairs(ide.buffers) do
				if tab.name == filename then
					ide:activateBuffer(i)
					break
				end
			end
			currentObject = nil
			currentFile = { path = path, uniqueId = fileUniqueId }
			enableIDE = true
			game.Stop3DInput = true
			return
		end

		local ok, content = pcall(Filesystem.read, path)
		if not ok then
			content = "-- Could not read file: " .. tostring(content)
		end
		content = content or ""

		ide:openTab(filename, content)
		activeFileTabs[fileUniqueId] = path

		currentObject = nil
		currentFile = { path = path, uniqueId = fileUniqueId }
		enableIDE = true
		game.Stop3DInput = true
	end
end)
local window = aereon.window(game)

repeat
	task.wait()
until frame.AbsolutePosition and frame.AbsoluteSize

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

renderer.Pool.new("2d", function(data)
	if game.Context ~= Enum.GameContext.Editor then
		return
	end

	local dt = rl.GetFrameTime()
	vend = KinemiumFontService.GetDefaultFont()

	frame.Position = Theme.WindowConfig.CodeEditor.position
	frame.AnchorPoint = Theme.WindowConfig.CodeEditor.anchorPoint
	frame.Size = Theme.WindowConfig.CodeEditor.size

	if enableIDE then
		ishared.path_enabled = false

		local width = frame.AbsoluteSize.X
		local height = frame.AbsoluteSize.Y
		ide.draw(
			frame.AbsolutePosition.X,
			frame.AbsolutePosition.Y,
			vector.create(width, height),
			50,
			StudioThemeService.SelectedTheme.aereon.ide
		)

		if currentObject then
			if currentObject.IsOverridden then
				ide.text:clear()
				ide.text:insertString(currentObject.Source)
				ide.text:setCursor(1, 1)
				ide._highlightCache = {}
				return
			end
			currentObject.Source = ide:getCode()
		elseif currentFile then
			-- Write file changes back to disk
			local ok = pcall(Filesystem.write, currentFile.path, ide:getCode())
		end
	else
		ishared.path_enabled = true
	end

	window.update(dt)
	window.draw(dt, StudioThemeService.SelectedTheme, renderer.Lib2d)
end, -999999)
-- we need this to draw as the very first item before all the other windows
