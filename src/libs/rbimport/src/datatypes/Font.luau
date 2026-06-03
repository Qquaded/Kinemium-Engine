--!strict
local Helper = require("./Helper");
local Enum = require("./Enums").DataType;
local EnumItem = require("./EnumItem");

type EnumItem = EnumItem.EnumItem;

local Font = {};
Font.__type = "Font";

local isFn = Helper.DataTypeIsFn(Font);

Font.__newindex = function()
    error("Cannot change");
end

local CACHE = setmetatable({}, {__mode = "v"});

function Font.new(family: string, weight: EnumItem, style: EnumItem): Font
    assert(type(family) == "string", "invalid argument #1, expected string");
    assert(EnumItem.Is(weight) and weight.EnumType == Enum.FontWeight, "invalid argument #2, expected Enum.FontWeight");
    assert(EnumItem.Is(style) and style.EnumType == Enum.FontStyle, "invalid argument #3, expected Enum.FontStyle");
    local hash = Helper.ValuesHash(family, weight.Value, style.Value);
    local cached = CACHE[hash];
    if (cached) then
        return cached;
    end
    local self = setmetatable({
        Family = family,
        Weight = weight,
        Style = style,
        Bold = weight == Enum.FontWeight.Bold,
        CacheId = (nil::any)::string?,
    }, Font);
    CACHE[hash] = self;
    return self;
end

export type Font = typeof(Font.new("", Enum.FontWeight.Normal, Enum.FontStyle.Normal));

local function Serialize(value: Font): (string, number, number, string?)
    return value.Family, value.Weight.Value, value.Style.Value, value.CacheId;
end

function Font.load(family: string?, weight: EnumItem?, style: EnumItem?): Font
    local family_str = family or "rbxasset://fonts/families/SourceSansPro.json";
    local weight_enum = weight or Enum.FontWeight.Regular;
    local style_enum = style or Enum.FontStyle.Normal;
    return Font.new(family_str, weight_enum, style_enum);
end

local function Deserialize(
    family: string,
    weight: number,
    style: number,
    cacheId: string
): Font
    local weightEnum = Enum.FontWeight.Regular;
    for _, item in Enum.FontWeight:GetEnumItems() do
        if (item.Value == weight) then
            weightEnum = item;
            break;
        end
    end
    local font = Font.load(
        family,
        weightEnum,
        if (style == 0) then
            Enum.FontStyle.Normal
        else
            Enum.FontStyle.Italic
    );
    if (#cacheId > 0) then
        rawset(font::any, "CacheId", cacheId)
    end
    return font
end

return {
    DataType = Font,
    Serialize = Serialize,
    Deserialize = Deserialize,
    Is = isFn,
};
