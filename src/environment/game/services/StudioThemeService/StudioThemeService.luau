local Instance = require("@Instance")
local Color3 = require("@Color3")
local UDim2 = require("@UDim2")
local Vector2 = require("@Vector2")
local Enum = require("@EnumMap")
local StudioTheme = require("@StudioTheme")

local const = require("@raylib").const

local StudioThemeService = Instance.new("StudioThemeService")
StudioThemeService.ExplorerHidden = true
StudioThemeService._Intents = Enum.PluginIntents.UI

local json5 = zune.serde.json5

StudioThemeService.InitRenderer = function(renderer, renderer_signal, datamodel)
	local themes = {
		dark = {
			WindowConfig = {
				Explorer = {
					position = UDim2.new(1, -20, 0, 40),
					anchorPoint = Vector2.new(1, 0),
					size = UDim2.new(0, 400, 0.38, 0),
				},
				GameSettings = {
					position = UDim2.new(0.5, 0, 0.5, 0),
					anchorPoint = Vector2.new(0.5, 0.5),
					size = UDim2.new(0.5, 0, 0.7, 0),
				},
				Toolbox = {
					position = UDim2.new(0.5, 0, 0.5, 0),
					anchorPoint = Vector2.new(0.5, 0.5),
					size = UDim2.new(0.6, 0, 0.7, 0),
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
					position = UDim2.new(0, 20, 0, 40),
					anchorPoint = Vector2.new(0, 0),
					size = UDim2.new(0, 800, 0, 600),
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
			Accent = Color3.new(1, 1, 1),
			AccentTransparency = 0,
			WindowBackgroundColor = Color3.new(0, 0, 0),
			WindowBackgroundTransparency = 0.15,
			TitleTextSize = 16,
			WindowTitleHeight = 29,
			ShadowsEnabled = true,
			ShadowTransparency = 0.98,
			CornerRadius = 0,
			ShadowColor = Color3.new(0, 0, 0),
			ArrowImageColor = Color3.new(1, 1, 1),
			TitleColor = Color3.new(1, 1, 1),

			aereon = {
				window = {
					BackgroundColor = Color3.new(0, 0, 0),
					BackgroundTransparency = 0.15,
					TextColor = Color3.new(1, 1, 1),
					SecondaryBackgroundColor = Color3.new(0.05, 0.05, 0.05),
					DragColor = Color3.new(0.02, 0.5, 1),
					DragOutlineTransparency = 1,
					TitleBackgroundTransparency = 0,
					TitleTextSize = 16,
					TitleColor = Color3.new(1, 1, 1),
					TitleHeight = 29,
					ShadowsEnabled = false,
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

					codecolors = {
						keyword = Color3.fromRGB(0, 191, 255), -- SKYBLUE
						builtin = Color3.fromRGB(255, 0, 255), -- MAGENTA
						stdlib = Color3.fromRGB(148, 0, 211), -- VIOLET
						string = Color3.fromRGB(0, 255, 0), -- GREEN
						number = Color3.fromRGB(255, 165, 0), -- ORANGE
						operator = Color3.fromRGB(0, 0, 255), -- BLUE
						comment = Color3.fromRGB(128, 128, 128), -- GRAY
						field = Color3.fromRGB(255, 255, 0), -- YELLOW
						method = Color3.fromRGB(255, 255, 0), -- YELLOW
						functionName = Color3.fromRGB(255, 215, 0), -- GOLD
						default = Color3.fromRGB(255, 255, 255), -- WHITE
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

	local themeObject = Instance.new("StudioTheme")
	StudioTheme.callback(themeObject)

	StudioThemeService:SetProperties({
		themes = themes,
		SelectedTheme = themes.dark,
		ThemeObject = themeObject,
	})

	function StudioThemeService.MakeUIPadded()
		StudioThemeService.SelectedTheme.WindowConfig = {
			Explorer = {
				position = UDim2.new(1, -20, 0, 40),
				anchorPoint = Vector2.new(1, 0),
				size = UDim2.new(0, 400, 0.38, 0),
			},
			GameSettings = {
				position = UDim2.new(0.5, 0, 0.5, 0),
				anchorPoint = Vector2.new(0.5, 0.5),
				size = UDim2.new(0.5, 0, 0.7, 0),
			},
			Toolbox = {
				position = UDim2.new(0.5, 0, 0.5, 0),
				anchorPoint = Vector2.new(0.5, 0.5),
				size = UDim2.new(0.6, 0, 0.7, 0),
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
				position = UDim2.new(0, 20, 0, 40),
				anchorPoint = Vector2.new(0, 0),
				size = UDim2.new(0, 800, 0, 600),
			},
		}
	end

	function StudioThemeService.MakeUIBoxed()
		local xSize = 350
		StudioThemeService.SelectedTheme.WindowConfig = {
			Toolbar = {
				position = UDim2.new(0, 0, 0, 0),
				anchorPoint = Vector2.new(0, 0),
				size = UDim2.new(1, 0, 0, 200),
			},
			Explorer = {
				position = UDim2.new(1, 0, 0, 30),
				anchorPoint = Vector2.new(1, 0),
				size = UDim2.new(0, xSize, 0.5, -50),
			},
			Inspector = {
				position = UDim2.new(1, 0, 0.5, -20),
				anchorPoint = Vector2.new(1, 0),
				size = UDim2.new(0, xSize, 0.5, 20),
			},
			CodeEditor = {
				position = UDim2.new(0, xSize, 0, 0),
				anchorPoint = Vector2.new(0, 0),
				size = UDim2.new(1, -xSize * 2, 1, -200),
			},
			Output = {
				position = UDim2.new(0, 0, 1, 0),
				anchorPoint = Vector2.new(0, 1),
				size = UDim2.new(1, -xSize, 0, 200),
			},
			GameSettings = {
				position = UDim2.new(0.5, 0, 0.5, 0),
				anchorPoint = Vector2.new(0.5, 0.5),
				size = UDim2.new(0.5, 0, 0.7, 0),
			},
			Toolbox = {
				position = UDim2.new(0.5, 0, 0.5, 0),
				anchorPoint = Vector2.new(0.5, 0.5),
				size = UDim2.new(0.6, 0, 0.7, 0),
			},
			FileBrowser = {
				position = UDim2.new(0, 0, 1, 0),
				anchorPoint = Vector2.new(0, 1),
				size = UDim2.new(0, xSize, 1, -20),
			},
		}
	end

	function StudioThemeService:ExportThemeAsJson()
		local function serialize(tbl)
			local result = {}

			for key, value in pairs(tbl) do
				if type(value) ~= "table" then
					result[key] = value
				elseif value.type then
					-- Userdata object (Color3, UDim2, etc.)

					if value.type == "Color3" then
						result[key] = Color3.fromHex(value)
					else
						print(value.type)
						result[key] = value:ToTable()
					end
				else
					-- Nested table
					result[key] = serialize(value)
				end
			end

			return result
		end

		local jsonCompat = serialize(themes.dark)
		local encoded = zune.serde.json.encode(jsonCompat)

		zune.fs.writeFile("./src/theme.json", encoded)

		return encoded
	end

	function StudioThemeService:LoadThemeJson(theme) end

	StudioThemeService.MakeUIBoxed()
end

return StudioThemeService
