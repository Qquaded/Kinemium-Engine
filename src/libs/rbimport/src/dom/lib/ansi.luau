--!strict
--!native
--!optimize 2
local COLORS = {
    black = 30,
    red = 31,
    green = 32,
    yellow = 33,
    blue = 34,
    magenta = 35,
    cyan = 36,
    white = 37,
}

local STYLES = {
    reset = 0,
    bold = 1,
    dim = 2,
    italic = 3,
    underline = 4,
    blink = 5,
    reverse = 7,
    hidden = 8,
}

for name, code in COLORS do
    COLORS[name] = `\x1b[{code}m`;
end

for name, code in STYLES do
    STYLES[name] = `\x1b[{code}m`;
end

return {
    color = function(name: string)
        assert(COLORS[name], "Unknown color");
        return COLORS[name];
    end,
    style = function(kind: string)
        assert(STYLES[kind], "Unknown style");
        return STYLES[kind];
    end,
    reset = function(kind: string?)
        return `\x1b[0m`;
    end,
};
