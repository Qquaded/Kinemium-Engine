local Instance = require("@Instance")
local Enum = require("@EnumMap")
local signal = require("@Kinemium.signal")
local zembed = require("@zembed")

local DataModel = {}
DataModel.__index = DataModel

local fs = zune.fs

local aliases = {}

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

	self.Services = {}

	local services
	if zembed.IsEmbedded() then
		services = zembed.GetScriptsThatHas([[game\services]])
	else
		services = fs.entries("./src/enviroment/game/services")
	end

	local serviceInitStart = os.clock()
	for _, service in pairs(services) do
		local addServiceStart = os.clock()
		local name
		local path
		if zembed.IsEmbedded() then
			name = fs.path.basename(service):gsub(".luau", "")
			name = string.gsub(name, ".luau", "")
			path = `./services/{name}/{name}`

			if string.find(path, "_") then
				print("Skipping " .. path)
				continue
			end
		else
			name = service.name:gsub(".luau", "")
			path = `./services/{name}/{name}`
		end

		local success, returnedData = pcall(require, path)
		local initTime = (os.clock() - addServiceStart) * 1000

		if success then
			local success2, returnedData2 = pcall(function()
				self.Services[name] = returnedData
				if returnedData.InitRenderer then
					returnedData.InitRenderer(RENDERER, RENDERER.EventBus, self)
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
				error(
					"Error initializing service '"
						.. name
						.. "' at path '"
						.. path
						.. "':\n"
						.. tostring(returnedData2)
						.. "\n"
						.. debug.traceback("", 2)
				)
			end
		else
			error(
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
		for found, data in pairs(aliases) do
			local lower = string.lower(v)
			if table.find(data, lower) then
				return found
			end
		end
		return self.Services[v]
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
