local Instance = require("@Instance")
local Color3 = require("@Color3")
local Enum = require("@EnumMap")
local signal = require("@Kinemium.signal")

local Studio = Instance.new("Studio")
Studio.ExplorerHidden = true
Studio._Intents = Enum.PluginIntents.UI

Studio.InitRenderer = function(renderer, renderer_signal, datamodel)
	task.spawn(function()
		repeat
			task.wait()
		until datamodel.Loaded == true and datamodel:GetService("StudioThemeService")
		local StudioThemeService = datamodel:GetService("StudioThemeService")
		local SelectedTheme = StudioThemeService.SelectedTheme
		local ThemeObj = StudioThemeService.ThemeObject

		Studio:SetProperties({
			themes = StudioThemeService,
			SelectedTheme = SelectedTheme,

			TextColor = SelectedTheme.TextColor,
			KeywordColor = SelectedTheme.KeywordColor,
			CommentColor = SelectedTheme.CommentColor,
			SelectionColor = SelectedTheme.SelectionColor,

			ActionOnAutoResumeSync = nil,
			ActionOnStopSync = nil,

			AlwaysSaveScriptChanges = false,
			AnimateHoverOver = true,
			AutoCleanEmptyLine = true,
			AutoClosingBrackets = true,
			AutoClosingQuotes = true,
			AutoDeleteClosingBracketsAndQuotes = true,
			AutoIndentRule = nil,
			AutoRecoveryEnabled = true,
			AutoRecoveryIntervalMinutes = 5,
			AutocompleteAcceptanceBehavior = nil,
			AutomaticallyTriggerAICodeCompletion = true,
			AutoResumeSyncOnPlaceOpen = false,
			AutoUpdateEnabled = true,

			BackgroundColor = Color3.new(),

			BasicObjectsDisplayMode = nil,

			CameraMouseWheelSpeed = 1,
			CameraPanSpeed = 1,
			CameraShiftSpeed = 1,
			CameraSpeed = 1,
			CameraSpeedAdjustBinding = nil,
			CameraZoomToMousePosition = true,
			CameraAdaptiveSpeed = true,
			CameraNavigationModel = nil,
			CameraOrbitSensitivity = 1,
			CameraPanSensitivity = 1,
			CameraShiftFactor = 1,
			CameraTweenFocus = true,
			CameraZoomSpeed = 1,

			ClearOutputOnStart = true,
			CommandBarEnterExec = true,
			CommandBarFont = nil,
			CommandBarLocalState = false,

			DefaultInstancesDir = nil,
			DefaultScriptSyncFileType = nil,
			DeprecatedObjectsShown = false,
			DisplayLanguage = "en",

			DraggerLengthFactor = 1,
			DraggerMajorGridIncrement = 1,
			DraggerMaxSoftSnaps = 8,
			DraggerScaleFactor = 1,
			DraggerShowAxisTicks = true,
			DraggerShowHoverRuler = true,
			DraggerShowMeasurement = true,
			DraggerShowNegativeAxes = true,
			DraggerShowPlanes = true,
			DraggerShowTargetSnap = true,
			DraggerShowTrackball = true,
			DraggerShowWhileDragging = true,
			DraggerSoftSnapMarginFactor = 1,
			DraggerSummonMarginFactor = 1,
			DraggerTiltRotateDuration = 0.2,

			EnableAutocomplete = true,
			EnableAutocompleteDocView = true,
			EnableCoreScriptDebugger = false,
			EnableHttpSandboxing = true,
			EnableInternalBetaFeatures = false,
			EnableInternalFeatures = false,
			EnableScriptAnalysis = true,
			EnableScrollbarMarkers = true,
			EnableSignatureHelp = true,
			EnableSignatureHelpDocView = true,
			EnableTemporaryTabs = true,
			EnableTemporaryTabsInExplorer = true,
			EnableTypeHover = true,
			EnableCodeAssist = true,
			EnableFindOnType = true,
			EnableIndentationRulers = true,
			EnableSelectionTooltips = true,
			EnableStudioStreaming = false,

			ExternalEditorMode = nil,
			ExternalEditorSelection = nil,

			Font = nil,

			FormatOnPaste = true,
			FormatOnType = true,

			HighlightCurrentLine = true,
			HighlightOccurances = true,

			HoverAnimateSpeed = nil,
			HoverBoxThickness = 1,
			HoverLineThickness = 1,

			IconOverrideDir = nil,

			IndentUsingSpaces = true,

			LargeFileLineCountThreshold = 10000,
			LargeFileThreshold = 10 * 1024 * 1024,

			LineThickness = 1,

			LoadAllBuiltinPluginsInRunModes = false,
			LoadInternalPlugins = true,
			LoadUserPluginsInRunModes = true,

			LocalAssetsFolder = nil,

			LuaDebuggerEnabled = true,
			LuaDebuggerEnabledAtStartup = true,

			MainVolume = 1,

			MaxFindReplaceAllResults = 1000,
			MaximumOutputLines = 10000,

			OnlyPlayAudioFromWindowInFocus = false,

			OutputFont = nil,
			OutputLayoutMode = nil,

			PermissionLevelShown = nil,

			PhysicalDraggersSelectScopeByDefault = false,

			PluginDebuggingEnabled = true,
			PluginsDir = nil,

			PreferredTextSize = nil,

			ReloadBuiltinPluginsOnChange = false,
			ReloadLocalPluginsOnChange = true,

			RespectStudioShortcutsWhenGameHasFocus = true,

			RuntimeUndoBehavior = nil,

			ScriptEditorColorPreset = nil,
			ScriptTimeoutLength = 10,

			ScrollPastLastLine = true,

			SetPivotOfImportedParts = true,

			ShowCoreGUIInExplorerWhilePlaying = false,
			ShowDiagnosticsBar = true,
			ShowFileSyncService = false,
			ShowHiddenObjectsInExplorer = false,
			ShowHoverOver = true,
			ShowLightGuides = true,
			ShowNavigationLabels = true,
			ShowNavigationMesh = false,
			ShowPathfindingLinks = false,
			ShowPluginGUIServiceInExplorer = false,
			ShowPlusButtonOnHoverInExplorer = true,
			ShowSinglySelectedAttachmentParentFrame = true,
			ShowWhitespace = false,
			ShowCorePackagesInExplorer = false,

			SkipClosingBracketsAndQuotes = true,

			TabWidth = 4,
			TextWrapping = false,

			Theme = nil,
			UITheme = nil,

			UseBoundingBoxMoveHandles = true,
			UseDefaultExternalEditor = false,
		})

		local ThemeChanged = signal.new()
		Studio.ThemeChanged = ThemeChanged

		Studio.Theme = ThemeObj
	end)
end

return Studio
