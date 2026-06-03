--!strict
local polyfill = require("@polyfill");
local mem = polyfill.mem;
local lz4 = polyfill.lz4;
local zlib = polyfill.zlib;
local zstd = polyfill.zstd;
local base64 = polyfill.base64;
local blake2 = polyfill.blake2;
local sink = polyfill.sink;
local stream = polyfill.stream;

local ansi = require("./lib/ansi");
local int64 = require("./lib/int64");

local roblox = require("./roblox");
local datatypes = require("../datatypes");
local reflection = require("../reflection");

local BinaryMagicHeader = "<roblox!\x89\xff\x0d\x0a\x1a\x0a";

local style = ansi.style;
local reset = ansi.reset;

local SER_TAG = `[dom{style("dim")}::{ansi.color("yellow")}serialize{reset()}]`;
local DES_TAG = `[dom{style("dim")}::{ansi.color("green")}deserialize{reset()}]`;

local log = function(...)
end;

local BinaryChunkType = {
    INST = 0,
    PROP = 1,
    PRNT = 2,
    META = 3,
    SSTR = 4,
    SIGN = 5,
    END = 6,
};

local BinaryChunkTypeMap = {
    ["INST"] = BinaryChunkType.INST,
    ["PROP"] = BinaryChunkType.PROP,
    ["PRNT"] = BinaryChunkType.PRNT,
    ["META"] = BinaryChunkType.META,
    ["SSTR"] = BinaryChunkType.SSTR,
    ["SIGN"] = BinaryChunkType.SIGN,
    ["END\0"] = BinaryChunkType.END,
}

local RobloxPropertyType = roblox.PropertyTypes;

type Instance = roblox.Instance;
type Document = roblox.Document;
type Signature = roblox.Signature;
type Property = roblox.Property;
type DocumentInfo = roblox.DocumentInfo;

export type ChunkInfo = {
    type: number,
    data: buffer,
    reserved: number,
    size: number,
    id: number,
};

local BinaryChunkTypeNameMap = {}
for name: string, value: number in BinaryChunkTypeMap::{[string]: number} do
    BinaryChunkTypeNameMap[value] = name;
end

local RobloxPropertyTypeNameMap = {}
for name: string, value: number in RobloxPropertyType::{[string]: number} do
    RobloxPropertyTypeNameMap[value] = name;
end

local function getBinaryChunkTypeName(type: number): string
    return (assert(BinaryChunkTypeNameMap[type], "Unknown chunk type"));
end

local function getPropertyTypeName(type: number): string
    return (assert(RobloxPropertyTypeNameMap[type], "Unknown property type"));
end

local function color(name: string, string)
    return `{ansi.color(name::any)}{string}{reset()}`;
end

local function rotatei32(b: buffer): number
    mem.reverse(b, 0, 4);
    local value = buffer.readi32(b, 0);
    value = bit32.bxor(bit32.rshift(value, 1), -bit32.band(value, 1));
    buffer.writeu32(b, 0, value);
    return buffer.readi32(b, 0);
end

local function tou32(b: buffer): number
    mem.reverse(b, 0, 4);
    return buffer.readu32(b, 0);
end

local function rotatei64(b: buffer): buffer
    mem.reverse(b, 0, 8);

    local n = int64.from_buffer(b, 0);

    local value = int64.bxor(int64.rshift(n, 1), int64.sub(vector.zero, int64.band(n, int64.from_u32(1))))

    local high, low = int64.to_pair(value);

    buffer.writeu32(b, 0, high);
    buffer.writeu32(b, 4, low);

    return b;
end

local function tou64(b: buffer): buffer
    mem.reverse(b, 0, 8);
    return b;
end

local function rotatef32(b: buffer): number
    mem.reverse(b, 0, 4);
    local value = buffer.readu32(b, 0);
    buffer.writeu32(b, 0, bit32.bor(bit32.rshift(value, 1), bit32.lshift(value, 31)));
    return buffer.readf32(b, 0);
end

local function ReadInterleaved<T>(b: buffer, offset: number, count: number, size: number, transform: (b: buffer) -> T): {T}
    if (buffer.len(b) - offset < count * size) then
        error("Too small");
    end
    local list = table.create(count);
    local bytes = buffer.create(size);
    for i = 1, count do
        for j = 0, size - 1 do
            buffer.writeu8(bytes, j, buffer.readu8(b, offset + ((j * count) + i - 1)))
        end
        list[i] = transform(bytes);
    end
    return list;
end

local function WriteInterleaved<T>(values: {T}, size: number, transform: (buffer, number, T) -> ()): buffer
    local count = #values;
    local b = buffer.create(count * size);
    local count_m1 = count - 1;
    for i = 0, count_m1 do
        transform(b, i * size, values[i + 1]);
    end
    if (count == 1) then
        return b;
    end

    local interleaved = buffer.create(count * size);

    local iter = 0;
    for i = 0, size - 1 do
        for c = 0, count_m1 do
            buffer.writeu8(interleaved, iter, buffer.readu8(b, (c * size) + i))
            iter += 1;
        end
    end
    return interleaved;
end

local function ReadInterleavedi32(stream: polyfill.IoReadable, count: number): {number}
    return ReadInterleaved(stream:read(count * 4) :: buffer, 0, count, 4, rotatei32);
end
local function ReadInterleavedu32(stream: polyfill.IoReadable, count: number): {number}
    return ReadInterleaved(stream:read(count * 4) :: buffer, 0, count, 4, tou32);
end

local function ReadInterleavedi64(stream: polyfill.IoReadable, count: number): {buffer}
    return ReadInterleaved(stream:read(count * 8) :: buffer, 0, count, 8, rotatei64);
end
local function ReadInterleavedu64(stream: polyfill.IoReadable, count: number): {buffer}
    return ReadInterleaved(stream:read(count * 8) :: buffer, 0, count, 8, tou64);
end

local function ReadInterleavedf32(stream: polyfill.IoReadable, count: number): {number}
    return ReadInterleaved(stream:read(count * 4) :: buffer, 0, count, 4, rotatef32);
end

local function ReadInstances(stream: polyfill.IoReadable, count: number): {number}
    local values = ReadInterleavedi32(stream, count);
    for i = 2, count do
        values[i] += values[i - 1];
    end
    for i = 1, count do
        values[i] += 1;
    end
    return values;
end

local function writeRotatei32(b: buffer, offset: number, value: number): ()
    buffer.writei32(b, offset, bit32.bxor(bit32.lshift(value, 1), bit32.arshift(value, 31)));
    mem.reverse(b, offset, 4);
end

local function writeu32(b: buffer, offset: number, value: number): ()
    buffer.writeu32(b, offset, value);
    mem.reverse(b, offset, 4);
end

local function writeRotatei64(b: buffer, offset: number, value: buffer): ()
    local n = int64.from_buffer(value, 0);
    local v = int64.bxor(int64.lshift(n, 1), int64.rshift(n, 63));

    local high, low = int64.to_pair(v);

    buffer.writei32(b, 0, high);
    buffer.writei32(b, 4, low);

    mem.reverse(b, offset, 8);
end
local function writeu64(b: buffer, offset: number, value: buffer): ()
    mem.reverse(b, offset, 8);
end

local function writeRotatef32(b: buffer, offset: number, value: number): ()
    buffer.writef32(b, offset, value);
    local v = buffer.readu32(b, offset);
    buffer.writeu32(b, offset, bit32.bor(bit32.lshift(v, 1), bit32.rshift(v, 31)));
    mem.reverse(b, offset, 4);
end

local function WriteInterleavedi32(values: {number}): buffer
    return WriteInterleaved(values, 4, writeRotatei32);
end
local function WriteInterleavedu32(values: {number}): buffer
    return WriteInterleaved(values, 4, writeu32);
end

local function WriteInterleavedi64(values: {buffer}): buffer
    return WriteInterleaved(values, 8, writeRotatei64);
end
local function WriteInterleavedu64(values: {buffer}): buffer
    return WriteInterleaved(values, 8, writeu64);
end
local function WriteInterleavedf32(values: {number}): buffer
    return WriteInterleaved(values, 4, writeRotatef32);
end

local function WriteInstances(values: {number}): buffer
    local copy = table.clone(values);
    for i = 1, #values do
        copy[i] -= 1;
    end
    for i = 2, #values do
        copy[i] -= values[i - 1] - 1;
    end
    return WriteInterleavedi32(copy);
end

local function size(t: {[any]: any}): number
    local c = 0;
    for _, _ in t do
        c += 1;
    end
    return c;
end

local function writeChunk(
    stream: polyfill.IoWritable,
    handle: (stream: polyfill.IoWritable) -> boolean
): ()
    local chunk_stream = sink.create(4);
    local compressed = handle(chunk_stream:writer());

    local bytes = chunk_stream:flush(true) :: buffer;

    local size = buffer.len(bytes);
    local data = if (compressed) then
        lz4.compress(bytes)
    else
        bytes;

    stream:writeu32(if (compressed) then buffer.len(data) else 0);
    stream:writeu32(size);
    stream:writeu32(0);
    stream:write(data);
end

local function propertiesToValues(values: {Property}): {any}
    local list = table.create(#values);
    for i, value in values do
        list[i] = value.value;
    end
    return list;
end

local function cframeSerializer(type: number, values: {Property}, stream: polyfill.IoWritable)
    local len = #values;
    if (type == RobloxPropertyType.OptionalCFrame) then
        stream:writeu8(RobloxPropertyType.CFrame);
    end

    local xs = table.create(len);
    local ys = table.create(len);
    local zs = table.create(len);

    for i, value in values do
        local x, y, z, r00, r01, r02, r10, r11, r12, r20, r21, r22;
        if (value.value) then
            x, y, z, r00, r01, r02, r10, r11, r12, r20, r21, r22 = datatypes.CFrame.Serialize(value.value);
        else
            x, y, z, r00, r01, r02, r10, r11, r12, r20, r21, r22 = 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0;
        end
        xs[i] = x;
        ys[i] = y;
        zs[i] = z;

        stream:writeu8(0);

        if (type == RobloxPropertyType.Quaternion) then
            local qt = (r00 + r11 + r22);
            if (qt > 0) then
                local s = math.sqrt(qt + 1);
                local r = 0.5 / s;

                stream:writef32((r21 - r12) * r);
                stream:writef32((r02 - r20) * r);
                stream:writef32((r10 - r01) * r);
                stream:writef32(s * 0.5);
            else
                local big = math.max(r00, r11, r22);
                if (big == r00) then
                    local s = math.sqrt(1 + r00 - r11 - r22);
                    local r = 0.5 / s;

                    stream:writef32(0.5 * s);
                    stream:writef32((r10 + r01) * r);
                    stream:writef32((r02 + r20) * r);
                    stream:writef32((r21 - r12) * r);
                elseif (big == r11) then
                    local s = math.sqrt(1 - r00 + r11 - r22);
                    local r = 0.5 / s;

                    stream:writef32((r10 + r01) * r);
                    stream:writef32(0.5 * s);
                    stream:writef32((r21 + r12) * r);
                    stream:writef32((r02 - r20) * r);
                elseif (big == r22) then
                    local s = math.sqrt(1 - r00 - r11 + r22);
                    local r = 0.5 / s;

                    stream:writef32((r02 + r20) * r);
                    stream:writef32((r21 + r12) * r);
                    stream:writef32(0.5 * s);
                    stream:writef32((r10 - r01) * r);
                end
            end
        else
            stream:writef32(r00);
            stream:writef32(r01);
            stream:writef32(r02);
            stream:writef32(r10);
            stream:writef32(r11);
            stream:writef32(r12);
            stream:writef32(r20);
            stream:writef32(r21);
            stream:writef32(r22);
        end
    end
    stream:write(WriteInterleavedf32(xs));
    stream:write(WriteInterleavedf32(ys));
    stream:write(WriteInterleavedf32(zs));

    if (type == RobloxPropertyType.OptionalCFrame) then
        stream:writeu8(RobloxPropertyType.Bool);
        for i, value in values do
            stream:writeu8(if (value.value) then 1 else 0);
        end
    end
end

local PropertySerializerMap = {
    [RobloxPropertyType.Unknown] = function(values: {Property}, stream: polyfill.IoWritable)
        error("Unknown Property Type not supported.")
    end,
    [RobloxPropertyType.String] = function(values: {Property}, stream: polyfill.IoWritable)
        for _, value in values do
            stream:writeu32(#value.value);
            stream:write(value.value);
        end
    end,
    [RobloxPropertyType.Bool] = function(values: {Property}, stream: polyfill.IoWritable)
        -- stream:expandToSize(stream.position + #values); -- preallocate
        for _, value in values do
            stream:writeu8(if (value.value) then 1 else 0);
        end
    end,
    [RobloxPropertyType.Int] = function(values: {Property}, stream: polyfill.IoWritable)
        stream:write(WriteInterleavedi32(propertiesToValues(values)));
    end,
    [RobloxPropertyType.Float] = function(values: {Property}, stream: polyfill.IoWritable)
        stream:write(WriteInterleavedf32(propertiesToValues(values)));
    end,
    [RobloxPropertyType.Double] = function(values: {Property}, stream: polyfill.IoWritable)
        -- stream:expandToSize(stream.position + (#values * 8)); -- preallocate
        for _, value in values do
            stream:writef64(value.value);
        end
    end,
    [RobloxPropertyType.UDim] = function(values: {Property}, stream: polyfill.IoWritable)
        local len = #values;
        local scales = table.create(len);
        local offsets = table.create(len);
        for i, value in values do
            local scale, offset = datatypes.UDim.Serialize(value.value);
            scales[i] = scale;
            offsets[i] = offset;
        end
        stream:write(WriteInterleavedf32(scales));
        stream:write(WriteInterleavedi32(offsets));
    end,
    [RobloxPropertyType.UDim2] = function(values: {Property}, stream: polyfill.IoWritable)
        local len = #values;
        local scales_x = table.create(len);
        local scales_y = table.create(len);
        local offsets_x = table.create(len);
        local offsets_y = table.create(len);
        for i, value in values do
            local scale_x, offset_x, scale_y, offset_y = datatypes.UDim2.Serialize(value.value);
            scales_x[i] = scale_x;
            offsets_x[i] = offset_x;
            scales_y[i] = scale_y;
            offsets_y[i] = offset_y;
        end
        stream:write(WriteInterleavedf32(scales_x));
        stream:write(WriteInterleavedf32(scales_y));
        stream:write(WriteInterleavedi32(offsets_x));
        stream:write(WriteInterleavedi32(offsets_y));
    end,
    [RobloxPropertyType.Ray] = function(values: {Property}, stream: polyfill.IoWritable)
        -- stream:expandToSize(stream.position + (#values * 24)); -- preallocate
        for i, value in values do
            local pos_x, pos_y, pos_z, dir_x, dir_y, dir_z = datatypes.Ray.Serialize(value.value);

            stream:writef32(pos_x);
            stream:writef32(pos_y);
            stream:writef32(pos_z);
            stream:writef32(dir_x);
            stream:writef32(dir_y);
            stream:writef32(dir_z);
        end
    end,
    [RobloxPropertyType.Faces] = function(values: {Property}, stream: polyfill.IoWritable)
        -- stream:expandToSize(stream.position + #values); -- preallocate
        for _, value in values do
            stream:writeu8(datatypes.Faces.Serialize(value.value));
        end
    end,
    [RobloxPropertyType.Axes] = function(values: {Property}, stream: polyfill.IoWritable)
        -- stream:expandToSize(stream.position + #values); -- preallocate
        for _, value in values do
            stream:writeu8(datatypes.Axes.Serialize(value.value));
        end
    end,
    [RobloxPropertyType.BrickColor] = function(values: {Property}, stream: polyfill.IoWritable)
        local list = table.create(#values);
        for i, value in values do
            list[i] = datatypes.BrickColor.Serialize(value.value);
        end
        stream:write(WriteInterleavedu32(list));
    end,
    [RobloxPropertyType.Color3] = function(values: {Property}, stream: polyfill.IoWritable)
        local len = #values;
        local rs = table.create(len);
        local gs = table.create(len);
        local bs = table.create(len);
        for i, value in values do
            rs[i], gs[i], bs[i] = datatypes.Color3.Serialize(value.value, false);
        end
        stream:write(WriteInterleavedf32(rs));
        stream:write(WriteInterleavedf32(gs));
        stream:write(WriteInterleavedf32(bs));
    end,
    [RobloxPropertyType.Vector2] = function(values: {Property}, stream: polyfill.IoWritable)
        local len = #values;
        local xs = table.create(len);
        local ys = table.create(len);
        for i, value in values do
            xs[i], ys[i] = datatypes.Vector2.Serialize(value.value);
        end
        stream:write(WriteInterleavedf32(xs));
        stream:write(WriteInterleavedf32(ys));
    end,
    [RobloxPropertyType.Vector3] = function(values: {Property}, stream: polyfill.IoWritable)
        local len = #values;
        local xs = table.create(len);
        local ys = table.create(len);
        local zs = table.create(len);
        for i, value in values do
            xs[i], ys[i], zs[i] = datatypes.Vector3.Serialize(value.value);
        end
        stream:write(WriteInterleavedf32(xs));
        stream:write(WriteInterleavedf32(ys));
        stream:write(WriteInterleavedf32(zs));
    end,
    [RobloxPropertyType.CFrame] = function(values: {Property}, stream: polyfill.IoWritable)
        cframeSerializer(RobloxPropertyType.CFrame, values, stream);
    end,
    [RobloxPropertyType.Quaternion] = function(values: {Property}, stream: polyfill.IoWritable)
        cframeSerializer(RobloxPropertyType.Quaternion, values, stream);
    end,
    [RobloxPropertyType.Enum] = function(values: {Property}, stream: polyfill.IoWritable)
        local list = table.create(#values);
        for i, value in values do
            list[i] =
                if (datatypes.EnumItem.Is(value.value)) then
                    value.value.Value
                else
                    value.value;
        end
        stream:write(WriteInterleavedu32(list));
    end,
    [RobloxPropertyType.Ref] = function(values: {Property}, stream: polyfill.IoWritable)
        local list = table.create(#values);
        for i, value in values do
            list[i] = if (value.value) then value.value else 0;
        end
        stream:write(WriteInstances(list));
    end,
    [RobloxPropertyType.Vector3int16] = function(values: {Property}, stream: polyfill.IoWritable)
        -- stream:expandToSize(stream.position + (#values * 6)); -- preallocate
        for i, value in values do
            local x, y, z = datatypes.Vector3int16.Serialize(value.value);

            stream:writei16(x);
            stream:writei16(y);
            stream:writei16(z);
        end
    end,
    [RobloxPropertyType.NumberSequence] = function(values: {Property}, stream: polyfill.IoWritable)
        -- stream:expandToSize(stream.position + (#values * 4)); -- preallocate (under-estimate)
        for i, value in values do
            local points = datatypes.NumberSequence.Serialize(value.value);
            stream:writeu32(#points);
            for _, point in points do
                local time, val, envelope = datatypes.NumberSequenceKeypoint.Serialize(point);

                stream:writef32(time);
                stream:writef32(val);
                stream:writef32(envelope);
            end
        end
    end,
    [RobloxPropertyType.ColorSequence] = function(values: {Property}, stream: polyfill.IoWritable)
        -- stream:expandToSize(stream.position + (#values * 4)); -- preallocate (under-estimate)
        for i, value in values do
            local points = datatypes.ColorSequence.Serialize(value.value);
            stream:writeu32(#points);
            for _, point in points do
                local time, color, envelope = datatypes.ColorSequenceKeypoint.Serialize(point);
                local r, g, b = datatypes.Color3.Serialize(color, false);
                stream:writef32(time);
                stream:writef32(r);
                stream:writef32(g);
                stream:writef32(b);
                stream:writef32(envelope);
            end
        end
    end,
    [RobloxPropertyType.NumberRange] = function(values: {Property}, stream: polyfill.IoWritable)
        -- stream:expandToSize(stream.position + (#values * 8)); -- preallocate
        for i, value in values do
            local min, max = datatypes.NumberRange.Serialize(value.value);
            stream:writef32(min);
            stream:writef32(max);
        end
    end,
    [RobloxPropertyType.Rect] = function(values: {Property}, stream: polyfill.IoWritable)
        local len = #values;
        local x0s = table.create(len);
        local y0s = table.create(len);
        local x1s = table.create(len);
        local y1s = table.create(len);
        for i = 1, len do
            x0s[i], y0s[i], x1s[i], y1s[i] = datatypes.Rect.Serialize(values[i].value);
        end
        stream:write(WriteInterleavedf32(x0s));
        stream:write(WriteInterleavedf32(y0s));
        stream:write(WriteInterleavedf32(x1s));
        stream:write(WriteInterleavedf32(y1s));
    end,
    [RobloxPropertyType.PhysicalProperties] = function(values: {Property}, stream: polyfill.IoWritable)
        -- stream:expandToSize(stream.position + #values); -- preallocate (under-estimate)
        for i, value in values do
            if (value.value) then
                local density, friction, elasticity, friction_weight, elasticity_weight, acoustic_absorption = datatypes.PhysicalProperties.Serialize(value.value);
                stream:writeu8(if (acoustic_absorption ~= 1) then 0b11 else 0b01);
                stream:writef32(density);
                stream:writef32(friction);
                stream:writef32(elasticity);
                stream:writef32(friction_weight);
                stream:writef32(elasticity_weight);
                if (acoustic_absorption ~= 1) then
                    stream:writef32(acoustic_absorption);
                end
            else
                stream:writeu8(0);
            end
        end
    end,
    [RobloxPropertyType.Color3uint8] = function(values: {Property}, stream: polyfill.IoWritable)
        -- stream:expandToSize(stream.position + (#values * 3)); -- preallocate
        local rs = buffer.create(#values);
        local gs = buffer.create(#values);
        local bs = buffer.create(#values);
        for i, value in values do
            local r, g, b = datatypes.Color3.Serialize(value.value, true);
            buffer.writeu8(rs, i - 1, r);
            buffer.writeu8(gs, i - 1, g);
            buffer.writeu8(bs, i - 1, b);
        end
        stream:write(rs);
        stream:write(gs);
        stream:write(bs);
    end,
    [RobloxPropertyType.Int64] = function(values: {Property}, stream: polyfill.IoWritable)
        local list = table.create(#values);
        for i, value in values do
            list[i] = value.value;
        end
        stream:write(WriteInterleavedi64(list));
    end,
    [RobloxPropertyType.SharedString] = function(values: {Property}, stream: polyfill.IoWritable)
        local keys = table.create(#values);
        for i, value in values do
            keys[i] = value.value - 1;
        end
        stream:write(WriteInterleavedu32(keys));
    end,
    [RobloxPropertyType.OptionalCFrame] = function(values: {Property}, stream: polyfill.IoWritable)
        cframeSerializer(RobloxPropertyType.OptionalCFrame, values, stream);
    end,
    [RobloxPropertyType.UniqueId] = function(values: {Property}, stream: polyfill.IoWritable)
        stream:write(WriteInterleaved(values, 16, function(b: buffer, offset: number, property)
            local random, index, time = datatypes.UniqueId.Serialize(property.value);
            buffer.copy(b, offset, random, 0, 8);
            buffer.writeu32(b, offset + 8, index);
            buffer.writeu32(b, offset + 12, time);
        end));
    end,
    [RobloxPropertyType.Font] = function(values: {Property}, stream: polyfill.IoWritable)
        for i, value in values do
            local family, weight, style, cacheId = datatypes.Font.Serialize(value.value);
            stream:writeu32(#family);
            stream:write(family);
            stream:writeu16(weight);
            stream:writeu8(style);
            stream:writeu32(#(cacheId or ""));
            stream:write(cacheId or "");
        end
    end,
    [RobloxPropertyType.SecurityCapabilities] = function(values: {Property}, stream: polyfill.IoWritable)
        local capabilities = table.create(#values);
        for i, value in values do
            capabilities[i] = value.value;
        end
        stream:write(WriteInterleavedu64(capabilities));
    end,
    [RobloxPropertyType.Content] = function(values: {Property}, stream: polyfill.IoWritable)
        local len = #values;
        local source_types = table.create(len);
        local uris: {string} = table.create(len);
        local objects = table.create(len);

        for i, value in values do
            local source_type, uri, object = datatypes.Content.Serialize(value.value);
            source_types[i] = source_type;
            if (source_type == 1) then
                table.insert(uris, uri :: string);
            elseif (source_type == 2) then
                if (type(object) ~= "number") then
                    error("Invalid object type, must be a reference");
                end
                table.insert(objects, object);
            end
        end

        stream:write(WriteInterleavedi32(source_types));

        stream:writeu32(#uris);
        for _, uri in uris do
            stream:writeu32(#uri);
            stream:write(uri);
        end
        stream:writeu32(#objects);
        stream:write(WriteInstances(objects));

        stream:writeu32(0);
    end,
}

local function getMemberProperty(class: string, member: string): reflection.PropertyMemberInfo?
    local memberInfo = reflection:GetClassMember(class, member, true);
    if (not memberInfo) then
        return;
    end
    if (memberInfo.MemberType == "Property") then
        return memberInfo;
    end
    return;
end

local function serialize(document: Document): buffer
    local stream = sink.create(#BinaryMagicHeader);

    local writer: polyfill.IoWritable = stream:writer();

    writer:write(BinaryMagicHeader);

    writer:writeu16(document.info.version);
    writer:writeu32(#document.classes);
    writer:writeu32(#document.instances);

    --[[ reserved ]] do
        writer:write(document.info.reserved);
    end

    local metadata_size = size(document.metadata);
    if (metadata_size > 0) then
        writer:write(getBinaryChunkTypeName(BinaryChunkType.META));
        writeChunk(writer, function(chunk)
            chunk:writeu32(metadata_size);
            for key, value in document.metadata do
                chunk:writeu32(#key);
                chunk:write(key);
                chunk:writeu32(#value);
                chunk:write(value);
            end
            return true;
        end)
    end

    local id = 0;
    local ordered_sharedstrings: {string} = {};
    local sharedstring = table.clone(document.sharedstrings);
    for key, value in sharedstring do
        id += 1;
        ordered_sharedstrings[id] = value;
        sharedstring[key] = id :: any;
    end

    --[[SSTR]] do
        writer:write(getBinaryChunkTypeName(BinaryChunkType.SSTR));
        writeChunk(writer, function(chunk)
            chunk:writeu32(0);
            chunk:writeu32(id);
            local blank = string.rep("\0\0\0\0", 4);
            for _, content in ordered_sharedstrings do
                chunk:write(blank);
                chunk:writeu32(#content);
                chunk:write(content);
            end
            return true;
        end)
    end

    --[[SIGN]] if (document.signatures) then
        local signatures = document.signatures;
        writer:write(getBinaryChunkTypeName(BinaryChunkType.SIGN));
        writeChunk(writer, function(chunk)
            chunk:writeu32(#signatures);
            for _, sign in signatures do
                chunk:writeu32(0);
                chunk:write(sign.PublicKey);
                chunk:writeu32(#sign.Value);
                chunk:write(sign.Value);
            end
            return true;
        end)
    end

    --[[INST]] for _, class in document.classes do
        if (#class.instances == 0) then
            continue;
        end
        writer:write(getBinaryChunkTypeName(BinaryChunkType.INST));
        writeChunk(writer, function(chunk)
            chunk:writeu32(class.index - 1);
            chunk:writeu32(#class.name);
            chunk:write(class.name);
            chunk:writeu8(if (class.isService) then 1 else 0);
            chunk:writeu32(#class.instances);

            chunk:write(WriteInstances(class.instances));

            if (class.isService) then
                for _, id in class.instances do
                    local instance = document.instances[id];
                    chunk:writeu8(if (instance.parent == nil) then 1 else 0)
                end
            end

            return true;
        end)
    end

    --[[PROP]] for _, class in document.classes do
        if (#class.instances == 0) then
            continue;
        end
        local instance = document.instances[class.instances[1]];
        for name, value in instance.properties do
            if (name:sub(1, 2) == "__") then
                continue;
            end
            if (PropertySerializerMap[value.type] == nil) then
                log(`{SER_TAG} Unsupported property type: {getPropertyTypeName(value.type)}`);
                continue;
            end

            local member = getMemberProperty(class.name, name);
            if (not member) then
                log(`{SER_TAG} Property {color("green", `"{name}"`)} in class {color("green", `"{class.name}"`)} was not found.`);
                continue;
            end
            if (not member.Serialization.CanSave) then
                log(`{SER_TAG} Property {color("green", `"{name}"`)} in class {color("green", `"{class.name}"`)} is not serializable.`);
                continue;
            end

            writer:write(getBinaryChunkTypeName(BinaryChunkType.PROP));
            writeChunk(writer, function(chunk)
                chunk:writeu32(class.index - 1);
                chunk:writeu32(#name);
                chunk:write(name);
                chunk:writeu8(value.type);

                local values = table.create(#class.instances);
                for _, id in class.instances do
                    local instance = document.instances[id];
                    local prop = instance.properties[name];
                    if (not prop) then
                        error(`Instance {id} missing property '{name}'`);
                    end
                    if (value.type == RobloxPropertyType.SharedString) then
                        local index = sharedstring[prop.value] or error("SharedString not found in document");
                        prop = table.clone(prop);
                        prop.value = index;
                    end
                    table.insert(values, prop);
                end

                PropertySerializerMap[value.type](values, chunk);

                return true;
            end)
        end
    end

    --[[PRNT]] do
        writer:write(getBinaryChunkTypeName(BinaryChunkType.PRNT));
        writeChunk(writer, function(chunk)
            local instance_len = #document.instances;
            local child_ids = table.create(instance_len);
            local parents_ids = table.create(instance_len);
            for i = 1, instance_len do
                local instance = document.instances[i];
                child_ids[i] = instance.referent;
                parents_ids[i] = if (instance.parent) then instance.parent else 0;
            end

            chunk:writeu8(0);
            chunk:writeu32(instance_len);
            chunk:write(WriteInstances(child_ids));
            chunk:write(WriteInstances(parents_ids));

            return true;
        end)
    end

    --[[END\0]] do
        writer:write(getBinaryChunkTypeName(BinaryChunkType.END));
        writeChunk(writer, function(chunk)
            chunk:write("</roblox>");
            return false;
        end)
    end

    return stream:flush(true) :: buffer;
end

local function readChunk(stream: polyfill.BufferStream): ChunkInfo
    if (not stream:canRead(16)) then
        error("Too small");
    end

    local chunk_type = BinaryChunkTypeMap[stream:read(4, false)];
    assert(chunk_type, "Invalid chunk type");
    local reader = stream:reader();
    local compressed_size = reader:readu32();
    local size = reader:readu32();
    local reserved = reader:readu32();

    local data: buffer = nil;
    if (compressed_size > 0) then
        local byte = reader:readu8()
        stream:seekBy(-1);
        if (byte == 0x58 or byte == 0x78) then
            data = zlib.decompress(reader:read(compressed_size, true) :: buffer);
        else
            stream:seekBy(1);
            if (reader:read(3, false) == "\xB5\x2F\xFD") then
                stream:seekBy(-4);
                data = zstd.decompress(
                    reader:read(compressed_size) :: buffer
                );
                assert(buffer.len(data) == size, `{DES_TAG} Chunk zstd data size mismatch`);
            else
                stream:seekBy(-4);
                data = lz4.decompress(
                    reader:read(compressed_size) :: buffer,
                    size
                );
            end
        end
    else
        data = reader:read(size) :: buffer;
    end

    return {
        type = chunk_type,
        data = data,
        reserved = reserved,
        size = size,
        id = -1,
    };
end

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

local function cframeDeserializer(type: number, values: {any}, property_name: string, stream: polyfill.IoReadable)
    local len = #values;
    if (type == RobloxPropertyType.OptionalCFrame) then
        local byte = stream:readu8();
        if (byte ~= RobloxPropertyType.CFrame) then
            for i = 1, len do
                values[i] = nil;
            end
            return;
        end
    end
    local matrices = table.create(len);
    for i = 1, len do
        local orient_id = stream:readu8();
        if (orient_id > 0) then
            local matrix = MatricesMap[orient_id] or error("Unknown CFrame Rotation Id");
            matrices[i] = matrix;
        elseif (type == RobloxPropertyType.Quaternion) then
            local qx = stream:readf32();
            local qy = stream:readf32();
            local qz = stream:readf32();
            local qw = stream:readf32();

            local xc = qx * 2;
            local yc = qy * 2;
            local zc = qz * 2;

            local xx = qx * xc;
            local xy = qx * yc;
            local xz = qx * zc;

            local wx = qw * xc;
            local wy = qw * yc;
            local wz = qw * zc;

            local yy = qy * yc;
            local yz = qy * zc;
            local zz = qz * zc;

            matrices[i] = {
                1 - (yy + zz), xy - wz, xz + wy,
                xy + wx, 1 - (xx + zz), yz - wx,
                xz - wy, yz + wx, 1 - (xx + yy),
            };
        else
            local matrix = table.create(9);
            for j = 1, 9 do
                matrix[j] = stream:readf32();
            end
            matrices[i] = matrix;
        end
    end
    local cxs = ReadInterleavedf32(stream, len);
    local cys = ReadInterleavedf32(stream, len);
    local czs = ReadInterleavedf32(stream, len);

    local cframes = table.create(len);
    for i = 1, len do
        cframes[i] = datatypes.CFrame.Deserialize(
            cxs[i], cys[i], czs[i],
            unpack(matrices[i])
        );
    end

    if (type == RobloxPropertyType.OptionalCFrame) then
        local byte = stream:readu8();
        if (byte ~= RobloxPropertyType.Bool) then
            for i = 1, len do
                values[i] = cframes[i];
            end
        else
            for i = 1, len do
                local exists = stream:readu8() ~= 0;
                if (not exists) then
                    values[i] = nil;
                    continue;
                end
                values[i] = cframes[i];
            end
        end
    else
        for i = 1, len do
            values[i] = cframes[i];
        end
    end
end

local function findPropertyFromClass(class: reflection.ClassInfo, propertyName: string): reflection.PropertyMemberInfo?
    for _, member in class.Members do
        if (member.MemberType == "Property" and member.Name == propertyName) then
            return member :: reflection.PropertyMemberInfo;
        end
    end
    if (class.Superclass ~= "<<<ROOT>>>") then
        local super = assert(reflection:GetClass(class.Superclass), `Missing superclass`);
        return findPropertyFromClass(super, propertyName);
    end
    return nil;
end

local PropertyDeserializerMap = {
    [RobloxPropertyType.Unknown] = function(values: {any}, property_name: string, stream: polyfill.IoReadable)
        error("Unknown Property Type not supported.")
    end,
    [RobloxPropertyType.String] = function(values: {any}, property_name: string, stream: polyfill.IoReadable)
        local len = #values;
        for i = 1, len do
            values[i] = stream:read(stream:readu32(), false);
        end
    end,
    [RobloxPropertyType.Bool] = function(values: {any}, property_name: string, stream: polyfill.IoReadable)
        local len = #values;
        for i = 1, len do
            values[i] = stream:readu8() ~= 0;
        end
    end,
    [RobloxPropertyType.Int] = function(values: {any}, property_name: string, stream: polyfill.IoReadable)
        local len = #values;
        local list = ReadInterleavedi32(stream, len);
        for i = 1, len do
            values[i] = list[i];
        end
    end,
    [RobloxPropertyType.Float] = function(values: {any}, property_name: string, stream: polyfill.IoReadable)
        local len = #values;
        local list = ReadInterleavedf32(stream, len);
        for i = 1, len do
            values[i] = list[i];
        end
    end,
    [RobloxPropertyType.Double] = function(values: {any}, property_name: string, stream: polyfill.IoReadable)
        local len = #values;
        for i = 1, len do
            values[i] = stream:readf64();
        end
    end,
    [RobloxPropertyType.UDim] = function(values: {any}, property_name: string, stream: polyfill.IoReadable)
        local len = #values;
        local scales = ReadInterleavedf32(stream, len);
        local offsets = ReadInterleavedi32(stream, len);
        for i = 1, len do
            values[i] = datatypes.UDim.Deserialize(scales[i], offsets[i]);
        end
    end,
    [RobloxPropertyType.UDim2] = function(values: {any}, property_name: string, stream: polyfill.IoReadable)
        local len = #values;
        local scales_x = ReadInterleavedf32(stream, len);
        local scales_y = ReadInterleavedf32(stream, len);
        local offsets_x = ReadInterleavedi32(stream, len);
        local offsets_y = ReadInterleavedi32(stream, len);
        for i = 1, len do
            values[i] = datatypes.UDim2.Deserialize(scales_x[i], offsets_x[i], scales_y[i], offsets_y[i]);
        end
    end,
    [RobloxPropertyType.Ray] = function(values: {any}, property_name: string, stream: polyfill.IoReadable)
        local len = #values;
        for i = 1, len do
            values[i] = datatypes.Ray.Deserialize(
                stream:readf32(), stream:readf32(), stream:readf32(),
                stream:readf32(), stream:readf32(), stream:readf32()
            );
        end
    end,
    [RobloxPropertyType.Faces] = function(values: {any}, property_name: string, stream: polyfill.IoReadable)
        local len = #values;
        for i = 1, len do
            values[i] = datatypes.Faces.Deserialize(stream:readu8());
        end
    end,
    [RobloxPropertyType.Axes] = function(values: {any}, property_name: string, stream: polyfill.IoReadable)
        local len = #values;
        for i = 1, len do
            values[i] = datatypes.Axes.Deserialize(stream:readu8());
        end
    end,
    [RobloxPropertyType.BrickColor] = function(values: {any}, property_name: string, stream: polyfill.IoReadable)
        local len = #values;
        local list = ReadInterleavedu32(stream, len);
        for i = 1, len do
            values[i] = datatypes.BrickColor.Deserialize(list[i]);
        end
    end,
    [RobloxPropertyType.Color3] = function(values: {any}, property_name: string, stream: polyfill.IoReadable)
        local len = #values;
        local rs = ReadInterleavedf32(stream, len);
        local gs = ReadInterleavedf32(stream, len);
        local bs = ReadInterleavedf32(stream, len);
        for i = 1, len do
            values[i] = datatypes.Color3.Deserialize(rs[i], gs[i], bs[i], false);
        end
    end,
    [RobloxPropertyType.Vector2] = function(values: {any}, property_name: string, stream: polyfill.IoReadable)
        local len = #values;
        local xs = ReadInterleavedf32(stream, len);
        local ys = ReadInterleavedf32(stream, len);
        for i = 1, len do
            values[i] = datatypes.Vector2.Deserialize(xs[i], ys[i]);
        end
    end,
    [RobloxPropertyType.Vector3] = function(values: {any}, property_name: string, stream: polyfill.IoReadable)
        local len = #values;
        local xs = ReadInterleavedf32(stream, len);
        local ys = ReadInterleavedf32(stream, len);
        local zs = ReadInterleavedf32(stream, len);
        for i = 1, len do
            values[i] = datatypes.Vector3.Deserialize(xs[i], ys[i], zs[i]);
        end
    end,
    [RobloxPropertyType.CFrame] = function(values: {any}, property_name: string, stream: polyfill.IoReadable)
        cframeDeserializer(RobloxPropertyType.CFrame, values, property_name, stream);
    end,
    [RobloxPropertyType.Quaternion] = function(values: {any}, property_name: string, stream: polyfill.IoReadable)
        cframeDeserializer(RobloxPropertyType.Quaternion, values, property_name, stream);
    end,
    [RobloxPropertyType.Enum] = function(values: {any}, property_name: string, stream: polyfill.IoReadable)
        local len = #values;
        local list = ReadInterleavedu32(stream, len);
        for i = 1, len do
            values[i] = list[i];
        end
    end,
    [RobloxPropertyType.Ref] = function(values: {any}, property_name: string, stream: polyfill.IoReadable)
        local len = #values;
        local list = ReadInstances(stream, len);
        for i = 1, len do
            values[i] = if (list[i] > 0) then list[i] else nil;
        end
    end,
    [RobloxPropertyType.Vector3int16] = function(values: {any}, property_name: string, stream: polyfill.IoReadable)
        local len = #values;
        for i = 1, len do
            local x = stream:readi16();
            local y = stream:readi16();
            local z = stream:readi16();
            values[i] = datatypes.Vector3int16.Deserialize(x, y, z);
        end
    end,
    [RobloxPropertyType.NumberSequence] = function(values: {any}, property_name: string, stream: polyfill.IoReadable)
        local len = #values;
        for i = 1, len do
            local keys = stream:readu32();
            local points = table.create(keys);
            for j = 1, keys do
                local time = stream:readf32();
                local value = stream:readf32();
                local envelope = stream:readf32();
                points[j] = datatypes.NumberSequenceKeypoint.Deserialize(
                    time, value, envelope
                );
            end
            values[i] = datatypes.NumberSequence.Deserialize(points);
        end
    end,
    [RobloxPropertyType.ColorSequence] = function(values: {any}, property_name: string, stream: polyfill.IoReadable)
        local len = #values;
        for i = 1, len do
            local keys = stream:readu32();
            local points = table.create(keys);
            for j = 1, keys do
                local time = stream:readf32();
                local r = stream:readf32();
                local g = stream:readf32();
                local b = stream:readf32();
                local envelope = stream:readf32();
                points[j] = datatypes.ColorSequenceKeypoint.Deserialize(
                    time, datatypes.Color3.Deserialize(r, g, b, false), envelope
                );
            end
            values[i] = datatypes.ColorSequence.Deserialize(points);
        end
    end,
    [RobloxPropertyType.NumberRange] = function(values: {any}, property_name: string, stream: polyfill.IoReadable)
        local len = #values;
        for i = 1, len do
            local min = stream:readf32();
            local max = stream:readf32();
            values[i] = datatypes.NumberRange.Deserialize(min, max);
        end
    end,
    [RobloxPropertyType.Rect] = function(values: {any}, property_name: string, stream: polyfill.IoReadable)
        local len = #values;
        local x0s = ReadInterleavedf32(stream, len);
        local y0s = ReadInterleavedf32(stream, len);
        local x1s = ReadInterleavedf32(stream, len);
        local y1s = ReadInterleavedf32(stream, len);
        for i = 1, len do
            values[i] = datatypes.Rect.Deserialize(x0s[i], y0s[i], x1s[i], y1s[i]);
        end
    end,
    [RobloxPropertyType.PhysicalProperties] = function(values: {any}, property_name: string, stream: polyfill.IoReadable)
        local len = #values;
        for i = 1, len do
            local mode = stream:readu8();
            local value = nil;
            if (mode == 0b01 or mode == 0b11) then
                local density = stream:readf32();
                local friction = stream:readf32();
                local elasticity = stream:readf32();
                local friction_weight = stream:readf32();
                local elasticity_weight = stream:readf32();
                local acoustic_absorption = if (mode == 0b11) then stream:readf32() else 1;
                value = datatypes.PhysicalProperties.Deserialize(
                    density,
                    friction,
                    elasticity,
                    friction_weight,
                    elasticity_weight,
                    acoustic_absorption
                );
            end
            values[i] = value;
        end
    end,
    [RobloxPropertyType.Color3uint8] = function(values: {any}, property_name: string, stream: polyfill.IoReadable)
        local len = #values;
        local rs = stream:read(len, true);
        local gs = stream:read(len, true);
        local bs = stream:read(len, true);
        for i = 0, len - 1 do
            local r = buffer.readu8(rs, i);
            local g = buffer.readu8(gs, i);
            local b = buffer.readu8(bs, i);
            values[i + 1] = datatypes.Color3.Deserialize(r, g, b, true);
        end
    end,
    [RobloxPropertyType.Int64] = function(values: {any}, property_name: string, stream: polyfill.IoReadable)
        local len = #values;
        local list = ReadInterleavedi64(stream, len);
        for i = 1, len do
            values[i] = list[i];
        end
    end,
    [RobloxPropertyType.SharedString] = function(values: {any}, property_name: string, stream: polyfill.IoReadable)
        local len = #values;
        local keys = ReadInterleavedu32(stream, len);
        for i = 1, len do
            values[i] = keys[i] + 1;
        end
    end,
    [RobloxPropertyType.OptionalCFrame] = function(values: {any}, property_name: string, stream: polyfill.IoReadable)
        cframeDeserializer(RobloxPropertyType.OptionalCFrame, values, property_name, stream);
    end,
    [RobloxPropertyType.UniqueId] = function(values: {any}, property_name: string, stream: polyfill.IoReadable)
        local len = #values;
        local ids = ReadInterleaved(stream:read(len * 16) :: buffer, 0, len, 16, function(b: buffer)
            local random = buffer.create(8);
            buffer.copy(random, 0, b, 0, 8);
            return {
                index = buffer.readu32(b, 8),
                time = buffer.readu32(b, 12),
                random = random,
            }
        end)
        for i = 1, len do
            values[i] = datatypes.UniqueId.Deserialize(ids[i].random, ids[i].index, ids[i].time);
        end
    end,
    [RobloxPropertyType.Font] = function(values: {any}, property_name: string, stream: polyfill.IoReadable)
        local len = #values;
        for i = 1, len do
            local family = stream:read(stream:readu32(), false);
            local weight = stream:readu16();
            local style = stream:readu8();
            local cache_id = stream:read(stream:readu32(), false);
            values[i] = datatypes.Font.Deserialize(family, weight, style, cache_id);
        end
    end,
    [RobloxPropertyType.SecurityCapabilities] = function(values: {any}, property_name: string, stream: polyfill.IoReadable)
        local len = #values;
        local capabilities = ReadInterleavedu64(stream, len);
        for i = 1, len do
            values[i] = capabilities[i];
        end
    end,
    [RobloxPropertyType.Content] = function(values: {any}, property_name: string, stream: polyfill.IoReadable)
        local len = #values;
        local source_types = ReadInterleavedi32(stream, len);
        local uri_count = stream:readu32();
        local uris = table.create(uri_count);
        for i = 1, uri_count do
            uris[i] = stream:read(stream:readu32(), false);
        end
        local object_count = stream:readu32();
        local objects = ReadInstances(stream, object_count);

        local extern_count = stream:readu32();
        local _ = stream:read(extern_count * 4);
        for i = 1, len do
            values[i] = datatypes.Content.Deserialize(
                source_types[i],
                if (source_types[i] == 1) then table.remove(uris) else nil,
                if (source_types[i] == 2) then table.remove(objects) else nil
            );
        end
    end,
}

local BLANK_PROPERTY = {
    type = RobloxPropertyType.Unknown,
    value = nil,
};

local function getDefaultEnum(enum: datatypes.Enum, member: any): datatypes.EnumItem?
    local default = member.Default;
    if (not default) then
        return nil;
    end
    return enum[default];
end

local DeserializerMap = {
    [BinaryChunkType.INST] = function(document: Document, chunk: ChunkInfo)
        local chunk_stream = stream.create(chunk.data);
        local reader: polyfill.IoReadable = chunk_stream:reader();
        local class_index = reader:readu32() + 1;
        local class_name = reader:read(reader:readu32(), false);
        local is_service = reader:readu8() ~= 0;
        local instances_len = reader:readu32();

        assert(instances_len)

        if (class_index < 1 or class_index > document.info.instances) then
            error(`index {class_index - 1} out of bounds {document.info.classes - 1}`);
        end

        local instances = ReadInstances(reader, instances_len);

        for i = 1, instances_len do
            local id = instances[i];
            local inst: Instance = {
                referent = id,
                className = class_name,
                properties = {},
            };
            if (is_service) then
                reader:readu8()
            end
            if (id < 1 or id > document.info.instances) then
                error(`index {id - 1} out of bounds {document.info.instances - 1}`);
            end
            document.instances[id] = inst;
        end

        document.classes[class_index] = {
            index = class_index,
            instances = instances,
            name = class_name,
            isService = is_service,
        };

        return false;
    end,
    [BinaryChunkType.PROP] = function(document: Document, chunk: ChunkInfo)
        local chunk_stream = stream.create(chunk.data);
        local reader = chunk_stream:reader();
        local class_index = reader:readu32() + 1;
        local property_name = reader:read(reader:readu32(), false);

        if (class_index < 1 or class_index > document.info.instances) then
            error(`index {class_index - 1} out of bounds {document.info.classes - 1}`);
        end
        local class = document.classes[class_index];
        if (not class) then
            error(`Deserializer property class not found: {property_name}`);
        end

        local type_byte = reader:readu8();

        local length = #class.instances;
        local values: {any} = table.create(length, BLANK_PROPERTY);

        --[[Validate Property]] do
            local member = getMemberProperty(class.name, property_name);
            if (not member) then
                log(`{DES_TAG} Unsupported property {color("green", `"{property_name}"`)} in class {color("green", `"{class.name}"`)} (Outdated?)`);
                return false;
            end
            if (not member.Serialization.CanLoad) then
                log(`{DES_TAG} Deserialization for property {color("green", `"{property_name}"`)} disabled in class {color("green", `"{class.name}"`)}`);
                return false;
            end
        end

        local deserializer = PropertyDeserializerMap[type_byte];
        if (not deserializer) then
            error(`Unsupported Property type: {getPropertyTypeName(type_byte)}`);
        end

        deserializer(values, property_name, reader);

        if (type_byte == roblox.PropertyTypes.Enum) then
            local class_api = reflection:GetClass(class.name);
            if (class_api) then
                local enum_member = findPropertyFromClass(class_api, property_name);
                if (enum_member and enum_member.ValueType.Category == "Enum") then
                    local enum = datatypes.Enums.DataType[enum_member.ValueType.Name];
                    if (enum) then
                        local default = getDefaultEnum(enum, enum_member);
                        local items = enum:GetEnumItems();
                        local value_map = table.create(#items);
                        for _, item in items do
                            value_map[item.Value] = item;
                        end
                        for i, value in values do
                            local store = value_map[value] or default;
                            if (not store) then
                                error(`Invalid EnumArrayId: {value} ({enum_member.ValueType.Name}) for {class.name}.{property_name} [{enum_member.Default}]`);
                            end
                            values[i] = store;
                        end
                    end
                end
            end
        end

        for i = 1, length do
            local id = class.instances[i];
            local instance = document.instances[id];
            local value = values[i];
            if (type_byte == roblox.PropertyTypes.SharedString) then
                local hash = (document.__sharedstrings_id :: any)[value];
                assert(hash, "SharedString hash not found")
                value = hash;
            end
            instance.properties[property_name] = {
                type = type_byte,
                value = value,
            };
        end

        return false;
    end,
    [BinaryChunkType.META] = function(document: Document, chunk: ChunkInfo)
        local chunk_stream = stream.create(chunk.data);
        local reader: polyfill.IoReadable = chunk_stream:reader();
        for i = 1, reader:readu32() do
            local key = reader:read(reader:readu32(), false);
            local value = reader:read(reader:readu32(), false);
            document.metadata[key] = value;
        end
        return false;
    end,
    [BinaryChunkType.PRNT] = function(document: Document, chunk: ChunkInfo)
        local chunk_stream = stream.create(chunk.data);
        local reader: polyfill.IoReadable = chunk_stream:reader();

        local format = reader:readu8();
        local count = reader:readu32();

        if (format ~= 0) then
            error(`Unsupported PRNT format: {format}`);
        end

        local childs = ReadInstances(reader, count);
        local parents = ReadInstances(reader, count);

        for i = 1, count do
            local child_id = childs[i];
            local parent_id = parents[i];
            if (parent_id < 0 or parent_id > document.info.instances) then
                error(`Invalid parent id, {parent_id}/{document.info.instances}, chunk#{chunk.id}[PRNT]`);
            end
            if (child_id < 0 or child_id > document.info.instances) then
                error(`Invalid child id, {child_id}/{document.info.instances}, chunk#{chunk.id}[PRNT]`);
            end
            if (parent_id >= 1) then
                document.instances[child_id].parent = parent_id;
            elseif (parent_id < 0) then
                error(`Invalid parent id: {parent_id - 1}`);
            end
        end

        return false;
    end,
    [BinaryChunkType.SIGN] = function(document: Document, chunk: ChunkInfo)
        local chunk_stream = stream.create(chunk.data);
        local reader: polyfill.IoReadable = chunk_stream:reader();

        local signs_len = reader:readu32();

        local signs: {Signature} = table.create(signs_len);

        for i = 1, signs_len do
            local type_idx = reader:readi32();
            local key = reader:read(8) :: buffer;
            local value = reader:read(reader:readu32(), false);
            signs[i] = {
                PublicKey = key,
                Type = if (type_idx == 0) then "Ed25519" else error("Unknown"),
                Value = value,
            };
        end

        return false;
    end,
    [BinaryChunkType.SSTR] = function(document: Document, chunk: ChunkInfo)
        local chunk_stream = stream.create(chunk.data);
        local reader: polyfill.IoReadable = chunk_stream:reader();
        local format = reader:readi32();
        local hash_len = reader:readu32();

        if (format ~= 0) then
            error("Bad SharedString format");
        end

        for i = 1, hash_len do
            chunk_stream:seekBy(16);
            local data = reader:read(reader:readu32(), false);
            local hash_base64 = blake2.b128(data, "base64");
            assert(document.__sharedstrings_id)
            table.insert(document.__sharedstrings_id, hash_base64);
            document.sharedstrings[hash_base64] = data;
        end
        return false;
    end,
};

local function deserialize(slice: buffer, slice_pos: number): Document
    local slice_len = buffer.len(slice);
    if (slice_len - slice_pos < 18) then
        error("Bad slice length");
    end
    local stream = stream.create(slice);
    local reader: polyfill.IoReadable = stream:reader();
    stream:seekBy(slice_pos);

    local version = reader:readu16();
    local classes = reader:readu32();
    local instances = reader:readu32();
    local reserved = reader:read(8) :: buffer; -- 8 bytes

    local document: Document = {
        info = {
            version = version,
            instances = instances,
            classes = classes,
            reserved = reserved,
        },
        classes = table.create(classes),
        instances = table.create(instances),
        sharedstrings = {},
        metadata = {},
        signatures = nil,
        -- internal
        __sharedstrings_id = {},
    }

    local chunks = table.create(32);

    local chunk_id = 0;
    while (true) do
        chunk_id += 1;
        local chunk = readChunk(stream);

        chunk.id = chunk_id;
        if (chunk.type == BinaryChunkType.END) then
            break;
        elseif (chunk.type ~= BinaryChunkType.PROP) then
            DeserializerMap[chunk.type](document, chunk);
            continue;
        end

        table.insert(chunks, chunk);

        if (slice_len <= stream:pos()) then
            error("EOF, expected more chunks.");
        end
    end

    for _, chunk in chunks do
        DeserializerMap[chunk.type](document, chunk);
    end

    document.__sharedstrings_id = nil;

    return document;
end

return {
    header = BinaryMagicHeader;
    serialize = serialize;
    deserialize = deserialize;
    debug = function(callback: (...any) -> ())
        log = callback::any;
    end
};
