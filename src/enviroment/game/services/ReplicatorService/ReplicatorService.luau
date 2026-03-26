local Instance = require("@Instance")

local ReplicatorService = Instance.new("ReplicatorService")
ReplicatorService.ExplorerHidden = true

local Server = require("./_Server")
local Client = require("./_Client")

ReplicatorService.InitRenderer = function(renderer, renderer_signal, game)
	task.spawn(function()
		-- wait a bit until the game loads
		task.wait(4)

		repeat
			--log("[Replicator] Waiting for SerializationService and NetworkService")
			task.wait()
		until game.SerializationService and game.NetworkService
		local ctx = {
			game = game,
			ReplicatorService = ReplicatorService,
			SerializationService = game:GetService("SerializationService"),
			NetworkService = game:GetService("NetworkService"),
			renderer = renderer,
			signal = renderer_signal,
		}

		log("[Replicator] Initialized")
		print(IsServer, IsClient)
		if IsServer then
			Server.init(ctx)
		end
		if IsClient then
			Client.init(ctx)
		end
	end)
end

return ReplicatorService
