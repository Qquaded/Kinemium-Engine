local Instance = require("@Instance")
local Color3 = require("@Color3")
local UDim2 = require("@UDim2")
local Vector2 = require("@Vector2")
local Enum = require("@EnumMap")
local StudioTheme = require("@StudioTheme")

local StudioThemeService = Instance.new("StudioThemeService")
StudioThemeService.ExplorerHidden = true
StudioThemeService._Intents = Enum.PluginIntents.UI

StudioThemeService.InitRenderer = function(renderer, renderer_signal, datamodel)
	local argon = require("@argon")
	local P = 4
	local TopH = 26
	local BottomPad = 12
	local showOutput = true

	local function getCoordinates()
		local viewportTop = 2 * P + TopH
		local viewportHeight = showOutput and 0.7 or 1
		local viewportHeightOffset = showOutput and -(viewportTop + P / 2) or -(viewportTop + BottomPad)

		local outputCoordinates = showOutput
				and {
					Size = UDim2.new(0.78, -P * 1.5, 0.3, -(P / 2 + P + BottomPad)),
					Position = UDim2.new(0, P, 0.7, P / 2),
				}
			or {
				Size = UDim2.new(0, 0, 0, 0),
				Position = UDim2.new(0, 0, 1, 0),
			}

		return {
			TopbarCoordinates = {
				Size = UDim2.new(1, -P * 2, 0, TopH),
				Position = UDim2.new(0, P, 0, P),
			},

			ViewportCoordinates = {
				Size = UDim2.new(0.78, -P * 1.5, viewportHeight, viewportHeightOffset),
				Position = UDim2.new(0, P, 0, viewportTop),
			},

			OutputCoordinates = outputCoordinates,

			ExplorerCoordinates = {
				Size = UDim2.new(0.22, -P * 1.5, 0.5, -(2 * P + TopH + P / 2)),
				Position = UDim2.new(0.78, P / 2, 0, 2 * P + TopH),
			},

			InspectorCoordinates = {
				Size = UDim2.new(0.22, -P * 1.5, 0.5, -(P / 2 + P + BottomPad)),
				Position = UDim2.new(0.78, P / 2, 0.5, P / 2),
			},
		}
	end

	local Coordinates = getCoordinates()

	local default = {
		BaseColor = argon:RGBA(15, 15, 15),
		BgColor = argon:RGBA(35, 35, 35),
		AccentColor = argon:RGBA(214, 133, 37),
		SecondaryColor = argon:RGBA(43, 43, 43),
		ThirdColor = argon:RGBA(25, 25, 25),
		TextColor = argon:RGBA(220, 220, 220),
		CornerRadius = 4,
		ButtonCornerRadius = 8,
		Font = "./src/assets/fonts/Montserrat-Regular.ttf",
		FontBold = "./src/assets/fonts/Montserrat-Regular.ttf",

		TopbarCoordinates = Coordinates.TopbarCoordinates,
		ViewportCoordinates = Coordinates.ViewportCoordinates,
		OutputCoordinates = Coordinates.OutputCoordinates,
		ExplorerCoordinates = Coordinates.ExplorerCoordinates,
		InspectorCoordinates = Coordinates.InspectorCoordinates,
	}

	--[[
	local system_theme = argon:GetSystemTheme()
	if system_theme == "dark" then
		default.BaseColor = argon:RGBA(15, 15, 15)
		default.BgColor = argon:RGBA(35, 35, 35)
		default.AccentColor = argon:RGBA(214, 133, 37)
		default.SecondaryColor = argon:RGBA(43, 43, 43)
		default.ThirdColor = argon:RGBA(25, 25, 25)
		default.TextColor = argon:RGBA(220, 220, 220)
	elseif system_theme == "light" then
		default.BaseColor = argon:RGBA(233, 233, 233)
		default.BgColor = argon:RGBA(245, 245, 245)
		default.AccentColor = argon:RGBA(214, 133, 37)
		default.SecondaryColor = argon:RGBA(235, 235, 235)
		default.ThirdColor = argon:RGBA(255, 255, 255)
		default.TextColor = argon:RGBA(35, 35, 35)
	end
	--]]

	function StudioThemeService:ChangeLayoutSettings(padding, headerHeight, bottomPadding)
		P = padding
		TopH = headerHeight
		bottomPadding = BottomPad

		default.TopbarCoordinates = {
			Size = UDim2.new(1, -P * 2, 0, TopH),
			Position = UDim2.new(0, P, 0, P),
		}
		default.ViewportCoordinates = {
			Size = UDim2.new(0.78, -P * 1.5, 0.7, -(2 * P + TopH + P / 2)),
			Position = UDim2.new(0, P, 0, 2 * P + TopH),
		}
		default.OutputCoordinates = {
			Size = UDim2.new(0.78, -P * 1.5, 0.3, -(P / 2 + P + BottomPad)),
			Position = UDim2.new(0, P, 0.7, P / 2),
		}
		default.ExplorerCoordinates = {
			Size = UDim2.new(0.22, -P * 1.5, 0.5, -(2 * P + TopH + P / 2)),
			Position = UDim2.new(0.78, P / 2, 0, 2 * P + TopH),
		}
		default.InspectorCoordinates = {
			Size = UDim2.new(0.22, -P * 1.5, 0.5, -(P / 2 + P + BottomPad)),
			Position = UDim2.new(0.78, P / 2, 0.5, P / 2),
		}
	end

	local themeObject = Instance.new("StudioTheme")
	StudioTheme.callback(themeObject)

	StudioThemeService:SetProperties({
		SelectedTheme = default,
		ThemeObject = themeObject,
	})

	function StudioThemeService:GetTheme()
		return default
	end

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
