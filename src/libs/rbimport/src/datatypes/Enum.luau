--!strict
local Helper = require("./Helper");

local Enum = {};
Enum.__type = "Enum";

local isFn = Helper.DataTypeIsFn(Enum);

Enum.__newindex = function()
    error("Cannot change");
end

function Enum.new(name: string): Enum
    return setmetatable({
        ["@name"] = name,
        ["@items"] = {}::any,
    }, Enum);
end

function Enum.GetEnumItems(self: Enum)
    return table.clone(self["@items"]);
end

Enum.__index = function(self: Enum, index: any): any
    if (index == "Name") then
        return self["@name"];
    end
    for _, item in self["@items"] do
        if (type(item) == "table" and item.Name == index) then
            return item;
        end
    end
    return Enum[index];
end

Enum.__tostring = function(self: Enum): string
    return self["@name"];
end

export type Enum = typeof(Enum.new(""));

return {
    DataType = Enum,
    Is = isFn,
};
