local Instance = require("@Instance")
local signal = require("@Kinemium.signal")
local encoder = require("./SerializationService/encoder")

local serde = zune.serde
local zstd = serde.zstd

local SerializationService = Instance.new("SerializationService")
SerializationService.ExplorerHidden = true

local blacklisted = {
	"function",
	"userdata",
	"FFIPointer",
	"buffer",
}

local function compress(tbl)
	local encoded = encoder.encode(tbl)
	local compressed = zstd.compress(encoded)
	return serde.base64.encode(compressed)
end

local function decompress(str)
	local compressed = serde.base64.decode(str)
	local decoded = zstd.decompress(compressed)
	return encoder.decode(decoded)
end

local function serialize_value(value)
	if type(value) == "table" then
		if value["ToTable"] then
			return value:ToTable()
		end
	elseif table.find(blacklisted, typeof(value)) then
		return nil
	else
		return value
	end
end

local function serialize_object(object)
	local result = {
		class = object.ClassName,
		name = object.Name,
		props = {},
		children = {},
		attr = {},
		tags = object.tags,
	}

	for propname, propvalue in pairs(object._props) do
		result.props[propname] = serialize_value(propvalue)
	end

	for _, child in pairs(object:GetChildren()) do
		result.children[child.Name] = serialize_object(child)
	end

	return result
end

local function deserialize_object(tbl)
	local obj = Instance.new(tbl.class)
	obj.Name = tbl.name

	for k, v in pairs(tbl.props) do
		obj._props[k] = v
	end

	for _, childTbl in pairs(tbl.children) do
		local child = deserialize_object(childTbl)
		child.Parent = obj
	end

	obj.tags = tbl.tags or {}
	for k, v in pairs(tbl.attr or {}) do
		obj:SetAttribute(k, v)
	end

	return obj
end

SerializationService.InitRenderer = function(renderer, renderer_signal)
	SerializationService:SetProperties({
		SerializeInstancesAsync = function(m)
			local objects = {}

			for _, v in pairs(m) do
				local serialized = serialize_object(v)
				table.insert(objects, serialized)
			end

			local compressed = compress(objects)
			return compressed
		end,
		Deserialize = function(str)
			local tbl = decompress(str)
			local instances = {}
			for _, objTbl in pairs(tbl) do
				table.insert(instances, deserialize_object(objTbl))
			end
			return instances
		end,
	})
end

return SerializationService
