local Instance = require("@Instance")
local adapter = require("@RaylibAdapter")
local Enum = require("@Enum")
local Vector2 = require("@Vector2")

local TextService = Instance.new("TextService")
TextService.ExplorerHidden = true
TextService._Intents = Enum.PluginIntents.UI

TextService.InitRenderer = function(renderer, signal, datamodel)
	TextService:SetProperties({
		MeasureText = function(text, font, textSize, spacing)
			local baseFontName
			if type(font) == "table" and font.Value then
				baseFontName = font.Value
			elseif type(font) == "string" then
				baseFontName = font
			else
				baseFontName = Enum.Font.DefaultEngineFont.Value
			end
			local resolvedFont = renderer.Font.Get(baseFontName)
			if not resolvedFont then
				resolvedFont = renderer.Font.Get(Enum.Font.DefaultEngineFont.Value) or adapter.lib.GetFontDefault()
			end
			local measured = adapter.lib.MeasureTextEx(resolvedFont, text, textSize, spacing)
			return Vector2.new(measured.x, measured.y)
		end,
		measureMultilineText = function(text, font, textSize, spacing)
			local lines = text:split("\n")
			local maxWidth = 0
			local totalHeight = 0

			for _, line in ipairs(lines) do
				local size = TextService.MeasureText(line == "" and " " or line, font, textSize, spacing)
				maxWidth = math.max(maxWidth, size.X)
				totalHeight = totalHeight + size.Y
			end

			totalHeight = totalHeight + (#lines - 1) * (spacing * 2)

			return Vector2.new(maxWidth, totalHeight)
		end,
	})
end

return TextService
