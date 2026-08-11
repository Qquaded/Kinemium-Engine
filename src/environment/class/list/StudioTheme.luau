-- description: "A studio theme."
local Color3 = require("@Color3")
local UDim2 = require("@UDim2")
local Vector2 = require("@Vector2")

local basic = {
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
	CornerRadius = 0.5,
	ShadowColor = Color3.new(0, 0, 0),
	ArrowImageColor = Color3.new(1, 1, 1),
	TitleColor = Color3.new(1, 1, 1),
}

local WindowConfig = {
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
}

local IDEConfig = {
	BackgroundColor = Color3.fromRGB(16, 20, 28),
	SecondaryBackgroundColor = Color3.new(0.07, 0.07, 0.07),
	TextColor = Color3.new(1, 1, 1),
	currentLineColor = Color3.new(0.2, 0.2, 0.2),
}

local IDEAutocomplete = {
	BackgroundColor = Color3.new(0.07, 0.07, 0.07),
	OutlineColor = Color3.new(1, 1, 1),
	ItemSelectColor = Color3.new(0, 0, 0.3),
	OutlineThickness = 0.6,
	OutlineTransparency = 0.8,
	CornerRadius = 0.2,

	Width = 200,
	Height = 20,
	ListPadding = 5,
}

local SyntaxHighlightConfig = {
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
}

local propTable = {
	Name = "Theme",
	BaseClass = "StudioTheme",
}

local colors = {}

local function clone(tble)
	for prop, value in pairs(tble) do
		colors[prop] = value
	end
end
clone(SyntaxHighlightConfig)
clone(IDEConfig)
clone(IDEAutocomplete)
clone(basic)
clone(WindowConfig)

return {
	class = "StudioTheme",
	callback = function(instance)
		instance:SetProperties(propTable)

		local map = {}

		local function reset()
			map = {
				MainBackground = colors.BackgroundColor,
				Titlebar = colors.BackgroundColor,
				Dropdown = colors.SecondaryBackgroundColor,
				Tooltip = colors.ThirdBackgroundColor,
				Notification = colors.ThirdBackgroundColor,
				ScrollBar = colors.Accent,
				ScrollBarBackground = colors.SecondaryBackgroundColor,
				TabBar = colors.SecondaryBackgroundColor,
				Tab = colors.BackgroundColor,

				RibbonTab = colors.BackgroundColor,
				RibbonTabTopBar = colors.BackgroundColor,

				Button = colors.SecondaryBackgroundColor,
				MainButton = colors.Accent,
				RibbonButton = colors.SecondaryBackgroundColor,

				ViewPortBackground = colors.BackgroundColor,

				InputFieldBackground = colors.SecondaryBackgroundColor,

				ColorPickerFrame = colors.BackgroundColor,

				Border = colors.Accent,
				DropShadow = colors.ShadowColor,
				Shadow = colors.ShadowColor,

				Light = colors.TextColor,
				Dark = colors.BackgroundColor,
				Mid = colors.ThirdBackgroundColor,
				Midlight = colors.SecondaryBackgroundColor,

				MainText = colors.TextColor,
				SubText = colors.SecondaryTextColor,
				TitlebarText = colors.TitleColor,
				BrightText = colors.TextColor,
				DimmedText = colors.SecondaryTextColor,
				LinkText = colors.Accent,
				WarningText = Color3.fromRGB(255, 200, 0),
				ErrorText = Color3.fromRGB(255, 80, 80),
				InfoText = Color3.fromRGB(0, 170, 255),
				SensitiveText = Color3.fromRGB(255, 120, 120),

				ScriptSideWidget = colors.SecondaryBackgroundColor,
				ScriptBackground = colors.BackgroundColor,
				ScriptText = colors.default,
				ScriptSelectionText = colors.default,
				ScriptSelectionBackground = colors.currentLineColor,
				ScriptFindSelectionBackground = colors.currentLineColor,
				ScriptMatchingWordSelectionBackground = colors.currentLineColor,

				ScriptOperator = colors.operator,
				ScriptNumber = colors.number,
				ScriptString = colors.string,
				ScriptComment = colors.comment,
				ScriptKeyword = colors.keyword,
				ScriptBuiltInFunction = colors.builtin,

				ScriptWarning = Color3.fromRGB(255, 200, 0),
				ScriptError = Color3.fromRGB(255, 80, 80),
				ScriptInformation = Color3.fromRGB(0, 170, 255),
				ScriptHint = Color3.fromRGB(120, 120, 120),

				ScriptWhitespace = Color3.fromRGB(80, 80, 80),
				ScriptRuler = colors.SecondaryBackgroundColor,

				DocViewCodeBackground = colors.BackgroundColor,

				DebuggerCurrentLine = colors.currentLineColor,
				DebuggerErrorLine = Color3.fromRGB(100, 30, 30),

				ScriptEditorCurrentLine = colors.currentLineColor,

				ScriptMethod = colors.method,
				ScriptProperty = colors.field,
				ScriptNil = Color3.fromRGB(180, 180, 180),
				ScriptBool = colors.keyword,
				ScriptFunction = colors.functionName,
				ScriptLocal = colors.default,
				ScriptSelf = colors.keyword,
				ScriptLuauKeyword = colors.keyword,
				ScriptFunctionName = colors.functionName,
				ScriptTodo = Color3.fromRGB(255, 255, 0),
				ScriptBracket = colors.default,

				ButtonBorder = colors.Accent,
				ButtonText = colors.TextColor,
				InputFieldBorder = colors.Accent,
				CheckedFieldBackground = colors.Accent,
				CheckedFieldBorder = colors.Accent,
				CheckedFieldIndicator = colors.TextColor,

				HeaderSection = colors.SecondaryBackgroundColor,
				StatusBar = colors.BackgroundColor,
				Separator = colors.SecondaryBackgroundColor,

				DialogButton = colors.SecondaryBackgroundColor,
				DialogButtonText = colors.TextColor,
				DialogButtonBorder = colors.Accent,
				DialogMainButton = colors.Accent,
				DialogMainButtonText = colors.TextColor,

				InfoBarWarningBackground = Color3.fromRGB(80, 60, 0),
				InfoBarWarningText = Color3.fromRGB(255, 220, 0),

				AttributeCog = colors.TextColor,

				BreakpointMarker = Color3.fromRGB(255, 0, 0),

				AutocompleteBackground = colors.BackgroundColor,
				AutocompleteBorder = colors.OutlineColor,
				AutocompleteSelection = colors.ItemSelectColor,
				AutocompleteText = colors.TextColor,
			}
		end

		reset()

		function instance:GetColor(style, modifier)
			if type(style) ~= "table" then
				return Color3.new(0, 0, 0)
			end

			print("Got style", style.Name)
			print("Mapped: ", map[style.Name])
			return map[style.Name]
		end

		function instance:ApplyDirectVar(prop, value)
			colors[prop] = value
			reset()
		end

		function instance:SetColor(style, new)
			if type(style) ~= "table" then
				return
			end
			map[style.Name] = new
		end

		function instance:Apply() end

		return instance
	end,
	inherit = function(tble)
		for prop, val in pairs(propTable) do
			tble[prop] = val
		end
	end,
}
