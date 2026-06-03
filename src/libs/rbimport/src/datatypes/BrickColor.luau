--!strict
local Helper = require("./Helper");
local Color3 = require("./Color3");

type Color3 = Color3.Color3;

local BrickColor = {};
BrickColor.__type = "BrickColor";

local isFn = Helper.DataTypeIsFn(BrickColor);

BrickColor.__newindex = function()
    error("Cannot change");
end

type PaletteColor = {
    Name: string,
    r: number,
    g: number,
    b: number,
    Number: number,
    ArrayId: number,
}

local function palette(name: string, value: number, r: number, g: number, b: number): PaletteColor
    return {
        Name = name,
        r = r,
        g = g,
        b = b,
        Number = value,
        ArrayId = 0,
    }
end

local Palette = {
    [1] = palette("White", 1, 0.950, 0.953, 0.953),
    [2] = palette("Grey", 2, 0.632, 0.648, 0.636),
    [3] = palette("Light yellow", 3, 0.977, 0.914, 0.600),
    [5] = palette("Brick yellow", 5, 0.844, 0.773, 0.604),
    [6] = palette("Light green (Mint)", 6, 0.761, 0.855, 0.722),
    [9] = palette("Light reddish violet", 9, 0.910, 0.730, 0.785),
    [11] = palette("Pastel Blue", 11, 0.502, 0.734, 0.859),
    [12] = palette("Light orange brown", 12, 0.797, 0.518, 0.259),
    [18] = palette("Nougat", 18, 0.800, 0.557, 0.412),
    [21] = palette("Bright red", 21, 0.769, 0.157, 0.110),
    [22] = palette("Med. reddish violet", 22, 0.769, 0.440, 0.628),
    [23] = palette("Bright blue", 23, 0.051, 0.412, 0.675),
    [24] = palette("Bright yellow", 24, 0.961, 0.804, 0.189),
    [25] = palette("Earth orange", 25, 0.385, 0.279, 0.197),
    [26] = palette("Black", 26, 0.106, 0.165, 0.208),
    [27] = palette("Dark grey", 27, 0.428, 0.432, 0.424),
    [28] = palette("Dark green", 28, 0.157, 0.499, 0.279),
    [29] = palette("Medium green", 29, 0.632, 0.769, 0.550),
    [36] = palette("Lig. Yellowich orange", 36, 0.953, 0.812, 0.608),
    [37] = palette("Bright green", 37, 0.295, 0.593, 0.295),
    [38] = palette("Dark orange", 38, 0.628, 0.373, 0.208),
    [39] = palette("Light bluish violet", 39, 0.757, 0.793, 0.871),
    [40] = palette("Transparent", 40, 0.926, 0.926, 0.926),
    [41] = palette("Tr. Red", 41, 0.804, 0.330, 0.295),
    [42] = palette("Tr. Lg blue", 42, 0.757, 0.875, 0.942),
    [43] = palette("Tr. Blue", 43, 0.483, 0.714, 0.910),
    [44] = palette("Tr. Yellow", 44, 0.969, 0.946, 0.553),
    [45] = palette("Light blue", 45, 0.706, 0.824, 0.895),
    [47] = palette("Tr. Flu. Reddish orange", 47, 0.851, 0.522, 0.424),
    [48] = palette("Tr. Green", 48, 0.518, 0.714, 0.553),
    [49] = palette("Tr. Flu. Green", 49, 0.973, 0.946, 0.518),
    [50] = palette("Phosph. White", 50, 0.926, 0.910, 0.871),
    [100] = palette("Light red", 100, 0.934, 0.769, 0.714),
    [101] = palette("Medium red", 101, 0.855, 0.526, 0.479),
    [102] = palette("Medium blue", 102, 0.432, 0.600, 0.793),
    [103] = palette("Light grey", 103, 0.781, 0.757, 0.718),
    [104] = palette("Bright violet", 104, 0.420, 0.197, 0.487),
    [105] = palette("Br. yellowish orange", 105, 0.887, 0.608, 0.251),
    [106] = palette("Bright orange", 106, 0.855, 0.522, 0.255),
    [107] = palette("Bright bluish green", 107, 0.000, 0.561, 0.612),
    [108] = palette("Earth yellow", 108, 0.408, 0.361, 0.263),
    [110] = palette("Bright bluish violet", 110, 0.263, 0.330, 0.577),
    [111] = palette("Tr. Brown", 111, 0.750, 0.718, 0.695),
    [112] = palette("Medium bluish violet", 112, 0.408, 0.455, 0.675),
    [113] = palette("Tr. Medi. reddish violet", 113, 0.899, 0.679, 0.785),
    [115] = palette("Med. yellowish green", 115, 0.781, 0.824, 0.236),
    [116] = palette("Med. bluish green", 116, 0.334, 0.648, 0.687),
    [118] = palette("Light bluish green", 118, 0.718, 0.844, 0.836),
    [119] = palette("Br. yellowish green", 119, 0.644, 0.742, 0.279),
    [120] = palette("Lig. yellowish green", 120, 0.851, 0.895, 0.655),
    [121] = palette("Med. yellowish orange", 121, 0.906, 0.675, 0.346),
    [123] = palette("Br. reddish orange", 123, 0.828, 0.436, 0.299),
    [124] = palette("Bright reddish violet", 124, 0.573, 0.224, 0.471),
    [125] = palette("Light orange", 125, 0.918, 0.722, 0.573),
    [126] = palette("Tr. Bright bluish violet", 126, 0.648, 0.648, 0.797),
    [127] = palette("Gold", 127, 0.863, 0.738, 0.506),
    [128] = palette("Dark nougat", 128, 0.683, 0.479, 0.350),
    [131] = palette("Silver", 131, 0.612, 0.640, 0.659),
    [133] = palette("Neon orange", 133, 0.836, 0.451, 0.240),
    [134] = palette("Neon green", 134, 0.848, 0.867, 0.338),
    [135] = palette("Sand blue", 135, 0.455, 0.526, 0.616),
    [136] = palette("Sand violet", 136, 0.530, 0.487, 0.565),
    [137] = palette("Medium orange", 137, 0.879, 0.597, 0.393),
    [138] = palette("Sand yellow", 138, 0.585, 0.542, 0.451),
    [140] = palette("Earth blue", 140, 0.126, 0.228, 0.338),
    [141] = palette("Earth green", 141, 0.153, 0.275, 0.177),
    [143] = palette("Tr. Flu. Blue", 143, 0.812, 0.887, 0.969),
    [145] = palette("Sand blue metallic", 145, 0.475, 0.534, 0.632),
    [146] = palette("Sand violet metallic", 146, 0.585, 0.557, 0.640),
    [147] = palette("Sand yellow metallic", 147, 0.577, 0.530, 0.404),
    [148] = palette("Dark grey metallic", 148, 0.342, 0.346, 0.342),
    [149] = palette("Black metallic", 149, 0.087, 0.114, 0.197),
    [150] = palette("Light grey metallic", 150, 0.671, 0.679, 0.675),
    [151] = palette("Sand green", 151, 0.471, 0.565, 0.510),
    [153] = palette("Sand red", 153, 0.585, 0.475, 0.467),
    [154] = palette("Dark red", 154, 0.483, 0.181, 0.185),
    [157] = palette("Tr. Flu. Yellow", 157, 1.000, 0.965, 0.483),
    [158] = palette("Tr. Flu. Red", 158, 0.883, 0.644, 0.761),
    [168] = palette("Gun metallic", 168, 0.459, 0.424, 0.385),
    [176] = palette("Red flip/flop", 176, 0.593, 0.412, 0.357),
    [178] = palette("Yellow flip/flop", 178, 0.706, 0.518, 0.334),
    [179] = palette("Silver flip/flop", 179, 0.538, 0.530, 0.534),
    [180] = palette("Curry", 180, 0.844, 0.663, 0.295),
    [190] = palette("Fire Yellow", 190, 0.977, 0.840, 0.181),
    [191] = palette("Flame yellowish orange", 191, 0.910, 0.671, 0.177),
    [192] = palette("Reddish brown", 192, 0.412, 0.251, 0.157),
    [193] = palette("Flame reddish orange", 193, 0.812, 0.377, 0.142),
    [194] = palette("Medium stone grey", 194, 0.640, 0.636, 0.648),
    [195] = palette("Royal blue", 195, 0.275, 0.404, 0.644),
    [196] = palette("Dark Royal blue", 196, 0.138, 0.279, 0.546),
    [198] = palette("Bright reddish lilac", 198, 0.557, 0.259, 0.522),
    [199] = palette("Dark stone grey", 199, 0.389, 0.373, 0.385),
    [200] = palette("Lemon metalic", 200, 0.510, 0.542, 0.365),
    [208] = palette("Light stone grey", 208, 0.899, 0.895, 0.875),
    [209] = palette("Dark Curry", 209, 0.691, 0.557, 0.267),
    [210] = palette("Faded green", 210, 0.440, 0.585, 0.471),
    [211] = palette("Turquoise", 211, 0.475, 0.710, 0.710),
    [212] = palette("Light Royal blue", 212, 0.624, 0.765, 0.914),
    [213] = palette("Medium Royal blue", 213, 0.424, 0.506, 0.718),
    [216] = palette("Rust", 216, 0.565, 0.299, 0.165),
    [217] = palette("Brown", 217, 0.487, 0.361, 0.275),
    [218] = palette("Reddish lilac", 218, 0.589, 0.440, 0.624),
    [219] = palette("Lilac", 219, 0.420, 0.385, 0.608),
    [220] = palette("Light lilac", 220, 0.655, 0.663, 0.808),
    [221] = palette("Bright purple", 221, 0.804, 0.385, 0.597),
    [222] = palette("Light purple", 222, 0.895, 0.679, 0.785),
    [223] = palette("Light pink", 223, 0.863, 0.565, 0.585),
    [224] = palette("Light brick yellow", 224, 0.942, 0.836, 0.628),
    [225] = palette("Warm yellowish orange", 225, 0.922, 0.722, 0.499),
    [226] = palette("Cool yellow", 226, 0.993, 0.918, 0.553),
    [232] = palette("Dove blue", 232, 0.491, 0.734, 0.867),
    [268] = palette("Medium lilac", 268, 0.204, 0.169, 0.459),
    [301] = palette("Slime green", 301, 0.314, 0.428, 0.330),
    [302] = palette("Smoky grey", 302, 0.357, 0.365, 0.412),
    [303] = palette("Dark blue", 303, 0.000, 0.063, 0.691),
    [304] = palette("Parsley green", 304, 0.173, 0.397, 0.114),
    [305] = palette("Steel blue", 305, 0.322, 0.487, 0.683),
    [306] = palette("Storm blue", 306, 0.200, 0.346, 0.510),
    [307] = palette("Lapis", 307, 0.063, 0.165, 0.863),
    [308] = palette("Dark indigo", 308, 0.240, 0.083, 0.522),
    [309] = palette("Sea green", 309, 0.204, 0.557, 0.251),
    [310] = palette("Shamrock", 310, 0.357, 0.604, 0.299),
    [311] = palette("Fossil", 311, 0.624, 0.632, 0.675),
    [312] = palette("Mulberry", 312, 0.350, 0.134, 0.350),
    [313] = palette("Forest green", 313, 0.122, 0.502, 0.114),
    [314] = palette("Cadet blue", 314, 0.624, 0.679, 0.753),
    [315] = palette("Electric blue", 315, 0.036, 0.538, 0.812),
    [316] = palette("Eggplant", 316, 0.483, 0.000, 0.483),
    [317] = palette("Moss", 317, 0.487, 0.612, 0.420),
    [318] = palette("Artichoke", 318, 0.542, 0.671, 0.522),
    [319] = palette("Sage green", 319, 0.726, 0.769, 0.695),
    [320] = palette("Ghost grey", 320, 0.793, 0.797, 0.820),
    [321] = palette("Lilac", 321, 0.655, 0.369, 0.608),
    [322] = palette("Plum", 322, 0.483, 0.185, 0.483),
    [323] = palette("Olivine", 323, 0.581, 0.746, 0.506),
    [324] = palette("Laurel green", 324, 0.659, 0.742, 0.600),
    [325] = palette("Quill grey", 325, 0.875, 0.875, 0.871),
    [327] = palette("Crimson", 327, 0.593, 0.000, 0.000),
    [328] = palette("Mint", 328, 0.695, 0.899, 0.651),
    [329] = palette("Baby blue", 329, 0.597, 0.761, 0.859),
    [330] = palette("Carnation pink", 330, 1.000, 0.597, 0.863),
    [331] = palette("Persimmon", 331, 1.000, 0.350, 0.350),
    [332] = palette("Maroon", 332, 0.459, 0.000, 0.000),
    [333] = palette("Gold", 333, 0.938, 0.722, 0.220),
    [334] = palette("Daisy orange", 334, 0.973, 0.851, 0.428),
    [335] = palette("Pearl", 335, 0.906, 0.906, 0.926),
    [336] = palette("Fog", 336, 0.781, 0.832, 0.895),
    [337] = palette("Salmon", 337, 1.000, 0.581, 0.581),
    [338] = palette("Terra Cotta", 338, 0.746, 0.408, 0.385),
    [339] = palette("Cocoa", 339, 0.338, 0.142, 0.142),
    [340] = palette("Wheat", 340, 0.946, 0.906, 0.781),
    [341] = palette("Buttermilk", 341, 0.997, 0.953, 0.734),
    [342] = palette("Mauve", 342, 0.879, 0.699, 0.816),
    [343] = palette("Sunrise", 343, 0.832, 0.565, 0.742),
    [344] = palette("Tawny", 344, 0.589, 0.334, 0.334),
    [345] = palette("Rust", 345, 0.561, 0.299, 0.165),
    [346] = palette("Cashmere", 346, 0.828, 0.746, 0.589),
    [347] = palette("Khaki", 347, 0.887, 0.863, 0.738),
    [348] = palette("Lily white", 348, 0.930, 0.918, 0.918),
    [349] = palette("Seashell", 349, 0.914, 0.855, 0.855),
    [350] = palette("Burgundy", 350, 0.534, 0.244, 0.244),
    [351] = palette("Cork", 351, 0.738, 0.608, 0.365),
    [352] = palette("Burlap", 352, 0.781, 0.675, 0.471),
    [353] = palette("Beige", 353, 0.793, 0.750, 0.640),
    [354] = palette("Oyster", 354, 0.734, 0.702, 0.699),
    [355] = palette("Pine Cone", 355, 0.424, 0.346, 0.295),
    [356] = palette("Fawn brown", 356, 0.628, 0.518, 0.310),
    [357] = palette("Hurricane grey", 357, 0.585, 0.538, 0.534),
    [358] = palette("Cloudy grey", 358, 0.671, 0.659, 0.620),
    [359] = palette("Linen", 359, 0.687, 0.581, 0.514),
    [360] = palette("Copper", 360, 0.589, 0.404, 0.400),
    [361] = palette("Medium brown", 361, 0.338, 0.259, 0.212),
    [362] = palette("Bronze", 362, 0.495, 0.408, 0.248),
    [363] = palette("Flint", 363, 0.412, 0.400, 0.361),
    [364] = palette("Dark taupe", 364, 0.353, 0.299, 0.259),
    [365] = palette("Burnt Sienna", 365, 0.416, 0.224, 0.036),
    [1001] = palette("Institutional white", 1001, 0.973, 0.973, 0.973),
    [1002] = palette("Mid gray", 1002, 0.804, 0.804, 0.804),
    [1003] = palette("Really black", 1003, 0.067, 0.067, 0.067),
    [1004] = palette("Really red", 1004, 1.000, 0.000, 0.000),
    [1005] = palette("Deep orange", 1005, 1.000, 0.691, 0.000),
    [1006] = palette("Alder", 1006, 0.706, 0.502, 1.000),
    [1007] = palette("Dusty Rose", 1007, 0.640, 0.295, 0.295),
    [1008] = palette("Olive", 1008, 0.757, 0.746, 0.259),
    [1009] = palette("New Yeller", 1009, 1.000, 1.000, 0.000),
    [1010] = palette("Really blue", 1010, 0.000, 0.000, 1.000),
    [1011] = palette("Navy blue", 1011, 0.000, 0.126, 0.377),
    [1012] = palette("Deep blue", 1012, 0.130, 0.330, 0.726),
    [1013] = palette("Cyan", 1013, 0.016, 0.687, 0.926),
    [1014] = palette("CGA brown", 1014, 0.667, 0.334, 0.000),
    [1015] = palette("Magenta", 1015, 0.667, 0.000, 0.667),
    [1016] = palette("Pink", 1016, 1.000, 0.400, 0.800),
    [1017] = palette("Deep orange", 1017, 1.000, 0.687, 0.000),
    [1018] = palette("Teal", 1018, 0.071, 0.934, 0.832),
    [1019] = palette("Toothpaste", 1019, 0.000, 1.000, 1.000),
    [1020] = palette("Lime green", 1020, 0.000, 1.000, 0.000),
    [1021] = palette("Camo", 1021, 0.228, 0.491, 0.083),
    [1022] = palette("Grime", 1022, 0.499, 0.557, 0.393),
    [1023] = palette("Lavender", 1023, 0.550, 0.357, 0.624),
    [1024] = palette("Pastel light blue", 1024, 0.687, 0.867, 1.000),
    [1025] = palette("Pastel orange", 1025, 1.000, 0.789, 0.789),
    [1026] = palette("Pastel violet", 1026, 0.695, 0.655, 1.000),
    [1027] = palette("Pastel blue-green", 1027, 0.624, 0.953, 0.914),
    [1028] = palette("Pastel green", 1028, 0.800, 1.000, 0.800),
    [1029] = palette("Pastel yellow", 1029, 1.000, 1.000, 0.800),
    [1030] = palette("Pastel brown", 1030, 1.000, 0.800, 0.600),
    [1031] = palette("Royal purple", 1031, 0.385, 0.146, 0.820),
    [1032] = palette("Hot pink", 1032, 1.000, 0.000, 0.750),
}

local IndexesArray = table.create(208); do
    local index_count = 0;
    for i, p in Palette do
        index_count += 1;
        table.insert(IndexesArray, i);
        p.ArrayId = index_count;
    end
end

local function paletteSearch(r: number, g: number, b: number): number
    local closest_palette: PaletteColor? = nil;
    local find_vector = vector.create(r, g, b)
    for _, palette in Palette do
        if (not closest_palette) then
            closest_palette = palette;
            continue;
        end
        -- TODO: Fix types
        local palette_vector: any = vector.create(palette.r, palette.g, palette.b);
        local closest_palette_vector: any = vector.create(closest_palette.r, closest_palette.g, closest_palette.b);
        local diff_palette = vector.magnitude(find_vector - palette_vector);
        local diff_closest = vector.magnitude(find_vector - closest_palette_vector);
        if (diff_palette < diff_closest) then
            closest_palette = palette;
        end
    end
    assert(closest_palette, "Internal Palette Error");
    return closest_palette.Number;
end

function BrickColor.new(...): BrickColor
    local count = select("#", ...);
    if (count == 0) then
        return BrickColor.palette(1003);
    elseif (count == 1) then
        local value = ...;
        if (Color3.Is(value)) then
            return BrickColor.palette(paletteSearch(value.R, value.G, value.B));
        elseif (type(value) == "number") then
            return BrickColor.palette(value);
        elseif (type(value) == "string") then
            local palette = nil;
            for _, p in Palette do
                if (p.Name == value) then
                    palette = p;
                    break;
                end
            end
            assert(palette, `Unknown palette name: {value}`);
            return BrickColor.palette(palette.Number);
        else
            error("Invalid argument type: ".. type(value));
        end
    elseif (count == 3) then
        local r, g, b = ...;
        assert(type(r) == "number", `Invalid argument type: {type(r)}`);
        assert(type(g) == "number", `Invalid argument type: {type(g)}`);
        assert(type(b) == "number", `Invalid argument type: {type(b)}`);
        return BrickColor.palette(paletteSearch(r, g, b));
    end
    error("No matching 'BrickColor' constructor");
end

local CACHE = setmetatable({}, {__mode = "k"});

function BrickColor.palette(paletteValue: number): BrickColor
    local cached = CACHE[paletteValue];
    if (cached) then
        return cached;
    end
    local palette = Palette[paletteValue];
    if (not palette) then
        return BrickColor.palette(194);
    end
    local self = setmetatable({
        Name = palette.Name,
        Number = palette.Number,
        r = palette.r,
        g = palette.g,
        b = palette.b,
        Color = Color3.DataType.new(palette.r, palette.g, palette.b),
        _ArrayId = palette.ArrayId,
    }, BrickColor);
    CACHE[paletteValue] = self;
    return self;
end

function BrickColor.random(): BrickColor
    local index = math.random(1, #IndexesArray);
    return BrickColor.palette(IndexesArray[index]);
end

function BrickColor.White(): BrickColor
    return BrickColor.palette(1);
end
function BrickColor.Gray(): BrickColor
    return BrickColor.palette(194);
end
function BrickColor.DarkGray(): BrickColor
    return BrickColor.palette(199);
end
function BrickColor.Black(): BrickColor
    return BrickColor.palette(26);
end
function BrickColor.Red(): BrickColor
    return BrickColor.palette(21);
end
function BrickColor.Yellow(): BrickColor
    return BrickColor.palette(24);
end
function BrickColor.Green(): BrickColor
    return BrickColor.palette(37);
end
function BrickColor.Blue(): BrickColor
    return BrickColor.palette(23);
end

export type BrickColor = typeof(BrickColor.new());

BrickColor.__tostring = function(self: BrickColor): string
    return self.Name;
end

local function Serialize(value: BrickColor): number
    return value.Number;
end

local function Deserialize(index: number): BrickColor
    return BrickColor.palette(index);
end

return {
    DataType = BrickColor,
    Serialize = Serialize,
    Deserialize = Deserialize,
    Is = isFn,
};
