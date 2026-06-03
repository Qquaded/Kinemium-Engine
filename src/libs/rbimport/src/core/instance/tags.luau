--!strict

local polyfill = require("@polyfill");
local Sink = polyfill.sink;

local function decodeTags(value: string): {string}
    return value:split("\0");
end

local function encodeTags(value: {string}): string
    local count = #value;
    if (count == 0) then
        return "";
    end
    local size = count - 1;
    for _, tag in value do
        size += #tag;
    end
    local sink = Sink.create(size);
    local writer = sink:writer()
    for i, tag in value do
        writer:write(tag);
        if (i == count) then
            break;
        end
        writer:writeu8(0);
    end
    return sink:flush(false) :: string;
end

return {
    decodeTags = decodeTags,
    encodeTags = encodeTags,
}
