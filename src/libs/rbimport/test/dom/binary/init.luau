--!strict
local fs = zune.fs;
local process = zune.process;
local testing = zune.testing;

local test = testing.test;

local xml = require("@roblox/dom/xml");
local binary = require("@roblox/dom/binary");
local roblox = require("@roblox/dom/roblox");
local reflection = require("@roblox/reflection");

local RobloxPropertyTypeNameMap = {}
for name: string, value: number in roblox.PropertyTypes::{[string]: number} do
    RobloxPropertyTypeNameMap[value] = name;
end

local function getPropertyTypeName(type: number): string
    return (assert(RobloxPropertyTypeNameMap[type], "Unknown property type"));
end

local function isSimilarType(a: number, b: number)
    if (a == b) then
        return true;
    end
    return false;
end

local function similarProperties(
    className: string,
    prop1: {[string]: roblox.Property},
    prop2: {[string]: roblox.Property},
    outdated: boolean?,
    ignore_content: boolean?
)
    local class: reflection.ClassInfo = reflection:FindClass(className) or ({Members = {}} :: any);
    local serializable = {};
    for _, member in class.Members do
        if (member.MemberType == "Property") then
            serializable[member.Name] = member.Serialization.CanSave;
        end
    end
    for name, p1 in prop1 do
        if (not serializable[name]) then
            continue;
        end
        if (ignore_content) then
            if (p1.type == roblox.PropertyTypes.Content) then
                continue;
            end
        end
        local p2 = prop2[name];
        if (not p2) then
            if (not outdated) then
                return false, `Property '{name}' not found`;
            end
            return true, "Supressed";
        end
        if (not isSimilarType(p1.type, p2.type)) then
            return false, `{getPropertyTypeName(p1.type)} != {getPropertyTypeName(p2.type)}`;
        end
        if (p1.type == p2.type) then
            if (type(p1.value) ~= type(p2.value)) then
                print(p1, p2)
                return false, ` @'{name}' type mismatch ({type(p1.value)} != {type(p2.value)})`;
            end
        end
        if (type(p1.value) == "buffer" or type(p1.value) == "table"
            or type(p2.value) == "buffer" or type(p2.value) == "table") then
            continue;
        end
        if (p1.value ~= p2.value) then
            if p2.value ~= p2.value and p1.value ~= p1.value then
                continue;
            end
            return false, `{tostring(p1.value)} !<{name} = {getPropertyTypeName(p1.type)} ({type(p1.value)}|{type(p2.value)})>= {tostring(p2.value)}`;
        end
    end
    return true, "";
end

local function isSimilar(
    instances1: {roblox.Instance},
    instances2: {roblox.Instance},
    outdated: boolean?,
    ignore_content: boolean?
)
    if (#instances1 ~= #instances2 and not outdated) then
        return false, `size #{#instances1} != #{#instances2}`;
    end
    for i = 1, #instances1 do
        local inst1 = instances1[i];
        if (outdated) then
            local _matched = 0;
            for _, inst2 in instances2 do
                if (inst1.className == inst2.className) then
                    local ok, _ = similarProperties(inst1.className, inst1.properties, inst2.properties, outdated);
                    if (ok) then
                        _matched = 2;
                        break;
                    else
                        _matched = 1;
                    end
                end
            end
            if (_matched == 1) then
                return false, `No outdated match for instance {i} ({inst1.className})`;
            end
        else
            local inst2 = instances2[i];
            if (not inst1 or not inst2) then
                return false, `Instance {i} missing`;
            end
            if (inst1.className ~= inst2.className) then
                return false, `{i}`;
            end
            if (inst1.referent ~= inst2.referent) then
                return false, `{i}`;
            end
            if (inst1.parent ~= inst2.parent) then
                return false, `{i}`;
            end
            local ok, msg = similarProperties(
                inst1.className,
                inst1.properties,
                inst2.properties,
                outdated,
                ignore_content
            );
            if (not ok) then
                return false, `{i}: {msg}`;
            end
        end
    end
    return true, '';
end

local function serializeDeserializeTest(name: string, path: string, outdated: boolean?)
    test(name, function()
        local buf = fs.readFile(path, true);
        assert(buffer.readstring(buf, 0, 14) == binary.header, "Mismatch")
        local doc = binary.deserialize(buf, 14);
        local content = binary.serialize(doc);
        assert(buffer.readstring(content, 0, 14) == binary.header, "Mismatch")
        local doc2 = binary.deserialize(content, 14);
        assert(isSimilar(doc.instances, doc2.instances, outdated));
        local content_xml = xml.serialize(doc);
        local doc3 = xml.deserialize(content_xml);
        assert(isSimilar(doc.instances, doc3.instances, outdated, true));
        for _, class in doc.classes do
            local found;
            for _, class2 in doc2.classes do
                if (class.name == class2.name) then
                    assert(class.isService == class2.isService, `Class {class.name} isService mismatch`);
                    found = class2;
                    break;
                end
            end
            assert(found, `Class {class.name} missing`);
        end
    end)
end

local RBX = "./rbx-test-files";

serializeDeserializeTest(
    "places/all instances 415", `{RBX}/places/all-instances-415/binary.rbxl`, true
)
serializeDeserializeTest(
    "places/baseplate 413", `{RBX}/places/baseplate-413/binary.rbxl`, true
)
serializeDeserializeTest(
    "places/baseplate 454", `{RBX}/places/baseplate-454/binary.rbxl`, true
)
serializeDeserializeTest(
    "places/baseplate 566", `{RBX}/places/baseplate-566/binary.rbxl`
)
local outdated_models = {
    "three-screengui",
    "gui-inset-and-font-migration",
};
for _, sample in fs.entries(`{RBX}/models/`) do
    local outdated = table.find(outdated_models, sample.name) ~= nil;
    serializeDeserializeTest(
        `models/{sample.name}`, `{RBX}/models/{sample.name}/binary.rbxm`, outdated
    )
end

if (process.args[2] == "--all") then
    require("@self/stream");
end

return nil;
