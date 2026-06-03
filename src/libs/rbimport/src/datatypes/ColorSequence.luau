--!strict
local Helper = require("./Helper");
local Color3 = require("./Color3");
local ColorSequenceKeypoint = require("./ColorSequenceKeypoint");

type ColorSequenceKeypoint = ColorSequenceKeypoint.ColorSequenceKeypoint;

local ColorSequence = {};
ColorSequence.__type = "ColorSequence";

local isFn = Helper.DataTypeIsFn(ColorSequence);

ColorSequence.__newindex = function()
    error("Cannot change");
end

local CACHE = setmetatable({}, {__mode = "v"});

local function newColorSequence(points: {ColorSequenceKeypoint}): ColorSequence
    local hash = Helper.ValuesHash(unpack(points));
    local cached = CACHE[hash];
    if (cached) then
        return cached;
    end
    local self = setmetatable({
        Keypoints = points,
    }, ColorSequence);
    CACHE[hash] = self;
    return self;
end

function ColorSequence.new(...): ColorSequence
    local count = select("#", ...);
    if (count == 1) then
        local value = ...;
        if (Color3.Is(value)) then
            return newColorSequence({
                ColorSequenceKeypoint.DataType.new(0, value),
                ColorSequenceKeypoint.DataType.new(1, value),
            });
        elseif (type(value) == "table") then
            assert(#value >= 2, "Must have equal to or more than 2 keypoints.");
            return newColorSequence(value);
        end
    elseif (count == 2) then
        local color0, color1 = ...;
        assert(Color3.Is(color0), "Invalid argument #1, expected Color3");
        assert(Color3.Is(color1), "Invalid argument #1, expected Color3");
        return newColorSequence({
            ColorSequenceKeypoint.DataType.new(0, color0),
            ColorSequenceKeypoint.DataType.new(1, color1),
        });
    end
    error("No matching 'ColorSequence' constructor");
end

export type ColorSequence = typeof(newColorSequence({}));

ColorSequence.__tostring = function(self: ColorSequence): string
    local points = {};
    for _, point in ipairs(self.Keypoints) do
        table.insert(points, tostring(point));
    end
    return table.concat(points, " ");
end

local function Serialize(value: ColorSequence): ({ColorSequenceKeypoint})
    return value.Keypoints;
end

local function Deserialize(values: {ColorSequenceKeypoint}): ColorSequence
    return ColorSequence.new(values);
end

return {
    DataType = ColorSequence,
    Serialize = Serialize,
    Deserialize = Deserialize,
    Is = isFn,
};
