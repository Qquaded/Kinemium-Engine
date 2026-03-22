-- devcell

local KinemiumRaylib = game:GetService("KinemiumRaylib")
local KinemiumIconLoader = game:GetService("KinemiumIconLoader")
local KinemiumFontService = game:GetService("KinemiumFontService")
local StudioThemeService = game:GetService("StudioThemeService")
local aereon = require("@Aereon")
local raylib = require("@raylib")
local rl = raylib.lib
local gui = aereon.gui
local rect = require("@arect")(rl)
local vend = KinemiumFontService.GetDefaultFontSmall()
local renderer = KinemiumRaylib.renderer

local logoPath = "./src/assets/images/icons/vanilla3/kinemium/KinemiumWhite.png"
local logoIcon = KinemiumIconLoader.ToTexture(logoPath)

local SecondaryBackgroundColor = StudioThemeService.SelectedTheme.SecondaryBackgroundColor

local aboutPrompt = gui.prompt({
	visible = false,
	width = 400,
	height = 600,
	bodyHeight = 400,
	font = vend,
	backgroundColor = SecondaryBackgroundColor,
	title = "ABOUT ENGINE",
	buttons = {},
	bodyRenderer = function(dt, x, y, width, height)
		local iconRect = rect.new(x, y, 200, 200)

		local iconRectSource = rect.new(0, 0, logoIcon.x, logoIcon.y)

		local tint = raylib.const.WHITE
		rl.DrawTexturePro(
			logoIcon.texture,
			rect:translate(iconRectSource),
			rect:translate(iconRect),
			vector.create(0, 0),
			0,
			tint
		)

		rl.DrawTextEx(
			vend,
			"Kinemium Engine\n  Version 1.9.0 \n  Made by devcell (Qquaded)\nContributions:\n  Lynxmountain\n  Uzixt\n  Contrastual\n  nicobloxy (Translator)\n  duck (Translator)",
			vector.create(x, y + 200),
			25,
			2,
			tint
		)
	end,
})

game.EngineSignal:Connect(function(route)
	if route == "EnableAboutMenu" then
		aboutPrompt.show()
	end
end)

renderer.Hook.new("After2D", function(data)
	if game.Context ~= Enum.GameContext.Editor then
		return
	end

	local dt = rl.GetFrameTime()
	aboutPrompt.render(dt)
end)
