local Instance = require("@Instance")
local signal = require("@Kinemium.signal")
local encoder = require("./SerializationService/encoder")
local Registry = require("@InstanceRegistry")

local serde = zune.serde
local zstd = serde.zstd

local Vector3 = require("@Vector3")
local CFrame = require("@CFrame")
local Color3 = require("@Color3")
local Color4 = require("@Color4")
local UDim = require("@UDim")
local UDim2 = require("@UDim2")
local Ray = require("@Ray")
local NumberSequence = require("@NumberSequence")
local NumberSequenceKeypoint = require("@NumberSequenceKeypoint")
local ColorSequence = require("@ColorSequence")
local ColorSequenceKeypoint = require("@ColorSequenceKeypoint")
local BrickColorMap = require("@BrickColorMap")
local CustomPhysicalProperties = require("@CustomPhysicalProperties")
local BoundingBox = require("@BoundingBox")

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
		parent = object.UniqueId,
	}

	for propname, propvalue in pairs(object._props) do
		if type(propvalue) == "buffer" then
			continue
		end
		if type(propname) == "buffer" then
			continue
		end
		result.props[propname] = serialize_value(propvalue)
	end

	for _, child in pairs(object:GetChildren()) do
		result.children[child.Name] = serialize_object(child)
	end

	return result
end

SerializationService.InitRenderer = function(renderer, renderer_signal, datamodel)
	local function deserialize_object(tbl)
		local obj = Registry.new(tbl.class, renderer, datamodel)
		obj.Name = tbl.name

		for k, v in pairs(tbl.props) do
			if type(v) == "table" then
				if v.type then
					if v.type == "Vector3" then
						obj._props[k] = Vector3.FromTable(v)
					elseif v.type == "CFrame" then
						obj._props[k] = CFrame.FromTable(v)
					elseif v.type == "Color3" then
						obj._props[k] = Color3.FromTable(v)
					elseif v.type == "Color4" then
						obj._props[k] = Color4.FromTable(v)
					elseif v.type == "UDim" then
						obj._props[k] = UDim.FromTable(v)
					elseif v.type == "UDim2" then
						obj._props[k] = UDim2.FromTable(v)
					elseif v.type == "Ray" then
						obj._props[k] = Ray.FromTable(v)
					elseif v.type == "NumberSequence" then
						obj._props[k] = NumberSequence.FromTable(v)
					elseif v.type == "NumberSequenceKeypoint" then
						obj._props[k] = NumberSequenceKeypoint.FromTable(v)
					elseif v.type == "ColorSequence" then
						obj._props[k] = ColorSequence.FromTable(v)
					elseif v.type == "ColorSequenceKeypoint" then
						obj._props[k] = ColorSequenceKeypoint.FromTable(v)
					elseif v.type == "BrickColorMap" then
						obj._props[k] = BrickColorMap.FromTable(v)
					elseif v.type == "CustomPhysicalProperties" then
						obj._props[k] = CustomPhysicalProperties.FromTable(v)
					elseif v.type == "BoundingBox" then
						obj._props[k] = BoundingBox.FromTable(v)
					end
				end
			else
				obj._props[k] = v
			end
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
