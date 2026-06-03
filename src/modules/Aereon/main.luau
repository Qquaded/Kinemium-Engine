-- Aereon | by devcell
local Aereon = {}

local raylib = require("@raylib")

-- init
local lib = raylib.lib

-- datatypes
local Color3 = require("@Color3")

-- components
local types = require("./types")
local window = require("./window")
local rect = require("./rect")
local ide = require("./ide/scripteditor")
local textbox = require("./ide/textbox")

-- config Data
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
local gui = require("./component/lib")
Aereon.raylib = raylib
Aereon.themes = themes
Aereon.gui = gui

local function syncDefaultFont(game)
	if not game or not game.GetService then
		return
	end

	local okService, fontService = pcall(function()
		return game:GetService("KinemiumFontService")
	end)
	if not okService or not fontService or type(fontService.GetDefaultFont) ~= "function" then
		return
	end

	local okFont, vend = pcall(fontService.GetDefaultFont)
	if okFont and vend then
		gui.SetFont(vend)
	end
end

function Aereon.theme(name, new)
	themes[name] = new
end

function Aereon.rect()
	return rect
end

function Aereon.getOnStep()
	return stepcallbacks
end

function Aereon.window(game, theme, priority)
	syncDefaultFont(game)
	local lib = window(raylib.lib, raylib.structs, game, function()
		return theme
	end)
	priority = priority or 0

	table.insert(stepcallbacks, { callback = lib.update, priority = priority })
	table.insert(stepcallbacks, { callback = lib.draw, priority = priority })

	return lib
end

function Aereon.ide(theme, game)
	syncDefaultFont(game)
	local lib = ide(lib, themes[theme] or themes.default, Aereon, game)
	return lib
end

function Aereon.textbox(theme, game)
	syncDefaultFont(game)
	local lib = textbox(lib, theme or themes.default, Aereon, game)
	return lib
end

function Aereon.create(structure: types.CreationStructure)
	local created = {}

	for name, config in pairs(structure) do
		local compName = config.comp
		local factory = Aereon.gui[compName]
		if factory then
			created[name] = factory(config)
		else
			warn("Aereon.create: Component '" .. tostring(compName) .. "' not found.")
		end
	end

	local renderList = {}

	for name, v in pairs(created) do
		if type(v) == "table" and v.render then
			table.insert(renderList, name)
		end
	end

	table.sort(renderList, function(a, b)
		return (structure[a].zindex or 1) < (structure[b].zindex or 1)
	end)

	created.render = function(dt, excluded)
		for _, name in ipairs(renderList) do
			if excluded and table.find(excluded, name) then
				continue
			end
			local v = created[name]
			v.render(dt)
		end
	end

	created.get = function(name)
		return created[name]
	end

	created.setprop = function(name, prop, value)
		if created[name].set then
			created[name].set(prop, value)
		end
	end

	return created
end

function Aereon.step(dt, ...)
	table.sort(stepcallbacks, function(a, b)
		return a.priority > b.priority
	end)

	for _, v in ipairs(stepcallbacks) do
		v.callback(dt, ...)
	end
	--Aereon.gui:step(dt)
end

export type Aereon = {
	raylib: any,
	themes: any,
	gui: gui.AereonGui,

	window: (any, any, number?) -> any,
	rect: () -> any,
	create: (types.CreationStructure) -> types.CreationOutput,
	step: (number, ...any) -> (),

	textbox: (any, any) -> typeof(textbox),
}

return Aereon :: Aereon
