--!strict
local Helper = require("./Helper");
local Vector3 = require("./Vector3");

type Vector3 = Vector3.Vector3;

local Ray = {};
Ray.__type = "Ray";

local isFn = Helper.DataTypeIsFn(Ray);

Ray.__newindex = function()
    error("Cannot change");
end

local CACHE = setmetatable({}, {__mode = "v"});

function Ray.new(Origin: Vector3, Direction: Vector3): Ray
    Origin = if (Origin :: any == nil) then Vector3.DataType.new(0, 0, 0) else Origin;
    Direction = if (Direction :: any == nil) then Vector3.DataType.new(0, 0, 0) else Direction;
    assert(Vector3.Is(Origin), "invalid argument #1, expected Vector3");
    assert(Vector3.Is(Direction), "invalid argument #2, expected Vector3");
    local hash = Helper.ValuesHash(Origin, Direction);
    local cached = CACHE[hash];
    if (cached) then
        return cached;
    end
    local self = setmetatable({
        Origin = Origin,
        Direction = Direction,
    }, Ray);
    CACHE[hash] = self;
    return self;
end

export type Ray = typeof(
    Ray.new(Vector3.DataType.new(0, 0, 0), Vector3.DataType.new(0, 0, 0))
);

local function Serialize(value: Ray): (number, number, number, number, number, number)
    return
        value.Origin.X, value.Origin.Y, value.Origin.Z,
        value.Direction.X, value.Direction.Y, value.Direction.Z;
end

local function Deserialize(
    posX: number, posY: number, posZ: number,
    dirX: number, dirY: number, dirZ: number
): Ray
    return Ray.new(
        Vector3.DataType.new(posX, posY, posZ),
        Vector3.DataType.new(dirX, dirY, dirZ)
    );
end

return {
    DataType = Ray,
    Serialize = Serialize,
    Deserialize = Deserialize,
    Is = isFn,
};
