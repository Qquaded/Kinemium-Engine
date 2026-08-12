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

	httpRequestsSection = {
		{
			name = "Enable HTTP Requests",
			description = "Allow scripts to make HTTP requests.",
			font = vend,
			editor = gui.checkbox({ value = false }),
			backgroundColor = StudioThemeService.SelectedTheme.SecondaryBackgroundColor,
		},
		{
			name = "Allowed Domains",
			description = "Comma-separated list of domains allowed for HTTP requests.",
			font = vend,
			editor = textbox.new({
				padding = 5,
				placeholder = "example.com,api.example.com",
				cornerRadius = 0.4,
				fontSize = 14,
				onSubmit = function(value) end,
			}),
			backgroundColor = StudioThemeService.SelectedTheme.SecondaryBackgroundColor,
		},
		{
			name = "Request Timeout",
			description = "Maximum time (in seconds) to wait for an HTTP request to complete.",
			font = vend,
			editor = textbox.new({
				padding = 5,
				placeholder = "30",
				cornerRadius = 0.4,
				fontSize = 14,
				onSubmit = function(value) end,
			}),
			backgroundColor = StudioThemeService.SelectedTheme.SecondaryBackgroundColor,
		},
		{
			name = "Max Requests Per Minute",
			description = "Maximum number of HTTP requests allowed per minute.",
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
			name = "Enable WebSockets",
			description = "Allow scripts to open WebSocket connections.",
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
	name = "HTTP Requests",
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
