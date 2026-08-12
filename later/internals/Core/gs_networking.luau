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

	networkingSection = {
		{
			name = "Enable Networking",
			description = "Allow multiplayer and network communication.",
			font = vend,
			editor = gui.checkbox({ value = true }),

			backgroundColor = StudioThemeService.SelectedTheme.SecondaryBackgroundColor,
		},

		{
			name = "Default Port",
			description = "Port used for incoming network connections.",
			font = vend,
			editor = textbox.new({
				padding = 5,
				placeholder = "1234",
				cornerRadius = 0.4,
				fontSize = 14,

				onSubmit = function(value) end,
			}),
			backgroundColor = StudioThemeService.SelectedTheme.SecondaryBackgroundColor,
		},

		{
			name = "Max Players",
			description = "Maximum number of players allowed in a server.",
			font = vend,
			editor = textbox.new({
				padding = 5,
				placeholder = "16",
				cornerRadius = 0.4,
				fontSize = 14,

				onSubmit = function(value) end,
			}),
			backgroundColor = StudioThemeService.SelectedTheme.SecondaryBackgroundColor,
		},

		{
			name = "Tick Rate",
			description = "Number of network updates sent per second.",
			font = vend,
			editor = textbox.new({
				padding = 5,
				placeholder = "20",
				cornerRadius = 0.4,
				fontSize = 14,

				onSubmit = function(value) end,
			}),
			backgroundColor = StudioThemeService.SelectedTheme.SecondaryBackgroundColor,
		},

		{
			name = "Replication Distance",
			description = "Maximum distance at which objects replicate to clients.",
			font = vend,
			editor = textbox.new({
				padding = 5,
				placeholder = "512",
				cornerRadius = 0.4,
				fontSize = 14,

				onSubmit = function(value) end,
			}),
			backgroundColor = StudioThemeService.SelectedTheme.SecondaryBackgroundColor,
		},

		{
			name = "Compression Enabled",
			description = "Compress network packets to reduce bandwidth usage.",
			font = vend,
			editor = gui.checkbox({ value = true }),

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
	name = "Networking",
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
