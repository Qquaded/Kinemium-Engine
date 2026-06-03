--!strict

-- DOMProperty
local polyfill = require("@polyfill");
local Stream = polyfill.stream;
local Sink = polyfill.sink;
local datatypes = require("../../datatypes");

type IoReadable = polyfill.IoReadable;

local function size(t: {[any]: any}): number
    local c = 0;
    for _ in t do
        c += 1;
    end
    return c;
end

local function validateAttributeKey(key: string): boolean
    return (key:find("[^%w_-]+")) == nil;
end

local VARIENTS = {
    Unknown = 0,
    String = 2,
    Bool = 3,
    Int = 4,
    Float = 5,
    Double = 6,
    UDim = 9,
    UDim2 = 10,
    BrickColor = 14,
    Color3 = 15,
    Vector2 = 16,
    Vector3 = 17,
    CFrame = 19,
    Enum = 21,
    NumberSequence = 23,
    ColorSequence = 25,
    NumberRange = 27,
    Rect = 28,
    Font = 33,
}

local MatricesMap = {
    [0x02] = {
        1, 0, 0,
        0, 1, 0,
        0, 0, 1,
    },
    [0x03] = {
        1, 0, 0,
        0, 0, -1,
        0, 1, 0,
    },
    [0x05] = {
        1, 0,  0,
        0, -1, 0,
        0, 0,  -1,
    },
    [0x06] = {
        1, 0,  0,
        0, 0,  1,
        0, -1, 0,
    },
    [0x07] = {
        0, 1, 0,
        1, 0, 0,
        0, 0, -1,
    },
    [0x09] = {
        0, 0, 1,
        1, 0, 0,
        0, 1, 0,
    },
    [0x0a] = {
        0, -1, 0,
        1, 0,  0,
        0, 0,  1,
    },
    [0x0c] = {
        0, 0,  -1,
        1, 0,  0,
        0, -1, 0,
    },
    [0x0d] = {
        0, 1, 0,
        0, 0, 1,
        1, 0, 0,
    },
    [0x0e] = {
        0, 0, -1,
        0, 1, 0,
        1, 0, 0,
    },
    [0x10] = {
        0, -1, 0,
        0, 0,  -1,
        1, 0,  0,
    },
    [0x11] = {
        0, 0,  1,
        0, -1, 0,
        1, 0,  0,
    },
    [0x14] = {
        -1, 0, 0,
        0,  1, 0,
        0,  0, -1,
    },
    [0x15] = {
        -1, 0, 0,
        0,  0, 1,
        0,  1, 0,
    },
    [0x17] = {
        -1, 0,  0,
        0,  -1, 0,
        0,  0,  1,
    },
    [0x18] = {
        -1, 0,  0,
        0,  0,  -1,
        0,  -1, 0,
    },
    [0x19] = {
        0,  1, 0,
        -1, 0, 0,
        0,  0, 1,
    },
    [0x1b] = {
        0,  0, 1,
        -1, 0, 0,
        0,  1, 0,
    },
    [0x1c] = {
        0,  -1, 0,
        -1, 0,  0,
        0,  0,  -1,
    },
    [0x1e] = {
        0,  0,  -1,
        -1, 0,  0,
        0,  -1, 0,
    },
    [0x1f] = {
        0,  1, 0,
        0,  0, -1,
        -1, 0, 0,
    },
    [0x20] = {
        0,  0, 1,
        0,  1, 0,
        -1, 0, 0,
    },
    [0x22] = {
        0,  -1, 0,
        0,  0,  1,
        -1, 0,  0,
    },
    [0x23] = {
        0,  0,  -1,
        0,  -1, 0,
        -1, 0,  0,
    },
}

local TYPE_DECODER = {
    [VARIENTS.Unknown] = function(reader: IoReadable): any
        error("Unknown Property Type not supported.")
    end,
    [VARIENTS.String] = function(reader: IoReadable): any
        return reader:read(reader:readu32(), false);
    end,
    [VARIENTS.Bool] = function(reader: IoReadable): any
        return reader:readu8() ~= 0;
    end,
    [VARIENTS.Int] = function(reader: IoReadable): any
        return reader:readi32();
    end,
    [VARIENTS.Float] = function(reader: IoReadable): any
        return reader:readf32();
    end,
    [VARIENTS.Double] = function(reader: IoReadable): any
        return reader:readf64();
    end,
    [VARIENTS.UDim] = function(reader: IoReadable): any
        return datatypes.UDim.Deserialize(reader:readf32(), reader:readi32());
    end,
    [VARIENTS.UDim2] = function(reader: IoReadable): any
        return datatypes.UDim2.Deserialize(reader:readf32(), reader:readi32(), reader:readf32(), reader:readi32());
    end,
    [VARIENTS.BrickColor] = function(reader: IoReadable): any
        return datatypes.BrickColor.Deserialize(reader:readu32());
    end,
    [VARIENTS.Color3] = function(reader: IoReadable): any
        return datatypes.Color3.Deserialize(reader:readf32(), reader:readf32(), reader:readf32(), false);
    end,
    [VARIENTS.Vector2] = function(reader: IoReadable): any
        return datatypes.Vector2.Deserialize(reader:readf32(), reader:readf32());
    end,
    [VARIENTS.Vector3] = function(reader: IoReadable): any
        return datatypes.Vector3.Deserialize(reader:readf32(), reader:readf32(), reader:readf32());
    end,
    [VARIENTS.CFrame] = function(reader: IoReadable): any
        local x = reader:readf32();
        local y = reader:readf32();
        local z = reader:readf32();
        local orient_id = reader:readu8();
        local rotation;
        if (orient_id > 0) then
            rotation = MatricesMap[orient_id] or error("Unknown CFrame Rotation Id");
        else
            rotation = {
                reader:readf32(), reader:readf32(), reader:readf32(),
                reader:readf32(), reader:readf32(), reader:readf32(),
                reader:readf32(), reader:readf32(), reader:readf32(),
            };
        end
        return datatypes.CFrame.Deserialize(x, y, z, unpack(rotation));
    end,
    [VARIENTS.Enum] = function(reader: IoReadable): any
        local enum_type = reader:read(reader:readu32(), false);
        local value = reader:readu32();
        local enum = datatypes.Enums.DataType[enum_type];
        if (not enum) then
            error(`Unknown Enum type: '{enum_type}'`);
        end
        local items = enum:GetEnumItems();
        return (assert(items[value], `Invalid EnumArrayId: {value} ({enum_type})`));
    end,
    [VARIENTS.ColorSequence] = function(reader: IoReadable): any
        local keys = reader:readu32();
        local points = table.create(keys);
        for j = 1, keys do
            local envelope = reader:readf32();
            local time = reader:readf32();
            local r = reader:readf32();
            local g = reader:readf32();
            local b = reader:readf32();
            points[j] = datatypes.ColorSequenceKeypoint.Deserialize(
                time, datatypes.Color3.Deserialize(r, g, b, false), envelope
            );
        end
        return datatypes.ColorSequence.Deserialize(points);
    end,
    [VARIENTS.NumberRange] = function(reader: IoReadable): any
        return datatypes.NumberRange.Deserialize(reader:readf32(), reader:readf32());
    end,
    [VARIENTS.Rect] = function(reader: IoReadable): any
        return datatypes.Rect.Deserialize(
            reader:readf32(),
            reader:readf32(),
            reader:readf32(),
            reader:readf32()
        );
    end,
    [VARIENTS.NumberSequence] = function(reader: IoReadable): any
        local keys = reader:readu32();
        local points = table.create(keys);
        for j = 1, keys do
            local time = reader:readf32();
            local value = reader:readf32();
            local envelope = reader:readf32();
            points[j] = datatypes.NumberSequenceKeypoint.Deserialize(
                time, value, envelope
            );
        end
        return datatypes.NumberSequence.Deserialize(points);
    end,
    [VARIENTS.Font] = function(reader: IoReadable): any
        local weight = reader:readu16();
        local style = reader:readu8();
        local family = reader:read(reader:readu32(), false);
        local cache_id = reader:read(reader:readu32(), false);
        return datatypes.Font.Deserialize(family, weight, style, cache_id);
    end,
};

local TYPE_ENCODER = {
    [VARIENTS.Unknown] = function(writer: polyfill.IoWritable, value: any): ()
        error("Unknown Property Type not supported.")
    end,
    [VARIENTS.String] = function(writer: polyfill.IoWritable, value: string): ()
        writer:writeu32(#value);
        writer:write(value);
    end,
    [VARIENTS.Bool] = function(writer: polyfill.IoWritable, value: boolean): ()
        writer:writeu8(if (value) then 1 else 0);
    end,
    [VARIENTS.Int] = function(writer: polyfill.IoWritable, value: number): ()
        writer:writei32(value);
    end,
    [VARIENTS.Float] = function(writer: polyfill.IoWritable, value: number): ()
        writer:writef32(value);
    end,
    [VARIENTS.Double] = function(writer: polyfill.IoWritable, value: number): ()
        writer:writef64(value);
    end,
    [VARIENTS.UDim] = function(writer: polyfill.IoWritable, value: datatypes.UDim): ()
        local scale, offset = datatypes.UDim.Serialize(value);
        writer:writef32(scale);
        writer:writei32(offset);
    end,
    [VARIENTS.UDim2] = function(writer: polyfill.IoWritable, value: datatypes.UDim2): ()
        local x_scale, x_offset, y_scale, y_offset = datatypes.UDim2.Serialize(value);
        writer:writef32(x_scale);
        writer:writei32(x_offset);
        writer:writef32(y_scale);
        writer:writei32(y_offset);
    end,
    [VARIENTS.BrickColor] = function(writer: polyfill.IoWritable, value: datatypes.BrickColor): ()
        writer:writeu32(datatypes.BrickColor.Serialize(value));
    end,
    [VARIENTS.Color3] = function(writer: polyfill.IoWritable, value: datatypes.Color3): ()
        local r, g, b = datatypes.Color3.Serialize(value, false);
        writer:writef32(r);
        writer:writef32(g);
        writer:writef32(b);
    end,
    [VARIENTS.Vector2] = function(writer: polyfill.IoWritable, value: datatypes.Vector2): ()
        local x, y = datatypes.Vector2.Serialize(value);
        writer:writef32(x);
        writer:writef32(y);
    end,
    [VARIENTS.Vector3] = function(writer: polyfill.IoWritable, value: datatypes.Vector3): ()
        local x, y, z = datatypes.Vector3.Serialize(value);
        writer:writef32(x);
        writer:writef32(y);
        writer:writef32(z);
    end,
    [VARIENTS.CFrame] = function(writer: polyfill.IoWritable, value: datatypes.CFrame): ()
        local x, y, z, r00, r01, r02, r10, r11, r12, r20, r21, r22 = datatypes.CFrame.Serialize(value);
        writer:writef32(x);
        writer:writef32(y);
        writer:writef32(z);

        -- TODO: Implement CFrame Rotation Id
        writer:writeu8(0);

        writer:writef32(r00); writer:writef32(r01); writer:writef32(r02);
        writer:writef32(r10); writer:writef32(r11); writer:writef32(r12);
        writer:writef32(r20); writer:writef32(r21); writer:writef32(r22);
    end,
    [VARIENTS.Enum] = function(writer: polyfill.IoWritable, value: datatypes.EnumItem): ()
        writer:writeu32(#value.EnumType["@name"]);
        writer:write(value.EnumType["@name"]);
        writer:writeu32(value.Value);
    end,
    [VARIENTS.ColorSequence] = function(writer: polyfill.IoWritable, value: datatypes.ColorSequence): ()
        local points = datatypes.ColorSequence.Serialize(value);
        -- stream:expandToSize(stream.position + (#points * 20) + 4) -- preallocate
        writer:writeu32(#points);
        for _, point in points do
            local time, color, envelope = datatypes.ColorSequenceKeypoint.Serialize(point);
            local r, g, b = datatypes.Color3.Serialize(color, false);
            writer:writef32(envelope);
            writer:writef32(time);
            writer:writef32(r);
            writer:writef32(g);
            writer:writef32(b);
        end
    end,
    [VARIENTS.NumberRange] = function(writer: polyfill.IoWritable, value: datatypes.NumberRange): ()
        local min, max = datatypes.NumberRange.Serialize(value);
        writer:writef32(min);
        writer:writef32(max);
    end,
    [VARIENTS.Rect] = function(writer: polyfill.IoWritable, value: datatypes.Rect): ()
        local x0, y0, x1, y1 = datatypes.Rect.Serialize(value);
        writer:writef32(x0);
        writer:writef32(y0);
        writer:writef32(x1);
        writer:writef32(y1);
    end,
    [VARIENTS.NumberSequence] = function(writer: polyfill.IoWritable, value: datatypes.NumberSequence): ()
        local points = datatypes.NumberSequence.Serialize(value);
        -- writer:expandToSize(stream.position + (#points * 12) + 4) -- preallocate
        writer:writeu32(#points);
        for _, point in points do
            local time, nvalue, envelope = datatypes.NumberSequenceKeypoint.Serialize(point);
            writer:writef32(time);
            writer:writef32(nvalue);
            writer:writef32(envelope);
        end
    end,
    [VARIENTS.Font] = function(writer: polyfill.IoWritable, value: datatypes.Font): ()
        local family, weight, style, cache_id = datatypes.Font.Serialize(value);
        writer:writeu16(weight);
        writer:writeu8(style);
        writer:writeu32(#family);
        writer:write(family);
        if (cache_id) then
            writer:writeu32(#cache_id);
            writer:write(cache_id);
        else
            writer:writeu32(0);
        end
    end,
};

local function decodeAttributes(value: string): {[string]: any}
    local stream = Stream.create(buffer.fromstring(value));
    if (not stream:canRead(4)) then
        return {};
    end
    local reader = stream:reader();
    local len = reader:readu32();
    local attributes = {};
    for i = 1, len do
        local key = reader:read(reader:readu32(), false);
        if (not validateAttributeKey(key)) then
            error(`Attribute Name: "{key}" contains illegal characters`);
        end
        local type_id = reader:readu8();
        local decoder = TYPE_DECODER[type_id];
        if (not decoder) then
            error(`Unknown Attribute Value Type: ({type_id}) for key '{key}'`);
        end
        attributes[key] = {
            type = type_id,
            value = decoder(reader),
        };
    end
    return attributes;
end

local function encodeAttributes(attributes: {[string]: any}): string
    local stream = Sink.create(4);
    local writer = stream:writer();
    writer:writeu32(size(attributes));
    for key, value in attributes do
        writer:writeu32(#key);
        writer:write(key);
        writer:writeu8(value.type);
        local encoder = TYPE_ENCODER[value.type];
        if (not encoder) then
            error(`Failed to Encode Attribute Value Type: ({value.type}) for key '{key}'`);
        end
        encoder(writer, value.value);
    end
    return stream:flush(false) :: string;
end

local DATATYPE_MAP: {[any]: number} = {
    [datatypes.UDim.DataType] = VARIENTS.UDim,
    [datatypes.UDim2.DataType] = VARIENTS.UDim2,
    [datatypes.BrickColor.DataType] = VARIENTS.BrickColor,
    [datatypes.Color3.DataType] = VARIENTS.Color3,
    [datatypes.Vector2.DataType] = VARIENTS.Vector2,
    [datatypes.Vector3.DataType] = VARIENTS.Vector3,
    [datatypes.CFrame.DataType] = VARIENTS.CFrame,
    [datatypes.EnumItem.DataType] = VARIENTS.Enum,
    [datatypes.NumberSequence.DataType] = VARIENTS.NumberSequence,
    [datatypes.ColorSequence.DataType] = VARIENTS.ColorSequence,
    [datatypes.NumberRange.DataType] = VARIENTS.NumberRange,
    [datatypes.Rect.DataType] = VARIENTS.Rect,
    [datatypes.Font.DataType] = VARIENTS.Font,
};

local function getTypeIdOf(value: any): number
    if (typeof(value) == "string") then
        return VARIENTS.String;
    elseif (typeof(value) == "boolean") then
        return VARIENTS.Bool;
    elseif (typeof(value) == "number") then
        local min, max = -3.402823e+38, 3.402823e+38;
        if (value >= min and value <= max) then
            return VARIENTS.Float;
        end
        return VARIENTS.Double;
    elseif (typeof(value) == "table" or typeof(value) == "userdata") then
        local type_id = DATATYPE_MAP[getmetatable(value)];
        if (type_id) then
            return type_id;
        end
    end
    error(`Unknown Attribute Value Type: ({typeof(value)})`);
end

return {
    getTypeIdOf = getTypeIdOf,
    decodeAttributes = decodeAttributes,
    validateAttributeKey = validateAttributeKey,
    encodeAttributes = encodeAttributes,
}
