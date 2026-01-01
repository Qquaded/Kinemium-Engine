local Instance = require("@Instance")
local signal = require("@Kinemium.signal")
local encoder = require("./SerializationService/encoder")

local serde = zune.serde
local lz4 = serde.lz4
local zstd = serde.zstd
local json = serde.json
local zlib = serde.zlib

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
	})
end

return SerializationService
