local Instance = require("@Instance")
local net = zune.net

local RojoSyncService = Instance.new("RojoSyncService")
RojoSyncService.ExplorerHidden = true

local Registry = require("@InstanceRegistry")

local isConnected = false
local rootInstanceId = nil
local sessionId = nil
local messageCursor = -1
local socket = nil
local instanceMap = {
	fromIds = {},
	fromInstances = {},
}

local Color3 = require("@Color3")
local CFrame = require("@CFrame")
local Vector3 = require("@Vector3")

RojoSyncService.InitRenderer = function(renderer, renderer_signal, game)
	task.spawn(function()
		repeat
			task.wait()
		until game["GetService"] and game:GetService("HttpService")
		local HttpService = game:GetService("HttpService")

		local function decodePropertyValue(prop)
			if type(prop) ~= "table" then
				return prop
			end

			if prop.Float32 ~= nil then
				return prop.Float32
			elseif prop.Float64 ~= nil then
				return prop.Float64
			elseif prop.Int32 ~= nil then
				return prop.Int32
			elseif prop.Int64 ~= nil then
				return prop.Int64
			elseif prop.Bool ~= nil then
				return prop.Bool
			elseif prop.String ~= nil then
				return prop.String
			elseif prop.Vector3 ~= nil then
				local v = prop.Vector3
				return Vector3.new(v[1], v[2], v[3])
			elseif prop.Color3 ~= nil then
				local c = prop.Color3
				if not c[1] then
					return
				end
				return Color3.new(c[1], c[2], c[3])
			elseif prop.CFrame ~= nil then
				return CFrame.new(unpack(prop.CFrame))
			elseif prop.Enum ~= nil then
				return prop.Enum
			end

			return nil
		end

		local function normalizeId(id)
			if type(id) == "string" then
				return id:gsub("-", "")
			end
			return id
		end

		local function constructInstance(id, parent, patchAdded)
			local virtualInstance = patchAdded[id] or patchAdded[normalizeId(id)]
			if not virtualInstance then
				return
			end

			local nid = normalizeId(id)
			local inst = instanceMap.fromIds[nid]

			if inst == nil then
				local className = virtualInstance.ClassName
				local ok, created = pcall(Instance.new, className)
				if not ok or created == nil then
					return
				end

				pcall(Registry.InitCallbackClass, created, className, renderer, game)
				inst = created
				inst.Name = virtualInstance.Name
				inst.Parent = parent
				instanceMap.fromIds[nid] = inst
				instanceMap.fromInstances[inst] = nid
			end

			if virtualInstance.Properties then
				for propName, propValue in pairs(virtualInstance.Properties) do
					local decoded = decodePropertyValue(propValue)
					if decoded ~= nil then
						pcall(function()
							inst[propName] = decoded
						end)
					end
				end
			end

			if virtualInstance.Children then
				for _, childId in ipairs(virtualInstance.Children) do
					constructInstance(normalizeId(childId), inst, patchAdded)
				end
			end

			return inst
		end

		local SERVICE_CLASSES = {
			"Workspace", "Players", "Lighting", "ReplicatedStorage", "ReplicatedFirst",
			"ServerScriptService", "ServerStorage", "StarterGui", "StarterPack",
			"StarterPlayer", "SoundService", "Teams", "TextChatService",
			"TweenService", "RunService", "UserInputService", "HttpService",
			"CollectionService", "DataStoreService", "PathfindingService",
			"PhysicsService", "ChatService",
		}

		local function applyFullSnapshot(instances)
			-- Destroy only non-service, non-game instances
			for _, inst in pairs(instanceMap.fromIds) do
				if inst ~= game then
					local ok, cls = pcall(function() return inst.ClassName end)
					local isService = false
					if ok then
						for _, sc in ipairs(SERVICE_CLASSES) do
							if sc == cls then
								isService = true
								break
							end
						end
					end
					if not isService then
						pcall(function() inst:Destroy() end)
					end
				end
			end

			local normRoot = normalizeId(rootInstanceId)
			instanceMap.fromIds = { [normRoot] = game }
			instanceMap.fromInstances = { [game] = normRoot }

			-- Build a normalized-key copy of instances so lookups always work
			local normInstances = {}
			if type(instances) == "table" then
				for k, v in pairs(instances) do
					normInstances[normalizeId(k)] = v
				end
			end

			-- Pre-seed known services so constructInstance reuses singletons
			for nid, vInst in pairs(normInstances) do
				if nid ~= normRoot and vInst.ClassName then
					for _, sc in ipairs(SERVICE_CLASSES) do
						if sc == vInst.ClassName then
							local ok, svc = pcall(function() return game:GetService(sc) end)
							if ok and svc then
								instanceMap.fromIds[nid] = svc
								instanceMap.fromInstances[svc] = nid
							end
							break
						end
					end
				end
			end

			local rootSnap = normInstances[normRoot]
			if rootSnap and rootSnap.Children then
				for _, childId in ipairs(rootSnap.Children) do
					constructInstance(normalizeId(childId), game, normInstances)
				end
			end
		end

		local function fetchReadSnapshot(baseUrl)
			if rootInstanceId == nil then
				return nil
			end

			local ok, readRes = pcall(net.http.request, baseUrl .. "/api/read/" .. tostring(rootInstanceId), {
				headers = { ["Accept"] = "application/json" },
			})
			
			if not ok or not readRes or not readRes.ok then
				return nil
			end

			local readSuccess, readData = pcall(HttpService.JSONDecode, HttpService, readRes.body)
			if not readSuccess or type(readData) ~= "table" then
				return nil
			end

			return readData
		end

		local function applyPatch(patch)
			-- Handle Removed
			if patch.removed then
				for _, id in ipairs(patch.removed) do
					local inst = instanceMap.fromIds[normalizeId(id)]
					if inst then
						inst:Destroy()
						instanceMap.fromIds[normalizeId(id)] = nil
						instanceMap.fromInstances[inst] = nil
					end
				end
			end

			-- Handle Added
			if patch.added then
				local normAdded = {}
				for id, virtualInstance in pairs(patch.added) do
					normAdded[normalizeId(id)] = virtualInstance
				end
				for id, virtualInstance in pairs(normAdded) do
					if not instanceMap.fromIds[id] then
						local parentInst = instanceMap.fromIds[normalizeId(virtualInstance.Parent)]
						local isChildOfAddition = normAdded[normalizeId(virtualInstance.Parent)] ~= nil
						if not isChildOfAddition then
							if parentInst then
								constructInstance(id, parentInst, normAdded)
							end
						end
					end
				end
			end

			-- Handle Updated
			if patch.updated then
				for _, update in ipairs(patch.updated) do
					local inst = instanceMap.fromIds[normalizeId(update.id)]
					if inst then
						if update.changedName then
							inst.Name = update.changedName
						end
						if update.changedProperties then
							for propName, propValue in pairs(update.changedProperties) do
								local decoded = decodePropertyValue(propValue)
								if decoded ~= nil then
									pcall(function()
										inst[propName] = decoded
									end)
								end
							end
						end
					end
				end
			end
		end

		function RojoSyncService:Connect(port)
			if isConnected then
				return true
			end
			port = port or 3487

			local baseUrl = "http://localhost:" .. tostring(port)
			local wsBaseUrl = "ws://localhost:" .. tostring(port)

			print("RojoSyncService: Connecting to " .. baseUrl)

			if socket then
				pcall(function()
					if socket.close then
						socket:close(1000)
					elseif socket.Destroy then
						socket:Destroy()
					end
				end)
				socket = nil
			end

			local ok, res = pcall(net.http.request, baseUrl .. "/api/rojo", {
				headers = { ["Accept"] = "application/json" },
			})
			if not ok or not res or not res.ok then
				print("RojoSyncService: Failed to connect to Rojo server.")
				return false
			end

			local success, serverInfo = pcall(HttpService.JSONDecode, HttpService, res.body)
			if not success then
				print("RojoSyncService: Failed to decode JSON from /api/rojo")
				return false
			end

			rootInstanceId = serverInfo.rootInstanceId
			sessionId = serverInfo.sessionId
			if rootInstanceId == nil then
				print("RojoSyncService: Missing rootInstanceId in /api/rojo response")
				return false
			end

			local readData = fetchReadSnapshot(baseUrl)
			if not readData then
				print("RojoSyncService: Failed to fetch initial snapshot from /api/read")
				return false
			end

			messageCursor = tonumber(readData.messageCursor) or -1

			applyFullSnapshot(readData.instances)

			print("Finished making instances")

			local function resyncFromRead(reason)
				local data = fetchReadSnapshot(baseUrl)
				if not data then
					print("RojoSyncService: Failed to resync snapshot (" .. tostring(reason) .. ")")
					return false
				end
				messageCursor = tonumber(data.messageCursor) or messageCursor
				applyFullSnapshot(data.instances)
				print("RojoSyncService: Resynced from /api/read (cursor " .. tostring(messageCursor) .. ")")
				return true
			end

			local function applyMessageEntry(entry)
				if type(entry) ~= "table" then
					return false
				end

				if entry.removed ~= nil or entry.added ~= nil or entry.updated ~= nil then
					applyPatch(entry)
					return true
				end

				return false
			end

			local function handleSocketMessage(rawMessage)
				local decodedOk, packet = pcall(HttpService.JSONDecode, HttpService, rawMessage)
				if not decodedOk or type(packet) ~= "table" then
					print("RojoSyncService: Failed to decode websocket message")
					return
				end

				-- If the session changed (Rojo restarted), do a full resync
				if packet.sessionId ~= nil and packet.sessionId ~= sessionId then
					print("RojoSyncService: Session changed, resyncing...")
					sessionId = packet.sessionId
					local resynced = resyncFromRead("session-change")
					if not resynced then
						return
					end
				end

				if packet.packetType ~= "messages" then
					if packet.packetType == "reset" then
						resyncFromRead("reset")
					end
					return
				end

				local body = packet.body
				if type(body) ~= "table" then
					return
				end

				if body.messageCursor ~= nil then
					messageCursor = tonumber(body.messageCursor) or messageCursor
				end

				for _, message in ipairs(body.messages or {}) do
					if not applyMessageEntry(message) and type(message) == "table" then
						for _, nested in ipairs(message) do
							applyMessageEntry(nested)
						end
					end
				end
			end

			local wsUrl = wsBaseUrl .. "/api/socket/" .. tostring(messageCursor)
			local socketOk, openedSocket = pcall(net.http.websocket, wsUrl, {
				timeout = -1,

				message = function(self, msg)
					handleSocketMessage(msg)
					return true
				end,
				close = function(self, code)
					print("RojoSyncService: Websocket closed (" .. tostring(code) .. ")")
					isConnected = false
					socket = nil
					return true
				end,
			})

			if not socketOk or not openedSocket then
				print("RojoSyncService: Failed to open websocket")
				return false
			end

			socket = openedSocket
			isConnected = true
			print("RojoSyncService: Connected (websocket mode)")

			return true
		end

		function RojoSyncService:Disconnect()
			if socket then
				pcall(function()
					if socket.close then
						socket:close(1000)
					elseif socket.Destroy then
						socket:Destroy()
					end
				end)
				socket = nil
			end
			isConnected = false
		end

		function RojoSyncService:IsConnected()
			return isConnected
		end
	end)
end

return RojoSyncService
