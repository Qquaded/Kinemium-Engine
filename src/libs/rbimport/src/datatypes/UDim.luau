--!strict
local Helper = require("./Helper");

local UDim = {};
UDim.__type = "UDim";

local isFn = Helper.DataTypeIsFn(UDim);

UDim.__newindex = function()
    error("Cannot change");
end

local CACHE = setmetatable({}, {__mode = "v"});

function UDim.new(Scale: number, Offset: number): UDim
    Offset = math.floor(Offset);
    local hash = Helper.ValuesHash(Scale, Offset);
    local cached = CACHE[hash];
    if (cached) then
        return cached;
    end
    local self = setmetatable({
        Scale = Scale,
        Offset = Offset,
    }, UDim);
    CACHE[hash] = self;
    return self;
end

export type UDim = typeof(UDim.new(0, 0));

UDim.__tostring = function(self: UDim): string
    return `{self.Scale}, {self.Offset}`;
end

function UDim.__add(self: UDim, b: UDim): UDim
    assert(isFn(b), "Invalid argument #1, expected UDim");
    return UDim.new(self.Scale + b.Scale, self.Offset + b.Offset);
end

function UDim.__sub(self: UDim, b: UDim): UDim
    assert(isFn(b), "Invalid argument #1, expected UDim");
    return UDim.new(self.Scale - b.Scale, self.Offset - b.Offset);
end

local function Serialize(value: UDim): (number, number)
    return value.Scale, value.Offset;
end

local function Deserialize(scale: number, offset: number): UDim
    return UDim.new(scale, offset)
end

return {
    DataType = UDim,
    Serialize = Serialize,
    Deserialize = Deserialize,
    Is = isFn,
};
