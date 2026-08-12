local aereon = require("@Aereon")
local Theme = game:GetService("StudioThemeService").SelectedTheme
local textbox = aereon.textbox(Theme, game)
local KinemiumFontService = game:GetService("KinemiumFontService")
local StudioThemeService = game:GetService("StudioThemeService")
local gui = aereon.gui
local vend = KinemiumFontService.GetDefaultFontSmall()
local rect = require("@arect")
local ConfigService = game:GetService("ConfigService")

local cells = gui.cellparser({
	x = 0,
	y = 0,
	width = 800,

	renderingSection = {
		{
			name = "Renderer",
			description = "more backends coming in a future version.....",
			font = vend,
			editor = gui.dropdown({
				options = {
					"OpenGL",
				},

				onSelect = function(i, new)
					ConfigService.prop("renderer_backend", new)
				end,
			}),
			backgroundColor = StudioThemeService.SelectedTheme.SecondaryBackgroundColor,
		},

		{
			name = "MSAA Level",
			description = "Multi-sample anti-aliasing level.",
			font = vend,
			editor = gui.dropdown({
				options = {
					"Off",
					"2x",
					"4x",
					"8x",
				},

				onSelect = function(i, new)
					ConfigService.prop("msaa_level", new)
				end,
			}),
			backgroundColor = StudioThemeService.SelectedTheme.SecondaryBackgroundColor,
		},

		{
			name = "Shadow Quality",
			description = "Quality level used for shadow rendering.",
			font = vend,
			editor = gui.dropdown({
				options = {
					"Low",
					"Medium",
					"High",
					"Ultra",
				},

				onSelect = function(i, new)
					ConfigService.prop("msaa_level", new)
				end,
			}),
			backgroundColor = StudioThemeService.SelectedTheme.SecondaryBackgroundColor,
		},

		{
			name = "Render Distance",
			description = "Maximum distance objects are rendered.",
			font = vend,
			editor = textbox.new({
				padding = 5,
				placeholder = "1000",
				cornerRadius = 0.4,
				fontSize = 14,

				onSubmit = function(value) end,
			}),
			backgroundColor = StudioThemeService.SelectedTheme.SecondaryBackgroundColor,
		},

		{
			name = "HDR",
			description = "Enable high dynamic range rendering.",
			font = vend,
			editor = gui.checkbox({}),
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
	name = "Rendering",
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
