local immco = require("@Immco")
local RunService = game:GetService("RunService")
local StudioThemeService = game:GetService("StudioThemeService")
local KinemiumRaylib = game:GetService("KinemiumRaylib")
local renderer = KinemiumRaylib.GetRenderer()
local rl = require("@RaylibAdapter").lib

local lib = immco:Init(game, StudioThemeService.SelectedTheme)

lib:Widget(function(window)
	lib:BeginList()
	lib:Text("Name:")
	lib:SameLine()

	lib:TextButton("Play", 120, 18, function()
		print("Clicked!")
	end, 16)

	lib:Separator()

	lib:Text("Indented block:")
	lib:Indent()
	lib:Text("child A")
	lib:Text("child B")
	lib:Unindent()

	lib:Separator()

	local graph = lib:Graph(nil, 150, {
		capacity = 120,
		lineColor = Color3.new(0.02, 0.5, 1),
		bgColor = Color3.new(0.1, 0.1, 0.1),
		min = 0,
		max = 200,
	})

	graph.push(rl.GetFPS())

	lib:EndList()
end)

renderer.Pool.new("2d", function(data)
	local dt = rl.GetFrameTime()
	immco:Render(dt)
end)
