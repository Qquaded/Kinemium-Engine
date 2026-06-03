--!strict
local testing = zune.testing;

local test = testing.test;
local expect = testing.expect;

local Stream = require("@roblox/dom/binary/stream");

test("Dynamic Allocating", function()
    local stream = Stream.new(0);
    for i = 1, 1000 do
        stream:writeu16(i);
    end
    stream:move(-2000);
    for i = 1, 1000 do
        local value = stream:readu16();
        expect(value).toBe(i);
    end
    -- Must have allocated more than 2000 bytes
    expect(stream.capacity).toBeGreaterThan(2000);
    stream:trim();
    -- Must have exact amount of bytes written/read after trim
    expect(stream.capacity).toBe(2000);
end)

test("Large Fast Allocating", function()
    local stream = Stream.new(0);
    stream:expandToSizePrecise(2000); --// pre-allocate 1000 bytes
    for i = 1, 1000 do
        stream:writeu16(i);
    end
    stream:move(-2000);
    for i = 1, 1000 do
        local value = stream:readu16();
        expect(value).toBe(i);
    end
    -- Must have not allocated more than 2000 bytes
    expect(stream.capacity).toBe(2000);
    stream:trim();
    -- Must have exact amount of bytes written/read after trim
    expect(stream.capacity).toBe(2000);
end)

return nil;
