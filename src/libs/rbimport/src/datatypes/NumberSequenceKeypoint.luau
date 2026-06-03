--!strict
local Helper = require("./Helper");

local NumberSequenceKeypoint = {};
NumberSequenceKeypoint.__type = "NumberSequenceKeypoint";

local isFn = Helper.DataTypeIsFn(NumberSequenceKeypoint);

NumberSequenceKeypoint.__newindex = function()
    error("Cannot change");
end

local CACHE = setmetatable({}, {__mode = "v"});

function NumberSequenceKeypoint.new(time: number, value: number, envelope: number?): NumberSequenceKeypoint
    local hash = Helper.ValuesHash(time, value, envelope or 0);
    local cached = CACHE[hash];
    if (cached) then
        return cached;
    end
    local self = setmetatable({
        Time = time,
        Value = value,
        Envelope = envelope or 0,
    }, NumberSequenceKeypoint);
    CACHE[hash] = self;
    return self;
end

export type NumberSequenceKeypoint = typeof(NumberSequenceKeypoint.new(0,2));

NumberSequenceKeypoint.__tostring = function(self: NumberSequenceKeypoint): string
    return `{self.Time} {self.Value} {self.Envelope}`;
end

local function Serialize(value: NumberSequenceKeypoint): (number, number, number)
    return value.Time, value.Value, value.Envelope;
end

local function Deserialize(time: number, value: number, envelope: number): NumberSequenceKeypoint
    return NumberSequenceKeypoint.new(time, value, envelope);
end

return {
    DataType = NumberSequenceKeypoint,
    Serialize = Serialize,
    Deserialize = Deserialize,
    Is = isFn,
};
