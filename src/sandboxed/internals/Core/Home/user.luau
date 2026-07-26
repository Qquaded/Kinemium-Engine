local aereon = require("@Aereon")
local gui = aereon.gui
local RunService = game:GetService("RunService")
local rect = require("@Arect")
local KinemiumRaylib = game:GetService("KinemiumRaylib")
local KinemiumFontService = game:GetService("KinemiumFontService")
local imageButton = gui.imageButton({})
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local interface = require("@raylibadapter")
local rl = interface.lib
local renderer = KinemiumRaylib.GetRenderer()

local structs = interface.structs
local vend = KinemiumFontService.GetDefaultFont()
local Theme = game:GetService("StudioThemeService").SelectedTheme
local fileService = game:GetService("KineFileService")
local ProjectLoaderService = game:GetService("ProjectLoaderService")
local enableMenu = false
local HTTPService = game:GetService("HTTPService")

local fileMenu = gui.menu({
	x = 0,
	y = 0,
	width = 200,
	height = 300,
	Font = vend,
	visible = false,
	items = {
		{ type = "category", label = "ACCOUNT" },

		{
			label = "Sign In",
			onClick = function()
				game.EngineSignal:Fire("EnableStudioSettingsMenu")
			end,
		},
		{
			label = "Create Account",
			onClick = function()
				game.EngineSignal:Fire("EnableStudioSettingsMenu")
			end,
		},

		{ type = "separator" },

		{
			label = "Switch Account",
			onClick = function()
				game.EngineSignal:Fire("EnableStudioSettingsMenu")
			end,
		},
		{
			label = "Sign Out",
			onClick = function()
				game.EngineSignal:Fire("EnableStudioSettingsMenu")
			end,
		},

		{ type = "separator" },

		{
			label = "Manage Account",
			onClick = function()
				game.EngineSignal:Fire("EnableStudioSettingsMenu")
			end,
		},
	},
}, interface)

local button = gui.imageButton({
	width = 0,
	height = 0,
	onClick = function()
		enableMenu = not enableMenu
	end,
})

renderer.Pool.new("2d", function(data)
	if not ishared.EnableHomescreen then
		return
	end
	local x = rl.GetRenderWidth() - 50
	local y = 10
	local dt = rl.GetFrameTime()
	button.render(dt)
	button.set("obj_rect", rect.new(x, y, 40, 40))

	if enableMenu then
		fileMenu.set("obj_rect", rect.new(x - 160, y + 50, 200, 300))
		fileMenu.set("visible", true)
		fileMenu.render(dt)
	end
end)
