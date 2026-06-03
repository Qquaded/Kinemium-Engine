local raylib = require("@raylib")
local lib = raylib.lib
local aereon = import("@Aereon")
local gui = aereon.gui

local KinemiumFontService = game:GetService("KinemiumFontService")
local StudioThemeService = game:GetService("StudioThemeService")

local vend = KinemiumFontService.GetDefaultFont()
local arect = require("@arect")
local boldFont = KinemiumFontService.GetBoldFont()
local backgroundColor = StudioThemeService.SelectedTheme.BackgroundColor
local SecondaryBackgroundColor = StudioThemeService.SelectedTheme.SecondaryBackgroundColor

local screenx, screeny = lib.GetRenderWidth(), lib.GetScreenHeight()

local categories = require("@apidumpbrowser")
local api_endpoint = ENGINE_ENDPOINT.API :: string
local HTTPService = game:GetService("HttpService")

local browser
browser = gui.apibrowser({
	x = 50,
	y = 50,
	categories = categories,
	width = 800,
	height = 600,
	fontSize = 25,
	game = game,
	font = vend,
	onItemSelect = function(item)
		if item.type == "class" then
			browser.setClassDescription(item.name, "# Loading..")

			task.spawn(function()
				local endpoint = api_endpoint .. item.name
				local data = HTTPService:GetAsync(endpoint)

				if string.find(data, "404") then
					browser.setClassDescription(
						item.name,
						[[# 404
						Documentation about this class is not found, You can check the docs here: https://kinemium-docs.vercel.app/docs]]
					)
					return
				end

				browser.setClassDescription(item.name, data)
			end)
		end
	end,
})

repeat
	task.wait()
until ishared.Home

ishared.Home.pages["API"] = function(dt, alpha, slideOffset)
	local fade = function(col, a)
		return col:ToRaylib(1 - (a or 1) * alpha)
	end

	if ishared.Home.activePage ~= "API" and ishared.Home.previousPage ~= "API" then
		return
	end

	screenx, screeny = lib.GetRenderWidth(), lib.GetScreenHeight()

	local startX = 100
	local headerY = 80 + slideOffset
	local headerDesc = 120 + slideOffset

	if vend then
		raylib.lib.DrawTextEx(
			boldFont,
			"API Documentation",
			vector.create(startX, headerY),
			32,
			1,
			fade(StudioThemeService.SelectedTheme.TextColor, 1)
		)
		raylib.lib.DrawTextEx(
			vend,
			"Explore the Kinemium Engine API and builtin services",
			vector.create(startX, headerDesc),
			16,
			1,
			fade(StudioThemeService.SelectedTheme.SecondaryTextColor, 1)
		)
	end

	browser.set("backgroundColor", backgroundColor)
	browser.set("headerColor", SecondaryBackgroundColor)

	browser.set("obj_rect", arect.new(startX, 160 + slideOffset, screenx - 130, screeny - 190))
	browser.render(dt)
end
