local Instance = require("@Instance")
local signal = require("@Kinemium.signal")
local lua = require("@lua")
local LuaVM = lua.LuaVM
local task = zune.task

local BrowserService = Instance.new("BrowserService")
BrowserService.ExplorerHidden = true

local raylib = require("@raylib")

local startup = [[
    package.path = package.path .. ";src/external/lua-webview/?.lua"
    package.cpath = package.cpath .. ";src/external/lua-webview/?.dll"
    
    require("webview-launcher")
    return true 
]]

local function getCode(link)
	local code = [[
        local webviewLauncher = require("webview-launcher")
		local webviewLib = require("webview")

        webviewLib.open('%s', "Kinemium Engine", 800, 600, true)
    ]]
	return string.format(code, link)
end

BrowserService.InitRenderer = function(renderer, renderer_signal)
	if IsHeadless then
		return
	end
	local lib: typeof(raylib.lib) = renderer.lib
	local vm = LuaVM.new()

	task.spawn(function()
		local success, result, err = vm:execute(startup)

		if not success then
			error("Failed to load webview-launcher.lua: " .. (err or "unknown error"))
		end
	end)

	BrowserService:SetProperties({
		openURL = lib.OpenURL,
		webview = {
			openWindowURL = function(str)
				vm:execute(getCode(str))
			end,
		},
	})
end

return BrowserService
