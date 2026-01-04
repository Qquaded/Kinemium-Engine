local Instance = require("@Instance")
local Vector3 = require("@Vector3")
local GameReplicator = Instance.new("GameReplicator")
local Color3 = require("@Color3")
local pool = {}

local raylib = require("@raylib")
local lib = raylib.lib
local structs = raylib.structs

local function Color3ToRaylib(c, transparency)
	local r, g, b = c:ToRGB()
	return structs.Color:new({
		r = r,
		g = g,
		b = b,
		a = math.floor(255 * (1 - transparency)),
	})
end

GameReplicator.InitRenderer = function(renderer, signal, game)
	GameReplicator:SetProperties({
		Run = function()
			task.spawn(function()
				repeat
					print("Waiting for game.NetworkService")
					task.wait()
				until game.NetworkService
				local KiNet = game.NetworkService.KiNet
				local SerializationService = game.SerializationService
				print("Successfully loaded")

				local function SerializeGame()
					local data = SerializationService.SerializeInstancesAsync({ game })
					return data
				end

				if KiNet.Client.Socket then
					print("Found client socket")
					KiNet.Client:OnRecieve(function(addr, data)
						log(data)
					end)
				end

				KiNet.Server:SendAll("hello people of kiNet")
			end)
		end,
	})
end

return GameReplicator
