-- devcell

local raylib = require("@raylib")
local lib = raylib.lib
local aereon = require("@Aereon")
local gui = aereon.gui

local KinemiumFontService = game:GetService("KinemiumFontService")
local StudioThemeService = game:GetService("StudioThemeService")

local vend = KinemiumFontService.GetDefaultFontSmall()
local arect = require("@arect")
local KinemiumIconLoader = game:GetService("KinemiumIconLoader")

local backgroundColor = StudioThemeService.SelectedTheme.BackgroundColor
local TextColor = StudioThemeService.SelectedTheme.TextColor:ToRaylib(StudioThemeService.SelectedTheme.TextTransparency)
StudioThemeService.SelectedTheme.GuiHandlesColor:ToRaylib(StudioThemeService.SelectedTheme.GuiHandlesTransparency)
local vsyncEnabled = false

local screenx, screeny = lib.GetRenderWidth(), lib.GetScreenHeight()

KinemiumIconLoader.new("Add", "./src/assets/images/icons/vanilla3/ui/16x/200/Add.png")

local textbox = aereon.textbox(StudioThemeService.SelectedTheme, game)
local group
local configService = game:GetService("ConfigService")

group = aereon.create({
	frame = {
		comp = "frame",
		x = 0,
		y = 0,
		width = screenx,
		height = screeny,
		zindex = 1,
	},

	title = {
		comp = "label",
		text = "Settings",
		x = 120,
		y = 120,
		font = vend,
		textColor = TextColor,
		backgroundColor = backgroundColor,
		zindex = 3,
	},
})

local cells = gui.cellparser({
	x = 0,
	y = 0,
	width = 800,

	cameraSection = {
		{
			name = "Camera speed",
			description = "Change the movement speed of the camera.",
			font = vend,
			editor = textbox.new({
				padding = 5,
				placeholder = "10",
				cornerRadius = 0.4,

				fontSize = 14,
				onSubmit = function(number)
					configService.prop("camera_speed", number)
				end,
			}),
			backgroundColor = StudioThemeService.SelectedTheme.SecondaryBackgroundColor,
		},

		{
			name = "Camera Sensitivity",
			description = "Change the sensitivity of the camera.",
			font = vend,
			editor = textbox.new({
				padding = 5,
				placeholder = "0.003",
				cornerRadius = 0.4,

				fontSize = 14,
				onSubmit = function(number)
					configService.prop("camera_sens", number)
				end,
			}),
			backgroundColor = StudioThemeService.SelectedTheme.SecondaryBackgroundColor,
		},
	},

	networking = {
		{
			name = "Marketplace Endpoint",
			description = "Changes the marketplace endpoint used for fetching plugins.",
			font = vend,
			editorWidth = 250,
			editor = textbox.new({
				padding = 5,
				placeholder = ENGINE_ENDPOINT.MARKETPLACE,
				cornerRadius = 0.4,
				text = ENGINE_ENDPOINT.MARKETPLACE,

				fontSize = 14,
				onSubmit = function(text)
					ENGINE_ENDPOINT.MARKETPLACE = text
				end,
			}),
			backgroundColor = StudioThemeService.SelectedTheme.SecondaryBackgroundColor,
		},
	},

	settingsSection = {
		{
			name = "Automatic updates",
			description = "Turn this off to prevent updates.",
			font = vend,
			editor = gui.checkbox({}),
			backgroundColor = StudioThemeService.SelectedTheme.SecondaryBackgroundColor,
		},
		{
			name = "Language",
			description = "Change interface language.",
			font = vend,
			editor = gui.dropdown({
				options = {
					"English",
					"Dutch",
					"Swedish",
					"Vietnamese",
				},

				onSelect = function(i, new)
					configService.prop("gui_language", new)
				end,
			}),
			backgroundColor = StudioThemeService.SelectedTheme.SecondaryBackgroundColor,
		},

		{
			name = "Theme",
			description = "Change display gui theme.",
			font = vend,
			backgroundColor = StudioThemeService.SelectedTheme.SecondaryBackgroundColor,
			editor = gui.dropdown({
				options = {
					"Dark",
					"White",
				},

				onSelect = function(i, new)
					configService.prop("gui_theme", new)
				end,
			}),
			editorWidth = 200,
		},
		{
			name = "Icon Pack",
			description = "Change display icon pack.",
			font = vend,
			backgroundColor = StudioThemeService.SelectedTheme.SecondaryBackgroundColor,
			editor = gui.filePickerButton({
				x = 10,
				y = 10,
				width = 250,
				height = 30,
				game = game,
				path = "C:/path/to/some/file.png", -- The currently selected path
				extensions = { { name = "Images", extensions = { "zip" } } }, -- Optional file extension filters
				onPathSelected = function(newPath)
					configService.prop("gui_iconpack", newPath)
				end,
			}),
			editorWidth = 200,
		},

		{
			name = "Font",
			description = "Change display font.",
			font = vend,
			backgroundColor = StudioThemeService.SelectedTheme.SecondaryBackgroundColor,
			editor = gui.filePickerButton({
				x = 10,
				y = 10,
				width = 250,
				height = 30,
				game = game,
				path = "C:/path/to/some/file.png", -- The currently selected path
				extensions = { { name = "Images", extensions = { "ttf", "otf" } } }, -- Optional file extension filters
				onPathSelected = function(newPath)
					KinemiumFontService.ReplaceDefaultFont(newPath)
					configService.prop("gui_font", newPath)
				end,
			}),
			editorWidth = 200,
		},
		{
			name = "Open project in IDE",
			description = "Launches the selected script editor; defaults to the engine's built-in editor.",
			font = vend,
			backgroundColor = StudioThemeService.SelectedTheme.SecondaryBackgroundColor,
			editor = gui.dropdown({
				options = {
					"Default",
					"VSCode",
					"Zed",
				},

				onSelect = function(i, new: string)
					configService.prop("code_editor_selected", new)
				end,
			}),
			editorWidth = 200,
		},
	},

	theming = {
		{
			name = "Window Background Color",
			description = "Determines the Background Color for the engine's Windows.",
			font = vend,
			backgroundColor = StudioThemeService.SelectedTheme.SecondaryBackgroundColor,
			editor = gui.colorPickerButton({
				x = 10,
				y = 10,
				width = 200,
				height = 32,
				color = StudioThemeService.SelectedTheme.aereon.window.BackgroundColor,
				alpha = StudioThemeService.SelectedTheme.aereon.window.BackgroundTransparency,
				showAlpha = true,
				onColorSelected = function(c, a)
					StudioThemeService.SelectedTheme.aereon.window.BackgroundColor = c
					StudioThemeService.SelectedTheme.aereon.window.BackgroundTransparency = c
				end,
			}),
			editorWidth = 200,
		},

		{
			name = "Window Text Color",
			description = "Determines the overall Text color for the engine's GUI",
			font = vend,
			backgroundColor = StudioThemeService.SelectedTheme.SecondaryBackgroundColor,
			editor = gui.colorPickerButton({
				x = 10,
				y = 10,
				width = 200,
				height = 32,
				color = StudioThemeService.SelectedTheme.aereon.window.TextColor,
				alpha = 0,
				showAlpha = true,
				onColorSelected = function(c, a)
					StudioThemeService.SelectedTheme.aereon.window.TextColor = c
					StudioThemeService.SelectedTheme.TextColor = c
				end,
			}),
			editorWidth = 200,
		},

		{
			name = "Window Secondary Color",
			description = "Determines the secondary color the engine uses.",
			font = vend,
			backgroundColor = StudioThemeService.SelectedTheme.SecondaryBackgroundColor,
			editor = gui.colorPickerButton({
				x = 10,
				y = 10,
				width = 200,
				height = 32,
				color = StudioThemeService.SelectedTheme.aereon.window.SecondaryBackgroundColor,
				alpha = 0,
				showAlpha = true,
				onColorSelected = function(c, a)
					StudioThemeService.SelectedTheme.aereon.window.SecondaryBackgroundColor = c
					StudioThemeService.SelectedTheme.SecondaryBackgroundColor = c
				end,
			}),
			editorWidth = 200,
		},

		{
			name = "Accent",
			description = "The general accent color for the engine's GUI",
			font = vend,
			backgroundColor = StudioThemeService.SelectedTheme.SecondaryBackgroundColor,
			editor = gui.colorPickerButton({
				x = 10,
				y = 10,
				width = 200,
				height = 32,
				color = StudioThemeService.SelectedTheme.Accent,
				alpha = 0,
				showAlpha = true,
				onColorSelected = function(c, a)
					StudioThemeService.SelectedTheme.Accent = c
					StudioThemeService.SelectedTheme.AccentTransparency = c
				end,
			}),
			editorWidth = 200,
		},
	},

	aboutSection = {
		{
			name = "Version " .. ENGINE_VERSION,
			font = vend,
			backgroundColor = StudioThemeService.SelectedTheme.SecondaryBackgroundColor,
		},

		{
			name = "Documentation",
			font = vend,

			editor = gui.textButton({
				text = "Open",
				onClick = function()
					raylib.lib.OpenURL(ENGINE_ENDPOINT.API)
				end,
			}),

			backgroundColor = StudioThemeService.SelectedTheme.SecondaryBackgroundColor,
		},
	},

	playtesting = {
		{
			name = "Server playtest flags",
			description = "Starts the server in playtest mode using the selected flags.",
			font = vend,
			backgroundColor = StudioThemeService.SelectedTheme.SecondaryBackgroundColor,
			editor = textbox.new({
				padding = 5,
				placeholder = "--headless",
				cornerRadius = 0.4,

				fontSize = 14,
				onSubmit = function(text)
					configService.prop("playtest_server_flags", text)
				end,
			}),
			editorWidth = 200,
		},

		{
			name = "Client playtest flags",
			description = "Starts the client in playtest mode using the selected flags.",
			font = vend,
			backgroundColor = StudioThemeService.SelectedTheme.SecondaryBackgroundColor,
			editor = textbox.new({
				padding = 5,
				placeholder = "None",
				cornerRadius = 0.4,

				fontSize = 14,
				onSubmit = function(text)
					configService.prop("playtest_client_flags", text)
				end,
			}),
			editorWidth = 200,
		},
	},

	window = {
		{
			name = "Toggle Fullscreen",
			description = "Makes the window fullscreen.",
			font = vend,
			backgroundColor = StudioThemeService.SelectedTheme.SecondaryBackgroundColor,
			editor = gui.checkbox({
				onChanged = function(new)
					raylib.lib.ToggleFullscreen()
				end,
			}),
			editorWidth = 200,
		},

		{
			name = "Window title",
			description = "Changes window title.",
			font = vend,
			backgroundColor = StudioThemeService.SelectedTheme.SecondaryBackgroundColor,
			editor = textbox.new({
				padding = 5,
				placeholder = "Kinemium Engine",
				cornerRadius = 0.4,

				fontSize = 14,
				onSubmit = function(text)
					raylib.lib.SetWindowTitle(text)
				end,
			}),
			editorWidth = 200,
		},

		{
			name = "VSync",
			description = "Toggles VSync.",
			font = vend,
			backgroundColor = StudioThemeService.SelectedTheme.SecondaryBackgroundColor,
			editor = gui.checkbox({
				onChanged = function(new)
					vsyncEnabled = new
					configService.prop("vsync", new)

					if vsyncEnabled then
						raylib.lib.SetWindowState(raylib.const.ConfigFlags.FLAG_VSYNC_HINT)
					else
						raylib.lib.ClearWindowState(raylib.const.ConfigFlags.FLAG_VSYNC_HINT)
					end
				end,
			}),
			editorWidth = 200,
		},

		{
			name = "Target FPS",
			description = "Sets the target framerate (0 = unlimited).",
			font = vend,
			backgroundColor = StudioThemeService.SelectedTheme.SecondaryBackgroundColor,
			editor = textbox.new({
				padding = 5,
				placeholder = "60",
				cornerRadius = 0.4,
				numeric = true,
				fontSize = 14,
				onSubmit = function(text)
					local fps = tonumber(text) or 0
					configService.prop("target_fps", fps)
					raylib.lib.SetTargetFPS(fps)
				end,
			}),
			editorWidth = 200,
		},

		{
			name = "Always on Top",
			description = "Forces the window to stay above others.",
			font = vend,
			backgroundColor = StudioThemeService.SelectedTheme.SecondaryBackgroundColor,
			editor = gui.checkbox({
				onChanged = function(new)
					configService.prop("window_topmost", new)
					if new then
						raylib.lib.SetWindowState(raylib.const.ConfigFlags.FLAG_WINDOW_TOPMOST)
					else
						raylib.lib.ClearWindowState(raylib.const.ConfigFlags.FLAG_WINDOW_TOPMOST)
					end
				end,
			}),
			editorWidth = 200,
		},

		{
			name = "Borderless Windowed",
			description = "Removes window borders and title bar.",
			font = vend,
			backgroundColor = StudioThemeService.SelectedTheme.SecondaryBackgroundColor,
			editor = gui.checkbox({
				onChanged = function(new)
					configService.prop("window_undecorated", new)
					if new then
						raylib.lib.SetWindowState(raylib.const.ConfigFlags.FLAG_WINDOW_UNDECORATED)
					else
						raylib.lib.ClearWindowState(raylib.const.ConfigFlags.FLAG_WINDOW_UNDECORATED)
					end
				end,
			}),
			editorWidth = 200,
		},
	},
})

local scrollArea = gui.scrollable({
	child = cells,
	scrollbarWidth = 8,
	scrollbarColor = StudioThemeService.SelectedTheme.SecondaryBackgroundColor,
	scrollbarHoverColor = StudioThemeService.SelectedTheme.Accent,
	scrollbarBackground = StudioThemeService.SelectedTheme.ThirdBackgroundColor,
	scrollbarBackgroundTransparency = 0.7,
})

group.frame.setTransparency(1)

repeat
	task.wait()
until ishared.Home

ishared.settings_cells = cells
ishared.settings_scrollArea = scrollArea

ishared.Home.pages["Settings"] = function(dt, alpha, slideOffset)
	if ishared.Home.activePage ~= "Settings" and ishared.Home.previousPage ~= "Settings" then
		return
	end

	screenx, screeny = lib.GetRenderWidth(), lib.GetScreenHeight()

	local x = 60
	local y = 60 + slideOffset

	group.frame.set("obj_rect", arect.new(x, y, screenx, screeny))
	group.title.set("obj_rect", arect.new(x + 60, y + 60, 200, 30))

	group.render(dt, { "newProjectPrompt" })
	vend = KinemiumFontService.GetDefaultFontSmall()
	cells.SetAllCellProp("font", vend)
	-- Render scroll area
	scrollArea.set("obj_rect", arect.new(x + 60, y + 100, screenx - 120, screeny - 160))
	cells.setWidth(screenx - 140)
	scrollArea.render(dt)
end
