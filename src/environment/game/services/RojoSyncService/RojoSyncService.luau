local Instance = require("@Instance")
local signal = require("@Kinemium.signal")

local RojoSyncService = Instance.new("RojoSyncService")
RojoSyncService.ExplorerHidden = true

local isConnected = false
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

		local function constructInstance(id, parent, patchAdded)
			local virtualInstance = patchAdded[id]
			if not virtualInstance then
				return
			end

			local className = virtualInstance.ClassName
			local inst = Instance.new(className)
			inst.Name = virtualInstance.Name
			inst.Parent = parent

			instanceMap.fromIds[id] = inst
			instanceMap.fromInstances[inst] = id

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
					constructInstance(childId, inst, patchAdded)
				end
			end

			return inst
		end

		local function applyPatch(patch)
			-- Handle Removed
			if patch.removed then
				for _, id in ipairs(patch.removed) do
					local inst = instanceMap.fromIds[id]
					if inst then
						inst:Destroy()
						instanceMap.fromIds[id] = nil
						instanceMap.fromInstances[inst] = nil
					end
				end
			end

			-- Handle Added
			if patch.added then
				for id, virtualInstance in pairs(patch.added) do
					if not instanceMap.fromIds[id] then
						local parentInst = instanceMap.fromIds[virtualInstance.Parent]
						-- Only construct if it's the root of an addition tree
						local isChildOfAddition = patch.added[virtualInstance.Parent] ~= nil
						if not isChildOfAddition then
							if parentInst then
								constructInstance(id, parentInst, patch.added)
							end
						end
					end
				end
			end

			-- Handle Updated
			if patch.updated then
				for _, update in ipairs(patch.updated) do
					local inst = instanceMap.fromIds[update.id]
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
			print("Warning: Rojo support is still being worked on, For now it does not work. Wow!")
			if isConnected then
				return
			end
			port = port or 3487

			local baseUrl = "http://localhost:" .. tostring(port)

			print("RojoSyncService: Connecting to " .. baseUrl)

			print(1)
			-- 1. Initialize session
			local _, res = HttpService:GetAsync(baseUrl .. "/api/rojo", { ["Accept"] = "application/json" })
			print(res.Ok)
			if not res.Ok then
				print("RojoSyncService: Failed to connect to Rojo server.")
				return false
			end

			local success, serverInfo = pcall(HttpService.JSONDecode, HttpService, res.Body)
			print(2, res.Ok)
			if not success then
				print("RojoSyncService: Failed to decode JSON from /api/rojo")
				return false
			end

			sessionId = serverInfo.sessionId

			-- 2. Read initial tree
			local readUrl = baseUrl .. "/api/read/" .. serverInfo.rootInstanceId
			local _, readRes = HttpService:GetAsync(readUrl, { ["Accept"] = "application/json" })

			print(readRes.Ok, 3)

			if readRes.Ok then
				local readSuccess, readData = pcall(HttpService.JSONDecode, HttpService, readRes.Body)
				print(readData)
				if readSuccess then
					messageCursor = readData.messageCursor

					instanceMap.fromIds[serverInfo.rootInstanceId] = game
					instanceMap.fromInstances[game] = serverInfo.rootInstanceId

					local rootSnap = readData.instances[serverInfo.rootInstanceId]
					task.spawn(function()
						if rootSnap and rootSnap.Children then
							for _, childId in ipairs(rootSnap.Children) do
								print(childId)
								constructInstance(childId, game, readData.instances)
							end
						end
					end)
				end
			end

			print("Finished making instances")

			-- 3. Connect Websocket
			isConnected = true
			print("RojoSyncService: Connected (polling mode)")

			task.spawn(function()
				while isConnected do
					task.wait(1)

					print("Syncing")

					local _, pollRes = HttpService:GetAsync(baseUrl .. "/api/read/" .. serverInfo.rootInstanceId)
					if not pollRes.Ok then
						print("RojoSyncService: Lost connection to Rojo")
						isConnected = false
						break
					end

					print(pollRes.Ok)

					local ok, data = pcall(HttpService.JSONDecode, HttpService, pollRes.Body)
					if ok and data.messageCursor ~= messageCursor then
						messageCursor = data.messageCursor

						print(messageCursor)

						-- Clear and rebuild changed instances
						-- Simple approach: full resync
						for id, inst in pairs(instanceMap.fromIds) do
							task.spawn(function()
								if inst ~= game then
									pcall(function()
										inst:Destroy()
									end)
								end
							end)
						end
						instanceMap.fromIds = { [serverInfo.rootInstanceId] = game }
						instanceMap.fromInstances = { [game] = serverInfo.rootInstanceId }

						local rootSnap = data.instances[serverInfo.rootInstanceId]
						task.spawn(function()
							if rootSnap and rootSnap.Children then
								for _, childId in ipairs(rootSnap.Children) do
									print(childId)
									constructInstance(childId, game, data.instances)
								end
							end
						end)

						print("RojoSyncService: Synced (cursor " .. messageCursor .. ")")
					end
				end
			end)

			return true
		end

		function RojoSyncService:Disconnect()
			if socket then
				socket:Destroy()
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
