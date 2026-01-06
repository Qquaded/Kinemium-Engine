local Instance = require("@Instance")
local Vector3 = require("@Vector3")
local ReplicatorService = Instance.new("ReplicatorService")
local Color3 = require("@Color3")
local Registry = require("@InstanceRegistry")
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

local OPCODES = {
	CREATE = 1,
	DELETE = 2,
	CHANGE = 3,
}

local function LookupUniqueId(id, container)
	for _, v in pairs(container:GetDescendants()) do
		if v.UniqueId == id then
			return v.UniqueId
		end
	end
end

ReplicatorService.InitRenderer = function(renderer, signal, game)
	ReplicatorService:SetProperties({
		Run = function()
			task.spawn(function()
				repeat
					print("Waiting for game.NetworkService")
					task.wait()
				until game.NetworkService
				local KiNet = game.NetworkService.KiNet
				local SerializationService = game.SerializationService

				if KiNet.Client.Socket then
					print("Found client socket")

					repeat
						print("Waiting for client authentication...")
						task.wait(0.5)
					until KiNet.Client.IsAuthenticated

					print("Client authenticated!")

					KiNet.Client:OnRecieve(function(addr, data)
						task.spawn(function()
							local type = data.type
							if type == OPCODES.CREATE then
								local Deserialized = SerializationService.Deserialize(data.instance)
								for _, object in pairs(Deserialized) do
									if LookupUniqueId(object.UniqueId, game.Workspace) then
										object:Destroy()
									end
									object.Parent = game.Workspace
								end
							end
						end)
					end)
				end

				if KiNet.Server.Socket then
					print("Found server socket")

					game.Workspace.ChildAdded:Connect(function(child)
						task.spawn(function()
							log(`Child added: {child.Name}, Syncing..`)
							local Serialized = SerializationService.SerializeInstancesAsync({ child })
							print(Serialized)

							KiNet.Server:SendAll({
								type = OPCODES.CREATE,
								instance = Serialized,
							})
						end)
					end)
				end
			end)
		end,
	})
end

return ReplicatorService
