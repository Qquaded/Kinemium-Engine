local Aereon = require("@Aereon")
local gui = Aereon.gui
local kinemiumRaylib = game:GetService("KinemiumRaylib")
local renderer = kinemiumRaylib.GetRenderer()
local lib = kinemiumRaylib.GetLib()
local UserInputService = game:GetService("UserInputService")
local StudioThemeService = game:GetService("StudioThemeService")
local EngineSignal = game.EngineSignal
local BackgroundColor = StudioThemeService.SelectedTheme.BackgroundColor
local BackgroundTransparency = StudioThemeService.SelectedTheme.BackgroundTransparency
local files = {}

-- template: 		{ name = "commandPalette.luau", path = "src\\modules\\Aereon\\component\\objects", tag = "recently opened" },

local fileSearch = gui.fileSearch({
	game = game,
	width = 700,
	backgroundColor = BackgroundColor,
	backgroundTransparency = BackgroundTransparency,

	files = {},
	onOpen = function(file)
		EngineSignal:Fire("idestate", true, file.instance)
	end,
})

renderer.Pool.new("2d", function()
	local dt = lib.GetFrameTime()

	fileSearch.render(dt)

	if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
		if UserInputService:IsKeyPressed(Enum.KeyCode.P) then
			if ishared.EnableHomescreen == false then
				table.clear(files)
				for _, object in pairs(game:GetDescendants()) do
					if object.BaseClass == "ScriptContainer" then
						table.insert(files, {
							name = object.Name,
							path = object:GetFullName(),
							instance = object,
						})
					end
				end
				fileSearch.setFiles(files)
				fileSearch.toggle()
			end
		end
	end
end, -99999999)
