local aereon = require("@Aereon")
local Theme = game:GetService("StudioThemeService").SelectedTheme
local textbox = aereon.textbox(Theme, game)
local KinemiumFontService = game:GetService("KinemiumFontService")
local StudioThemeService = game:GetService("StudioThemeService")
local gui = aereon.gui
local vend = KinemiumFontService.GetDefaultFontSmall()
local rect = require("@arect")
local ConfigService = game:GetService("ConfigService")

local data = {
	x = 0,
	y = 0,
	width = 800,

	generalSection = {
		{
			name = "Game Name",
			description = "The name displayed for your game.",
			font = vend,
			editor = textbox.new({
				padding = 5,
				placeholder = ishared.GameName,
				cornerRadius = 0.4,
				fontSize = 14,

				onSubmit = function(value)
					ishared.GameName = value
					ConfigService.prop("game_name", value)
				end,
			}),
			backgroundColor = StudioThemeService.SelectedTheme.SecondaryBackgroundColor,
		},

		{
			name = "Game Description",
			description = "A short description of your game.",
			font = vend,
			editor = textbox.new({
				padding = 5,
				placeholder = "Enter game description...",
				cornerRadius = 0.4,
				fontSize = 14,

				onSubmit = function(value)
					ConfigService.prop("game_description", value)
				end,
			}),
			backgroundColor = StudioThemeService.SelectedTheme.SecondaryBackgroundColor,
		},

		{
			name = "Version",
			description = "Current game version.",
			font = vend,
			editor = textbox.new({
				padding = 5,
				placeholder = "1.0.0",
				cornerRadius = 0.4,
				fontSize = 14,

				onSubmit = function(value)
					ConfigService.prop("game_version", value)
				end,
			}),
			backgroundColor = StudioThemeService.SelectedTheme.SecondaryBackgroundColor,
		},

		{
			name = "Icon",
			description = "Path to the game's icon.",
			font = vend,
			editor = textbox.new({
				padding = 5,
				placeholder = "assets/icon.png",
				cornerRadius = 0.4,
				fontSize = 14,

				onSubmit = function(value)
					ConfigService.prop("game_icon", value)
				end,
			}),
			backgroundColor = StudioThemeService.SelectedTheme.SecondaryBackgroundColor,
		},
	},
}

local cells = gui.cellparser(data)

local scrollArea = gui.scrollable({
	child = cells,
	scrollbarWidth = 8,
	scrollbarColor = Theme.SecondaryBackgroundColor,
	scrollbarHoverColor = Theme.Accent,
	scrollbarBackground = Theme.ThirdBackgroundColor,
	scrollbarBackgroundTransparency = 0.7,
})

local game_name_editor = data.generalSection[1].editor
local PADDING = 12

game.EngineSignal:Connect(function(prop)
	if prop == "EnableGameSettingsMenu" then
		game_name_editor.placeholder = ishared.GameName
	end
end)

game.EngineSignal:Fire("CreateGameSettingsTab", {
	name = "General",
	render = function(wd)
		local contentOffsetY = wd._titleBarH + wd._tabBarH
		local contentH = wd.height - contentOffsetY
		vend = KinemiumFontService.GetDefaultFont()
		scrollArea.set(
			"obj_rect",
			rect.new(wd.x + PADDING, wd.y + contentOffsetY + PADDING, wd.width - PADDING * 2, contentH - PADDING * 2)
		)
		cells.setWidth(wd.width - PADDING * 2)
		cells.SetAllCellProp("font", vend)

		scrollArea.render(wd._dt or 0)
	end,
})
ishared.gsettings_window:SetTabByName("General")
