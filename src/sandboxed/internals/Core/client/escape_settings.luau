repeat
	task.wait()
until ishared.CoreGuiSignal

repeat
	task.wait()
until ishared.ReactPointer

local KinemiumRaylib = game:GetService("KinemiumRaylib")
local RunService = game:GetService("RunService")

if not RunService:IsClient() then
	return
end

local sign = ishared.CoreGuiSignal
local manager = ishared.ReactPointer
local renderer = KinemiumRaylib.renderer
local HUDService = game:GetService("HUDService")

local KinemiumFontService = game:GetService("KinemiumFontService")
local ConfigService = game:GetService("ConfigService")

local vend = KinemiumFontService.GetDefaultFontSmall()

local function runtime(key, fallback)
	local value = manager:get("#runtime", key)
	if value == nil then
		return fallback
	end
	return value
end

local function runtimeCellFont(fallback)
	local runtimeFont = runtime("font", Enum.Font.DefaultEngineFont)
	if type(runtimeFont) == "table" and runtimeFont.Value and renderer and renderer.Font and renderer.Font.Get then
		local resolvedFont = renderer.Font.Get(runtimeFont.Value)
		if resolvedFont then
			return resolvedFont
		end
	end
	return fallback
end

local function applyCellTheme(sections)
	for _, entries in pairs(sections) do
		if type(entries) ~= "table" then
			continue
		end
		entries.titleFont = runtimeCellFont(vend)
		for _, cell in ipairs(entries) do
			if type(cell) ~= "table" then
				continue
			end
			cell.font = runtimeCellFont(vend)
			cell.backgroundColor = runtime("secondarybackground", Color3.new(0, 0, 0))
			cell.textColor = runtime("text", Color3.new(1, 1, 1))
			cell.descriptionColor = runtime("mutedtext", Color3.new(0.85, 0.85, 0.85))
		end
	end
end

local function cloneSections(sections)
	local cloned = {}
	for name, entries in pairs(sections) do
		cloned[name] = entries
	end
	return cloned
end

local DEFAULT_SETTINGS = {
	Gui = {
		["Color Theme"] = {
			Value = "Dark",
			Description = "Change color theme.",
		},
		Font = {
			Value = "Default",
			Description = "Change font.",
		},
		TextSize = {
			Value = 14,
			Description = "Change text size.",
		},
		["Aspect Ratio"] = {
			Value = "16:9",
			Description = "Change aspect ratio.",
		},
	},
	Controls = {
		CameraSensitivity = {
			Value = 1,
			Description = "Change camera sensitivity.",
		},
		FieldOfView = {
			Value = 70,
			Description = "Change camera FOV.",
		},
		CameraMode = {
			Value = "Classic",
			Description = "Change camera mode.",
		},
	},
	Chat = {
		["Text Transparency"] = {
			Value = 1,
			Description = "Change text transparency.",
		},
		["Background Transparency"] = {
			Value = 1,
			Description = "Change background transparency.",
		},
		["Gui Size"] = {
			Value = 1,
			Description = "Change gui size.",
		},
		["Text Size"] = {
			Value = 20,
			Description = "Change text size.",
		},
	},
	Graphics = {
		Quality = {
			Value = Enum.GraphicsLevel.Automatic,
			Description = "Change graphics quality.",
		},
		Shadows = {
			Value = true,
			Description = "Enable shadows.",
		},
		Bloom = {
			Value = true,
			Description = "Enable bloom.",
		},
		Vsync = {
			Value = true,
			Description = "Enable vsync.",
		},
		PostProcessing = {
			Value = true,
			Description = "Enable post processing.",
		},
		["Particle Effects"] = {
			Value = true,
			Description = "Enable particle effects.",
		},

		["Anti-Aliasing"] = {
			Value = true,
			Description = "Enable anti-aliasing.",
		},
	},
	Audio = {
		Volume = {
			Value = 0.5,
			Description = "Change audio volume.",
		},
		Music = {
			Value = true,
			Description = "Enable music.",
		},
		SoundEffects = {
			Value = true,
			Description = "Enable sound effects.",
		},
	},
	Misc = {
		Language = {
			Value = "English",
			Description = "Change game language.",
		},
		Fullscreen = {
			Value = false,
			Description = "Toggle fullscreen.",
		},
		DeveloperMode = {
			Value = false,
			Description = "Toggle developer mode.",
		},
		["Show Debugger"] = {
			Value = false,
			Description = "Toggle debug info display.",
		},
		["Auto-Update"] = {
			Value = true,
			Description = "Toggle automatic updates.",
		},
		["Beta Features"] = {
			Value = false,
			Description = "Toggle access to beta features.",
		},
	},
}

HUDService.MergeSettings(DEFAULT_SETTINGS)

local function buildSettingsSections()
	local sections = {}
	local canvasSize = 0

	for section, entries in pairs(ConfigService.GetConfig() or {}) do
		local values = {}

		for propName, propData in pairs(entries) do
			if type(propData) ~= "table" then
				continue
			end

			table.insert(values, {
				name = propName,
				description = propData.Description,
				font = runtimeCellFont(vend),
				backgroundColor = runtime("secondarybackground", Color3.new(0, 0, 0)),
				textColor = runtime("text", Color3.new(1, 1, 1)),
				descriptionColor = runtime("mutedtext", Color3.new(0.85, 0.85, 0.85)),
				value = propData.Value,
			})
			canvasSize += 100
		end

		sections[section] = values
	end

	applyCellTheme(sections)

	return sections, canvasSize
end

sign:Fire("MakeWindow", "Settings", function(window)
	window.ClipsDescendants = true

	local ScrollingFrame = Instance.new("ScrollingFrame")
	ScrollingFrame.Size = UDim2.new(1, 0, 1, 0)
	ScrollingFrame.ClipsDescendants = true
	ScrollingFrame.BackgroundTransparency = 1
	ScrollingFrame.AutoScrollSize = false
	ScrollingFrame.Parent = window

	local cellList = Instance.new("UICellList")
	cellList.Parent = ScrollingFrame
	cellList.Size = UDim2.new(1, -20, 1, 0)
	cellList.Sections = {}

	local function refreshSections()
		local sections, canvasSize = buildSettingsSections()
		cellList.Sections = cloneSections(sections)
		ScrollingFrame.CanvasSize = canvasSize
	end

	refreshSections()
	ConfigService.ConfigChanged:Connect(refreshSections)

	manager:subscribe("#runtime", "background", function()
		refreshSections()
	end)
	manager:subscribe("#runtime", "secondarybackground", function()
		refreshSections()
	end)
	manager:subscribe("#runtime", "text", function()
		refreshSections()
	end)
	manager:subscribe("#runtime", "mutedtext", function()
		refreshSections()
	end)
	manager:subscribe("#runtime", "font", function()
		refreshSections()
	end)
end)
