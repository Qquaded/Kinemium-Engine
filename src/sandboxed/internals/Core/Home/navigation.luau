if FlagExists("client") then
	return
end

local RunService = game:GetService("RunService")
if RunService:IsServer() then
	return
end

local rlservice = game:GetService("KinemiumRaylib")
local raylib = require("@raylib")
local lib = raylib.lib
local renderer = rlservice.GetRenderer()
local aereon = require("@Aereon")
local gui = aereon.gui

local KinemiumFontService = game:GetService("KinemiumFontService")
local StudioThemeService = game:GetService("StudioThemeService")
local KinemiumIconLoader = game:GetService("KinemiumIconLoader")

local vend = KinemiumFontService.GetDefaultFont()
local arect = require("@arect")

local backgroundColor = StudioThemeService.SelectedTheme.BackgroundColor
local SecondaryBackgroundColor = StudioThemeService.SelectedTheme.SecondaryBackgroundColor
local SecondaryBackgroundColorRaylib = StudioThemeService.SelectedTheme.SecondaryBackgroundColor:ToRaylib(
	StudioThemeService.SelectedTheme.SecondaryBackgroundColorTransparency
)

local screenx, screeny = lib.GetRenderWidth(), lib.GetScreenHeight()
local frame = gui.frame({ x = 0, y = 0, width = 0, height = 0 })
local topframe = gui.frame({ x = 0, y = 0, width = screenx, height = 60 })

local logoPath = "./src/assets/images/kinemium/KinemiumWhite.png"
local logoTex = KinemiumIconLoader.ToTexture(logoPath)

local mainSignal = Signal.new()

local texture, image = renderer.LoadImageAsTex("./src/assets/images/inverse.png")

ishared.Home = {
	signal = mainSignal,
	rendering = {},
	pages = {},
	activePage = "Projects",
	previousPage = "",
	transitionAlpha = 1,
	transitionDir = 1, -- 1 for forward, -1 for back
}

local nav
nav = gui.navigation({
	x = 0,
	y = 60,
	width = 60,
	height = lib.GetRenderHeight(),
	items = {},
	selectedColor = StudioThemeService.SelectedTheme.Accent,
	selectedIconColor = SecondaryBackgroundColor,
	itemBackgroundColor = SecondaryBackgroundColor,
	font = vend,

	onItemClick = function(item, index)
		if ishared.Home.activePage == item.label then
			return
		end
		ishared.Home.activePage = item.label
		mainSignal:Fire(item.label)
	end,
})

nav.addItem("home", "icon", "Projects", KinemiumIconLoader.ToTexture("./src/assets/images/home.png"))
nav.addItem("settings", "icon", "Settings", KinemiumIconLoader.ToTexture("./src/assets/images/settings.png"))
nav.addItem("marketplace", "icon", "Marketplace", KinemiumIconLoader.ToTexture("./src/assets/images/marketplace.png"))
nav.addItem("marketplace", "icon", "API", KinemiumIconLoader.ToTexture("./src/assets/images/api.png"))
nav.addItem(
	"servers",
	"icon",
	"Servers",
	KinemiumIconLoader.ToTexture("./src/assets/images/icons/ServerScriptService.png")
)

local homeButton = gui.imageButton({
	x = 15,
	y = 15,
	width = 40,
	height = 40,
	image = logoTex,
	backgroundColor = SecondaryBackgroundColor,
	hoverColor = StudioThemeService.SelectedTheme.Accent,
	pressColor = StudioThemeService.SelectedTheme.Accent,
	imageScale = 1,
	rounded = { 1, 0 },
	onClick = function()
		ishared.Home.activePage = "Projects"
		mainSignal:Fire("Projects")
	end,
})

ishared.EnableHomescreen = true

if FlagExists("dhs") then
	return
end
renderer.Pool.new("2d", function()
	if ishared.EnableHomescreen == false then
		game.Context = Enum.GameContext.Editor
		return
	end
	local dt = raylib.lib.GetFrameTime()

	renderer:SetDimension("2D")

	game.Context = Enum.GameContext.Home
	screenx, screeny = lib.GetRenderWidth(), lib.GetScreenHeight()

	frame.set("raylib_color", backgroundColor:ToRaylib(0))
	frame.set("obj_rect", arect.new(0, 0, screenx, screeny))
	frame.render(dt)

	local activePage = ishared.Home.pages[ishared.Home.activePage]
	if activePage then
		activePage(dt, 1, 0) -- Full alpha, zero offset
	end

	for _, objecttoRender in pairs(ishared.Home.rendering) do
		objecttoRender.render(dt)
	end

	nav.set("obj_rect", arect.new(0, 60, 60, screeny))
	nav.set("backgroundColor", SecondaryBackgroundColor)
	nav.render(dt)

	topframe.set("raylib_color", SecondaryBackgroundColorRaylib)
	topframe.set("obj_rect", arect.new(0, 0, screenx, 60))
	topframe.render(dt)

	homeButton.render(dt)

	local cornerSize = 50
	local cornerOffsetX = 10

	if not nav.config.isExpanded then
		lib.DrawTexturePro(
			texture,
			raylib.structs.Rectangle:new({ x = 0, y = 0, width = 256, height = 256 }),
			raylib.structs.Rectangle:new({ x = 60 + cornerOffsetX, y = 60, width = cornerSize, height = cornerSize }),
			vector.create(0, 0),
			0,
			SecondaryBackgroundColorRaylib
		)
	end
end, -1)
