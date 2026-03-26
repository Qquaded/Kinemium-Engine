local Enum = require("@EnumMap")
local logic = require("@Kinemium.2dinput")
local GuiObject = require("@GuiObject")
local rl = require("@raylib")
local Color3 = require("@Color3")
local aereon = require("@Aereon")

local propTable = {
	Name = "TextBox",
	AutoButtonColor = true,
	ChangeCursorOnHover = true,
	Visible = true,
	Focused = false,
	Text = "",
	PlaceholderText = "Type here...",
	FontSize = 18,
	TextColor3 = Color3.new(1, 1, 1),
	BackgroundColor3 = Color3.new(0.15, 0.15, 0.15),
	PlaceholderColor3 = Color3.new(0.5, 0.5, 0.5),
	FocusColor3 = Color3.new(0.02, 0.5, 1),
	TextXAlignment = Enum.TextXAlignment.Left,

	TextYAlignment = Enum.TextYAlignment.Center,

	MultiLine = false,
	ReadOnly = false,
	MaxLength = nil,
	Mask = nil, -- e.g. "*" for password fields
	AllowedChars = nil, -- regex pattern or function
	TrimWhitespace = false,
	TabSize = 4,
	AutoPairs = true,
	AutoIndent = false,
	WordWrap = false,

	Validator = nil, -- function(text) -> bool, errorMessage

	Numeric = false,
	NumericMin = nil,
	NumericMax = nil,
	NumericStep = 1,
	NumericPrecision = nil,
	ShowStepButtons = false,
	StepButtonWidth = 20,

	Slider = false,
	SliderMin = 0,
	SliderMax = 100,
	SliderStep = 1,
	SliderWidth = 100,
	SliderPosition = "right", -- "left" | "right" | "bottom"
	SliderGap = 10,

	Scrollable = false,
	EnableScrollbar = true,
	ScrollbarWidth = 10,

	ShowLineNumbers = false,
	ShowLineCount = false,
	ShowCharCount = false,

	CornerRadius = 0,
	CornerSegments = 8,
	BorderWidth = 1,
	FocusBorderWidth = 1,
	DropShadow = false,
	ShadowOffset = 2,
	LineHighlight = true,
	MatchBrackets = false,
	EnableAnimatedFocus = true,
	EnableMinimap = false,
	EnableHyperlinks = false,
	EnableDragDrop = true,
	EnableColumnSelection = true,

	Label = nil,
	LabelPosition = "left", -- "left" | "top" | "right"
	LabelWidth = 60,
	LabelGap = 10,

	Prefix = nil,
	Suffix = nil,
	PrefixGap = 5,
	SuffixGap = 5,

	SelectAllOnFocus = false,
	SubmitOnCtrlEnter = false,
	BlurOnSubmit = true,
	ClearOnEscape = false,
	EscapeBlurs = false,
	DoubleClickSelect = true,
	TripleClickSelect = true,
	ContextMenu = true,

	OnChange = nil, -- function(text)
	OnSubmit = nil, -- function(text)
	OnFocus = nil,
	OnBlur = nil,
	OnValidationError = nil, -- function(errorMessage)
	OnSearch = nil, -- function(query, resultCount)

	MaxHistory = 100,

	KeyRepeatInitialDelay = 0.5,
	KeyRepeatMinInterval = 0.02,
	KeyRepeatAcceleration = 0.85,
}
GuiObject.inherit(propTable)

propTable.render = function(lib, object, dt, structs, renderer, datamodel)
	local framePos, frameSize = GuiObject.render(lib, object, dt, structs, renderer)
	if not object.Visible or not framePos or not frameSize then
		return
	end

	if object._aereonInput then
		local ai = object._aereonInput
		local SyntaxHighlighter = object:FindFirstChildOfClass("SyntaxHighlighter")

		ai.theme.background = object.BackgroundColor3:ToRaylib(0)
		ai.theme.text = object.TextColor3:ToRaylib(0)
		ai.theme.placeholder = object.PlaceholderColor3:ToRaylib(0)
		ai.theme.focusBorder = object.FocusColor3:ToRaylib(0)
		ai.placeholder = object.PlaceholderText
		ai.fontSize = object.FontSize
		ai.multiline = object.MultiLine
		ai.syntaxHighlighter = SyntaxHighlighter and SyntaxHighlighter:GetMetadata("Highlighter").highlight or nil
		ai.readOnly = object.ReadOnly
		ai.maxLength = object.MaxLength
		ai.mask = object.Mask
		ai.allowedChars = object.AllowedChars
		ai.trimWhitespace = object.TrimWhitespace
		ai.tabSize = object.TabSize
		ai.autoPairs = object.AutoPairs
		ai.autoIndent = object.AutoIndent
		ai.wordWrap = object.WordWrap
		ai.validator = object.Validator
		ai.numeric = object.Numeric
		ai.numericMin = object.NumericMin
		ai.numericMax = object.NumericMax
		ai.numericStep = object.NumericStep
		ai.numericPrecision = object.NumericPrecision
		ai.showStepButtons = object.ShowStepButtons
		ai.stepButtonWidth = object.StepButtonWidth
		ai.slider = object.Slider
		ai.sliderMin = object.SliderMin
		ai.sliderMax = object.SliderMax
		ai.sliderStep = object.SliderStep
		ai.sliderWidth = object.SliderWidth
		ai.sliderPosition = object.SliderPosition
		ai.sliderGap = object.SliderGap
		ai.scrollable = object.Scrollable
		ai.enableScrollbar = object.EnableScrollbar
		ai.scrollbarWidth = object.ScrollbarWidth
		ai.showLineNumbers = object.ShowLineNumbers
		ai.showLineCount = object.ShowLineCount
		ai.showCharCount = object.ShowCharCount
		ai.cornerRadius = object.CornerRadius
		ai.cornerSegments = object.CornerSegments
		ai.borderWidth = object.BorderWidth
		ai.focusBorderWidth = object.FocusBorderWidth
		ai.dropShadow = object.DropShadow
		ai.shadowOffset = object.ShadowOffset
		ai.lineHighlight = object.LineHighlight
		ai.matchBrackets = object.MatchBrackets
		ai.enableAnimatedFocus = object.EnableAnimatedFocus
		ai.enableMinimap = object.EnableMinimap
		ai.enableHyperlinks = object.EnableHyperlinks
		ai.enableDragDrop = object.EnableDragDrop
		ai.enableColumnSelection = object.EnableColumnSelection
		ai.label = object.Label
		ai.labelPosition = object.LabelPosition
		ai.labelWidth = object.LabelWidth
		ai.labelGap = object.LabelGap
		ai.prefix = object.Prefix
		ai.suffix = object.Suffix
		ai.prefixGap = object.PrefixGap
		ai.suffixGap = object.SuffixGap
		ai.selectAllOnFocus = object.SelectAllOnFocus
		ai.submitOnCtrlEnter = object.SubmitOnCtrlEnter
		ai.blurOnSubmit = object.BlurOnSubmit
		ai.clearOnEscape = object.ClearOnEscape
		ai.escapeBlurs = object.EscapeBlurs
		ai.doubleClickSelect = object.DoubleClickSelect
		ai.tripleClickSelect = object.TripleClickSelect
		ai.contextMenu = object.ContextMenu

		if object.Focused and not ai.isFocused then
			ai:focus()
		elseif not object.Focused and ai.isFocused then
			ai:blur()
		end

		if ai:getText() ~= object.Text then
			ai.buffer.lines = { object.Text }
			ai.buffer:setCursor(1, #object.Text + 1)
			ai:updateSearch()
		end

		ai:drawWithExtras(framePos.X, framePos.Y, frameSize.X, frameSize.Y)
	end

	return framePos, frameSize
end

return {
	class = "TextBox",
	callback = function(instance, renderer, game)
		logic:SetupSignals(propTable)
		instance:SetProperties(propTable)

		local TextBoxClass = aereon.textbox(rl.lib, game)

		instance._aereonInput = TextBoxClass.new({
			text = instance.Text,
			placeholder = instance.PlaceholderText,
			fontSize = instance.FontSize,

			backgroundColor = instance.BackgroundColor3,
			textColor = instance.TextColor3,
			placeholderColor = instance.PlaceholderColor3,
			focusBorderColor = instance.FocusColor3,

			multiline = instance.MultiLine,
			readOnly = instance.ReadOnly,
			maxLength = instance.MaxLength,
			mask = instance.Mask,
			allowedChars = instance.AllowedChars,
			trimWhitespace = instance.TrimWhitespace,
			tabSize = instance.TabSize,
			autoPairs = instance.AutoPairs,
			autoIndent = instance.AutoIndent,
			wordWrap = instance.WordWrap,

			validator = instance.Validator,

			numeric = instance.Numeric,
			numericMin = instance.NumericMin,
			numericMax = instance.NumericMax,
			numericStep = instance.NumericStep,
			numericPrecision = instance.NumericPrecision,
			showStepButtons = instance.ShowStepButtons,
			stepButtonWidth = instance.StepButtonWidth,

			slider = instance.Slider,
			sliderMin = instance.SliderMin,
			sliderMax = instance.SliderMax,
			sliderStep = instance.SliderStep,
			sliderWidth = instance.SliderWidth,
			sliderPosition = instance.SliderPosition,
			sliderGap = instance.SliderGap,

			scrollable = instance.Scrollable,
			enableScrollbar = instance.EnableScrollbar,
			scrollbarWidth = instance.ScrollbarWidth,

			showLineNumbers = instance.ShowLineNumbers,
			showLineCount = instance.ShowLineCount,
			showCharCount = instance.ShowCharCount,

			cornerRadius = instance.CornerRadius,
			cornerSegments = instance.CornerSegments,
			borderWidth = instance.BorderWidth,
			focusBorderWidth = instance.FocusBorderWidth,
			dropShadow = instance.DropShadow,
			shadowOffset = instance.ShadowOffset,
			lineHighlight = instance.LineHighlight,
			matchBrackets = instance.MatchBrackets,
			enableAnimatedFocus = instance.EnableAnimatedFocus,
			enableMinimap = instance.EnableMinimap,
			enableHyperlinks = instance.EnableHyperlinks,
			enableDragDrop = instance.EnableDragDrop,
			enableColumnSelection = instance.EnableColumnSelection,

			label = instance.Label,
			labelPosition = instance.LabelPosition,
			labelWidth = instance.LabelWidth,
			labelGap = instance.LabelGap,

			prefix = instance.Prefix,
			suffix = instance.Suffix,
			prefixGap = instance.PrefixGap,
			suffixGap = instance.SuffixGap,

			selectAllOnFocus = instance.SelectAllOnFocus,
			submitOnCtrlEnter = instance.SubmitOnCtrlEnter,
			blurOnSubmit = instance.BlurOnSubmit,
			clearOnEscape = instance.ClearOnEscape,
			escapeBlurs = instance.EscapeBlurs,
			doubleClickSelect = instance.DoubleClickSelect,
			tripleClickSelect = instance.TripleClickSelect,
			contextMenu = instance.ContextMenu,

			maxHistory = instance.MaxHistory,

			keyRepeatInitialDelay = instance.KeyRepeatInitialDelay,
			keyRepeatMinInterval = instance.KeyRepeatMinInterval,
			keyRepeatAcceleration = instance.KeyRepeatAcceleration,

			-- Callbacks
			onChange = function(text)
				instance.Text = text
				if instance.OnChange then
					instance.OnChange(text)
				end
			end,
			onSubmit = function(text)
				if instance.OnSubmit then
					instance.OnSubmit(text)
				end
			end,
			onFocus = function()
				instance.Focused = true
				if instance.OnFocus then
					instance.OnFocus()
				end
			end,
			onBlur = function()
				instance.Focused = false
				if instance.OnBlur then
					instance.OnBlur()
				end
			end,
			onValidationError = function(err)
				if instance.OnValidationError then
					instance.OnValidationError(err)
				end
			end,
			onSearch = function(query, count)
				if instance.OnSearch then
					instance.OnSearch(query, count)
				end
			end,
		})

		if instance.Text and #instance.Text > 0 then
			instance._aereonInput.buffer:insertString(instance.Text)
		end

		return instance
	end,

	inherit = function(tble)
		for prop, val in pairs(propTable) do
			if tble[prop] then
				continue
			end
			tble[prop] = val
		end
	end,
}
