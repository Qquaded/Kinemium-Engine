--!strict
local Helper = require("./Helper");
local Vector2 = require("./Vector2");

type Vector2 = Vector2.Vector2;

local Rect = {};
Rect.__type = "Rect";

local isFn = Helper.DataTypeIsFn(Rect);

Rect.__newindex = function()
    error("Cannot change");
end

local CACHE = setmetatable({}, {__mode = "v"});

local function newRect(
    Min: Vector2,
    Max: Vector2
)
    local hash = Helper.ValuesHash(Min, Max);
    local cached = CACHE[hash];
    if (cached) then
        return cached;
    end
    local self = setmetatable({
        Width = Max.X - Min.X,
        Height = Max.Y - Min.Y,
        Min = Min,
        Max = Max,
    }, Rect);
    CACHE[hash] = self;
    return self;
end

function Rect.new(...): Rect
    local count = select("#", ...);
    if (count == 0) then
        return newRect(
            Vector2.DataType.new(0, 0),
            Vector2.DataType.new(0, 0)
        );
    elseif (count == 2) then
        local min: Vector2, max: Vector2 = ...;
        assert(Vector2.Is(min), "invalid argument #1, expected Vector2");
        assert(Vector2.Is(max), "invalid argument #2, expected Vector2");
        return newRect(min, max);
    elseif (count == 4) then
        local minX, minY, maxX, maxY  = ...;
        assert(type(minX) == "number", "invalid argument #1, expected number");
        assert(type(minY) == "number", "invalid argument #2, expected number");
        assert(type(maxX) == "number", "invalid argument #3, expected number");
        assert(type(maxY) == "number", "invalid argument #4, expected number");
        assert(minX <= maxX, "minimum X must be less than or equal to maximum X");
        assert(minY <= maxY, "minimum Y must be less than or equal to maximum Y");
        return newRect(
            Vector2.DataType.new(minX, minY), Vector2.DataType.new(maxX, maxY)
        );
    end
    error("No matching 'Rect' constructor");
end

export type Rect = typeof(Rect.new(0, 0));

local function Serialize(value: Rect): (number, number, number, number)
    return
        value.Min.X,
        value.Min.Y,
        value.Max.X,
        value.Max.Y;
end

local function Deserialize(
    minX: number, minY: number,
    maxX: number, maxY: number
): Rect
    return Rect.new(
        minX, minY,
        maxX, maxY
    );
end

return {
    DataType = Rect,
    Serialize = Serialize,
    Deserialize = Deserialize,
    Is = isFn,
};
