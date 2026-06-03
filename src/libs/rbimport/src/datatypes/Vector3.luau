--!strict
local Helper = require("./Helper");

local Vector3 = {};
Vector3.__type = "Vector3";

local isFn = Helper.DataTypeIsFn(Vector3);

Vector3.__newindex = function()
    error("Cannot change");
end

local CACHE = setmetatable({}, {__mode = "v"});

local function getNan(vec: vector): vector?
    local res = vector.create(
        if (vec.x ~= vec.x) then 1 else 0,
        if (vec.y ~= vec.y) then 1 else 0,
        if (vec.z ~= vec.z) then 1 else 0
    );
    if (vector.magnitude(res) > 0) then
        return res;
    end
    return;
end

local NAN_HASH = {}
for x = 0, 1 do
    for y = 0, 1 do
        for z = 0, 1 do
            local vec = vector.create(x, y, z);
            NAN_HASH[vec] = `{x}, {y}, {z}`;
        end
    end
end

local function newFromVec(vec: vector)
    local hash = vec;
    local nan_vector = getNan(vec);
    if (nan_vector) then
        hash = NAN_HASH[nan_vector]::any;
    end
    local cached = CACHE[hash];
    if (cached) then
        return cached;
    end
    local self = setmetatable({
        _internal = vec;
    }, Vector3);
    CACHE[hash] = self;
    return self;
end

function Vector3.new(X: number?, Y: number?, Z: number?): Vector3
    return newFromVec(vector.create(X or 0, Y or 0, Z or 0));
end

Vector3.zero = Vector3.new(0, 0, 0);
Vector3.one = Vector3.new(1, 1, 1);
Vector3.xAxis = Vector3.new(1, 0, 0);
Vector3.yAxis = Vector3.new(0, 1, 0);
Vector3.zAxis = Vector3.new(0, 0, 1);

export type Vector3 = typeof(setmetatable({
    _internal = (nil::any);
}, Vector3));

Vector3.__tostring = function(self: Vector3): string
    return `{self._internal.X}, {self._internal.Y}, {self._internal.Z}`;
end

Vector3.__index = function(self: Vector3, index: string): any
    if (type(index) == "string") then
        local lower = index:lower()
        if (lower == "x") then
            return self._internal.X;
        elseif (lower == "y") then
            return self._internal.Y;
        elseif (lower == "z") then
            return self._internal.Z;
        end
        return Vector3[index];
    end
    return nil;
end

function Vector3.__unm(self: Vector3): Vector3
    return newFromVec(-self._internal);
end

function Vector3.__add(self: Vector3, b: Vector3): Vector3
    assert(isFn(b), "Invalid argument #1, expected Vector3");
    return newFromVec(self._internal + b._internal);
end

function Vector3.__sub(self: Vector3, b: Vector3): Vector3
    assert(isFn(b), "Invalid argument #1, expected Vector3");
    return newFromVec(self._internal - b._internal);
end

function Vector3.__mul(self: Vector3, b: Vector3 | number): Vector3
    if (type(b) == "number") then
        return newFromVec(self._internal * b);
    end
    assert(isFn(b), "Invalid argument #1, expected Vector3");
    return newFromVec(self._internal * b._internal);
end

function Vector3.__div(self: Vector3, b: Vector3 | number): Vector3
    if (type(b) == "number") then
        return newFromVec(self._internal / b);
    end
    assert(isFn(b), "Invalid argument #1, expected Vector3");
    return newFromVec(self._internal / b._internal);
end

function Vector3.__idiv(self: Vector3, b: Vector3 | number): Vector3
    if (type(b) == "number") then
        return newFromVec(self._internal // b);
    end
    assert(isFn(b), "Invalid argument #1, expected Vector3");
    return newFromVec(self._internal // b._internal);
end

function Vector3.Abs(self: Vector3): Vector3
    return newFromVec(vector.abs(self._internal));
end
function Vector3.Ceil(self: Vector3): Vector3
    return newFromVec(vector.ceil(self._internal));
end
function Vector3.Floor(self: Vector3): Vector3
    return newFromVec(vector.floor(self._internal));
end
function Vector3.Sign(self: Vector3): Vector3
    return newFromVec(vector.sign(self._internal));
end
function Vector3.Cross(self: Vector3, b: Vector3): Vector3
    assert(isFn(b), "Invalid argument #1, expected Vector3");
    return newFromVec(vector.cross(self._internal, b._internal));
end
function Vector3.Angle(self: Vector3, b: Vector3, c: Vector3?): number
    assert(isFn(b), "Invalid argument #1, expected Vector3");
    assert(c == nil or isFn(c), "Invalid argument #2, expected Vector3");
    return vector.angle(self._internal, b._internal, if (c) then c._internal else nil);
end
function Vector3.Dot(self: Vector3, b: Vector3): number
    assert(isFn(b), "Invalid argument #1, expected Vector3");
    return vector.dot(self._internal, b._internal);
end
function Vector3.Max(self: Vector3, b: Vector3): Vector3
    assert(isFn(b), "Invalid argument #1, expected Vector3");
    return newFromVec(vector.max(self._internal, b._internal));
end
function Vector3.Min(self: Vector3, b: Vector3): Vector3
    assert(isFn(b), "Invalid argument #1, expected Vector3");
    return newFromVec(vector.min(self._internal, b._internal));
end

local function Serialize(value: Vector3): (number, number, number)
    return value._internal.X, value._internal.Y, value._internal.Z;
end

local function Deserialize(x: number, y: number, z: number): Vector3
    return Vector3.new(x, y, z)
end

return {
    DataType = Vector3,
    Serialize = Serialize,
    Deserialize = Deserialize,
    Is = isFn,
};
