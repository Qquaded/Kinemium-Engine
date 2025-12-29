local Instance = require("@Instance")
local signal = require("@Kinemium.signal")

local SteamService = Instance.new("SteamService")
SteamService.ExplorerHidden = false

SteamService.InitRenderer = function(renderer, renderer_signal)
	local steam = require("@steam")
	local lib = steam.lib

	local initResult = lib.SteamAPI_InitSafe()
	if initResult == nil then
		error("Failed to initialize Steam API")
	end

	local steamUser = lib.SteamAPI_SteamUser_v023()
	local steamFriends = lib.SteamAPI_SteamFriends_v018()
	local steamUtils = lib.SteamAPI_SteamUtils_v010()

	SteamService:SetProperties({
		Enabled = true, -- master switch
		RunCallbacks = true, -- call SteamAPI_RunCallbacks
		InitOnStart = true, -- auto init steam
		Debug = false, -- log steam status
		AppIdOverride = 0, -- manual SteamAppId (0 = none)

		UseFriends = true,
		UseUtils = true,
		UseUser = true,

		-- internals
		api = steam,
	})

	-- this is currently limited; will add more features soon prob

	renderer_signal:Connect(function(route)
		if route == "RenderStepped" then
			lib.SteamAPI_RunCallbacks()
		end
	end)
end

return SteamService
