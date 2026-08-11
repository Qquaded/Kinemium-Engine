local Instance = require("@Instance")
local Enum = require("@EnumMap")
local signal = require("@Kinemium.signal")
local zembed = require("@zembed")

local DataModel = {}
DataModel.__index = DataModel

local fs = zune.fs

local aliases = {}
local HEADLESS_SKIP_INIT = {
	FileDialogService = true,
	GuiStackService = true,
	KinemiumFontService = true,
	KinemiumIconLoader = true,
	Plugin = true,
	ProjectLoaderService = true,
	ProjectSyncService = true,
	Selection = true,
	SoundService = true,
	SteamService = true,
	StudioThemeService = true,
	UserInputService = true,
	VideoService = true,
}
local kilang = require("@kilang")

function DataModel.new(RENDERER, ...)
	local self = setmetatable({}, DataModel)

	self = Instance.new("DataModel")
	self.Name = "datamodel"
	self.Dimension = Enum.Dimension["3D"]
	self.Context = Enum.GameContext.Editor
	self.EngineSignal = signal.new()
	self.Stop3DInput = false
	self.ShutdownCallbacks = {}
	self.Loaded = false
	self.MultiplayerMode = Enum.MultiplayerMode.Multiplayer
	self.PlaceId = 0
	self.GameId = 0

	self.Services = {}

	local services
	if zembed.IsEmbedded() then
		services = {}
		for _, servicePath in pairs(zembed.GetScriptsThatHas([[environment\game\services]])) do
			local normalized = servicePath:gsub([[\]], "/")
			local folderName, fileName = normalized:match("/services/([^/]+)/([^/]+)%.luau$")
			if folderName and fileName == folderName then
				table.insert(services, servicePath)
			end
		end
	else
		services = fs.entries("./src/environment/game/services")
	end

	local serviceInitStart = os.clock()
	for _, service in pairs(services) do
		local addServiceStart = os.clock()
		local name
		local path
		if zembed.IsEmbedded() then
			name = fs.path.basename(service):gsub(".luau", "")
			path = `./services/{name}/{name}`

			if string.find(path, "_") then
				print("Skipping " .. path)
				continue
			end
		else
			name = service.name
			path = `./src/environment/game/services/{name}/{name}.luau`
		end

		local read = zune.fs.readFile(path)
		local stack, success, returnedData = kilang:execute(read, {
			SecurityCapabilities = Enum.SecurityCapabilities.Internals,
			StackId = path,
		})
		local initTime = (os.clock() - addServiceStart) * 1000

		if success then
			local success2, returnedData2 = pcall(function()
				self.Services[name] = returnedData
				if not returnedData then
					return
				end
				if returnedData.InitRenderer then
					if not (IsHeadless == true and HEADLESS_SKIP_INIT[name] == true) then
						returnedData.InitRenderer(RENDERER, RENDERER.EventBus, self)
					else
						log(string.format("[ServiceRegistry] Skipped headless init for service %s", name))
					end
					if returnedData.aliases then
						aliases[name] = returnedData.aliases
					end
				end
			end)

			if success2 then
				log(
					string.format(
						"[ServiceRegistry] Added service %s in %.3fms (required in %.3fms)",
						name,
						(os.clock() - addServiceStart) * 1000,
						initTime
					)
				)
			else
				warn(
					"Error initializing service '"
						.. name
						.. "' at path '"
						.. path
						.. "':\n"
						.. tostring(returnedData2)
						.. "\n"
						.. debug.traceback("", 2)
				)
				zune.process.exit(0)
			end
		else
			print(
				"Failed to require service '"
					.. name
					.. "' at path '"
					.. path
					.. "':\n"
					.. tostring(returnedData)
					.. "\n"
					.. debug.traceback("", 2)
			)
		end
	end
	self.Loaded = true

	log(string.format("[ServiceRegistry] Core services initialized in %.2fs", os.clock() - serviceInitStart))

	for name, service in pairs(self.Services) do
		service.Name = name
		service.Parent = self
		service.BaseClass = "Singleton"
		service._props.BaseClass = "Singleton"
	end

	function self:GetService(v)
		local callerEnv = getfenv(2)
		local caller_capabilities = callerEnv.SecurityCapabilities
		local service = self.Services[v]

		for found, data in pairs(aliases) do
			local lower = string.lower(v)
			if table.find(data, lower) then
				service = found
				break
			end
		end

		if
			service
			and service._SecurityCapabilities
			and caller_capabilities.Value ~= service._SecurityCapabilities.Value
		then
			error("Permission denied for getting service " .. v)
			return nil
		end

		if callerEnv.ThreadPluginIntents then
			if service._PluginAccess == false then
				print("Plugins do not have access to " .. service.Name)
				return
			end
			if service._Intents then
				local hasIntent = false
				for _, intent in pairs(callerEnv.ThreadPluginIntents) do
					if intent.Value == service._Intents.Value then
						hasIntent = true
						break
					end
				end
				if not hasIntent then
					print(
						"Plugin does not have required intent: ",
						service._Intents,
						`\n- Service tried to access {service.Name}\n- Plugin ID: {callerEnv.PluginId}`
					)
					return
				end
			end
		end

		return service
	end

	function self:AddService(ServiceObject)
		ServiceObject.Parent = self
		self.Services[ServiceObject.Name] = ServiceObject
	end

	return self
end

function DataModel:__index(key)
	if DataModel[key] then
		return DataModel[key]
	end

	if self.Services and self.Services[key] then
		return self.Services[key]
	end

	return nil
end

return DataModel
