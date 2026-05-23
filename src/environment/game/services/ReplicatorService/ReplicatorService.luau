local Instance = require("@Instance")

local ReplicatorService = Instance.new("ReplicatorService")
ReplicatorService.ExplorerHidden = true

local Server = require("./_Server")
local Client = require("./_Client")
local StateRegistry = require("./StateRegistry")
local NetworkOwnership = require("./NetworkOwnership")
local NetworkReplicateSync = require("./NetworkReplicateSync")
local NetworkPropSync = require("./NetworkPropSync")

ReplicatorService.InitRenderer = function(renderer, renderer_signal, game)
	task.spawn(function()
		local networkService
		repeat
			task.wait()
			networkService = game.NetworkService or (game.GetService and game:GetService("NetworkService"))
		until game.SerializationService
			and networkService
			and type(networkService.RegisterMessageHandler) == "function"
			and type(networkService.SendToServer) == "function"
			and type(networkService.SendToClient) == "function"
			and type(networkService.Broadcast) == "function"

		local ctx = {
			game = game,
			ReplicatorService = ReplicatorService,
			SerializationService = game:GetService("SerializationService"),
			NetworkService = networkService,
			renderer = renderer,
			signal = renderer_signal,
			StateRegistry = StateRegistry,
			NetworkOwnership = NetworkOwnership,
		}

		local replicateSync = NetworkReplicateSync.new(ctx)
		local propSync = NetworkPropSync.new(ctx)

		ReplicatorService:SetProperties({
			RegisterStateAdapter = function(self, name, adapter)
				StateRegistry.RegisterAdapter(name, adapter)
			end,
			StateRegistry = StateRegistry,
			NetworkOwnership = NetworkOwnership,
			NetworkReplicateSync = replicateSync,
			NetworkPropSync = propSync,
			IsReplicationDone = false,
			IsPlaceReplicationDone = false,
			IsTransformReplicateDone = false,
			IsClientScriptReplicateDone = false,
		})

		if IsServer then
			propSync:StartProcessLoop()
			local ok, err = pcall(Server.init, ctx)
			if not ok then
				warn(`[ReplicatorService] Server.init failed: {err}`)
			end
		end
		if IsClient then
			replicateSync:StartProcessLoop()
			local ok, err = pcall(Client.init, ctx)
			if not ok then
				warn(`[ReplicatorService] Client.init failed: {err}`)
			end
		end
	end)
end

return ReplicatorService
