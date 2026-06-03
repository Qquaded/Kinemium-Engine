-- devcell
--[[
local KinemiumRaylib = game:GetService("KinemiumRaylib")
local RunService = game:GetService("RunService")
if RunService:IsServer() then
	return
end

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local rl = KinemiumRaylib.GetLib()
local structs = KinemiumRaylib.GetStructs()
local StudioThemeService = game:GetService("StudioThemeService")
local ScriptContext = game:GetService("ScriptContext")

if game.Context ~= Enum.GameContext.Editor then
	return
end

if FlagExists("cli") or FlagExists("headless") then
	return
end

local aereon = require("@Aereon")
local arect = require("@arect")
local Theme = StudioThemeService.SelectedTheme

local syntax_highlighter = require("@syntax_highlighter")
local syntax_autocomplete = require("@syntax_autocomplete")
local textbox = aereon.textbox(Theme, game)
local vend = game:GetService("KinemiumFontService").GetDefaultFont()

local box = textbox.new({
	multiline = true,
	placeholder = 'return function(parent)\n\tlocal frame = Instance.new("Frame")\n\tframe.Parent = parent\n\treturn frame\nend',
	fontSize = 16,
	font = vend,
	backgroundColor = Theme.SecondaryBackgroundColor,
	borderColor = Theme.SecondaryBackgroundColor,
	syntaxHighlighter = syntax_highlighter.highlight,
	autocompleteProvider = syntax_autocomplete,
})

local defaultCode = [[return function(parent)
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, 0, 1, 0)
	frame.BackgroundColor3 = Color3.new(0.15, 0.15, 0.15)
	frame.Parent = parent

	local textLabel = Instance.new("TextLabel")
	textLabel.Size = UDim2.new(1, 0, 0, 50)
	textLabel.Position = UDim2.new(0, 0, 0.5, -25)
	textLabel.Text = "Hello from UI Builder!"
	textLabel.TextColor3 = Color3.new(1, 1, 1)
	textLabel.BackgroundTransparency = 1
	textLabel.Parent = frame

	return frame
end

box:setText(defaultCode)

local viewerGui = Instance.new("ScreenGui")
viewerGui.Name = "UIBuilderViewer"

local window = aereon.window(game, nil, 1)
local renderer = KinemiumRaylib.GetRenderer()

local comps = aereon.create({
	runButton = {
		comp = "textButton",
		text = "Run Code",
		x = 0,
		y = 0,
		width = 100,
		height = 30,
		onClick = function()
			local source = box:getText()

			local thread, id, success, result =
				ScriptContext.RunSource(source, "Luau", "UIBuilderScript" .. math.random(1, 1000))

			if result then
				local success, object = pcall(result, viewerGui)
				if success and object then
					for _, child in pairs(viewerGui:GetChildren()) do
						child:Destroy()
					end
					object.Parent = viewerGui
				end
			else
				warn("UI Builder Compilation Error:", result)
			end
		end,
	},
	viewer = {
		comp = "engineUIContainer",
		x = 0,
		y = 0,
		width = 100,
		height = 100,
		instance = viewerGui,
		datamodel = game,
		renderer = renderer,
	},
})

local myWindow = window.create({
	title = "UI Builder",
	x = 300,
	y = 200,
	width = 800,
	height = 500,
	tabs = {
		{
			name = "Editor",
			render = function(windowData)
				local pad = 10
				local winW = windowData.width
				local winH = windowData.height
				local winX = windowData.x
				local winY = windowData.y + 30

				local leftWidth = winW * 0.5 - pad * 1.5
				local rightWidth = winW * 0.5 - pad * 1.5
				local contentHeight = winH - 30 - pad * 2

				box:drawWithExtras(winX + pad, winY + pad + 25, leftWidth, contentHeight - 70)

				comps.setprop(
					"runButton",
					"obj_rect",
					arect.new(winX + pad, winY + pad + contentHeight - 30, leftWidth, 30)
				)

				-- Draw a background for the viewer area
				rl.DrawRectangle(
					winX + leftWidth + pad * 2,
					winY + pad,
					rightWidth,
					contentHeight,
					structs.Color:new({ r = 40, g = 40, b = 40, a = 255 })
				)

				comps.setprop(
					"viewer",
					"obj_rect",
					arect.new(winX + leftWidth + pad * 2, winY + pad, rightWidth, contentHeight)
				)

				comps.render(rl.GetFrameTime())
			end,
		},
	},
})

renderer.Pool.new("2d", function(data)
	if game.Context ~= Enum.GameContext.Editor then
		return
	end

	local dt = rl.GetFrameTime()
	local mainTheme = StudioThemeService.SelectedTheme

	window.update(dt)
	window.draw(dt, mainTheme.aereon)
end)
--]]
