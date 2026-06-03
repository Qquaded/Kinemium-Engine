--!strict
local Helper = require("./Helper");
local Color3 = require("./Color3");

type Color3 = Color3.Color3;

local ColorSequenceKeypoint = {};
ColorSequenceKeypoint.__type = "ColorSequenceKeypoint";

local isFn = Helper.DataTypeIsFn(ColorSequenceKeypoint);

ColorSequenceKeypoint.__newindex = function()
    error("Cannot change");
end

local CACHE = setmetatable({}, {__mode = "v"});

local function newColorSequenceKeypoint(time: number, color: Color3, envelope: number)
    local hash = Helper.ValuesHash(time, color, envelope);
    local cached = CACHE[hash];
    if (cached) then
        return cached;
    end
    local self = setmetatable({
        Time = time,
        Value = color,
        Envelope = envelope,
    }, ColorSequenceKeypoint);
    CACHE[hash] = self;
    return self;
end

function ColorSequenceKeypoint.new(time: number, color: Color3): ColorSequenceKeypoint
    return newColorSequenceKeypoint(time, color, 0);
end

export type ColorSequenceKeypoint = typeof(
    newColorSequenceKeypoint(0, Color3.DataType.new(0, 0, 0), 0)
);

ColorSequenceKeypoint.__tostring = function(self: ColorSequenceKeypoint): string
    return `{self.Time} {self.Value.R} {self.Value.G} {self.Value.B} {self.Envelope}`;
end

local function Serialize(value: ColorSequenceKeypoint): (number, Color3, number)
    return value.Time, value.Value, value.Envelope;
end

local function Deserialize(time: number, value: Color3, envelope: number): ColorSequenceKeypoint
    return newColorSequenceKeypoint(time, value, envelope);
end

return {
    DataType = ColorSequenceKeypoint,
    Serialize = Serialize,
    Deserialize = Deserialize,
    Is = isFn,
};
