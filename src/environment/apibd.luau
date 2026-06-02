local api = {
	{
		name = "Classes",
		count = 858,
		expanded = true,
		items = {
			{
				name = "Instance",
				type = "class",
				expanded = false,
				children = {
					{ name = "Accessory", type = "class" },
					{ name = "Animation", type = "class" },
				},
			},
		},
	},
	{
		name = "Enums",
		count = 545,
		expanded = false,
		items = {
			{ name = "AccessModifierType", type = "enum" },
			{ name = "AccessoryType", type = "enum" },
			{ name = "ActionType", type = "enum" },
		},
	},
	{
		name = "Types",
		count = 69,
		expanded = false,
		items = {
			{ name = "DataType", type = "type" },
			{ name = "BinaryString", type = "type" },
			{ name = "Color3", type = "type" },
		},
	},
}

local datatypes = require("@Kinemium.datatypes.get")
local Registry = require("@Kinemium.registry")
local EnumMap = require("@Enum")

for i, v in pairs(EnumMap) do
	local desc = "Available Items:\n"
	if type(v) == "table" then
		for enumName, enumValue in pairs(v) do
			if type(enumName) ~= "string" then
				continue
			end
			if enumName:sub(1, 1) == "_" then
				continue
			end
			if enumName == "__index" then
				continue
			end
			if enumName == "type" then
				continue
			end
			if enumName == "GetEnumItems" then
				continue
			end
			if enumName == "GetItemsNames" then
				continue
			end

			local result
			if type(enumValue) == "table" then
				result = enumValue.Value
			else
				result = enumValue
			end
			desc = desc .. "\n" .. enumName .. ": " .. result
		end
	end
	table.insert(api[2].items, { name = i, type = "enum", description = desc })
end

for i, v in pairs(Registry.getClasses()) do
	local super = "Instance"
	if v.inherit then
		local dummy = {}
		pcall(v.inherit, dummy)
		if dummy.BaseClass then
			super = dummy.BaseClass
		end
	end

	table.insert(api[1].items[1].children, {
		name = i,
		type = "class",
		super = super,
		description = "I think, therefore I am, therefore I am AM",
	})
end

for i, v in pairs(datatypes) do
	table.insert(api[3].items, { name = i, type = "type" })
end

return api
