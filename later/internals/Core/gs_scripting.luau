local aereon = require("@Aereon")
local Theme = game:GetService("StudioThemeService").SelectedTheme
local textbox = aereon.textbox(Theme, game)
local KinemiumFontService = game:GetService("KinemiumFontService")
local StudioThemeService = game:GetService("StudioThemeService")
local gui = aereon.gui
local vend = KinemiumFontService.GetDefaultFontSmall()
local rect = require("@arect")

local cells = gui.cellparser({
	x = 0,
	y = 0,
	width = 800,

	scriptingSection = {
		{
			name = "Script Timeout",
			description = "Maximum time a script can run before timing out (in seconds).",
			font = vend,
			editor = textbox.new({
				padding = 5,
				placeholder = "60",
				cornerRadius = 0.4,
				fontSize = 14,
				onSubmit = function(value) end,
			}),
			backgroundColor = StudioThemeService.SelectedTheme.SecondaryBackgroundColor,
		},
		{
			name = "Enable FFI",
			description = "Enable Foreign Function Interface for Luau scripts.",
			font = vend,
			editor = gui.checkbox({ value = false }),
			backgroundColor = StudioThemeService.SelectedTheme.SecondaryBackgroundColor,
		},
		{
			name = "Enable JIT",
			description = "Enable Just-In-Time compilation for Luau scripts.",
			font = vend,
			editor = gui.checkbox({ value = false }),
			backgroundColor = StudioThemeService.SelectedTheme.SecondaryBackgroundColor,
		},
		{
			name = "Enable Hot Reloading",
			description = "Enable hot reloading for script changes during playtesting.",
			font = vend,
			editor = gui.checkbox({ value = false }),
			backgroundColor = StudioThemeService.SelectedTheme.SecondaryBackgroundColor,
		},
		{
			name = "Warning Level",
			description = "Level of warnings to show for scripts (0-3).",
			font = vend,
			editor = textbox.new({
				padding = 5,
				placeholder = "1",
				cornerRadius = 0.4,
				fontSize = 14,
				onSubmit = function(value) end,
			}),
			backgroundColor = StudioThemeService.SelectedTheme.SecondaryBackgroundColor,
		},
	},
})

local scrollArea = gui.scrollable({
	child = cells,
	scrollbarWidth = 8,
	scrollbarColor = Theme.SecondaryBackgroundColor,
	scrollbarHoverColor = Theme.Accent,
	scrollbarBackground = Theme.ThirdBackgroundColor,
	scrollbarBackgroundTransparency = 0.7,
})

local PADDING = 12

game.EngineSignal:Fire("CreateGameSettingsTab", {
	name = "Scripting",
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
