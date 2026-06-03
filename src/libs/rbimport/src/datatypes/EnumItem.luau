--!strict
local Helper = require("./Helper");

type Enum = typeof(require("./Enum").DataType.new(""))

local EnumItem = {};
EnumItem.__type = "EnumItem";

local isFn = Helper.DataTypeIsFn(EnumItem);

EnumItem.__newindex = function()
    error("Cannot change");
end

function EnumItem.new(name: string, value: number, enum_type: Enum): EnumItem
    return setmetatable({
        Name = name,
        Value = value,
        EnumType = enum_type,
    }, EnumItem);
end

EnumItem.__tostring = function(self: EnumItem): string
    return `Enum.{self.EnumType.Name}.{self.Name}`;
end

export type EnumItem = typeof(EnumItem.new("", 0, (nil::any)));

return {
    DataType = EnumItem,
    Is = isFn,
};
