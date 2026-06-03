--!strict
local Helper = require("./Helper");

local UniqueId = {};
UniqueId.__type = "UniqueId";

local isFn = Helper.DataTypeIsFn(UniqueId);

UniqueId.__newindex = function()
    error("Cannot change");
end

local CACHE = setmetatable({}, {__mode = "v"});

function newUniqueId(index: number, time: number, random: buffer): UniqueId
    local hash = Helper.ValuesHash(index, time, buffer.readu32(random, 0), buffer.readu32(random, 4));
    local cached = CACHE[hash];
    if (cached) then
        return cached;
    end
    local self = setmetatable({
        Index = index,
        Time = time,
        Random = random,
    }, UniqueId);
    CACHE[hash] = self;
    return self;
end

UniqueId["nil"] = newUniqueId(0, 0, buffer.create(8));

local INDEX = 0;
UniqueId.now = function(): UniqueId
    local time = os.time();
    local random = buffer.create(8);
    buffer.writeu32(random, 0, math.random(0, 0xFFFFFFFF));
    buffer.writeu32(random, 4, math.random(0, 0xFFFFFFFF));
    INDEX += 1;
    return newUniqueId(INDEX, time, random);
end

UniqueId.load = function(): UniqueId
    return UniqueId["nil"];
end

export type UniqueId = typeof(newUniqueId(0, 0, buffer.create(0)));

local function Serialize(value: UniqueId): (buffer, number, number)
    return value.Random, value.Index, value.Time;
end

local function Deserialize(
    random: buffer,
    index: number,
    time: number
): UniqueId
    return newUniqueId(index, time, random);
end

return {
    DataType = UniqueId,
    Serialize = Serialize,
    Deserialize = Deserialize,
    Is = isFn,
};
