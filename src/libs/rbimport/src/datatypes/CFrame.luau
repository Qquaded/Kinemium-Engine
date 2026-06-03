--!strict
local Helper = require("./Helper");
local Vector3 = require("./Vector3");

type Vector3 = Vector3.Vector3;

local CFrame = {};
CFrame.__type = "CFrame";

local isFn = Helper.DataTypeIsFn(CFrame);

CFrame.__newindex = function()
    error("Cannot change");
end

local function checkNumbers(...)
    for _, v in {...} do
        if (type(v) ~= "number") then
            return false;
        end
    end
    return true;
end

local identity_posVector = Vector3.DataType.new(0, 0, 0);
local identity_XVector = Vector3.DataType.new(1, 0, 0);
local identity_YVector = Vector3.DataType.new(0, 1, 0);
local identity_ZVector = Vector3.DataType.new(0, 0, 1);

CFrame.identity = setmetatable({
    Position = identity_posVector,
    RightVector = identity_XVector,
    UpVector = identity_YVector,
    LookVector = -identity_ZVector,
    XVector = identity_XVector,
    YVector = identity_YVector,
    ZVector = identity_ZVector,
}, CFrame);

local CACHE = setmetatable({}, {__mode = "v"});

CACHE[Helper.ValuesHash(
    identity_posVector,
    identity_XVector,
    identity_YVector,
    identity_ZVector
)] = CFrame.identity;

function CFrame.new(...): CFrame
    local count = select("#", ...);
    if (count == 0) then
        return CFrame.identity;
    elseif (count == 1) then
        local position = ...;
        assert(Vector3.Is(position), "Invalid argument #1, expected Vector3");
        local x, y, z = position.X, position.Y, position.Z;
        local posVector = Vector3.DataType.new(x, y, z);
        local hash = Helper.ValuesHash(posVector, identity_XVector, identity_YVector, identity_ZVector);
        local cached = CACHE[hash];
        if (cached) then
            return cached;
        end
        local self = setmetatable({
            Position = posVector,
            RightVector = identity_XVector,
            UpVector = identity_YVector,
            LookVector = -identity_ZVector,
            XVector = identity_XVector,
            YVector = identity_YVector,
            ZVector = identity_ZVector,
        }, CFrame);
        CACHE[hash] = self;
        return self;
    elseif (count == 2) then
    elseif (count == 3) then
    elseif (count == 7) then
    elseif (count == 12) then
        assert(checkNumbers(...), "Invalid type (12)");
        local x, y, z, r00, r01, r02, r10, r11, r12, r20, r21, r22 = ...;
        local posVector = Vector3.DataType.new(x, y, z);
        local XVector = Vector3.DataType.new(r00, r10, r20);
        local YVector = Vector3.DataType.new(r01, r11, r21);
        local ZVector = Vector3.DataType.new(r02, r12, r22);
        local hash = Helper.ValuesHash(posVector, XVector, YVector, ZVector);
        local cached = CACHE[hash];
        if (cached) then
            return cached;
        end
        local self = setmetatable({
            Position = posVector,
            RightVector = XVector,
            UpVector = YVector,
            LookVector = -ZVector,
            XVector = XVector,
            YVector = YVector,
            ZVector = ZVector,
        }, CFrame);
        CACHE[hash] = self;
        return self;
    end
    error("No matching 'CFrame' constructor");
end

export type CFrame = typeof(CFrame.new());

CFrame.__tostring = function(self: CFrame): string
    return `{self.Position.X}, {self.Position.Y}, {self.Position.Z}, `
        .. `{self.XVector.X}, {self.YVector.X}, {self.ZVector.X}, `
        .. `{self.XVector.Y}, {self.YVector.Y}, {self.ZVector.Y}, `
        .. `{self.XVector.Z}, {self.YVector.Z}, {self.ZVector.Z}`;
end

local function Serialize(value: CFrame): (
    number, number, number,
    number, number, number,
    number, number, number,
    number, number, number
)
    return value.Position.X, value.Position.Y, value.Position.Z,
        value.XVector.X, value.YVector.X, value.ZVector.X,
        value.XVector.Y, value.YVector.Y, value.ZVector.Y,
        value.XVector.Z, value.YVector.Z, value.ZVector.Z;
end

local function Deserialize(
    x: number, y: number, z: number,
    r00: number, r01: number, r02: number,
    r10: number, r11: number, r12: number,
    r20: number, r21: number, r22: number
): CFrame
    return CFrame.new(
        x, y, z,
        r00, r01, r02,
        r10, r11, r12,
        r20, r21, r22
    );
end

return {
    DataType = CFrame,
    Serialize = Serialize,
    Deserialize = Deserialize,
    Is = isFn,
};
