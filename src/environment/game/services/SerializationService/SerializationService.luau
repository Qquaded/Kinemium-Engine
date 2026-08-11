local Instance = require("@Instance")
local Registry = require("@InstanceRegistry")

local Enum = require("@EnumMap")
local Datatypes = require("@Kinemium.datatypes.get")

local SerializationService = Instance.new("SerializationService")
SerializationService.ExplorerHidden = true
SerializationService._Intents = Enum.PluginIntents.Serialization

local BLACKLISTED_TYPES = {
	["function"] = true,
	["userdata"] = true,
	["FFIPointer"] = true,
}

local SKIP_PROPS = {
	Parent = true,
	Children = true,
	UniqueId = true,
	ClassName = true,
	BaseClass = true,
	tags = true,
	attributes = true,
	_childByName = true,
	RigBindings = true,
	RigParts = true,
	RigPartIndex = true,
	RigChains = true,
	RigDescriptor = true,
	SpeedModifiers = true,
	PoseOffsets = true,
	StateMachine = true,
	Animator = true,
	Died = true,
	HealthChanged = true,
	MoveToFinished = true,
	Running = true,
	Jumping = true,
	FreeFalling = true,
	Seated = true,
	Landed = true,
	StateChanged = true,
	StanceChanged = true,
	RigBuilt = true,
	SprintStarted = true,
	SprintEnded = true,
	CrouchStarted = true,
	CrouchEnded = true,
	Dashed = true,
	ChildAdded = true,
	ChildRemoved = true,
	DescendantAdded = true,
	DescendantRemoving = true,
	DescendantChanged = true,
	AncestryChanged = true,
	Changed = true,
	Destroying = true,
	NetworkOwner = true,
	NetworkOwnerType = true,
	CanReplicate = true,
	IsPlaytesting = true,
	PlayerAdded = true,
	PlayerRemoving = true,
	CharacterAdded = true,
	CharacterRemoving = true,
}

local TYPE_DESERIALIZERS = {
	EnumItem = function(v)
		local enumTypeName = if type(v) == "table" and type(v.EnumType) == "table" then v.EnumType.Name else v.EnumType
		if type(v) ~= "table" or type(enumTypeName) ~= "string" or type(v.Name) ~= "string" then
			return nil
		end
		local enumGroup = Enum[enumTypeName]
		if enumGroup == nil then
			warn("[SerializationService] Unknown EnumType '" .. enumTypeName .. "' during deserialization")
			return nil
		end
		local item = enumGroup[v.Name]
		if item == nil then
			warn(
				"[SerializationService] Unknown Enum value '"
					.. enumTypeName
					.. "."
					.. v.Name
					.. "' during deserialization"
			)
		end
		return item
	end,
	Content = function(v)
		if type(v) ~= "table" then
			return v
		end

		local objectRef = v.Object
		if type(objectRef) == "table" and objectRef.__ref then
			return objectRef
		end
		if objectRef ~= nil then
			return objectRef
		end

		if type(v.Uri) == "string" then
			return v.Uri
		end

		return nil
	end,
	Buf = function(v)
		if type(v.value) ~= "string" then
			return nil
		end
		local decoded = zune.serde.base64.decode(v.value)
		return buffer.fromstring(decoded)
	end,
}

local warnedUnknownTypeTags = {}

local function isSignalLikeTable(value)
	return type(value) == "table"
		and rawget(value, "_connections") ~= nil
		and rawget(value, "_queuedFires") ~= nil
		and rawget(value, "_history") ~= nil
end

for name, datatype in pairs(Datatypes) do
	if type(datatype) == "function" then
		continue
	end
	if datatype.FromTable then
		TYPE_DESERIALIZERS[name] = datatype.FromTable
	end
end

local workers = {}
local pendingRequests = {}
local reqIdCounter = 0
local nextWorkerIndex = 1
local MAX_WORKERS = 18

local function initWorkers()
	if #workers > 0 then
		return
	end

	for i = 1, MAX_WORKERS do
		local w = zune.thread.fromModule("@SerialWorker")
		w:start()
		table.insert(workers, w)

		task.spawn(function()
			while true do
				local res = w:receive()
				if res and res.id and pendingRequests[res.id] then
					print(`[SerializationService] Worker {i} finished task {res.id}`)
					local t = pendingRequests[res.id]
					pendingRequests[res.id] = nil
					task.spawn(t, res)
				end
			end
		end)
	end
end

local function getNextWorker()
	initWorkers()
	local w = workers[nextWorkerIndex]
	nextWorkerIndex = (nextWorkerIndex % MAX_WORKERS) + 1
	return w
end

local UseWorkers = true

local function sanitizeForThread(value, seen)
	local valueType = type(value)
	if valueType == "number" or valueType == "string" or valueType == "boolean" or value == nil then
		return value
	end

	if valueType == "buffer" then
		return { __buf = zune.serde.base64.encode(buffer.tostring(value)) }
	end

	if valueType ~= "table" then
		return nil
	end

	seen = seen or {}
	if seen[value] then
		return nil
	end
	seen[value] = true

	local copy = {}
	for key, child in pairs(value) do
		local keyType = type(key)
		if keyType == "string" or keyType == "number" or keyType == "boolean" then
			copy[key] = sanitizeForThread(child, seen)
		end
	end

	seen[value] = nil
	return copy
end

local function compress(tbl)
	if not UseWorkers then
		local encoder = require("./_encoder")
		local encoded = encoder.encode(tbl)
		return zune.serde.zstd.compress(encoded, { level = 1 })
	end

	local w = getNextWorker()
	reqIdCounter += 1
	local id = reqIdCounter
	pendingRequests[id] = coroutine.running()
	print(`[SerializationService] Sending compress task {id} to worker...`)
	w:send({ id = id, action = "compress", data = sanitizeForThread(tbl) })
	local res = coroutine.yield()
	if res.error then
		error(res.error)
	end
	return res.result
end

local function decompress(str)
	if not UseWorkers then
		local encoder = require("./_encoder")
		local decompressed = zune.serde.zstd.decompress(str)
		return encoder.decode(decompressed)
	end

	local w = getNextWorker()
	reqIdCounter += 1
	local id = reqIdCounter
	pendingRequests[id] = coroutine.running()
	print(`[SerializationService] Sending decompress task {id} to worker...`)
	w:send({ id = id, action = "decompress", data = str })
	local res = coroutine.yield()
	if res.error then
		print("[SerializationService] Failed to decode serialized payload: " .. tostring(res.error))
		return nil
	end
	return res.result
end

local sharedVisited = {}

local function serialize_value(value, visited)
	local luaType = type(value)

	if luaType == "function" or luaType == "thread" or luaType == "userdata" then
		return nil, false
	end

	if luaType == "number" or luaType == "string" or luaType == "boolean" or value == nil then
		return value, true
	end

	if luaType == "buffer" then
		return { type = "Buf", value = zune.serde.base64.encode(buffer.tostring(value)) }, true
	end

	if BLACKLISTED_TYPES[luaType] then
		return nil, false
	end

	if isSignalLikeTable(value) then
		return nil, false
	end

	-- Instance reference (has ClassName, _props, and UniqueId)
	if luaType == "table" then
		local props = rawget(value, "_props")
		if props and props.ClassName then
			local uid = props.UniqueId
			if uid then
				return { __ref = uid }, true
			end
			return nil, false
		end
	end

	-- Typed userdata (CFrame, Vector3, Color3, etc.)
	local robloxType = luaType
	if luaType == "table" and value.__type then
		robloxType = value.__type
	end

	if luaType == "table" and robloxType ~= "table" then
		if type(value.ToTable) == "function" then
			return value:ToTable(), true
		end
		local datatype = Datatypes[robloxType]
		if datatype and value ~= datatype and datatype.ToTable then
			return datatype.ToTable(value), true
		end
		if not TYPE_DESERIALIZERS[robloxType] then
			return nil, false
		end
	end

	if luaType == "table" then
		if visited[value] then
			return nil, false
		end
		visited[value] = true

		local dict = {}

		if robloxType ~= "table" then
			dict.type = robloxType
		end
		for k, v in pairs(value) do
			local sv, ok = serialize_value(v, visited)
			if ok then
				dict[k] = sv
			end
		end

		visited[value] = nil
		return dict, true
	end

	return nil, false
end

local function serialize_object(object, obj_visited)
	if obj_visited[object] then
		return nil
	end
	obj_visited[object] = true

	local props = object._props
	local result = {
		c = object.ClassName,
		n = object.Name,
		p = {},
		ch = {},
		at = {},
		t = {},
		uid = props.UniqueId,
	}

	local visited = sharedVisited
	local resultProps = result.p
	for propname, propvalue in pairs(props) do
		if SKIP_PROPS[propname] then
			continue
		end
		if object.ClassName == "Player" and propname == "Character" then
			continue
		end
		local propType = type(propname)
		if string.sub(propname, 1, 1) == "_" and propname ~= "_mesh" then
			continue
		end
		if propType == "buffer" or type(propvalue) == "buffer" then
			resultProps[propname] = {
				type = "Buf",
				value = zune.serde.base64.encode(buffer.tostring(propvalue)),
			}
			print("Saved buffer: " .. propname)
			print(`Buffer length: #{buffer.len(propvalue)}`)
			print(propvalue)
			continue
		end
		local serialized, ok = serialize_value(propvalue, visited)
		if ok then
			resultProps[propname] = serialized
		end
		for k in pairs(visited) do
			visited[k] = nil
		end
	end

	local attrs = object:GetAttributes()
	if next(attrs) then
		local resultAttrs = result.at
		for attrname, attrvalue in pairs(attrs) do
			local serialized, ok = serialize_value(attrvalue, visited)
			if ok then
				resultAttrs[attrname] = serialized
			end
			for k in pairs(visited) do
				visited[k] = nil
			end
		end
	end

	local tags = object:GetTags()
	if #tags > 0 then
		result.t = tags -- Directly assign  no need to copy one-by-one
	end

	local children = object:GetChildren()
	local resultChildren = result.ch
	local childCount = 0
	for i = 1, #children do
		if children[i].ClassName == "Camera" then
			continue
		end
		local serialized_child = serialize_object(children[i], obj_visited)
		if serialized_child then
			childCount += 1
			resultChildren[childCount] = serialized_child
		end
	end

	return result
end

local function deserialize_value(v)
	if type(v) ~= "table" then
		return v
	end
	if v.__ref then
		return v
	end
	if v.type then
		local deserializer = TYPE_DESERIALIZERS[v.type]
		if deserializer then
			return deserializer(v)
		else
			local typeTag = tostring(v.type)
			if not warnedUnknownTypeTags[typeTag] then
				warn("Unknown type tag during deserialization: " .. typeTag)
				warnedUnknownTypeTags[typeTag] = true
			end
			return v
		end
	end
	local dict = {}
	for key, val in pairs(v) do
		dict[key] = deserialize_value(val)
	end
	return dict
end

SerializationService.InitRenderer = function(renderer, renderer_signal, datamodel)
	SerializationService:SetProperties({
		SerializeInstancesAsync = function(instances)
			print("[DEBUG] SerializeInstancesAsync called for", #instances, "instances")
			local objects = {}
			local objVisited = {}
			for i = 1, #instances do
				objects[i] = serialize_object(instances[i], objVisited)
			end
			print("[DEBUG] SerializeInstancesAsync compressing objects")
			local res = compress(objects)
			print("[DEBUG] SerializeInstancesAsync compress done")
			return res
		end,
		Deserialize = function(str, cb)
			local tbl = decompress(str)
			if not tbl then
				return {}
			end
			local instances = {}
			local id_map = {}
			local instanceCount = 0

			local function create_object(objTbl)
				local className = objTbl.c
				if type(className) ~= "string" or className == "" then
					return nil
				end

				if Registry.ClassValid(className) then
					return Registry.new(className, renderer, datamodel, true)
				end

				return Instance.new(className)
			end

			local function deserialize_object_with_map(objTbl)
				local obj = create_object(objTbl)
				if not obj then
					return nil
				end
				obj.Name = objTbl.n

				if cb then
					cb(obj)
				end

				if objTbl.uid then
					id_map[objTbl.uid] = obj
					obj._props.UniqueId = objTbl.uid
				end

				local objProps = obj._props
				for k, v in pairs(objTbl.p) do
					objProps[k] = deserialize_value(v)
				end

				local objAttrs = objTbl.at
				if objAttrs and next(objAttrs) then
					for k, v in pairs(objAttrs) do
						obj:SetAttribute(k, deserialize_value(v))
					end
				end

				obj.tags = objTbl.t or {}

				local objChildren = objTbl.ch
				if objChildren then
					for i = 1, #objChildren do
						local child = deserialize_object_with_map(objChildren[i])
						if child then
							child.Parent = obj
						end
					end
				end

				return obj
			end

			for i = 1, #tbl do
				local ok, result = pcall(deserialize_object_with_map, tbl[i])
				if ok and result then
					instanceCount += 1
					instances[instanceCount] = result
				else
					warn(("Failed to deserialize object of class %q: %s"):format(tostring(tbl[i].c), tostring(result)))
				end
			end

			for i = 1, instanceCount do
				local stack = { instances[i] }
				local stackSize = 1
				while stackSize > 0 do
					local inst = stack[stackSize]
					stackSize -= 1

					-- Resolve refs in _props
					local instProps = inst._props
					if instProps then
						for k, v in pairs(instProps) do
							if type(v) == "table" then
								if v.__ref then
									instProps[k] = id_map[v.__ref]
								end
							end
						end
					end

					-- Resolve refs in attributes
					local instAttrs = inst.attributes
					if instAttrs then
						for k, v in pairs(instAttrs) do
							if type(v) == "table" and v.__ref then
								instAttrs[k] = id_map[v.__ref]
							end
						end
					end

					-- Push children onto stack
					local children = inst:GetChildren()
					for j = 1, #children do
						stackSize += 1
						stack[stackSize] = children[j]
					end
				end
			end

			return instances
		end,

		userdata = {
			Encode = function(value)
				local serialized, ok = serialize_value(value, {})
				if ok then
					return serialized
				end
				return nil
			end,
			Decode = function(value)
				return deserialize_value(value)
			end,
		},
	})
end

return SerializationService
