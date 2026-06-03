--!strict
--!native
--!optimize 2
local serde = require("@lune/serde") :: any;

return {
    base64 = require("./luau/base64"), -- fallback
    blake2 = require("./luau/blake2"), -- fallback
    datetime = require("@self/datetime"),
    lz4 = require("./luau/lz4"), -- fallback
    md5 = function(value: string): string
        return serde.hash("md5", value);
    end,
    mem = require("./luau/mem"),
    sink = require("./luau/sink"),
    stream = require("./luau/stream"),
    task = require("@lune/task") :: any,
    zlib = {
        compress = function(src: buffer | string): buffer | string
            local isBuffer = type(src) == "buffer";
            local compressed = serde.compress("zlib", if (isBuffer) then buffer.tostring(src::buffer) else src::string);
            if (isBuffer) then
                return buffer.fromstring(compressed)
            end
            return compressed
        end::any,
        decompress = function(src: buffer | string, _: number): buffer | string
            local isBuffer = type(src) == "buffer";
            local decompressed = serde.decompress("zlib", if (isBuffer) then buffer.tostring(src::buffer) else src::string);
            if (isBuffer) then
                return buffer.fromstring(decompressed)
            end
            return decompressed
        end::any,
    },
    zstd = {
        compress = function(src: buffer | string): buffer | string
            local isBuffer = type(src) == "buffer";
            local compressed = serde.compress("zstd", if (isBuffer) then buffer.tostring(src::buffer) else src::string);
            if (isBuffer) then
                return buffer.fromstring(compressed)
            end
            return compressed
        end::any,
        decompress = function(src: buffer | string, _: number): buffer | string
            local isBuffer = type(src) == "buffer";
            local decompressed = serde.decompress("zstd", if (isBuffer) then buffer.tostring(src::buffer) else src::string);
            if (isBuffer) then
                return buffer.fromstring(decompressed)
            end
            return decompressed
        end::any
    },
}
