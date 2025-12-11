local Instance = require("@Instance")
local signal = require("@Kinemium.signal")
local fs = zune.fs
local task = zune.task

local KinemiumFontService = Instance.new("KinemiumFontService")
KinemiumFontService.ExplorerHidden = true

local FontRemoved = signal.new()
local FontAdded = signal.new()

local function transformFontName(v: string)
	return v:gsub("-", "")
end

local engine_fonts = "./src/assets/fonts"
local fontCount = 0

KinemiumFontService.InitRenderer = function(renderer, renderer_signal)
	local default_font = "./src/assets/fonts/Montserrat-Medium.ttf"
	local font = renderer.LoadFont("DefaultEngineFont", default_font)

	KinemiumFontService:SetProperties({
		LoadFont = function(self, name, fontPath)
			local fontInstance = {}

			FontAdded:Fire(name, fontPath)

			fontInstance.Font = renderer.LoadFont(name, fontPath)
			fontInstance.Unload = function()
				renderer.UnloadFont(name)
				FontRemoved:Fire(fontPath)
			end
			return fontInstance
		end,

		GetDefaultFont = function()
			return font
		end,

		LoadAllEngineFonts = function()
			for _, font in pairs(fs.entries(engine_fonts)) do
				local path = engine_fonts .. "/" .. font.name
				renderer.LoadFont(transformFontName(font.name), path)
				fontCount += 1
				print("FONTSERVICE | Loaded font " .. font.name)
			end
			print("FONTSERVICE | Loaded " .. fontCount .. " fonts.")
		end,
		FontAdded = FontAdded,
		FontRemoved = FontRemoved,
	})

	print("Adding engine fonts.....")
end

return KinemiumFontService
