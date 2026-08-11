local Enum = require("@EnumMap")

local Font = {}
Font.__index = Font

local function enumOrDefault(enumType, value, defaultName)
	if value ~= nil then
		return value
	end
	return enumType and enumType[defaultName] or nil
end

function Font.new(family: string?, weight: any?, style: any?)
	local self = setmetatable({}, Font)
	self.Family = family or ""
	self.Weight = enumOrDefault(Enum.FontWeight, weight, "Regular")
	self.Style = enumOrDefault(Enum.FontStyle, style, "Normal")
	self.__type = "Font"
	return self
end

function Font.fromName(name: string)
	return Font.new(name, Enum.FontWeight.Regular, Enum.FontStyle.Normal)
end

function Font.fromEnum(font: any)
	local family = font
	if type(font) == "table" then
		family = font.Value or font.Name or font.Family
	end
	return Font.new(tostring(family or ""), Enum.FontWeight.Regular, Enum.FontStyle.Normal)
end

function Font:ToTable()
	return {
		Family = self.Family,
		Weight = self.Weight and self.Weight:ToTable() or nil,
		Style = self.Style and self.Style:ToTable() or nil,
		type = "Font",
	}
end

function Font.FromTable(tbl)
	if type(tbl) ~= "table" then
		return Font.new()
	end
	return Font.new(tbl.Family, tbl.Weight, tbl.Style)
end

function Font:__eq(other)
	return type(other) == "table"
		and other.Family == self.Family
		and other.Weight == self.Weight
		and other.Style == self.Style
end

function Font:__tostring()
	local weight = self.Weight and self.Weight.Name or "Regular"
	local style = self.Style and self.Style.Name or "Normal"
	return string.format("Font(%s, %s, %s)", tostring(self.Family), tostring(weight), tostring(style))
end

return Font
