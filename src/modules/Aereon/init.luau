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

-- config Data
local config = {}
local stepcallbacks = {}

-- themes
local themes = {
	default = {
		window = {
			BackgroundColor = Color3.new(0.07, 0.07, 0.07),
			BackgroundTransparency = 0.015,
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
	},
}

-- data
Aereon.raylib = raylib

function Aereon.theme(name, new)
	themes[name] = new
end

function Aereon.rect()
	return rect(raylib.lib)
end

function Aereon.window(game, theme, priority)
	local lib = window(raylib.lib, raylib.structs, game, themes[theme] or themes.default)
	priority = priority or 0

	table.insert(stepcallbacks, { callback = lib.update, priority = priority })
	table.insert(stepcallbacks, { callback = lib.draw, priority = priority })

	return lib
end

function Aereon.include(game)
	local callerEnv = getfenv(2)
	callerEnv.aRect = Aereon.rect()
	callerEnv.window = Aereon.window(game, themes.default)
end

function Aereon.step()
	table.sort(stepcallbacks, function(a, b)
		return a.priority > b.priority
	end)

	for _, v in ipairs(stepcallbacks) do
		v.callback(game)
	end
end

export type Aereon = typeof(Aereon)

return Aereon :: Aereon
