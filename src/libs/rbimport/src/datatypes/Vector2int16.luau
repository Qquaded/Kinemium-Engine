--!strict
local Helper = require("./Helper");

local Vector2int16 = {};
Vector2int16.__type = "Vector2int16";

local isFn = Helper.DataTypeIsFn(Vector2int16);

Vector2int16.__newindex = function()
    error("Cannot change");
end

local CACHE = setmetatable({}, {__mode = "v"});

function Vector2int16.new(X: number?, Y: number?): Vector2int16
    assert(X >= -32768 and X < 32768, "X must be in the range of -32768 to 32767");
    assert(Y >= -32768 and Y < 32768, "Y must be in the range of -32768 to 32767");
    local hash = Helper.ValuesHash(X or 0, Y or 0);
    local cached = CACHE[hash];
    if (cached) then
        return cached;
    end
    local self = setmetatable({
        X = X or 0,
        Y = Y or 0,
    }, Vector2int16);
    CACHE[hash] = self;
    return self;
end

export type Vector2int16 = typeof(Vector2int16.new(0, 0));

Vector2int16.__tostring = function(self: Vector2int16): string
    return `{self.X}, {self.Y}`;
end

function Vector2int16.__unm(self: Vector2int16): Vector2int16
    return Vector2int16.new(-self.X, -self.Y);
end

function Vector2int16.__add(self: Vector2int16, b: Vector2int16): Vector2int16
    assert(isFn(b), "Invalid argument #1, expected Vector2int16");
    return Vector2int16.new(self.X + b.X, self.Y + b.Y);
end

function Vector2int16.__sub(self: Vector2int16, b: Vector2int16): Vector2int16
    assert(isFn(b), "Invalid argument #1, expected Vector2int16");
    return Vector2int16.new(self.X - b.X, self.Y - b.Y);
end

function Vector2int16.__mul(self: Vector2int16, b: number | Vector2int16): Vector2int16
    if (type(b) == "number") then
        return Vector2int16.new((self.X * b) // 1, (self.Y * b) // 1);
    end
    assert(isFn(b), "Invalid argument #1, expected number or Vector2int16");
    return Vector2int16.new((self.X * b.X) // 1, (self.Y * b.Y) // 1);
end

local function Serialize(value: Vector2int16): (number, number)
    return value.X, value.Y;
end

local function Deserialize(x: number, y: number): Vector2int16
    return Vector2int16.new(x, y)
end

return {
    DataType = Vector2int16,
    Serialize = Serialize,
    Deserialize = Deserialize,
    Is = isFn,
};
