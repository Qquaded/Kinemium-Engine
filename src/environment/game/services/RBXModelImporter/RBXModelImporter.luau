local Instance = require("@Instance")
local rbxImport = require("@RbxImport")
local registry = require("@InstanceRegistry")
local Enum = require("@EnumMap")

local Axes = require("@Axes")
local BrickColor = require("@BrickColor")
local CFrame = require("@CFrame")
local Color3 = require("@Color3")
local ColorSequence = require("@ColorSequence")
local ColorSequenceKeypoint = require("@ColorSequenceKeypoint")
local CustomPhysicalProperties = require("@PhysicalProperties")
local NumberRange = require("@NumberRange")
local NumberSequence = require("@NumberSequence")
local NumberSequenceKeypoint = require("@NumberSequenceKeypoint")
local Ray = require("@Ray")
local Rect = require("@Rect")
local UDim = require("@UDim")
local UDim2 = require("@UDim2")
local Vector2 = require("@Vector2")
local Vector3 = require("@Vector3")
local Vector3int16 = require("@Vector3int16")

local fs = zune.fs

local RBXModelImporter = Instance.new("RBXModelImporter")
RBXModelImporter.ExplorerHidden = true

local types = {
	Unknown = 0,
	String = 1,
	Bool = 2,
	Int = 3,
	Float = 4,
	Double = 5,
	UDim = 6,
	UDim2 = 7,
	Ray = 8,
	Faces = 9,
	Axes = 10,
	BrickColor = 11,
	Color3 = 12,
	Vector2 = 13,
	Vector3 = 14,
	-- Padded
	CFrame = 16,
	Quaternion = 17,
	Enum = 18,
	Ref = 19,
	Vector3int16 = 20,
	NumberSequence = 21,
	ColorSequence = 22,
	NumberRange = 23,
	Rect = 24,
	PhysicalProperties = 25,
	Color3uint8 = 26,
	Int64 = 27,
	SharedString = 28,
	OptionalCFrame = 30,
	UniqueId = 31,
	Font = 32,
	SecurityCapabilities = 33,
	Content = 34,
}

local function bufferToHex(value)
	local bytes = table.create(buffer.len(value))
	for index = 0, buffer.len(value) - 1 do
		bytes[index + 1] = string.format("%02x", buffer.readu8(value, index))
	end

	return table.concat(bytes)
end

local function mapImportedInstance(value, instanceMap)
	if type(value) ~= "table" then
		return nil
	end

	local mapped = instanceMap[value]
	if mapped == false then
		return nil
	end

	return mapped
end

local function deserializeEnumItem(value)
	if type(value) ~= "table" then
		return value
	end

	local enumType = value.EnumType
	local enumTypeName = if type(enumType) == "table" then enumType.Name else nil
	if not enumTypeName then
		return value
	end

	local engineEnumType = Enum[enumTypeName]
	if not engineEnumType then
		return value
	end

	local byName = engineEnumType[value.Name]
	if byName then
		return byName
	end

	if type(engineEnumType.GetEnumItems) == "function" then
		for _, item in ipairs(engineEnumType:GetEnumItems()) do
			if item.Value == value.Value then
				return item
			end
		end
	end

	return value
end

local function deserializeVector2(value)
	local x = (value._internal and (value._internal.x or value._internal.X)) or value.X or value.x or 0
	local y = (value._internal and (value._internal.y or value._internal.Y)) or value.Y or value.y or 0
	return Vector2.new(x, y)
end

local function deserializeVector3(value)
	local x = (value._internal and (value._internal.x or value._internal.X)) or value.x or value.X or 0
	local y = (value._internal and (value._internal.y or value._internal.Y)) or value.y or value.Y or 0
	local z = (value._internal and (value._internal.z or value._internal.Z)) or value.z or value.Z or 0
	return Vector3.new(x, y, z)
end

local function deserializeUDim(value)
	local scale = value.Scale or 0
	local offset = value.Offset or 0
	return UDim.new(scale, offset)
end

local function deserializeUDim2(value)
	local xs = value.X and value.X.Scale or 0
	local xo = value.X and value.X.Offset or 0
	local ys = value.Y and value.Y.Scale or 0
	local yo = value.Y and value.Y.Offset or 0
	return UDim2.new(xs, xo, ys, yo)
end

local function deserializeColor3(value)
	local r = value.R or value.r or 0
	local g = value.G or value.g or 0
	local b = value.B or value.b or 0
	return Color3.new(r, g, b)
end

local function deserializeAxes(value)
	return Axes.new(
		value.X,
		value.Y,
		value.Z,
		value.Top,
		value.Bottom,
		value.Left,
		value.Right,
		value.Front,
		value.Back
	)
end

local function deserializeFaces(value)
	return Axes.new(
		value.Left or value.Right,
		value.Top or value.Bottom,
		value.Front or value.Back,
		value.Top,
		value.Bottom,
		value.Left,
		value.Right,
		value.Front,
		value.Back
	)
end

local function deserializeCFrame(value)
	local position = value.Position
	local xVec = value.XVector or value.RightVector
	local yVec = value.YVector or value.UpVector
	local zVec = value.ZVector

	if not zVec and value.LookVector then
		zVec = { x = -value.LookVector.x, y = -value.LookVector.y, z = -value.LookVector.z }
	end

	local function getX(v)
		return v and ((v._internal and (v._internal.x or v._internal.X)) or v.x or v.X) or 0
	end
	local function getY(v)
		return v and ((v._internal and (v._internal.y or v._internal.Y)) or v.y or v.Y) or 0
	end
	local function getZ(v)
		return v and ((v._internal and (v._internal.z or v._internal.Z)) or v.z or v.Z) or 0
	end

	local px = getX(position)
	local py = getY(position)
	local pz = getZ(position)

	-- Engine rotation matrix is column-major: each column is Right, Up, -Look
	-- Row 0: [Right.X, Up.X, (-Look).X]
	-- Row 1: [Right.Y, Up.Y, (-Look).Y]
	-- Row 2: [Right.Z, Up.Z, (-Look).Z]
	local r00 = xVec and getX(xVec) or 1
	local r01 = yVec and getX(yVec) or 0
	local r02 = zVec and getX(zVec) or 0

	local r10 = xVec and getY(xVec) or 0
	local r11 = yVec and getY(yVec) or 1
	local r12 = zVec and getY(zVec) or 0

	local r20 = xVec and getZ(xVec) or 0
	local r21 = yVec and getZ(yVec) or 0
	local r22 = zVec and getZ(zVec) or 1

	return CFrame.new(px, py, pz, r00, r01, r02, r10, r11, r12, r20, r21, r22)
end

local function deserializeNumberSequenceKeypoint(value)
	return NumberSequenceKeypoint.new(value.Time, value.Value)
end

local function deserializeNumberSequence(value)
	local keypoints = table.create(#value.Keypoints)
	for index, keypoint in ipairs(value.Keypoints) do
		keypoints[index] = deserializeNumberSequenceKeypoint(keypoint)
	end

	return NumberSequence.new(keypoints)
end

local function deserializeColorSequenceKeypoint(value)
	return ColorSequenceKeypoint.new(value.Time, deserializeColor3(value.Value))
end

local function deserializeColorSequence(value)
	local keypoints = table.create(#value.Keypoints)
	for index, keypoint in ipairs(value.Keypoints) do
		keypoints[index] = deserializeColorSequenceKeypoint(keypoint)
	end

	return ColorSequence.new(keypoints)
end

local function deserializeRect(value)
	return Rect.new(deserializeVector2(value.Min), deserializeVector2(value.Max))
end

local function deserializeRay(value)
	return Ray.new(deserializeVector3(value.Origin), deserializeVector3(value.Direction))
end

local function deserializeBrickColor(value)
	local success, result = pcall(BrickColor.new, value.Name)
	if success then
		return result
	end

	if value.Color then
		return BrickColor.fromColor3(deserializeColor3(value.Color))
	end

	return value.Name
end

local function deserializePhysicalProperties(value)
	if value == nil then
		return nil
	end

	return CustomPhysicalProperties.new(
		value.Density,
		value.Friction,
		value.Elasticity,
		value.FrictionWeight,
		value.ElasticityWeight
	)
end

local function deserializeGeneric(value, instanceMap, visited)
	local mappedInstance = mapImportedInstance(value, instanceMap)
	if mappedInstance then
		return mappedInstance
	end

	local valueType = type(value)
	if valueType == "buffer" then
		return "0x" .. bufferToHex(value)
	end

	if valueType ~= "table" then
		return value
	end

	if value.EnumType and value.Name and value.Value ~= nil then
		return deserializeEnumItem(value)
	end

	visited = visited or {}
	local existing = visited[value]
	if existing then
		return existing
	end

	local clone = {}
	visited[value] = clone

	for key, nestedValue in pairs(value) do
		clone[key] = deserializeGeneric(nestedValue, instanceMap, visited)
	end

	return clone
end

local function deserializeValue(propertyType, value, instanceMap)
	if type(propertyType) == "string" then
		propertyType = types[propertyType] or propertyType
	end

	if value == nil then
		return nil
	end

	if
		propertyType == types.Unknown
		or propertyType == types.String
		or propertyType == types.Bool
		or propertyType == types.Int
		or propertyType == types.Float
		or propertyType == types.Double
		or propertyType == types.SharedString
	then
		return value
	elseif propertyType == types.UDim then
		return deserializeUDim(value)
	elseif propertyType == types.UDim2 then
		return deserializeUDim2(value)
	elseif propertyType == types.Ray then
		return deserializeRay(value)
	elseif propertyType == types.Faces then
		return deserializeFaces(value)
	elseif propertyType == types.Axes then
		return deserializeAxes(value)
	elseif propertyType == types.BrickColor then
		return deserializeBrickColor(value)
	elseif propertyType == types.Color3 or propertyType == types.Color3uint8 then
		return deserializeColor3(value)
	elseif propertyType == types.Vector2 then
		return deserializeVector2(value)
	elseif propertyType == types.Vector3 then
		return deserializeVector3(value)
	elseif propertyType == types.CFrame or propertyType == types.Quaternion or propertyType == types.OptionalCFrame then
		return deserializeCFrame(value)
	elseif propertyType == types.Enum then
		return deserializeEnumItem(value)
	elseif propertyType == types.Ref then
		return mapImportedInstance(value, instanceMap)
	elseif propertyType == types.Vector3int16 then
		return Vector3int16.new(value.X, value.Y, value.Z)
	elseif propertyType == types.NumberSequence then
		return deserializeNumberSequence(value)
	elseif propertyType == types.ColorSequence then
		return deserializeColorSequence(value)
	elseif propertyType == types.NumberRange then
		return NumberRange.new(value.Min, value.Max)
	elseif propertyType == types.Rect then
		return deserializeRect(value)
	elseif propertyType == types.PhysicalProperties then
		return deserializePhysicalProperties(value)
	elseif propertyType == types.Int64 then
		return if type(value) == "buffer" then "0x" .. bufferToHex(value) else value
	elseif propertyType == types.UniqueId then
		return {
			type = "UniqueId",
			Index = value.Index,
			Time = value.Time,
			Random = if type(value.Random) == "buffer" then "0x" .. bufferToHex(value.Random) else value.Random,
		}
	elseif propertyType == types.Font then
		return {
			type = "Font",
			Family = value.Family,
			Weight = deserializeEnumItem(value.Weight),
			Style = deserializeEnumItem(value.Style),
			Bold = value.Bold,
			CacheId = value.CacheId,
		}
	elseif propertyType == types.SecurityCapabilities then
		return if type(value) == "buffer" then "0x" .. bufferToHex(value) else value
	elseif propertyType == types.Content then
		local mappedObject = mapImportedInstance(value.Object, instanceMap)
		if value.Uri ~= nil then
			return value.Uri
		end
		if mappedObject then
			return mappedObject
		end

		return {
			type = "Content",
			Uri = value.Uri,
			Object = mappedObject,
			SourceType = deserializeEnumItem(value.SourceType),
		}
	end

	return deserializeGeneric(value, instanceMap)
end

RBXModelImporter.InitRenderer = function(renderer, renderer_signal, datamodel)
	local function decodeObject(rootObject)
		local instanceMap = {}

		local function createInstances(object)
			if instanceMap[object] ~= nil then
				return instanceMap[object]
			end

			local className = object.ClassName
			local success, newInstance = pcall(function()
				return registry.new(className, renderer, datamodel)
			end)

			if success and newInstance then
				instanceMap[object] = newInstance
			else
				print(newInstance)
				instanceMap[object] = false
			end

			for _, child in ipairs(object:GetChildren()) do
				createInstances(child)
			end

			return instanceMap[object]
		end

		local function linkHierarchy(object)
			local parentInstance = instanceMap[object]
			for _, child in ipairs(object:GetChildren()) do
				local childInstance = instanceMap[child]
				if parentInstance and childInstance then
					childInstance.Parent = parentInstance
				end
				linkHierarchy(child)
			end
		end

		local function applyProperties(object)
			local newInstance = instanceMap[object]
			local rawInstance = rawget(object, "@instance")
			local props = rawInstance.properties

			if newInstance then
				local finalPropsToApply = {}
				for prop, propdata in pairs(props) do
					if prop ~= "UniqueId" and prop ~= "Parent" then
						local mappedProp = prop

						if mappedProp == "size" then
							mappedProp = "Size"
						end
						if mappedProp:lower() == "color3uint8" then
							mappedProp = "Color"
						end

						if newInstance[mappedProp] == nil then
							local tryCap = mappedProp:sub(1, 1):upper() .. mappedProp:sub(2)
							if newInstance[tryCap] ~= nil then
								mappedProp = tryCap
							else
								local engineProps = rawget(newInstance, "_props") or newInstance
								local lowerProp = mappedProp:lower()
								for k, _ in pairs(engineProps) do
									if type(k) == "string" and k:lower() == lowerProp then
										mappedProp = k
										break
									end
								end
							end
						end

						local deserialized = deserializeValue(propdata.type, propdata.value, instanceMap)

						-- Discard property conflicts caused by rbimport's loadDefaultProperties fallback injections
						local isDefaultInjection = false
						if newInstance:IsA("BasePart") then
							if prop == "Position" or prop == "Rotation" or prop == "Orientation" then
								isDefaultInjection = true
							end
						end

						if prop == "Size" and (props["size"] ~= nil) then
							isDefaultInjection = true
						end
						if
							prop == "Color"
							and (
								props["Color3uint8"] ~= nil
								or props["color3uint8"] ~= nil
								or props["brickColor"] ~= nil
							)
						then
							isDefaultInjection = true
						end

						if not isDefaultInjection then
							finalPropsToApply[mappedProp] = deserialized
						end
					end
				end

				-- Apply all verified properties to the instance
				for propName, val in pairs(finalPropsToApply) do
					newInstance[propName] = val
				end
			end

			for _, child in ipairs(object:GetChildren()) do
				applyProperties(child)
			end
		end

		local function findFirstImportedInstance(object)
			local mapped = instanceMap[object]
			if mapped then
				return mapped
			end

			for _, child in ipairs(object:GetChildren()) do
				local found = findFirstImportedInstance(child)
				if found then
					return found
				end
			end
		end

		createInstances(rootObject)
		linkHierarchy(rootObject)
		applyProperties(rootObject)

		return findFirstImportedInstance(rootObject)
	end

	RBXModelImporter:SetProperties({
		ImportModel = function(binary)
			local decoded = rbxImport.deserializeModel(binary)
			return decodeObject(decoded[1])
		end,

		ImportPlace = function(binary)
			local decoded = rbxImport.deserializePlace(binary)
			local results = {}
			for _, root in ipairs(decoded) do
				local inst = decodeObject(root)
				if inst then
					table.insert(results, inst)
				end
			end
			return results
		end,

		ImportPlaceFile = function(path)
			local file = fs.readFile(path, true) -- return buffer
			if file then
				local decoded = rbxImport.deserializePlace(file)
				local converted = {}

				for _, service in pairs(decoded:GetChildren()) do
					converted[service.Name] = {}

					for _, child in pairs(service:GetChildren()) do
						if child.Name == "Camera" then
							continue
						end

						local inst = decodeObject(child)
						if inst then
							table.insert(converted[service.Name], inst)
						end

						task.wait()
					end

					task.wait()
				end
				return converted
			end
			return false
		end,
	})
end
return RBXModelImporter
