--!strict
local Helper = require("./Helper");

local NumberRange = {};
NumberRange.__type = "NumberRange";

local isFn = Helper.DataTypeIsFn(NumberRange);

NumberRange.__newindex = function()
    error("Cannot change");
end

local CACHE = setmetatable({}, {__mode = "v"});

local function newNumberRange(min: number, max: number): NumberRange
    local hash = Helper.ValuesHash(min, max);
    local cached = CACHE[hash];
    if (cached) then
        return cached;
    end
    local self = setmetatable({
        Min = min,
        Max = max,
    }, NumberRange);
    CACHE[hash] = self;
    return self;
end

function NumberRange.new(...): NumberRange
    local count = select("#", ...);
    if (count == 1) then
        local value = ...;
        assert(type(value) == "number", "invalid argument #1, expected number");
        return newNumberRange(value, value);
    elseif (count == 2) then
        local a, b = ...;
        assert(type(a) == "number", "invalid argument #1, expected number");
        assert(type(b) == "number", "invalid argument #2, expected number");
        return newNumberRange(a, b);
    end
    error("No matching 'NumberRange' constructor");
end

export type NumberRange = typeof(NumberRange.new(0, 0));

NumberRange.__tostring = function(self: NumberRange): string
    return `{self.Min} {self.Max}`;
end

local function Serialize(value: NumberRange): (number, number)
    return value.Min, value.Max;
end

local function Deserialize(min: number, max: number): NumberRange
    return NumberRange.new(min, max);
end

return {
    DataType = NumberRange,
    Serialize = Serialize,
    Deserialize = Deserialize,
    Is = isFn,
};
