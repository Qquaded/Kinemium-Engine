--!strict
local fs = zune.fs
local process = zune.process
local testing = zune.testing

local test = testing.test
local describe = testing.describe

local lib = require("@roblox");

local dom = require("@roblox/dom");
dom.setDebugCallback("BINARY", print)

test("Deserialize and serialize place (Audio)", function()
end)

test("Deserialize and serialize place", function()
    local file = fs.readFile("./rbx-test-files/places/baseplate-566/binary.rbxl");
    local datamodel = lib.deserializePlace(file);
    local serialized = lib.serializePlace(datamodel);
    print(datamodel, serialized);
end)

test("Deserialize and serialize model", function()
    local file = fs.readFile("./rbx-test-files/models/attributes/binary.rbxm");
    local model = lib.deserializeModel(file);
    local serialized = lib.serializeModel(model);
    print(model, serialized);
end)

local function serializeDeserializeTest(name: string, path: string, outdated: boolean?)
    test(name, function()
        local file = fs.readFile(path, true);
        local model = lib.deserializeModel(file);
        local _ = lib.serializeModel(model);
    end)
end

local RBX = "./rbx-test-files";

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
    describe("DOM", function()
        describe("Binary", function()
            require("@self/dom/binary");
        end);
        describe("XML", function()
            require("@self/dom/xml");
        end);
    end);
end
