--!strict
local Helper = require("./Helper");
local UDim = require("./UDim");

type UDim = UDim.UDim;

local UDim2 = {};
UDim2.__type = "UDim2";

local isFn = Helper.DataTypeIsFn(UDim2);

UDim2.__newindex = function()
    error("Cannot change");
end

local CACHE = setmetatable({}, {__mode = "v"});

local function newUDim2(X: UDim, Y: UDim): UDim2
    local hash = Helper.ValuesHash(X, Y);
    local cached = CACHE[hash];
    if (cached) then
        return cached;
    end
    local self = setmetatable({
        X = X,
        Y = Y,
    }, UDim2);
    CACHE[hash] = self;
    return self;
end

function UDim2.new(...): UDim2
    local count = select("#", ...);
    if (count == 0) then
        return newUDim2(UDim.DataType.new(0, 0), UDim.DataType.new(0, 0));
    elseif (count == 2) then
        local X, Y = ...;
        assert(UDim.Is(X), "Invalid argument #1, expected UDim");
        assert(UDim.Is(Y), "Invalid argument #2, expected UDim");
        return newUDim2(X, Y);
    elseif (count == 4) then
        local XScale, XOffset, YScale, YOffset = ...;
        assert(type(XScale) == "number", "Invalid argument #1, expected number");
        assert(type(XOffset) == "number", "Invalid argument #2, expected number");
        assert(type(YScale) == "number", "Invalid argument #3, expected number");
        assert(type(YOffset) == "number", "Invalid argument #4, expected number");
        return newUDim2(UDim.DataType.new(XScale, XOffset), UDim.DataType.new(YScale, YOffset));
    end
    error("No matching 'UDim2' constructor");
end

export type UDim2 = typeof(UDim2.new(0, 0));

UDim2.__tostring = function(self: UDim2): string
    return `\{{self.X}\}, \{{self.Y}\}`;
end

function UDim2.__index(self: UDim2, index: any): any
    if (index == "Width") then
        return self.X;
    elseif (index == "Height") then
        return self.Y;
    end
    return;
end

function UDim2.__add(self: UDim2, b: UDim2): UDim2
    assert(isFn(b), "Invalid argument #1, expected UDim");
    return UDim2.new(self.X + b.X, self.Y + b.Y);
end

function UDim2.__sub(self: UDim2, b: UDim2): UDim2
    assert(isFn(b), "Invalid argument #1, expected UDim");
    return UDim2.new(self.X - b.X, self.Y - b.Y);
end

local function Serialize(value: UDim2): (number, number, number, number)
    return value.X.Scale, value.X.Offset, value.Y.Scale, value.Y.Offset;
end

local function Deserialize(scale_x: number, offset_x: number, scale_y: number, offset_y: number): UDim2
    return UDim2.new(scale_x, offset_x, scale_y, offset_y);
end

return {
    DataType = UDim2,
    Serialize = Serialize,
    Deserialize = Deserialize,
    Is = isFn,
};
