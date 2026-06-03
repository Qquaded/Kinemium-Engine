--!strict
local Helper = require("./Helper");
local Enums = require("./Enums");

local Faces = {};
Faces.__type = "Faces";

local isFn = Helper.DataTypeIsFn(Faces);

local FaceFlags = {
    RIGHT = 1,
    TOP = 2,
    BACK = 4,
    LEFT = 8,
    BOTTOM = 16,
    FRONT = 32,
}

Faces.__newindex = function()
    error("Cannot change");
end

local function Serialize(value: Faces): number
    local flags = 0;
    if (value.Top) then
        flags = bit32.bor(flags, FaceFlags.TOP);
    end
    if (value.Bottom) then
        flags = bit32.bor(flags, FaceFlags.BOTTOM);
    end
    if (value.Left) then
        flags = bit32.bor(flags, FaceFlags.LEFT);
    end
    if (value.Right) then
        flags = bit32.bor(flags, FaceFlags.RIGHT);
    end
    if (value.Back) then
        flags = bit32.bor(flags, FaceFlags.BACK);
    end
    if (value.Front) then
        flags = bit32.bor(flags, FaceFlags.FRONT);
    end
    return flags;
end

local CACHE = setmetatable({}, {__mode = "v"});

local function newFaces(
    Top: boolean?,
    Bottom: boolean?,
    Left: boolean?,
    Right: boolean?,
    Back: boolean?,
    Front: boolean?
): Faces
    local input = {
        Top = Top or false,
        Bottom = Bottom or false,
        Left = Left or false,
        Right = Right or false,
        Back = Back or false,
        Front = Front or false,
    };
    local id = Serialize(input)
    local cached = CACHE[id];
    if (cached) then
        return cached;
    end
    local self = setmetatable(input, Faces);
    CACHE[id] = self;
    return self::any;
end

function Faces.new(...): Faces
    local normals = {...};
    return newFaces(
        table.find(normals, Enums.DataType.NormalId.Top) ~= nil,
        table.find(normals, Enums.DataType.NormalId.Bottom) ~= nil,
        table.find(normals, Enums.DataType.NormalId.Left) ~= nil,
        table.find(normals, Enums.DataType.NormalId.Right) ~= nil,
        table.find(normals, Enums.DataType.NormalId.Back) ~= nil,
        table.find(normals, Enums.DataType.NormalId.Front) ~= nil
    );
end

export type Faces = typeof(
    newFaces()
);

local function Deserialize(flags: number): Faces
    return newFaces(
        bit32.band(flags, FaceFlags.TOP) ~= 0,
        bit32.band(flags, FaceFlags.BOTTOM) ~= 0,
        bit32.band(flags, FaceFlags.LEFT) ~= 0,
        bit32.band(flags, FaceFlags.RIGHT) ~= 0,
        bit32.band(flags, FaceFlags.BACK) ~= 0,
        bit32.band(flags, FaceFlags.FRONT) ~= 0
    )
end

return {
    DataType = Faces,
    Serialize = Serialize,
    Deserialize = Deserialize,
    Is = isFn,
};
