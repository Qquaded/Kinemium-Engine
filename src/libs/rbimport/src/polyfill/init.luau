--!strict
--!native
--!optimize 2

export type IoWritable = {
    write: (self: IoWritable, value: string | buffer) -> (),
    writei8: (self: IoWritable, value: number) -> (),
    writeu8: (self: IoWritable, value: number) -> (),
    writei16: (self: IoWritable, value: number) -> (),
    writeu16: (self: IoWritable, value: number) -> (),
    writei32: (self: IoWritable, value: number) -> (),
    writeu32: (self: IoWritable, value: number) -> (),
    writef32: (self: IoWritable, value: number) -> (),
    writef64: (self: IoWritable, value: number) -> (),
}

export type IoReadable = {
    read:
        & ((self: IoReadable, amount: number?, bytes: true?) -> buffer)
        & ((self: IoReadable, amount: number?, bytes: false) -> string),
    readi8: (self: IoReadable) -> number,
    readu8: (self: IoReadable) -> number,
    readi16: (self: IoReadable) -> number,
    readu16: (self: IoReadable) -> number,
    readi32: (self: IoReadable) -> number,
    readu32: (self: IoReadable) -> number,
    readf32: (self: IoReadable) -> number,
    readf64: (self: IoReadable) -> number,
}

export type BufferStream = typeof(require("@self/impl/luau").stream.create(buffer.create(0)));

type Impl = {
    base64: typeof(require("@self/impl/luau/base64")),
    blake2: typeof(require("@self/impl/luau/blake2")),
    datetime: typeof(require("@self/impl/luau/datetime")),
    lz4: typeof(require("@self/impl/luau/lz4")),
    md5: typeof(require("@self/impl/luau/md5")),
    mem: typeof(require("@self/impl/luau/mem")),
    sink: typeof(require("@self/impl/luau/sink")),
    stream: typeof(require("@self/impl/luau/stream")),
    task: typeof(require("@self/impl/luau/task")),
    zlib: typeof(require("@self/impl/luau/zlib")),
    zstd: typeof(require("@self/impl/luau/zstd")),
}

if (type(_VERSION) == "string") then
    if (string.sub(_VERSION, 1, 4) == "zune") then
        return require("@self/impl/zune") :: Impl;
    elseif (string.sub(_VERSION, 1, 4) == "Lune") then
        return require("@self/impl/lune") :: Impl;
    end
end

-- other/unknown
return require("@self/impl/luau") :: Impl;