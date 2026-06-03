--!strict
local Helper = require("./Helper");
local NumberSequenceKeypoint = require("./NumberSequenceKeypoint");

type NumberSequenceKeypoint = NumberSequenceKeypoint.NumberSequenceKeypoint;

local NumberSequence = {};
NumberSequence.__type = "NumberSequence";

local isFn = Helper.DataTypeIsFn(NumberSequence);

NumberSequence.__newindex = function()
    error("Cannot change");
end

local CACHE = setmetatable({}, {__mode = "v"});

local function newNumberSequence(points: {NumberSequenceKeypoint}): NumberSequence
    local hash = Helper.ValuesHash(unpack(points));
    local cached = CACHE[hash];
    if (cached) then
        return cached;
    end
    local self = setmetatable({
        Keypoints = points,
    }, NumberSequence);
    CACHE[hash] = self;
    return self;
end

function NumberSequence.new(...): NumberSequence
    local count = select("#", ...);
    if (count == 1) then
        local value = ...;
        if (type(value) == "number") then
            return newNumberSequence({
                NumberSequenceKeypoint.DataType.new(0, value),
                NumberSequenceKeypoint.DataType.new(1, value),
            });
        elseif (type(value) == "table") then
            assert(#value > 1, "NumberSequence needs at least 2 keypoints")
            return newNumberSequence(value);
        end
    elseif (count == 2) then
        local a, b = ...;
        assert(type(a) == "number", "invalid argument #1, expected number");
        assert(type(b) == "number", "invalid argument #2, expected number");
        return newNumberSequence({
            NumberSequenceKeypoint.DataType.new(0, a),
            NumberSequenceKeypoint.DataType.new(1, b),
        });
    end
    error("No matching 'NumberSequence' constructor");
end

function NumberSequence.load(): NumberSequence
    return NumberSequence.new(0, 0);
end

export type NumberSequence = typeof(NumberSequence.new(0, 0));

NumberSequence.__tostring = function(self: NumberSequence): string
    local points = {};
    for _, point in ipairs(self.Keypoints) do
        table.insert(points, tostring(point));
    end
    return table.concat(points, " ");
end

local function Serialize(value: NumberSequence): {NumberSequenceKeypoint}
    return value.Keypoints;
end

local function Deserialize(values: {NumberSequenceKeypoint}): NumberSequence
    return NumberSequence.new(values);
end

return {
    DataType = NumberSequence,
    Serialize = Serialize,
    Deserialize = Deserialize,
    Is = isFn,
};
