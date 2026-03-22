local datatypes = require("@Kinemium.datatypes.get")
local Registry = require("@Kinemium.registry")
local DataModel = require("@DataModel")
local EnumMap = require("@EnumMap")
local PlayerGui = require("@PlayerGui")
local Terrain = require("@Terrain")
local capi = require("./capi")
local shared = {}

return function(renderer, Kinemium_camera)
	local mainDatamodel = DataModel.new(renderer)
	local data = datatypes
	local ScriptRunnerService = mainDatamodel:GetService("ScriptRunnerService")

	data.Instance = {
		new = function(class, parent)
			local Object = Registry.new(class, renderer, mainDatamodel)
			if parent and Object then
				Object.Parent = parent
			end
			return Object
		end,
		getClasses = Registry.getClasses,
	}

	data.buffer = {
		copy = buffer.copy,
		create = buffer.create,
		len = buffer.len,
		tostring = buffer.tostring,
		fromstring = buffer.fromstring,

		readi8 = buffer.readi8,
		readi16 = buffer.readi16,
		readi32 = buffer.readi32,
		readu8 = buffer.readu8,
		readu16 = buffer.readu16,
		readu32 = buffer.readu32,
		readf32 = buffer.readf32,
		readf64 = buffer.readf64,
		readstring = buffer.readstring,
		readbits = buffer.readbits,

		writei8 = buffer.writei8,
		writei16 = buffer.writei16,
		writei32 = buffer.writei32,
		writeu8 = buffer.writeu8,
		writeu16 = buffer.writeu16,
		writeu32 = buffer.writeu32,
		writef32 = buffer.writef32,
		writef64 = buffer.writef64,
		writestring = buffer.writestring,
		writebits = buffer.writebits,

		readi64 = function(b: buffer, offset: number): number
			local lo = buffer.readu32(b, offset)
			local hi = buffer.readi32(b, offset + 4)
			return hi * 2 ^ 32 + lo
		end,

		writei64 = function(b: buffer, offset: number, value: number)
			local lo = value % 2 ^ 32
			local hi = math.floor(value / 2 ^ 32)
			buffer.writeu32(b, offset, lo)
			buffer.writei32(b, offset + 4, hi)
		end,

		readu64 = function(b: buffer, offset: number): number
			local lo = buffer.readu32(b, offset)
			local hi = buffer.readu32(b, offset + 4)
			return hi * 2 ^ 32 + lo
		end,

		writeu64 = function(b: buffer, offset: number, value: number)
			local lo = value % 2 ^ 32
			local hi = math.floor(value / 2 ^ 32)
			buffer.writeu32(b, offset, lo)
			buffer.writeu32(b, offset + 4, hi)
		end,

		fill = function(b: buffer, value: number, offset: number?, length: number?)
			local start = offset or 0
			local stop = start + (length or buffer.len(b) - start)
			for i = start, stop - 1 do
				buffer.writeu8(b, i, value)
			end
		end,

		slice = function(b: buffer, offset: number, length: number): buffer
			local out = buffer.create(length)
			buffer.copy(out, 0, b, offset, length)
			return out
		end,

		concat = function(a: buffer, b: buffer): buffer
			local aLen = buffer.len(a)
			local bLen = buffer.len(b)
			local out = buffer.create(aLen + bLen)
			buffer.copy(out, 0, a, 0, aLen)
			buffer.copy(out, aLen, b, 0, bLen)
			return out
		end,

		equals = function(a: buffer, b: buffer): boolean
			local len = buffer.len(a)
			if len ~= buffer.len(b) then
				return false
			end
			for i = 0, len - 1 do
				if buffer.readu8(a, i) ~= buffer.readu8(b, i) then
					return false
				end
			end
			return true
		end,

		tohex = function(b: buffer, sep: string?): string
			local parts = {}
			for i = 0, buffer.len(b) - 1 do
				parts[i + 1] = string.format("%02x", buffer.readu8(b, i))
			end
			return table.concat(parts, sep or "")
		end,

		fromhex = function(hex: string): buffer
			hex = hex:gsub("%s+", "")
			local len = #hex / 2
			local b = buffer.create(len)
			for i = 0, len - 1 do
				buffer.writeu8(b, i, tonumber(hex:sub(i * 2 + 1, i * 2 + 2), 16))
			end
			return b
		end,
	}
	data.Enum = EnumMap

	data.task = {
		cancel = zune.task.cancel,
		wait = zune.task.wait,
		spawn = function(fn, ...)
			local thread = zune.task.spawn(fn, ...)
			ScriptRunnerService.RegisterUserThread(thread)
			return thread
		end,
		defer = function(fn, ...)
			local thread = zune.task.defer(fn, ...)
			ScriptRunnerService.RegisterUserThread(thread)
			return thread
		end,
		delay = function(dt, fn, ...)
			local thread = zune.task.delay(dt, fn, ...)
			ScriptRunnerService.RegisterUserThread(thread)
			return thread
		end,
	}
	data.game = mainDatamodel
	data.ishared = {}
	data.workspace = mainDatamodel:GetService("Workspace")
	data.shared = shared
	data._VERSION = "Luau Kilang"
	data.wait = zune.task.wait

	data.typeof = function(v)
		if type(v) == "table" then
			if v.type then
				return v.type
			elseif v.__type then
				return v.__type
			elseif v.ClassName then
				return "Instance"
			else
				return "table"
			end
		else
			return type(v)
		end
	end

	local playerGui = PlayerGui.InitRenderer(renderer, renderer.Signal)
	local terrainObject = Terrain.InitRenderer(renderer, renderer.Signal, mainDatamodel)

	local players = mainDatamodel:GetService("Players")
	players.LocalPlayer.PlayerGui = playerGui
	players.LocalPlayer.Parent = players

	playerGui.Parent = players.LocalPlayer

	Kinemium_camera.Parent = mainDatamodel:GetService("Workspace")

	terrainObject.Parent = mainDatamodel:GetService("Workspace")

	ScriptRunnerService.InitEnviroment(data, mainDatamodel)

	local LogService = mainDatamodel:GetService("LogService")

	data.print = function(...)
		runtime(...)

		return LogService.CreateLog("print", tostring(...))
	end

	data.warn = function(...)
		runtime(...)

		return LogService.CreateLog("warn", tostring(...))
	end

	data.error = function(...)
		runtime(...)

		return LogService.CreateLog("error", tostring(...))
	end

	data.regex = zune.regex
	data.io = zune.io
	data.platform = zune.platform

	data.require = function(Instance)
		if type(Instance) == "table" then
			if Instance.ClassName == "ModuleScript" then
				data.script = Instance

				local returned = ScriptRunnerService.RunScript(Instance)

				if returned then
					return returned
				end
			end
		elseif type(Instance) == "string" then
			local callerEnv = getfenv(2)

			if callerEnv.SecurityCapabilities == EnumMap.SecurityCapabilities.Internals then
			end

			return require(Instance)
		else
			error("require: cannot require table; expected ModuleScript")
		end
	end

	data.import = function(v)
		local callerEnv = getfenv(2)
		--print(callerEnv)
		if callerEnv.SecurityCapabilities ~= EnumMap.SecurityCapabilities.Internals then
			print("Security capabilities not equal to level 2")
			return {}
		end
		return require(v)
	end

	data.include = function(object: Instance)
		local callerEnv = getfenv(2)
		local result = data.require(object)
		if result then
			for p, v in pairs(result) do
				callerEnv[p] = v
			end
			print("Successfully included header " .. object.Name)
		end
	end

	local c_api = capi(data)

	return data, c_api
end
