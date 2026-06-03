--!strict
-- TODO: use native `vector` luau datatype
local Helper = require("./Helper");

local Vector3int16 = {};
Vector3int16.__type = "Vector3int16";

local isFn = Helper.DataTypeIsFn(Vector3int16);

Vector3int16.__newindex = function()
    error("Cannot change");
end

local CACHE = setmetatable({}, {__mode = "v"});

function Vector3int16.new(X: number?, Y: number?, Z: number?): Vector3int16
    assert(X >= -32768 and X < 32768, "X must be in the range of -32768 to 32767");
    assert(Y >= -32768 and Y < 32768, "Y must be in the range of -32768 to 32767");
    assert(Z >= -32768 and Z < 32768, "Z must be in the range of -32768 to 32767");
    local hash = Helper.ValuesHash(X or 0, Y or 0, Z or 0);
    local cached = CACHE[hash];
    if (cached) then
        return cached;
    end
    local self = setmetatable({
        X = X or 0,
        Y = Y or 0,
        Z = Z or 0,
    }, Vector3int16);
    CACHE[hash] = self;
    return self;
end

export type Vector3int16 = typeof(Vector3int16.new(0, 0));

Vector3int16.__tostring = function(self: Vector3int16): string
    return `{self.X}, {self.Y}, {self.Z}`;
end

function Vector3int16.__unm(self: Vector3int16): Vector3int16
    return Vector3int16.new(-self.X, -self.Y, -self.Z);
end

function Vector3int16.__add(self: Vector3int16, b: Vector3int16): Vector3int16
    assert(isFn(b), "Invalid argument #1, expected Vector3int16");
    return Vector3int16.new(self.X + b.X, self.Y + b.Y, self.Z + b.Z);
end

function Vector3int16.__sub(self: Vector3int16, b: Vector3int16): Vector3int16
    assert(isFn(b), "Invalid argument #1, expected Vector3int16");
    return Vector3int16.new(self.X - b.X, self.Y - b.Y, self.Z - b.Z);
end

function Vector3int16.__mul(self: Vector3int16, b: number | Vector3int16): Vector3int16
    if (type(b) == "number") then
        return Vector3int16.new((self.X * b) // 1, (self.Y * b) // 1, (self.Z * b) // 1);
    end
    assert(isFn(b), "Invalid argument #1, expected number or Vector3int16");
    return Vector3int16.new((self.X * b.X) // 1, (self.Y * b.Y) // 1, (self.Z * b.Z) // 1);
end

local function Serialize(value: Vector3int16): (number, number, number)
    return value.X, value.Y, value.Z;
end

local function Deserialize(x: number, y: number, z: number): Vector3int16
    return Vector3int16.new(x, y, z)
end

return {
    DataType = Vector3int16,
    Serialize = Serialize,
    Deserialize = Deserialize,
    Is = isFn,
};
