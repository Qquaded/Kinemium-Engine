--[[
ReplicatorService — entry point                             
                                                            
Wires together the server & client replication subsystems.   
Waits for NetworkService and SerializationService to be      
ready, then kicks off either Server.init or Client.init.     
--]]

-- Instance class system — every service/object inherits from Instance
local Instance = require("@Instance")
local Enum = require("@EnumMap")

-- Create the singleton service object
local ReplicatorService = Instance.new("ReplicatorService")
ReplicatorService.ExplorerHidden = true -- Hide from Studio explorer
ReplicatorService._Intents = Enum.PluginIntents.Network -- Declare capability

-- Sub-modules for server & client replication logic
local Server = require("@Server")
local Client = require("@Client")
-- StateRegistry: serialises/deserialises object state for owned-state sync
local StateRegistry = require("@StateRegistry")
-- NetworkOwnership: manages which client "owns" each physics object
local NetworkOwnership = require("@NetworkOwnership")
-- NetworkReplicateSync: chunked object replication sync (used on client)
local NetworkReplicateSync = require("@NetworkReplicateSync")
-- NetworkPropSync: batched SyncVar property broadcasts
local NetworkPropSync = require("@NetworkPropSync")

-- Called by the engine after renderer is ready. Runs in a separate coroutine
-- so it can wait for dependencies without blocking startup.
ReplicatorService.InitRenderer = function(renderer, renderer_signal, game)
	task.spawn(function()
		-- Wait until NetworkService is available and exposes the expected API surface
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

		-- Context table passed to Server.init / Client.init
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

		-- Expose subsystems as properties so sandboxed scripts can access them
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
