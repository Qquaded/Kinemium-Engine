--!strict
--!native
--!optimize 2

return {
    base64 = zune.serde.base64,
    blake2 = {
        b128 = function(input, encoding: ("hex" | "base64")?): buffer | string
            local hash = zune.crypto.createHash("blake2b128");
            hash:update(input);
            return hash:digest(encoding or "binary");
        end
    },
    datetime = require("@self/datetime"),
    lz4 = zune.serde.lz4,
    md5 = function(input: string)
        local hash = zune.crypto.createHash("md5");
        hash:update(input);
        return hash:digest("hex");
    end,
    mem = zune.mem,
    sink = {
        create = function(size: number?): BufferSink
            return zune.io.createBufferSink({
                size = size,
            });
        end,
    },
    stream = {
        create = zune.io.createFixedBufferStream,
    },
    task = zune.task,
    zlib = zune.serde.zlib,
    zstd = zune.serde.zstd,
}
