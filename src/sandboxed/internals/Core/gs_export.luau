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

	exportSection = {
		{
			name = "Executable Name",
			description = "Name of the generated executable file.",
			font = vend,
			editor = textbox.new({
				padding = 5,
				placeholder = "MyGame",
				cornerRadius = 0.4,
				fontSize = 14,

				onSubmit = function(value)
					ConfigService.prop("executable_name", value)
				end,
			}),
			backgroundColor = StudioThemeService.SelectedTheme.SecondaryBackgroundColor,
		},

		{
			name = "Package Identifier",
			description = "Unique identifier used for application packaging.",
			font = vend,
			editor = textbox.new({
				padding = 5,
				placeholder = "com.company.mygame",
				cornerRadius = 0.4,
				fontSize = 14,

				onSubmit = function(value)
					ConfigService.prop("package_identifier", value)
				end,
			}),
			backgroundColor = StudioThemeService.SelectedTheme.SecondaryBackgroundColor,
		},

		{
			name = "Target Platform",
			description = "Platform to build the game for.",
			font = vend,
			editor = gui.dropdown({
				options = {
					"Windows",
					"Linux",
					"macOS",
					"Web",
					"Android",
					"iOS",
				},

				onSelect = function(i, new)
					ConfigService.prop("target_platform", new)
				end,
			}),
			backgroundColor = StudioThemeService.SelectedTheme.SecondaryBackgroundColor,
		},

		{
			name = "Build Configuration",
			description = "Controls optimization and debugging features.",
			font = vend,
			editor = gui.dropdown({
				options = {
					"Debug",
					"Release",
				},

				onSelect = function(i, new)
					ConfigService.prop("build_configuration", new)
				end,
			}),
			backgroundColor = StudioThemeService.SelectedTheme.SecondaryBackgroundColor,
		},

		{
			name = "Compression Level",
			description = "Compression level used when packaging builds.",
			font = vend,
			editor = gui.dropdown({
				options = {
					"None",
					"Low",
					"Medium",
					"High",
					"Maximum",
				},

				onSelect = function(i, new)
					ConfigService.prop("compression_level", new)
				end,
			}),
			backgroundColor = StudioThemeService.SelectedTheme.SecondaryBackgroundColor,
		},

		{
			name = "Output Directory",
			description = "Directory where exported builds will be placed.",
			font = vend,
			editor = textbox.new({
				padding = 5,
				placeholder = "./Builds/Windows",
				cornerRadius = 0.4,
				fontSize = 14,

				onSubmit = function(value)
					ConfigService.prop("output_directory", value)
				end,
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
	name = "Export",
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
