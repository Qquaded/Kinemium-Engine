--!strict
--!native
--!optimize 2
local task = require("@lute/task") :: any;
local crypto = require("@lute/crypto") :: any;

return {
    base64 = require("./luau/base64"), -- fallback
    blake2 = require("./luau/blake2"), -- fallback
    datetime = require("./luau/datetime"), -- fallback
    lz4 = require("./luau/lz4"), -- fallback
    md5 = function(value: string): string
        return buffer.tostring(crypto.digest(crypto.hash.md5, value));
    end,
    mem = require("./luau/mem"),
    sink = require("./luau/sink"),
    stream = require("./luau/stream"),
    task =  {
        spawn = task.spawn,
        wait = task.wait,
        delay = function(time: number, f: (() -> ()) | thread): thread
            return task.spawn(function()
                task.wait(time);
                if (type(f) == "function") then
                    f();
                else
                    task.resume(f);
                end
            end);
        end,
        defer = function(f: (() -> ()) | thread): thread
            return task.spawn(function()
                task.defer();
                if (type(f) == "function") then
                    f();
                else
                    task.resume(f);
                end
            end);
        end,
    },
    zlib = require("./luau/zlib"), -- fallback
    zstd = require("./luau/zstd"), -- fallback
}