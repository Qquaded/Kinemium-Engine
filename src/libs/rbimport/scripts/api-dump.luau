--!strict
local fs = zune.fs;
local net = zune.net;
local serde = zune.serde;
local crypto = zune.crypto;

local REPO = "MaximumADHD/Roblox-Client-Tracker";
local BRANCH = "roblox";

local TARGET_PATH = "src/reflection/generated";

local URL = `https://raw.githubusercontent.com/{REPO}/refs/heads/{BRANCH}/Mini-API-Dump.json`;
local VERSION_URL = `https://raw.githubusercontent.com/{REPO}/refs/heads/{BRANCH}/version.txt`;

if (fs.stat("scripts/.cache").kind == "none") then
    fs.makeDir("scripts/.cache");
end

if (fs.stat(TARGET_PATH).kind == "none") then
    fs.makeDir(TARGET_PATH, true);
end

local TYPE_INFO = [[
export type ThreadSafety = "Unsafe" | "ReadSafe" | "Safe"

export type Security = string | {
    Read: string,
    Write: string,
}

export type Capabilities = {
    Read: {string},
}

export type TypeInfo = {
    Category: string,
    Name: string,
}

export type ValueType = {
    Name: string,
    Type: TypeInfo,
    Tags: {string}
}

export type FunctionMemberInfo = {
    MemberType: "Function",
    Name: string,
    Tags: {string}?,
    Serialization: {
        CanLoad: boolean,
        CanSave: boolean,
    },
    Parameters: {ValueType},
    ReturnType: TypeInfo | {TypeInfo},
    ThreadSafety: ThreadSafety,
    Security: Security,
}

export type EventMemberInfo = {
    MemberType: "Event",
    Name: string,
    Tags: {string}?,
    Parameters: {
        {
            Name: string,
            Type: {
                Category: string,
                Name: string,
            },
            Tags: {string}
        }
    },
    ThreadSafety: ThreadSafety,
    Security: Security,
}

export type PropertyMemberInfo = {
    Category: string,
    MemberType: "Property",
    Capabilities: Capabilities,
    Name: string,
    Tags: {string}?,
    Default: string?,
    Serialization: {
        CanLoad: boolean,
        CanSave: boolean,
    },
    ValueType: {
        Category: string,
        Name: string,
    },
    ThreadSafety: ThreadSafety,
    Security: Security,
}

export type MemberInfo = FunctionMemberInfo | EventMemberInfo | PropertyMemberInfo

export type ClassInfo = {
    Name: string,
    Superclass: string,
    Tags: {string}?,
    MemoryCategory: string,
    Members: {MemberInfo},
}

export type EnumInfo = {
    Name: string,
    Tags: {string}?,
    Items: {
        {
            Name: string,
            Value: number,
            Tags: {string}?
        }
    }
}

export type ApiDump = {
    Version: number,
    Classes: {ClassInfo},
    Enums: {EnumInfo}
}
]]

local function build(list: {string}): string
    return table.concat(list, '\n');
end

local version = net.http.request(VERSION_URL, {
    method = "GET" :: "GET",
    max_body_size = 64; -- 64 bytes
});
assert(version.ok, `Invalid version response ({version.status_code}): {version.body}`);

local function count(t: {any}): number
    local c = 0;
    for _, _ in t do
        c += 1;
    end
    return c;
end

local function jsonToLua(json_value: any, d: number?): string
    local depth = d or 0;
    if (type(json_value) == "table") then
        local writer = {};
        local fields = {};
        local size = count(json_value);
        local array_size = #json_value;
        local array = array_size > 0 and next(json_value) ~= nil
        table.insert(writer, "{")
        if (array) then
            for i, v in ipairs(json_value) do
                local data = jsonToLua(v, depth + 1);
                size = math.max(#data // 10, size);
                table.insert(fields, jsonToLua(v, depth + 1))
            end
            if (size > 5) then
                table.insert(writer, `\n{string.rep('\t', depth + 1)}`)
            end
            table.insert(writer, table.concat(fields, if (size > 5) then `,\n{string.rep('\t', depth + 1)}` else ","));
            if (size > 5) then
                table.insert(writer, `\n{string.rep('\t', depth)}`)
            end
        else
            for i, v in pairs(json_value) do
                local data = jsonToLua(v, depth + 1);
                size = math.max(#data // 10, size);
                if (string.find(i, "[\0-\64\91-\96\123-\255]")) then
                    table.insert(fields, `["{i}"] = {data}`);
                else
                    table.insert(fields, `{i} = {data}`);
                end
            end
            if (size > 5) then
                table.insert(writer, `\n{string.rep('\t', depth + 1)}`)
            end
            table.insert(writer, table.concat(fields, if (size > 5) then `,\n{string.rep('\t', depth + 1)}` else ","));
            if (size > 5) then
                table.insert(writer, `\n{string.rep('\t', depth)}`)
            end
        end
        table.insert(writer, "}")
        return table.concat(writer, "");
    elseif (type(json_value) == "string") then
        local closing = "\"";
        if (not json_value:find("\"", 1, true)) then
            closing = "\"";
        elseif (not json_value:find("'", 1, true)) then
            closing = "'"
        elseif (not json_value:find("`", 1, true)) then
            closing = "`"
        else
            return `[===[{json_value}]===]`;
        end
        return `{closing}{json_value}{closing}`;
    elseif (type(json_value) == "number" or type(json_value) == "boolean") then
        return tostring(json_value);
    end
    return error(type(json_value));
end

local function saveDump(version: string, dump: string)
    local data = serde.json.decode(dump);
    fs.writeFile(`{TARGET_PATH}/api-dump.luau`, build {
        `return {jsonToLua(data)};`,
        ''
    });
    fs.writeFile(`{TARGET_PATH}/init.luau`, build {
        '-- Luau code generated by api-dump.luau',
        '--!strict',
        TYPE_INFO,
        'return {',
        `    Version = "{version}",`,
        '    ApiDump = require("@self/api-dump") :: any,',
        '}',
        ''
    });
end

local hasher = crypto.createHash("md5")
hasher:update(`{version.body}({URL})`);
local hash = hasher:digest("hex");
local ok, file = pcall(fs.openFile, `scripts/.cache/{hash}`)
if (ok) then
    local dump_compressed = file:read();
    local dump = serde.gzip.decompress(dump_compressed);
    saveDump(version.body, dump);
    print(`Roblox API Dump saved at {TARGET_PATH}/dump.json (from cache)`);
    print(`  Version: {version.body}`);
    return;
end

local dump = net.http.request(URL, {
    method = "GET" :: "GET",
    max_body_size = 8 * 1024 * 1024; -- 8MB
});
assert(dump.ok, `Invalid dump response ({dump.status_code}): {dump.body}`);

saveDump(version.body, dump.body);

local contents = serde.gzip.compress(dump.body, {
    level = 9
});
fs.writeFile(`scripts/.cache/{hash}`, contents);

print(`Roblox API Dump saved at {TARGET_PATH}/dump.json`);
print(`  Version: {version.body}`);
