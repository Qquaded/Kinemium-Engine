-- devcell

local KinemiumRaylib = game:GetService("KinemiumRaylib")
local KinemiumIconLoader = game:GetService("KinemiumIconLoader")
local DiscordRPC = game:GetService("DiscordRPC")
local EngineSignal = game.EngineSignal
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local renderer = KinemiumRaylib.renderer
local rl = KinemiumRaylib.lib
local structs = KinemiumRaylib.structs

if game.Context ~= Enum.GameContext.Editor then
	return
end

if FlagExists("client") then
	return
end

local aereon = import("@Kinemium.Aereon")
local ide = aereon.ide(nil, game)

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "Output"
screenGui.Parent = LocalPlayer.PlayerGui

local function Color3ToRaylib(c, transparency)
	local r, g, b = c:ToRGB()
	return structs.Color:new({
		r = r,
		g = g,
		b = b,
		a = math.floor(255 * (1 - transparency)),
	})
end

--[[
task.wait(2)

renderer.renderWorkspaceCallbackSet(function(texture, lib, size)
	lib.DrawTexturePro(
		texture,
		structs.Rectangle:new({ x = 0, y = 0, width = size.x, height = -size.y }),
		structs.Rectangle:new({
			x = frame.AbsolutePosition.X,
			y = frame.AbsolutePosition.Y,
			width = lib.GetRenderWidth(),
			height = lib.GetRenderHeight(),
		}),
		vector.create(0, 0, 0),
		0,
		KinemiumRaylib.const.WHITE
	)
end)
--]]

local enableIDE = false
local currentObject

EngineSignal:Connect(function(route, value, Script)
	if route == "idestate" then
		if value == true then
			--KinemiumIDE.Open()
			ide.text:clear()
			ide.text:insertString(Script.Source)
			enableIDE = true
			currentObject = Script
			DiscordRPC.ChangeDetail(`Editing {Script.Name}`)

			game.Stop3DInput = true
		else
			enableIDE = false
			currentObject = nil
			DiscordRPC.ChangeDetail(`idle..`)

			game.Stop3DInput = false
		end
	end
end)

renderer.Add2DStack(function(data)
	local screenWidth = rl.GetMonitorWidth(0)
	local screenHeight = rl.GetMonitorHeight(0)
	local toolbarHeight = 120
	local viewportX = 0
	local viewportY = toolbarHeight
	local viewportWidth = screenWidth - 400
	local viewportHeight = screenHeight - toolbarHeight - screenHeight * 0.2

	aereon.step(rl.GetFrameTime())

	if enableIDE then
		ide.draw(viewportX, viewportY, vector.create(viewportWidth, viewportHeight), 50)

		if currentObject then
			currentObject.Source = ide:getCode()
		end
	end
end)
