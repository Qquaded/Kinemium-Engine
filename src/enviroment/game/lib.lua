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
	self.Name = "game"
	self.Dimension = Enum.Dimension["3D"]
	self.Context = Enum.GameContext.Editor
	self.EngineSignal = signal.new()
	self.Stop3DInput = false
	self.ShutdownCallbacks = {}

	self.Services = {}

	local services
	if zembed.IsEmbedded() then
		services = zembed.GetScriptsThatHas([[game\services]])
	else
		services = fs.entries("./src/enviroment/game/services")
	end
	for _, service in pairs(services) do
		local name
		local path
		if zembed.IsEmbedded() then
			name = fs.path.basename(service):gsub(".luau", "")
			name = string.gsub(name, ".lua", "")
			path = "./services/" .. name
		else
			name = service.name:gsub(".lua", "")
			path = "./services/" .. name
		end
		local success, returnedData = pcall(require, path)

		if success then
			local success2, returnedData2 = pcall(function()
				self.Services[name] = returnedData
				if returnedData.InitRenderer then
					returnedData.InitRenderer(RENDERER, RENDERER.Signal, self)
					if returnedData.aliases then
						aliases[name] = returnedData.aliases
					end
				end
			end)

			if success2 then
				log("[ServiceRegistry] Added service: " .. name)
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
			end
		else
			warn(
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

	for name, service in pairs(self.Services) do
		service.Name = name
		service.Parent = self
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
