local Instance = require("@Instance")
local signal = require("@Kinemium.signal")
local Enum = require("@EnumMap")

local KinemiumFontService = Instance.new("KinemiumFontService")
KinemiumFontService.ExplorerHidden = true
KinemiumFontService._Intents = Enum.PluginIntents.UI

local FontRemoved = signal.new()
local FontAdded = signal.new()

local DEFAULT_FONT_PATH = "./src/assets/fonts/Montserrat-Medium.ttf"
local DEFAULT_CODE_FONT_PATH = "./src/assets/fonts/JetBrainsMono-Light.ttf"
local DEFAULT_FONT_BOLD_PATH = "./src/assets/fonts/Montserrat-Bold.ttf"

local fontMap = {}

local ENGINE_FONT_FILES = {
	Legacy = DEFAULT_FONT_PATH,
	Arial = "./src/assets/fonts/Arimo-Regular.ttf",
	ArialBold = "./src/assets/fonts/Arimo-Bold.ttf",
	SourceSans = "./src/assets/fonts/SourceSansPro-Regular.ttf",
	SourceSansBold = "./src/assets/fonts/SourceSansPro-Bold.ttf",
	SourceSansLight = "./src/assets/fonts/SourceSansPro-Light.ttf",
	SourceSansItalic = "./src/assets/fonts/SourceSansPro-It.ttf",
	Bodoni = "./src/assets/fonts/AccanthisADFStd-Regular.otf",
	Garamond = "./src/assets/fonts/Guru-Regular.otf",
	Cartoon = "./src/assets/fonts/ComicNeue-Angular-Bold.ttf",
	Code = "./src/assets/fonts/GoogleSansCode-Regular.ttf",
	GoogleSansCode = "./src/assets/fonts/GoogleSansCode-Regular.ttf",
	DefaultEngineFont = DEFAULT_FONT_PATH,
	DefaultCodeEngineFont = DEFAULT_CODE_FONT_PATH,
	MontserratBold = DEFAULT_FONT_BOLD_PATH,
	Highway = "./src/assets/fonts/HWYGOTH.ttf",
	SciFi = "./src/assets/fonts/Zekton.ttf",
	Arcade = "./src/assets/fonts/PressStart2P-Regular.ttf",
	Fantasy = "./src/assets/fonts/Balthazar-Regular.ttf",
	Antique = "./src/assets/fonts/RomanAntique.otf",
	SourceSansSemibold = "./src/assets/fonts/SourceSansPro-Semibold.ttf",
	Gotham = "./src/assets/fonts/Montserrat-Regular.ttf",
	GothamMedium = DEFAULT_FONT_PATH,
	GothamBold = "./src/assets/fonts/Montserrat-Bold.ttf",
	GothamBlack = "./src/assets/fonts/Montserrat-Black.ttf",
	BuilderSans = "./src/assets/fonts/Montserrat-Regular.ttf",
	BuilderSansMedium = DEFAULT_FONT_PATH,
	BuilderSansBold = "./src/assets/fonts/Montserrat-Bold.ttf",
	BuilderSansExtraBold = "./src/assets/fonts/Montserrat-Black.ttf",
	Vend = "./src/assets/fonts/Vend.ttf",
	VCR = "./src/assets/fonts/VCR.ttf",
	Bembo = "./src/assets/fonts/Bembo.otf",
	Beyno = "./src/assets/fonts/Beyno.ttf",
	Avenir = "./src/assets/fonts/Avenir.otf",
	Atiba = "./src/assets/fonts/Atiba.ttf",
	Aerova = "./src/assets/fonts/Aerova.otf",
	["Duskfall Gothic"] = "./src/assets/fonts/Duskfall Gothic.ttf",
	DuskfallGothic = "./src/assets/fonts/Duskfall Gothic.ttf",
	Filted = "./src/assets/fonts/Filted.ttf",
	GillSans = "./src/assets/fonts/GillSans.otf",
	Curlz = "./src/assets/fonts/Curlz.ttf",
	AmaticSC = "./src/assets/fonts/AmaticSC-Regular.ttf",
	Bangers = "./src/assets/fonts/Bangers-Regular.ttf",
	Creepster = "./src/assets/fonts/Creepster-Regular.ttf",
	DenkOne = "./src/assets/fonts/DenkOne-Regular.ttf",
	Fondamento = "./src/assets/fonts/Fondamento-Regular.ttf",
	Audiowide = "./src/assets/fonts/Audiowide-Regular.ttf",
	AudiowideRegular = "./src/assets/fonts/Audiowide-Regular.ttf",
	FredokaOne = "./src/assets/fonts/FredokaOne-Regular.ttf",
	GrenzeGotisch = "./src/assets/fonts/GrenzeGotisch-Regular.ttf",
	IndieFlower = "./src/assets/fonts/IndieFlower-Regular.ttf",
	JosefinSans = "./src/assets/fonts/JosefinSans-Regular.ttf",
	Jura = "./src/assets/fonts/Jura-Regular.ttf",
	Kalam = "./src/assets/fonts/Kalam-Regular.ttf",
	LuckiestGuy = "./src/assets/fonts/LuckiestGuy-Regular.ttf",
	Merriweather = "./src/assets/fonts/Merriweather-Regular.ttf",
	Michroma = "./src/assets/fonts/Michroma-Regular.ttf",
	Nunito = "./src/assets/fonts/Nunito-Regular.ttf",
	Oswald = "./src/assets/fonts/Oswald-Regular.ttf",
	Exo = "./src/assets/fonts/Exo-Regular.ttf",
	ExoRegular = "./src/assets/fonts/Exo-Regular.ttf",
	ExoBold = "./src/assets/fonts/Exo-Bold.ttf",
	ExoItalic = "./src/assets/fonts/Exo-Italic.ttf",
	PatrickHand = "./src/assets/fonts/PatrickHand-Regular.ttf",
	PermanentMarker = "./src/assets/fonts/PermanentMarker-Regular.ttf",
	Roboto = "./src/assets/fonts/Roboto-Regular.ttf",
	RobotoCondensed = "./src/assets/fonts/RobotoCondensed-Regular.ttf",
	RobotoMono = "./src/assets/fonts/RobotoMono-Regular.ttf",
	Sarpanch = "./src/assets/fonts/Sarpanch-Regular.ttf",
	SpecialElite = "./src/assets/fonts/SpecialElite-Regular.ttf",
	TitilliumWeb = "./src/assets/fonts/TitilliumWeb-Regular.ttf",
	Ubuntu = "./src/assets/fonts/Ubuntu-Regular.ttf",
	Arimo = "./src/assets/fonts/Arimo-Regular.ttf",
	ArimoBold = "./src/assets/fonts/Arimo-Bold.ttf",
	EvenStevens = "./src/assets/fonts/EvenStevens.ttf",
	Unknown = DEFAULT_FONT_PATH,
}

local zembed = require("@zembed")
local fontCount = 0

local function resolveFontPath(path: string)
	return zembed.AssetPath(path)
end

KinemiumFontService.InitRenderer = function(renderer, renderer_signal)
	local loadedFonts = {}
	local loadingFonts = {}

	local fonts = zune.fs.entries("./src/assets/fonts/")

	local function normalizeName(name)
		name = name:gsub("%-", " ")
		name = name:gsub("(%a)([%w_]*)", function(first, rest)
			return first:upper() .. rest:lower()
		end)
		return name
	end

	local function buildFontMap(fonts)
		for i, file in ipairs(fonts) do
			local filename = file.name

			local stem = filename:gsub("%.%w+$", "")

			local family, style = stem:match("^(.*)%-(.+)$")

			if not family then
				family = stem
				style = "Regular"
			end

			family = normalizeName(family)
			style = normalizeName(style)

			if not fontMap[family] then
				fontMap[family] = {}
			end

			fontMap[family][style] = "./src/assets/fonts/" .. file.name
			if fontMap[family]["Regular"] then
				Enum.Font[family] = fontMap[family]["Regular"]
			end
			if not Enum.FontWeight[style] then
				Enum.FontWeight[style] = i * 10
			end
		end
	end

	buildFontMap(fonts)

	local function loadEngineFont(name: string, size: number?)
		if loadedFonts[name] then
			return loadedFonts[name]
		end
		if loadingFonts[name] then
			return nil
		end

		local path = ENGINE_FONT_FILES[name]
		if not path then
			return nil
		end

		loadingFonts[name] = true
		local loaded = renderer.Font.new(name, resolveFontPath(path), size or 64)
		loadingFonts[name] = nil
		loadedFonts[name] = loaded
		FontAdded:Fire(name, path)

		print(loaded)

		return loaded
	end

	renderer.Font.SetResolver(function(name)
		return loadEngineFont(name)
	end)

	local font = loadEngineFont("DefaultEngineFont", 32)
	local loaded_cf = loadEngineFont("DefaultCodeEngineFont", 32)

	KinemiumFontService:SetProperties({
		LoadFont = function(self, name, fontPath)
			local fontInstance = {}

			FontAdded:Fire(name, fontPath)

			fontPath = resolveFontPath(fontPath)
			fontInstance.Font = renderer.Font.new(name, fontPath, 64)
			loadedFonts[name] = fontInstance.Font
			fontInstance.Unload = function()
				renderer.Font.Remove(name)
				loadedFonts[name] = nil
				FontRemoved:Fire(fontPath)
			end
			return fontInstance
		end,

		ReplaceDefaultFont = function(path)
			print(loadingFonts, loadedFonts)
			loadedFonts["DefaultEngineFont"] = nil
			loadingFonts["DefaultEngineFont"] = nil
			ENGINE_FONT_FILES["DefaultEngineFont"] = path
			font = loadEngineFont("DefaultEngineFont", 32)
		end,

		GetDefaultFontSmall = function()
			return font
		end,

		GetDefaultFont = function()
			return font
		end,

		GetMonoFontDefault = function()
			return loaded_cf
		end,

		GetBoldFont = function()
			return loadEngineFont("MontserratBold", 32)
		end,

		LoadAllEngineFonts = function()
			local fontsLoadStart = os.clock()
			local loaded = 0

			for name, _ in pairs(ENGINE_FONT_FILES) do
				local fontLoadStart = os.clock()
				if loadEngineFont(name, 64) then
					loaded += 1
					print(
						string.format(
							"FONTSERVICE | Loaded font %s in %.3fms",
							name,
							(os.clock() - fontLoadStart) * 1000
						)
					)
				end
			end

			fontCount = loaded
			print(
				string.format(
					"FONTSERVICE | Loaded %i fonts in %.3fms",
					fontCount,
					(os.clock() - fontsLoadStart) * 1000
				)
			)
		end,
		FontAdded = FontAdded,
		FontRemoved = FontRemoved,
	})
end

return KinemiumFontService
