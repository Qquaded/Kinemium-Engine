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

	physicsSection = {
		{
			name = "Solver Iterations",
			description = "Number of solver iterations for physics calculations.",
			font = vend,
			editor = textbox.new({
				padding = 5,
				placeholder = "8",
				cornerRadius = 0.4,
				fontSize = 14,
				onSubmit = function(value) end,
			}),
			backgroundColor = StudioThemeService.SelectedTheme.SecondaryBackgroundColor,
		},
		{
			name = "Sleep Threshold",
			description = "Minimum energy threshold for physics objects to go to sleep.",
			font = vend,
			editor = textbox.new({
				padding = 5,
				placeholder = "0.1",
				cornerRadius = 0.4,
				fontSize = 14,
				onSubmit = function(value) end,
			}),
			backgroundColor = StudioThemeService.SelectedTheme.SecondaryBackgroundColor,
		},
		{
			name = "Continuous Collision Detection",
			description = "Enable continuous collision detection to prevent tunneling.",
			font = vend,
			editor = gui.checkbox({ value = false }),
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
	name = "Physics",
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
