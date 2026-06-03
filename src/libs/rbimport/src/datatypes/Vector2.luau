--!strict
local Helper = require("./Helper");

local Vector2 = {};
Vector2.__type = "Vector2";

local isFn = Helper.DataTypeIsFn(Vector2);

Vector2.__newindex = function()
    error("Cannot change");
end

local CACHE = setmetatable({}, {__mode = "v"});

-- TODO: use "vector" type instead of "any" when indexing .X, .Y, .Z doesn't cause an error
local function getNan(vec: any): vector?
    local res = vector.create(
        if (vec.X ~= vec.X) then 1 else 0,
        if (vec.Y ~= vec.Y) then 1 else 0,
        0
    );
    if (vector.magnitude(res) > 0) then
        return res;
    end
    return;
end

local NAN_HASH = {}
for x = 0, 1 do
    for y = 0, 1 do
        local vec = vector.create(x, y, 0);
        NAN_HASH[vec] = `{x}, {y}`;
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
    }, Vector2);
    CACHE[hash] = self;
    return self;
end

function Vector2.new(X: number?, Y: number?): Vector2
    return newFromVec(vector.create(X or 0, Y or 0, 0));
end

export type Vector2 = typeof(Vector2.new(0, 0));

Vector2.__tostring = function(self: Vector2): string
    return `{self._internal.X}, {self._internal.Y}`;
end

Vector2.__index = function(self: Vector2, index: string): any
    if (type(index) == "string") then
        if (index == "x" or index == "X") then
            return self._internal.X;
        elseif (index == "y" or index == "Y") then
            return self._internal.Y;
        end
        return Vector2[index];
    end
    return nil;
end

function Vector2.__add(self: Vector2, b: Vector2): Vector2
    assert(isFn(b), "Invalid argument #1, expected Vector2");
    return newFromVec(self._internal + b._internal);
end

function Vector2.__sub(self: Vector2, b: Vector2): Vector2
    assert(isFn(b), "Invalid argument #1, expected Vector2");
    return newFromVec(self._internal - b._internal);
end

function Vector2.__mul(self: Vector2, b: number | Vector2): Vector2
    if (type(b) == "number") then
        return newFromVec(self._internal * b);
    end
    assert(isFn(b), "Invalid argument #1, expected number or Vector2");
    return newFromVec(self._internal * b._internal);
end

function Vector2.__div(self: Vector2, b: number | Vector2): Vector2
    if (type(b) == "number") then
        return newFromVec(self._internal / b);
    end
    assert(isFn(b), "Invalid argument #1, expected number or Vector2");
    return newFromVec(self._internal / b._internal);
end

function Vector2.__idiv(self: Vector2, b: number | Vector2): Vector2
    if (type(b) == "number") then
        return newFromVec(self._internal // b);
    end
    assert(isFn(b), "Invalid argument #1, expected number or Vector2");
    return newFromVec(self._internal // b._internal);
end

local function Serialize(value: Vector2): (number, number)
    return value._internal.X, value._internal.Y;
end

local function Deserialize(x: number, y: number): Vector2
    return Vector2.new(x, y)
end

return {
    DataType = Vector2,
    Serialize = Serialize,
    Deserialize = Deserialize,
    Is = isFn,
};
