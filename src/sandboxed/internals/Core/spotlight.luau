--[[
local aereon = require("@Aereon")
local gui = aereon.gui

local KinemiumRaylib = game:GetService("KinemiumRaylib")
local EngineSignal = game.EngineSignal
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local renderer = KinemiumRaylib.renderer

local browser = gui.fileSearch({
	x = 50,
	y = 50,
	width = 400,
	height = 300,
	files = {
		{ name = "main.lua", path = "C:/Projects/main.lua", type = "lua" },
		{ name = "readme.txt", path = "C:/Projects/readme.txt", type = "file" },
	},
	recentlyOpened = {
		{ name = "old.lua", path = "C:/Projects/old.lua", type = "lua" },
	},
	onFileSelect = function(file)
		print("Selected file:", file.name, file.path)
	end,
	onClose = function()
		print("Browser closed")
	end,
})

renderer.Pool.new("2d", function(data)
	if game.Context ~= Enum.GameContext.Editor then
		return
	end
	browser.render(data)
end)
--]]
