local Instance = require("@Instance")
local signal = require("@Kinemium.signal")
local ChatService = Instance.new("ChatService")
local Enum = require("@EnumMap")
ChatService.ExplorerHidden = true
ChatService._Intents = Enum.PluginIntents.UI

ChatService.InitRenderer = function(renderer, renderer_signal)
	ChatService:SetProperties({
		ChatEnabled = true,

		CreateChatMessage = function(player, message) end,
		CreateChatMessageForAll = function(message) end,
		CreateChatMessageForPlayers = function(players, message) end,

		OnMessageServerReplace = function() end,
		OnMessageClientReplace = function(player, message)
			if not player then
				return message
			end
			return `[{player.Name}]: {message}`
		end,
		OnMessageRecieveServer = signal.new(),
		OnMessageRecieveClient = signal.new(),
		GetChatGui = function() end,
	})
end

return ChatService
