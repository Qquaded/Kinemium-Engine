--!strict
local Helper = require("./Helper");

local Color3 = {};
Color3.__type = "Color3";

local isFn = Helper.DataTypeIsFn(Color3);

Color3.__newindex = function()
    error("Cannot change");
end

local CACHE = setmetatable({}, {__mode = "v"});

function Color3.new(red: number?, green: number?, blue: number?): Color3
    local hash = Helper.ValuesHash(
        ((red or 0) * 255) // 1,
        ((green or 0) * 255) // 1,
        ((blue or 0) * 255) // 1
    );
    local cached = CACHE[hash];
    if (cached) then
        return cached;
    end
    local self = setmetatable({
        R = red or 0,
        G = green or 0,
        B = blue or 0,
    }, Color3);
    CACHE[hash] = self;
    return self;
end

function Color3.fromRGB(red: number?, green: number?, blue: number?): Color3
    local r = (red or 0)/255;
    local g = (green or 0)/255;
    local b = (blue or 0)/255;
    return Color3.new(r, g, b);
end

function Color3.fromHSV(hue: number, saturation: number, value: number): Color3
    local chroma = value * saturation;
    local hue1 = hue / 60;
    local x = chroma * (1 - math.abs(hue1 % 2 - 1));
    local r, g, b;
    if (hue1 >= 0 and hue1 <= 1) then
        r, g, b = chroma, x, 0;
    elseif (hue1 >= 1 and hue1 <= 2) then
        r, g, b = x, chroma, 0;
    elseif (hue1 >= 2 and hue1 <= 3) then
        r, g, b = 0, chroma, x;
    elseif (hue1 >= 3 and hue1 <= 4) then
        r, g, b = 0, x, chroma;
    elseif (hue1 >= 4 and hue1 <= 5) then
        r, g, b = x, 0, chroma;
    elseif (hue1 >= 5 and hue1 <= 6) then
        r, g, b = chroma, 0, x;
    else
        r, g, b = 0, 0, 0;
    end
    local m = value - chroma;
    return Color3.new(r + m, g + m, b + m);
end

function Color3.fromHex(hex: string): Color3
    hex = hex:gsub("#", "");
    local r = tonumber(hex:sub(1, 2), 16);
    local g = tonumber(hex:sub(3, 4), 16);
    local b = tonumber(hex:sub(5, 6), 16);
    return Color3.fromRGB(r, g, b);
end

export type Color3 = typeof(Color3.new(0,0,0));

Color3.__tostring = function(self: Color3): string
    return `{self.R}, {self.G}, {self.B}`;
end

local function Serialize(value: Color3, u8: boolean): (number, number, number)
    if (u8) then
        return (value.R * 255)//1, (value.G * 255)//1, (value.B * 255)//1;
    end
    return value.R, value.G, value.B;
end

local function Deserialize(r: number, g: number, b: number, u8: boolean): Color3
    if (u8) then
        return Color3.fromRGB(r, g, b);
    end
    return Color3.new(r, g, b);
end

return {
    DataType = Color3,
    Serialize = Serialize,
    Deserialize = Deserialize,
    Is = isFn,
};
