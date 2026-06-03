--!strict
local Helper = require("./Helper");
local Enums = require("./Enums");

local Axes = {};
Axes.__type = "Axes";

local isFn = Helper.DataTypeIsFn(Axes);

local AxisFlags = {
    X = 1,
    Y = 2,
    Z = 4,
}

Axes.__newindex = function()
    error("Cannot change");
end

local function notNil(value: any): boolean
    return value ~= nil;
end

local function Serialize(value: Axes): number
    local flags = 0;
    if (value.X) then
        flags = bit32.bor(flags, AxisFlags.X);
    end
    if (value.Y) then
        flags = bit32.bor(flags, AxisFlags.Y);
    end
    if (value.Z) then
        flags = bit32.bor(flags, AxisFlags.Z);
    end
    return flags;
end

local CACHE = setmetatable({}, {__mode = "v"});

local function newAxes(X: boolean, Y: boolean, Z: boolean): Axes
    local input = {
        X = X,
        Y = Y,
        Z = Z,
    };
    local id = Serialize(input)
    local cached = CACHE[id];
    if (cached) then
        return cached;
    end
    local self = setmetatable(input, Axes);
    CACHE[id] = self;
    return self::any;
end

function Axes.new(...): Axes
    local axes = {...};
    return newAxes(
        notNil(table.find(axes, Enums.DataType.NormalId.Left)
            or table.find(axes, Enums.DataType.NormalId.Right)),
        notNil(table.find(axes, Enums.DataType.NormalId.Top)
            or table.find(axes, Enums.DataType.NormalId.Bottom)),
        notNil(table.find(axes, Enums.DataType.NormalId.Front)
            or table.find(axes, Enums.DataType.NormalId.Back))
    );
end

export type Axes = typeof(Axes.new());

local function Deserialize(flags: number): Axes
    return newAxes(
        bit32.band(flags, AxisFlags.X) ~= 0,
        bit32.band(flags, AxisFlags.Y) ~= 0,
        bit32.band(flags, AxisFlags.Z) ~= 0
    )
end

return {
    DataType = Axes,
    Serialize = Serialize,
    Deserialize = Deserialize,
    Is = isFn,
};
