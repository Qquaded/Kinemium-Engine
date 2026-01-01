-- Aereon | by devcell
local Aereon = {}

local raylib = require("@raylib")

-- init
local structs = raylib.structs
local const = raylib.const
local lib = raylib.lib

-- datatypes
local Color3 = require("@Color3")

-- components
local window = require("./Aereon/window")
local rect = require("./Aereon/rect")
local ide = require("./Aereon/ide/scripteditor")

-- config Data
local config = {}
local stepcallbacks = {}

-- themes
local themes = {
	default = {
		window = {
			BackgroundColor = Color3.new(0, 0, 0),
			BackgroundTransparency = 0.05,
			TextColor = Color3.new(1, 1, 1),
			SecondaryBackgroundColor = Color3.new(0.05, 0.05, 0.05),
			DragColor = Color3.new(0.02, 0.5, 1),
			DragOutlineTransparency = 0,
			TitleBackgroundTransparency = 0,
			TitleTextSize = 16,
			TitleColor = Color3.new(1, 1, 1),
			TitleHeight = 29,
			ShadowsEnabled = true,
			ShadowTransparency = 0.98,
			ShadowColor = Color3.new(0, 0, 0),
		},

		ide = {
			BackgroundColor = Color3.new(0.05, 0.05, 0.05),
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
}

-- data
Aereon.raylib = raylib
Aereon.gui = require("./Aereon/component/lib")

function Aereon.theme(name, new)
	themes[name] = new
end

function Aereon.rect()
	return rect(raylib.lib)
end

function Aereon.getOnStep()
	return stepcallbacks
end

function Aereon.window(game, theme, priority)
	local lib = window(raylib.lib, raylib.structs, game, function()
		return themes[theme] or themes.default
	end)
	priority = priority or 0

	table.insert(stepcallbacks, { callback = lib.update, priority = priority })
	table.insert(stepcallbacks, { callback = lib.draw, priority = priority })

	return lib
end

function Aereon.ide(theme, game)
	local lib = ide(lib, themes[theme] or themes.default, Aereon, game)
	return lib
end

function Aereon.include(game)
	local callerEnv = getfenv(2)
	callerEnv.aRect = Aereon.rect()
	callerEnv.window = Aereon.window(game, themes.default)
end

function Aereon.step(dt)
	table.sort(stepcallbacks, function(a, b)
		return a.priority > b.priority
	end)

	for _, v in ipairs(stepcallbacks) do
		v.callback(dt)
	end
	Aereon.gui:step(dt)
end

export type Aereon = typeof(Aereon)

return Aereon :: Aereon
