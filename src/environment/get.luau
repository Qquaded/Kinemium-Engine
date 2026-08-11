local datatypes = require("@Kinemium.datatypes.get")
local Registry = require("@Kinemium.registry")
local DataModel = require("@DataModel")
local EnumMap = require("@EnumMap")
local PlayerGui = require("@PlayerGui")
local Terrain = require("@Terrain")
local capi = require("./capi")
local shared = {}

local logs = {}

return function(renderer, Kinemium_camera)
	local mainDatamodel = DataModel.new(renderer)
	local data = {}

	data.Instance = {
		new = function(class, parent)
			local Object = Registry.new(class, renderer, mainDatamodel)
			if parent and Object then
				Object.Parent = parent
			end
			return Object
		end,
		getClasses = Registry.getClasses,
		GetActiveInstances = Registry.GetActiveInstances,
	}

	data.Filesystem = zune.fs
	data.newproxy = newproxy

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

		readi128 = function(b: buffer, offset: number): number
			local lo = data.buffer.readu64(b, offset)
			local hi = data.buffer.readi64(b, offset + 8)
			return hi * 2 ^ 64 + lo
		end,

		writei128 = function(b: buffer, offset: number, value: number)
			local lo = value % 2 ^ 64
			local hi = math.floor(value / 2 ^ 64)
			data.buffer.writeu64(b, offset, lo)
			data.buffer.writei64(b, offset + 8, hi)
		end,

		readu128 = function(b: buffer, offset: number): number
			local lo = data.buffer.readu64(b, offset)
			local hi = data.buffer.readu64(b, offset + 8)
			return hi * 2 ^ 64 + lo
		end,

		writeu128 = function(b: buffer, offset: number, value: number)
			local lo = value % 2 ^ 64
			local hi = math.floor(value / 2 ^ 64)
			data.buffer.writeu64(b, offset, lo)
			data.buffer.writeu64(b, offset + 8, hi)
		end,

		readi256 = function(b: buffer, offset: number): number
			local lo = data.buffer.readu128(b, offset)
			local hi = data.buffer.readi128(b, offset + 16)
			return hi * 2 ^ 128 + lo
		end,

		writei256 = function(b: buffer, offset: number, value: number)
			local lo = value % 2 ^ 128
			local hi = math.floor(value / 2 ^ 128)
			data.buffer.writeu128(b, offset, lo)
			data.buffer.writei128(b, offset + 16, hi)
		end,

		readu256 = function(b: buffer, offset: number): number
			local lo = data.buffer.readu128(b, offset)
			local hi = data.buffer.readu128(b, offset + 16)
			return hi * 2 ^ 128 + lo
		end,

		writeu256 = function(b: buffer, offset: number, value: number)
			local lo = value % 2 ^ 128
			local hi = math.floor(value / 2 ^ 128)
			data.buffer.writeu128(b, offset, lo)
			data.buffer.writeu128(b, offset + 16, hi)
		end,

		readi512 = function(b: buffer, offset: number): number
			local lo = data.buffer.readu256(b, offset)
			local hi = data.buffer.readi256(b, offset + 32)
			return hi * 2 ^ 256 + lo
		end,

		writei512 = function(b: buffer, offset: number, value: number)
			local lo = value % 2 ^ 256
			local hi = math.floor(value / 2 ^ 256)
			data.buffer.writeu256(b, offset, lo)
			data.buffer.writei256(b, offset + 32, hi)
		end,

		readu512 = function(b: buffer, offset: number): number
			local lo = data.buffer.readu256(b, offset)
			local hi = data.buffer.readu256(b, offset + 32)
			return hi * 2 ^ 256 + lo
		end,

		writeu512 = function(b: buffer, offset: number, value: number)
			local lo = value % 2 ^ 256
			local hi = math.floor(value / 2 ^ 256)
			data.buffer.writeu256(b, offset, lo)
			data.buffer.writeu256(b, offset + 32, hi)
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
			return thread
		end,
		defer = function(fn, ...)
			local thread = zune.task.defer(fn, ...)
			return thread
		end,
		delay = function(dt, fn, ...)
			local thread = zune.task.delay(dt, fn, ...)
			return thread
		end,
		desynchronize = function()
			local thread = coroutine.running()
			if thread then
				zune.task.defer(thread)
				coroutine.yield()
			end
		end,
		synchronize = function()
			local thread = coroutine.running()
			if thread then
				zune.task.defer(thread)
				coroutine.yield()
			end
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
			if rawget(v, "BaseClass") == "Instance" then
				return "Instance"
			end
			local t = rawget(v, "type")
			if t then
				return t
			end
			local t2 = rawget(v, "__type")
			if t2 then
				return t2
			end

			table.insert(logs, { type = "table", value = v })
			return "table"
		else
			return type(v)
		end
	end

	local playerGui = nil
	if not IsHeadless then
		playerGui = PlayerGui.InitRenderer(renderer, renderer.Signal, mainDatamodel)
	end
	local terrainObject = Terrain.InitRenderer(renderer, renderer.Signal, mainDatamodel)

	local players = mainDatamodel:GetService("Players")
	if not IsServer and playerGui then
		players.LocalPlayer.PlayerGui = playerGui

		playerGui.Parent = players.LocalPlayer
	end

	Kinemium_camera.Parent = mainDatamodel:GetService("Workspace")

	terrainObject.Parent = mainDatamodel:GetService("Workspace")

	local LogService = mainDatamodel:GetService("LogService")

	data.print = function(...)
		runtime(...)

		return LogService.CreateLog("print", ...)
	end

	data.printConsole = function(...)
		runtime(...)
	end

	data.warn = function(...)
		runtime(...)

		return LogService.CreateLog("warn", ...)
	end

	data.error = function(...)
		runtime(...)

		return LogService.CreateLog("error", ...)
	end

	data.regex = zune.regex
	data.io = zune.io
	data.platform = zune.platform

	data.tick = function()
		return os.clock()
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

	-- set zune as 0 to override zune global in sandboxed scripts
	data.zune = 0

	local c_api = capi(data)

	datatypes:Init(mainDatamodel, renderer, data)

	return data, c_api
end
