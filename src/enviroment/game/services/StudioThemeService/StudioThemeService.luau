local Instance = require("@Instance")
local Color3 = require("@Color3")
local UDim2 = require("@UDim2")
local Vector2 = require("@Vector2")

local StudioThemeService = Instance.new("StudioThemeService")
StudioThemeService.ExplorerHidden = true

StudioThemeService.InitRenderer = function(renderer, renderer_signal, datamodel)
	local themes = {
		dark = {
			WindowConfig = {
				Explorer = {
					position = UDim2.new(1, -20, 0, 40),
					anchorPoint = Vector2.new(1, 0),
					size = UDim2.new(0, 400, 0.38, 0),
				},
				Inspector = {
					position = UDim2.new(1, -20, 0.44, 0),
					anchorPoint = Vector2.new(1, 0),
					size = UDim2.new(0, 400, 0.55, 0),
				},
				Output = {
					position = UDim2.new(0, 20, 0.99, 0),
					anchorPoint = Vector2.new(0, 1),
					size = UDim2.new(1, -450, 0, 200),
				},
				Toolbar = {
					position = UDim2.new(0, 0, 0, 0),
					anchorPoint = Vector2.new(0, 0),
					size = UDim2.new(1, 0, 0, 170),
				},
				CodeEditor = {
					position = UDim2.new(0, 20, 0, 220),
					anchorPoint = Vector2.new(0, 0),
					size = UDim2.new(1, -420, 0.73, -20),
				},
			},
			TextColor = Color3.new(1, 1, 1),
			ImageColor = Color3.new(1, 1, 1),
			ImageTransparency = 0,
			GuiHandlesColor = Color3.new(0, 0, 1),
			GuiHandlesTransparency = 0,
			TextTransparency = 0,
			BackgroundColor = Color3.new(0, 0, 0),
			BackgroundTransparency = 0.3,
			SecondaryTextTransparency = 0,
			SecondaryTextColor = Color3.new(0.541176, 0.541176, 0.541176),
			SecondaryBackgroundColor = Color3.new(0.05, 0.05, 0.05),
			ThirdBackgroundColor = Color3.new(0.15, 0.15, 0.15),
			SecondaryBackgroundColorTransparency = 0,
			Accent = Color3.new(1, 0.5490196078431373, 0),
			AccentTransparency = 0,
			WindowBackgroundColor = Color3.new(0, 0, 0),
			WindowBackgroundTransparency = 0.05,
			TitleTextSize = 16,
			WindowTitleHeight = 29,
			ShadowsEnabled = true,
			ShadowTransparency = 0.98,
			CornerRadius = 15,
			ShadowColor = Color3.new(0, 0, 0),
			ArrowImageColor = Color3.new(1, 1, 1),
			TitleColor = Color3.new(1, 1, 1),

			aereon = {
				window = {
					BackgroundColor = Color3.new(0, 0, 0),
					BackgroundTransparency = 1,
					TextColor = Color3.new(1, 1, 1),
					SecondaryBackgroundColor = Color3.new(0.05, 0.05, 0.05),
					DragColor = Color3.new(0.02, 0.5, 1),
					DragOutlineTransparency = 1,
					TitleBackgroundTransparency = 0,
					TitleTextSize = 16,
					TitleColor = Color3.new(1, 1, 1),
					TitleHeight = 29,
					ShadowsEnabled = true,
					ShadowTransparency = 0.98,
					ShadowColor = Color3.new(0, 0, 0),
				},

				ide = {
					BackgroundColor = Color3.fromRGB(16, 20, 28),
					SecondaryBackgroundColor = Color3.new(0.07, 0.07, 0.07),
					TextColor = Color3.new(1, 1, 1),
					currentLineColor = Color3.new(0.2, 0.2, 0.2),

					autocomplete = {
						BackgroundColor = Color3.new(0.07, 0.07, 0.07),
						OutlineColor = Color3.new(1, 1, 1),
						ItemSelectColor = Color3.new(0, 0, 0.3),
						OutlineThickness = 0.6,
						OutlineTransparency = 0.8,
						CornerRadius = 0.2,

						Width = 200,
						Height = 20,
						ListPadding = 5,
					},
				},
			},
		},
	}

	themes.dark.aereon.window.BackgroundColor = themes.dark.WindowBackgroundColor
	themes.dark.aereon.window.BackgroundTransparency = themes.dark.WindowBackgroundTransparency
	themes.dark.aereon.window.TextColor = themes.dark.TextColor
	themes.dark.aereon.window.SecondaryBackgroundColor = themes.dark.SecondaryBackgroundColor
	themes.dark.aereon.window.DragColor = themes.dark.Accent
	themes.dark.aereon.window.DragOutlineTransparency = themes.dark.AccentTransparency
	themes.dark.aereon.window.TitleBackgroundTransparency = themes.dark.SecondaryBackgroundColorTransparency
	themes.dark.aereon.window.TitleTextSize = themes.dark.TitleTextSize
	themes.dark.aereon.window.TitleColor = themes.dark.TitleColor
	themes.dark.aereon.window.TitleHeight = themes.dark.WindowTitleHeight
	themes.dark.aereon.window.ShadowsEnabled = themes.dark.ShadowsEnabled
	themes.dark.aereon.window.ShadowTransparency = themes.dark.ShadowTransparency
	themes.dark.aereon.window.ShadowColor = themes.dark.ShadowColor
	themes.dark.aereon.window.CornerRadius = themes.dark.CornerRadius

	StudioThemeService:SetProperties({
		themes = themes,
		SelectedTheme = themes.dark,
	})
end

return StudioThemeService
