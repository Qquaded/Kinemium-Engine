--!strict
local Helper = require("./Helper");
local Enum = require("./Enum");
local EnumItem = require("./EnumItem");
local RefectionDatabase = require("../reflection");

local Enums = {};
Enums.__type = "Enums";

local isFn = Helper.DataTypeIsFn(Enums);

Enums.__newindex = function()
    error("Cannot change");
end

function Enums.new(): Enums
    local items = {};

    local dump = RefectionDatabase:GetApiDump();

    for _, enum_api in dump.Enums do
        local enum = Enum.DataType.new(enum_api.Name)
        for _, item in enum_api.Items do
            table.insert(enum["@items"], EnumItem.DataType.new(item.Name, item.Value, enum));
        end
        items[enum_api.Name] = enum;
    end

    return setmetatable({
        ["@items"] = items,
    }, Enums);
end

local function GetEnums(self: Enums)
    local array = {};
    for _, enum in self["@items"]::any do
        table.insert(array, enum);
    end
    return array;
end

Enums.__index = function(self: Enums, index: any): any
    if (index == "GetEnums") then
        return GetEnums;
    end
    return self["@items"][index];
end

export type Enums = typeof(Enums.new()) & {
    [string]: Enum.Enum,
};

return {
    DataType = Enums.new(),
    Is = isFn,
};
