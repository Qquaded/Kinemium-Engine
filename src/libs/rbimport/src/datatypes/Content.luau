--!strict
local Helper = require("./Helper");
local Enum = require("./Enums").DataType;
local EnumItem = require("./EnumItem");

type EnumItem = EnumItem.EnumItem;

local Content = {};
Content.__type = "Content";

local isFn = Helper.DataTypeIsFn(Content);

Content.__newindex = function()
    error("Cannot change");
end

local CACHE = setmetatable({}, {__mode = "v"});

function newContent(uri: string?, object: any?, source_type: EnumItem): Content
    assert(EnumItem.Is(source_type) and source_type.EnumType == Enum.ContentSourceType, "invalid argument #3, expected Enum.ContentSourceType");
    local hash = Helper.ValuesHash(uri, object, source_type.Value);
    local cached = CACHE[hash];
    if (cached) then
        return cached;
    end
    local self = setmetatable({
        Uri = uri,
        Object = object,
        SourceType = source_type,
    }, Content);
    CACHE[hash] = self;
    return self;
end

Content.none = newContent(nil, nil, Enum.ContentSourceType.None);

Content.load = function(): Content
    return Content.none;
end

export type Content = typeof(newContent(nil, nil, Enum.ContentSourceType.None));

local function Serialize(value: Content): (number, string?, any?)
    return value.SourceType.Value, value.Uri, value.Object;
end

local function Deserialize(
    type: number,
    uri: string?,
    object: any?
): Content
    local sourceType = Enum.ContentSourceType.None;
    for _, item in Enum.ContentSourceType:GetEnumItems() do
        if (item.Value == type) then
            sourceType = item;
            break;
        end
    end
    return newContent(uri, object, sourceType);
end

return {
    DataType = Content,
    Serialize = Serialize,
    Deserialize = Deserialize,
    Is = isFn,
};
