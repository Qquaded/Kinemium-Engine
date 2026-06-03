local Enum = {}
local EnumItem = {}
EnumItem.__index = EnumItem

function EnumItem:IsA(value)
	return self.EnumType == value
end

function EnumItem:__eq(other)
	if getmetatable(other) == EnumItem then
		return self.EnumType == other.EnumType and self.Value == other.Value
	end
	return false
end

local function createEnumValue(itemName, itemValue, enumType)
	local item = setmetatable({}, EnumItem)
	item.Name = itemName
	item.Value = itemValue
	item.EnumType = enumType
	item.__type = "EnumItem"

	function item:ToTable()
		return {
			Name = itemName,
			Value = itemValue,
			EnumType = enumType.Name,
			type = "EnumItem",
		}
	end

	if type(itemValue) == "number" then
		Enum._numberIndex[itemName] = item
	end

	enumType[itemName] = item
end

local function createEnum(api)
	Enum._numberIndex = {}

	for enumName, items in pairs(api) do
		local enumType = {}
		enumType.Name = enumName
		enumType.__index = enumType
		enumType.__type = "EnumType"

		local itemList = {}

		for itemName, itemValue in pairs(items) do
			local item = setmetatable({}, EnumItem)
			item.Name = itemName
			item.Value = itemValue
			item.EnumType = enumType
			item.__type = "EnumItem"

			function item:ToTable()
				return {
					Name = itemName,
					Value = itemValue,
					EnumType = enumType.Name,
					type = "EnumItem",
				}
			end

			if type(itemValue) == "number" then
				Enum._numberIndex[itemName] = item
			end

			enumType[itemName] = item
			table.insert(itemList, item)
		end

		function enumType:GetEnumItems()
			local copy = {}
			for i, v in ipairs(itemList) do
				copy[i] = v
			end
			return copy
		end

		function enumType:GetItemsNames()
			local items = enumType:GetEnumItems()
			local names = {}

			for _, item in pairs(items) do
				table.insert(names, item.Name)
			end

			return names
		end

		Enum[enumName] = enumType
	end

	return Enum
end

Enum.new = createEnum
Enum.newValue = createEnumValue

return Enum
