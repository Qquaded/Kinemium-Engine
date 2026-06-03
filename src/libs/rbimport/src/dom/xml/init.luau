--!strict
--!native
--!optimize 2
local polyfill = require("@polyfill");
local base64 = polyfill.base64;
local blake2 = polyfill.blake2;

local ansi = require("./lib/ansi");
local int64 = require("./lib/int64");

local roblox = require("./roblox");
local datatypes = require("../datatypes");
local reflection = require("../reflection");

local xml = require("@self/xml");

local style = ansi.style;
local reset = ansi.reset;

local SER_TAG = `[dom{style("dim")}::{ansi.color("yellow")}serialize{reset()}]`;
local DES_TAG = `[dom{style("dim")}::{ansi.color("green")}deserialize{reset()}]`;

local log = function(...)
    print(...)
end;

type Instance = roblox.Instance;
type Document = roblox.Document;
type Signature = roblox.Signature;
type Property = roblox.Property;
type DocumentInfo = roblox.DocumentInfo;

local function findPropertyFromClass(class: reflection.ClassInfo, propertyName: string): reflection.PropertyMemberInfo?
    for _, member in class.Members do
        if (member.MemberType == "Property" and member.Name == propertyName) then
            return member :: reflection.PropertyMemberInfo;
        end
    end
    if (class.Superclass ~= "<<<ROOT>>>") then
        local super = assert(reflection:GetClass(class.Superclass), `Missing superclass`);
        return findPropertyFromClass(super, propertyName);
    end
    return nil;
end

local function newStringNode(tag: string, value: string, attributes: {[string]: string}?): xml.Node
    return {
        tag = tag,
        attributes = attributes or {},
        children = value,
    }
end

local function newRawStringNode(tag: string, value: string, attributes: {[string]: string}?): xml.Node
    return {
        tag = tag,
        attributes = attributes or {},
        children = value,
        raw = true,
    }
end

local PropertySerializerMap: {[string]: (Property) -> xml.Node} = {
    ["string"] = function(value: Property): xml.Node
        return newStringNode("string", value.value);
    end,
    ["BinaryString"] = function(value: Property): xml.Node
        local base64 = base64.encode(value.value):gsub(("."):rep(72), function(s)
            return `{s}\n`;
        end);
        return {
            tag = "BinaryString",
            attributes = {},
            cdata = true,
            children = base64,
        }
    end,
    ["bool"] = function(value: Property): xml.Node
        return newStringNode("bool", tostring(value.value));
    end,
    ["int"] = function(value: Property): xml.Node
        return newStringNode("int", tostring(value.value // 1));
    end,
    ["float"] = function(value: Property): xml.Node
        return newStringNode("float", tostring(value.value));
    end,
    ["double"] = function(value: Property): xml.Node
        return newStringNode("double", tostring(value.value));
    end,
    ["UDim"] = function(value: Property): xml.Node
        local S, O = datatypes.UDim.Serialize(value.value);
        return {
            tag = "UDim",
            attributes = {},
            children = {
                newStringNode("S", tostring(S));
                newStringNode("O", tostring(O));
            }
        }
    end,
    ["UDim2"] = function(value: Property): xml.Node
        local XS, XO, YS, YO = datatypes.UDim2.Serialize(value.value);
        return {
            tag = "UDim2",
            attributes = {},
            children = {
                newStringNode("XS", tostring(XS));
                newStringNode("XO", tostring(XO));
                newStringNode("YS", tostring(YS));
                newStringNode("YO", tostring(YO));
            }
        }
    end,
    ["Ray"] = function(value: Property): xml.Node
        local OX, OY, OZ, DX, DY, DZ = datatypes.Ray.Serialize(value.value);
        return {
            tag = "Ray",
            attributes = {},
            children = {
                {
                    tag = "origin",
                    attributes = {},
                    children = {
                        newStringNode("X", tostring(OX));
                        newStringNode("Y", tostring(OY));
                        newStringNode("Z", tostring(OZ));
                    },
                };
                {
                    tag = "direction",
                    attributes = {},
                    children = {
                        newStringNode("X", tostring(DX));
                        newStringNode("Y", tostring(DY));
                        newStringNode("Z", tostring(DZ));
                    },
                }
            },
        }
    end,
    ["Faces"] = function(value: Property): xml.Node
        local flag = datatypes.Faces.Serialize(value.value);
        return {
            tag = "Faces",
            attributes = {},
            children = {
                newStringNode("faces", tostring(flag));
            },
        }
    end,
    ["Axes"] = function(value: Property): xml.Node
        local flag = datatypes.Axes.Serialize(value.value);
        return {
            tag = "Axes",
            attributes = {},
            children = {
                newStringNode("axes", tostring(flag));
            },
        }
    end,
    ["BrickColor"] = function(value: Property): xml.Node
        local number = datatypes.BrickColor.Serialize(value.value);
        return newStringNode("int", tostring(number));
    end,
    ["Color3"] = function(value: Property): xml.Node
        local R, G, B = datatypes.Color3.Serialize(value.value, false);
        return {
            tag = "Color3",
            attributes = {},
            children = {
                newStringNode("R", tostring(R));
                newStringNode("G", tostring(G));
                newStringNode("B", tostring(B));
            },
        }
    end,
    ["Vector2"] = function(value: Property): xml.Node
        local X, Y = datatypes.Vector2.Serialize(value.value);
        return {
            tag = "Vector2",
            attributes = {},
            children = {
                newStringNode("X", tostring(X));
                newStringNode("Y", tostring(Y));
            },
        }
    end,
    ["Vector3"] = function(value: Property): xml.Node
        local X, Y, Z = datatypes.Vector3.Serialize(value.value);
        return {
            tag = "Vector3",
            attributes = {},
            children = {
                newStringNode("X", tostring(X));
                newStringNode("Y", tostring(Y));
                newStringNode("Z", tostring(Z));
            },
        }
    end,
    ["CFrame"] = function(value: Property): xml.Node
        local X, Y, Z, R00, R01, R02, R10, R11, R12, R20, R21, R22 = datatypes.CFrame.Serialize(value.value);
        return {
            tag = "CoordinateFrame",
            attributes = {},
            children = {
                newStringNode("X", tostring(X):upper());
                newStringNode("Y", tostring(Y):upper());
                newStringNode("Z", tostring(Z):upper());
                newStringNode("R00", tostring(R00):upper());
                newStringNode("R01", tostring(R01):upper());
                newStringNode("R02", tostring(R02):upper());
                newStringNode("R10", tostring(R10):upper());
                newStringNode("R11", tostring(R11):upper());
                newStringNode("R12", tostring(R12):upper());
                newStringNode("R20", tostring(R20):upper());
                newStringNode("R21", tostring(R21):upper());
                newStringNode("R22", tostring(R22):upper());
            },
        }
    end,
    ["Vector3int16"] = function(value: Property): xml.Node
        local X, Y, Z = datatypes.Vector3int16.Serialize(value.value);
        return {
            tag = "Vector3int16",
            attributes = {},
            children = {
                newStringNode("X", tostring(X // 1));
                newStringNode("Y", tostring(Y // 1));
                newStringNode("Z", tostring(Z // 1));
            },
        }
    end,
    ["NumberSequence"] = function(value: Property): xml.Node
        local content = {}
        for i, keypoint in datatypes.NumberSequence.Serialize(value.value) do
            local time, v, envelope = datatypes.NumberSequenceKeypoint.Serialize(keypoint);
            table.insert(content, tostring(time));
            table.insert(content, tostring(v));
            table.insert(content, tostring(envelope));
        end
        table.insert(content, ""); -- trailing space
        return newStringNode("NumberSequence", table.concat(content, " "));
    end,
    ["ColorSequence"] = function(value: Property): xml.Node
        local content = {}
        for i, keypoint in datatypes.ColorSequence.Serialize(value.value) do
            local time, color, envelope = datatypes.ColorSequenceKeypoint.Serialize(keypoint);
            local R, G, B = datatypes.Color3.Serialize(color, false);
            table.insert(content, tostring(time));
            table.insert(content, tostring(R));
            table.insert(content, tostring(G));
            table.insert(content, tostring(B));
            table.insert(content, tostring(envelope));
        end
        table.insert(content, ""); -- trailing space
        return newStringNode("ColorSequence", table.concat(content, " "));
    end,
    ["NumberRange"] = function(value: Property): xml.Node
        local min, max = datatypes.NumberRange.Serialize(value.value);
        return {
            tag = "NumberRange",
            attributes = {},
            children = `{min} {max} `,
        }
    end,
    ["Rect"] = function(value: Property): xml.Node
        local minX, minY, maxX, maxY = datatypes.Rect.Serialize(value.value);
        return {
            tag = "Rect2D",
            attributes = {},
            children = {
                {
                    tag = "min",
                    attributes = {},
                    children = {
                        newStringNode("X", tostring(minX));
                        newStringNode("Y", tostring(minY));
                    },
                };
                {
                    tag = "max",
                    attributes = {},
                    children = {
                        newStringNode("X", tostring(maxX));
                        newStringNode("Y", tostring(maxY));
                    },
                }
            },
        }
    end,
    ["PhysicalProperties"] = function(value: Property): xml.Node
        if (value.value) then
            local density, friction, elasticity, frictionWeight, elasticityWeight, acousticAbsorption = datatypes.PhysicalProperties.Serialize(value.value);
            return {
                tag = "PhysicalProperties",
                attributes = {},
                children = {
                    newStringNode("CustomPhysics", "true"),
                    newStringNode("Density", tostring(density));
                    newStringNode("Friction", tostring(friction));
                    newStringNode("Elasticity", tostring(elasticity));
                    newStringNode("FrictionWeight", tostring(frictionWeight));
                    newStringNode("ElasticityWeight", tostring(elasticityWeight));
                    newStringNode("AcousticAbsorption", tostring(acousticAbsorption));
                },
            }
        end
        return {
            tag = "PhysicalProperties",
            attributes = {},
            children = {
                newStringNode("CustomPhysics", "false"),
            },
        }
    end,
    ["Color3uint8"] = function(value: Property): xml.Node
        local R, G, B = datatypes.Color3.Serialize(value.value, true);
        local hex = string.format("FF%02X%02X%02X", R, G, B);
        return {
            tag = "Color3uint8",
            attributes = {},
            children = `{tonumber(hex, 16)}`,
        }
    end,
    ["int64"] = function(value: Property): xml.Node
        return newStringNode("int64", int64.to_dec_string(int64.from_buffer(value.value)));
    end,
    ["ProtectedString"] = function(value: Property): xml.Node
        return {
            tag = "ProtectedString",
            attributes = {},
            cdata = true,
            children = value.value,
        };
    end,
    ["OptionalCoordinateFrame"] = function(value: Property): xml.Node
        if (value.value) then
            local X, Y, Z, R00, R01, R02, R10, R11, R12, R20, R21, R22 = datatypes.CFrame.Serialize(value.value);
            return {
                tag = "OptionalCoordinateFrame",
                attributes = {},
                children = {
                    {
                        tag = "CFrame",
                        attributes = {},
                        children = {
                            newStringNode("X", tostring(X):upper());
                            newStringNode("Y", tostring(Y):upper());
                            newStringNode("Z", tostring(Z):upper());
                            newStringNode("R00", tostring(R00):upper());
                            newStringNode("R01", tostring(R01):upper());
                            newStringNode("R02", tostring(R02):upper());
                            newStringNode("R10", tostring(R10):upper());
                            newStringNode("R11", tostring(R11):upper());
                            newStringNode("R12", tostring(R12):upper());
                            newStringNode("R20", tostring(R20):upper());
                            newStringNode("R21", tostring(R21):upper());
                            newStringNode("R22", tostring(R22):upper());
                        },
                    },
                },
            }
        end
        return newStringNode("OptionalCoordinateFrame", "");
    end,
    ["UniqueId"] = function(value: Property): xml.Node
        local random, index, time = datatypes.UniqueId.Serialize(value.value);
        local hex = string.format(
            "%02x%02x%02x%02x%02x%02x%02x%02x%08x%08x",
            buffer.readu8(random, 0),
            buffer.readu8(random, 1),
            buffer.readu8(random, 2),
            buffer.readu8(random, 3),
            buffer.readu8(random, 4),
            buffer.readu8(random, 5),
            buffer.readu8(random, 6),
            buffer.readu8(random, 7),
            bit32.band(time, 0xFFFFFFFF),
            bit32.band(index, 0xFFFFFFFF)
        )
        assert(#hex == 32, "invalid UniqueId hex length");
        return newStringNode("UniqueId", hex);
    end,
    ["Font"] = function(value: Property): xml.Node
        local font = value.value;
        local url, weight, style, cache_id = font.Family, font.Weight.Value, font.Style.Name, font.CacheId
        return {
            tag = "Font",
            attributes = {},
            children = {
                newRawStringNode("Family", xml.stringify(newStringNode("url", url or error("missing url"))));
                newStringNode("Weight", tostring(weight));
                newStringNode("Style", style);
                if (cache_id) then
                    newRawStringNode("CachedFaceId", xml.stringify(newStringNode("url", cache_id)))
                else
                    nil :: any,
            },
        }
    end,
    ["SecurityCapabilities"] = function(value: Property): xml.Node
        return newStringNode("SecurityCapabilities", int64.to_dec_string(int64.from_buffer(value.value)));
    end,
    ["Content"] = function(value: Property): xml.Node
        local type, url = datatypes.Content.Serialize(value.value);
        if (type == 0) then
            return newRawStringNode("Content", "<null></null>");
        elseif (type == 1) then
            return newRawStringNode("Content", xml.stringify(newStringNode("url", url or error("missing url"))));
        else
            error("Unsupported object source type");
        end
    end,
    ["ContentId"] = function(value: Property): xml.Node
        local url = value.value;
        if (url == "") then
            return newRawStringNode("Content", "<null></null>");
        else
            return newRawStringNode("Content", xml.stringify(newStringNode("url", url)));
        end
    end,
}

local function serialize(doc: Document): buffer
    local xml_doc: xml.Node = {
        tag = "roblox",
        attributes = {
            ["xmlns:xmime"] = "http://www.w3.org/2005/05/xmlmime",
            ["xmlns:xsi"] = "http://www.w3.org/2001/XMLSchema-instance",
            ["xsi:noNamespaceSchemaLocation"] = "http://www.roblox.com/roblox.xsd",
            ["version"] = "4",
        },
        children = {
            newStringNode("External", "null"),
            newStringNode("External", "nil"),
        },
    }

    for meta, value in doc.metadata do
        table.insert(xml_doc.children :: any, newStringNode("Meta", value, {name = meta}));
    end

    local xml_instances: {xml.Node} = {};

    for i, instance in doc.instances do
        local properties: xml.Node = {
            tag = "Properties",
            attributes = {},
            children = {},
        };
        for name, prop in instance.properties do
            local class = assert(reflection:GetClass(instance.className), `Missing class {instance.className}`);
            local member = assert(findPropertyFromClass(class, name), `Missing property {name} in class {instance.className}`);
            if (not member.Serialization.CanSave) then
                continue;
            end
            if (member.ValueType.Category == "Class") then
                if (prop.value and not doc.instances[prop.value]) then
                    error(`Instance {i} has property '{name}' referencing missing instance '{prop.value}'`);
                end
                local node: xml.Node = {
                    tag = "Ref",
                    attributes = {
                        ["name"] = name,
                    },
                    children = `{if (prop.value) then `RBX{blake2.b128(`{prop.value}`, "hex"):upper()}` else "null"}`,
                };
                table.insert(properties.children :: any, node);
            elseif (member.ValueType.Category == "Enum") then
                local node: xml.Node = {
                    tag = "token",
                    attributes = {
                        ["name"] = name,
                    },
                    children = `{prop.value.Value}`,
                };
                table.insert(properties.children :: any, node);
            else
                if (member.ValueType.Name == "SharedString") then
                    local node = {
                        tag = "SharedString",
                        attributes = {
                            name = name,
                        },
                        children = prop.value,
                    };
                    table.insert(properties.children :: any, node);
                    continue;
                elseif (member.ValueType.Name == "NetAssetRef") then
                    local node = {
                        tag = "NetAssetRef",
                        attributes = {
                            name = name,
                        },
                        children = prop.value,
                    };
                    table.insert(properties.children :: any, node);
                    continue;
                end
                if (member.ValueType.Name == "Content") then
                    continue; -- ContentId is serialized instead
                end
                local serializer = PropertySerializerMap[member.ValueType.Name] or error(`No serializer for property type {member.ValueType.Name}`);
                local node = serializer(prop);
                node.attributes.name = name;
                table.insert(properties.children :: any, node);
            end
        end
        xml_instances[i] = {
            tag = "Item",
            attributes = {
                ["class"] = instance.className,
                ["referent"] = `RBX{blake2.b128(`{i}`, "hex"):upper()}`,
            },
            children = {
                properties
            },
        };
    end

    for i, instance in doc.instances do
        if (instance.parent) then
            local parent = xml_instances[instance.parent];
            assert(parent, "Parent instance not found");
            local child = xml_instances[i];
            table.insert(parent.children :: any, child);
        else
            table.insert(xml_doc.children :: any, xml_instances[i]);
        end
    end

    local sharedstrings: xml.Node = {
        tag = "SharedStrings",
        attributes = {},
        children = {},
    }
    for md5, value in doc.sharedstrings do
        local base64 = base64.encode(value):gsub(("."):rep(72), function(s)
            return `{s}\n`;
        end);
        table.insert(sharedstrings.children :: any, newStringNode("SharedString", base64, {md5 = md5}));
    end
    if (sharedstrings.children :: any)[1] then
        table.insert(xml_doc.children :: any, sharedstrings);
    end

    return buffer.fromstring(xml.stringify(xml_doc));
end

local function walk(node: xml.Node, action: (xml.Node) -> boolean, exit: (xml.Node) -> ()): ()
    if (not action(node)) then
        return;
    end
    if (type(node.children) == "table") then
        for _, child in node.children do
            walk(child, action, exit);
        end
    end
    exit(node);
end

local function getDefaultEnum(enum: datatypes.Enum, member: any): datatypes.EnumItem?
    local default = member.Default;
    if (not default) then
        return nil;
    end
    return enum[default];
end

local TRANSLATE_CLASS_PROP = {
    ["CFrame"] = {"CoordinateFrame"};
    ["OptionalCFrame"] = {"OptionalCoordinateFrame"};
    ["Rect"] = {"Rect2D"};
    ["BrickColor"] = {"int", "BrickColor"};
    ["ContentId"] = {"Content"};
}

local function findNode(prop: xml.Node, search: string): xml.Node?
    if (type(prop.children) ~= "table") then
        return nil;
    end
    for _, node in prop.children do
        if (node.tag == search) then
           return node;
        end
    end
    return;
end

local function readNode(prop: xml.Node, search: string): string
    local node = findNode(prop, search);
    assert(node, `{search} not found`);
    assert(type(node.children) == "string", `{search} without text`);
    return node.children;
end

local function readAnyNode(prop: xml.Node, search: string): string?
    local node = findNode(prop, search);
    if (not node) then
        return nil;
    end
    assert(type(node.children) == "string", `{search} without text`);
    return node.children;
end

local function readFloatList(prop: xml.Node, list: {string}): {[string]: number}
    local scan_list = table.clone(list);
    local results = {};
    assert(type(prop.children) == "table", "node without children");
    for _, node in prop.children do
        if #scan_list == 0 then
            break;
        end
        for i, scan in scan_list do
            if (node.tag == scan) then
                assert(type(node.children) == "string", `{scan} without text`);
                local value = tonumber(node.children) or error("failed to parse float");
                results[scan] = value;
                table.remove(scan_list, i);
                break;
            end
        end
    end
    assert(#scan_list == 0, "incomplete list");
    return results;
end

local PropertyDeserializerMap = {
    ["string"] = function(inst: roblox.Instance, prop: xml.Node): roblox.Property
        assert(type(prop.children) == "string", "property without text");
        return {
            type = roblox.PropertyTypes.String,
            value = prop.children,
        }
    end,
    ["BinaryString"] = function(inst: roblox.Instance, prop: xml.Node): roblox.Property
        assert(type(prop.children) == "string", "property without text");
        local base64 = prop.children;
        local decoded = polyfill.base64.decode(base64:gsub("\n", ""));
        return {
            type = roblox.PropertyTypes.String,
            value = decoded,
        }
    end,
    ["bool"] = function(inst: roblox.Instance, prop: xml.Node): roblox.Property
        assert(type(prop.children) == "string", "property without text");
        local value = string.lower(prop.children) == "true"
        return {
            type = roblox.PropertyTypes.Bool,
            value = value,
        }
    end,
    ["int"] = function(inst: roblox.Instance, prop: xml.Node): roblox.Property
        assert(type(prop.children) == "string", "property without text");
        local value = tonumber(prop.children) or error("failed to parse int");
        return {
            type = roblox.PropertyTypes.Int,
            value = value,
        }
    end,
    ["float"] = function(inst: roblox.Instance, prop: xml.Node): roblox.Property
        assert(type(prop.children) == "string", "property without text");
        local value = tonumber(prop.children) or error("failed to parse float");
        return {
            type = roblox.PropertyTypes.Float,
            value = value,
        }
    end,
    ["double"] = function(inst: roblox.Instance, prop: xml.Node): roblox.Property
        assert(type(prop.children) == "string", "property without text");
        local value = tonumber(prop.children) or error("failed to parse double");
        return {
            type = roblox.PropertyTypes.Double,
            value = value,
        }
    end,
    ["UDim"] = function(inst: roblox.Instance, prop: xml.Node): roblox.Property
        assert(type(prop.children) == "table", "property without children");
        local res = readFloatList(prop, {"S", "O"});
        return {
            type = roblox.PropertyTypes.UDim,
            value = datatypes.UDim.Deserialize(res.S, res.O),
        }
    end,
    ["UDim2"] = function(inst: roblox.Instance, prop: xml.Node): roblox.Property
        assert(type(prop.children) == "table", "property without children");
        local res = readFloatList(prop, {"XS", "XO", "YS", "YO"});
        return {
            type = roblox.PropertyTypes.UDim2,
            value = datatypes.UDim2.Deserialize(res.XS, res.XO, res.YS, res.YO),
        }
    end,
    ["Ray"] = function(inst: roblox.Instance, prop: xml.Node): roblox.Property
        local origin = findNode(prop, "origin");
        local direction = findNode(prop, "direction");
        assert(origin, "Ray without Origin");
        assert(direction, "Ray without Direction");
        local pos = readFloatList(origin, {"X", "Y", "Z"});
        local dir = readFloatList(direction, {"X", "Y", "Z"});
        return {
            type = roblox.PropertyTypes.Ray,
            value = datatypes.Ray.Deserialize(pos.X, pos.Y, pos.Z, dir.X, dir.Y, dir.Z),
        }
    end,
    ["Faces"] = function(inst: roblox.Instance, prop: xml.Node): roblox.Property
        local flags_node = findNode(prop, "faces")
        assert(flags_node, "Faces without faces");
        assert(type(flags_node.children) == "string", "property without text");
        local flags = tonumber(flags_node.children) or error("failed to parse int");
        flags = math.floor(flags);
        return {
            type = roblox.PropertyTypes.Faces,
            value = datatypes.Faces.Deserialize(flags),
        }
    end,
    ["Axes"] = function(inst: roblox.Instance, prop: xml.Node): roblox.Property
        local flags_node = findNode(prop, "axes")
        assert(flags_node, "Axes without axes");
        assert(type(flags_node.children) == "string", "property without text");
        local flags = tonumber(flags_node.children) or error("failed to parse int");
        flags = math.floor(flags);
        return {
            type = roblox.PropertyTypes.Axes,
            value = datatypes.Axes.Deserialize(flags),
        }
    end,
    ["BrickColor"] = function(inst: roblox.Instance, prop: xml.Node): roblox.Property
        assert(type(prop.children) == "string", "property without text");
        local value = tonumber(prop.children) or error("failed to parse int");
        value = math.floor(value);
        local color = datatypes.BrickColor.Deserialize(value);
        return {
            type = roblox.PropertyTypes.BrickColor,
            value = color,
        }
    end,
    ["Color3"] = function(inst: roblox.Instance, prop: xml.Node): roblox.Property
        assert(type(prop.children) == "table", "node without children");
        local res = readFloatList(prop, {"R", "G", "B"});
        return {
            type = roblox.PropertyTypes.Color3,
            value = datatypes.Color3.Deserialize(res.R, res.G, res.B, false),
        }
    end,
    ["Vector2"] = function(inst: roblox.Instance, prop: xml.Node): roblox.Property
        local res = readFloatList(prop, {"X", "Y"});
        return {
            type = roblox.PropertyTypes.Vector2,
            value = datatypes.Vector2.Deserialize(res.X, res.Y),
        }
    end,
    ["Vector3"] = function(inst: roblox.Instance, prop: xml.Node): roblox.Property
        local res = readFloatList(prop, {"X", "Y", "Z"});
        return {
            type = roblox.PropertyTypes.Vector3,
            value = datatypes.Vector3.Deserialize(res.X, res.Y, res.Z),
        }
    end,
    ["CFrame"] = function(inst: roblox.Instance, prop: xml.Node): roblox.Property
        local res = readFloatList(prop, {"X", "Y", "Z", "R00", "R01", "R02", "R10", "R11", "R12", "R20", "R21", "R22"});
        return {
            type = roblox.PropertyTypes.CFrame,
            value = datatypes.CFrame.Deserialize(
                res.X, res.Y, res.Z,
                res.R00, res.R01, res.R02,
                res.R10, res.R11, res.R12,
                res.R20, res.R21, res.R22
            ),
        }
    end,
    ["Vector3int16"] = function(inst: roblox.Instance, prop: xml.Node): roblox.Property
        local res = readFloatList(prop, {"X", "Y", "Z"});
        return {
            type = roblox.PropertyTypes.Vector3int16,
            value = datatypes.Vector3int16.Deserialize(math.floor(res.X), math.floor(res.Y), math.floor(res.Z)),
        }
    end,
    ["NumberSequence"] = function(inst: roblox.Instance, prop: xml.Node): roblox.Property
        assert(type(prop.children) == "string", "node without text");
        local points = {};
        local seq = prop.children:split(" ");
        for i = 1, #seq // 3 do
            local index = ((i - 1) * 3) + 1;
            local time = tonumber(seq[index]) or error("failed to parse float");
            local value = tonumber(seq[index + 1]) or error("failed to parse float");
            local envelope = tonumber(seq[index + 2]) or error("failed to parse float");
            points[i] = datatypes.NumberSequenceKeypoint.Deserialize(time, value, envelope)
        end
        return {
            type = roblox.PropertyTypes.NumberSequence,
            value = datatypes.NumberSequence.Deserialize(points),
        }
    end,
    ["ColorSequence"] = function(inst: roblox.Instance, prop: xml.Node): roblox.Property
        assert(type(prop.children) == "string", "node without text");
        local points = {};
        local seq = prop.children:split(" ");
        for i = 1, #seq // 5 do
            local index = ((i - 1) * 5) + 1;
            local time = tonumber(seq[index]) or error("failed to parse float");
            local r = tonumber(seq[index + 1]) or error("failed to parse float");
            local g = tonumber(seq[index + 2]) or error("failed to parse float");
            local b = tonumber(seq[index + 3]) or error("failed to parse float");
            local envelope = tonumber(seq[index + 4]) or error("failed to parse float");
            points[i] = datatypes.ColorSequenceKeypoint.Deserialize(time, datatypes.Color3.Deserialize(r, g, b, false), envelope)
        end
        return {
            type = roblox.PropertyTypes.ColorSequence,
            value = datatypes.ColorSequence.Deserialize(points),
        }
    end,
    ["NumberRange"] = function(inst: roblox.Instance, prop: xml.Node): roblox.Property
        assert(type(prop.children) == "string", "node without text");
        local res = prop.children:split(" ");
        local min = tonumber(res[1]) or error("failed to parse float");
        local max = tonumber(res[2]) or error("failed to parse float");
        return {
            type = roblox.PropertyTypes.NumberRange,
            value = datatypes.NumberRange.Deserialize(min, max),
        }
    end,
    ["Rect"] = function(inst: roblox.Instance, prop: xml.Node): roblox.Property
        local min_node = findNode(prop, "min");
        local max_node = findNode(prop, "max");
        assert(min_node, "Rect without min");
        assert(max_node, "Rect without max");
        local min = readFloatList(min_node, {"X", "Y"});
        local max = readFloatList(max_node, {"X", "Y"});
        return {
            type = roblox.PropertyTypes.Rect,
            value = datatypes.Rect.Deserialize(min.X, min.Y, max.X, max.Y),
        }
    end,
    ["PhysicalProperties"] = function(inst: roblox.Instance, prop: xml.Node): roblox.Property
        local CustomPhysics_node = findNode(prop, "CustomPhysics");
        assert(CustomPhysics_node, "PhysicalProperties without CustomPhysics");
        assert(type(CustomPhysics_node.children) == "string", "CustomPhysics without text");
        local is_custom = string.lower(CustomPhysics_node.children) == "true";
        local value = nil;
        if (is_custom) then
            local density = tonumber(readNode(prop, "Density")) or error("failed to parse float");
            local friction = tonumber(readNode(prop, "Friction")) or error("failed to parse float");
            local elasticity = tonumber(readNode(prop, "Elasticity")) or error("failed to parse float");
            local frictionWeight = tonumber(readNode(prop, "FrictionWeight")) or error("failed to parse float");
            local elasticityWeight = tonumber(readNode(prop, "ElasticityWeight")) or error("failed to parse float");
            local acousticAbsorption = tonumber(readAnyNode(prop, "AcousticAbsorption") or 1) or error("failed to parse float");
            value = datatypes.PhysicalProperties.Deserialize(density, friction, elasticity, frictionWeight, elasticityWeight, acousticAbsorption);
        end
        return {
            type = roblox.PropertyTypes.PhysicalProperties,
            value = value,
        }
    end,
    ["Color3uint8"] = function(inst: roblox.Instance, prop: xml.Node): roblox.Property
        assert(type(prop.children) == "string", "node without text");
        local value = tonumber(prop.children) or error("failed to parse int");
        value = math.floor(value);
        local R = bit32.rshift(bit32.band(value, 0xFF0000), 16);
        local G = bit32.rshift(bit32.band(value, 0x00FF00), 8);
        local B = bit32.band(value, 0x0000FF);
        return {
            type = roblox.PropertyTypes.Color3uint8,
            value = datatypes.Color3.Deserialize(R, G, B, true),
        }
    end,
    ["int64"] = function(inst: roblox.Instance, prop: xml.Node): roblox.Property
        -- WARNING: precision loss
        assert(type(prop.children) == "string", "property without text");
        local value = tonumber(prop.children) or error("failed to parse int64");
        value = math.floor(value);
        return {
            type = roblox.PropertyTypes.Int64,
            value = int64.to_buffer(int64.from_f64(value)),
        }
    end,
    -- ["SharedString"] = function(inst: roblox.Instance, prop: xml.Node): roblox.Property
    --     assert(type(prop.children) == "string", "property without text");
    --     local value = prop.children;
    --     return {
    --         type = roblox.PropertyTypes.SharedString,
    --         value = value,
    --     }
    -- end,
    ["ProtectedString"] = function(inst: roblox.Instance, prop: xml.Node): roblox.Property
        assert(type(prop.children) == "string", "property without text");
        return {
            type = roblox.PropertyTypes.String,
            value = prop.children,
        }
    end,
    ["OptionalCoordinateFrame"] = function(inst: roblox.Instance, prop: xml.Node): roblox.Property
        local cframe_node = findNode(prop, "CFrame");
        if (cframe_node) then
            local res = readFloatList(cframe_node, {"X", "Y", "Z", "R00", "R01", "R02", "R10", "R11", "R12", "R20", "R21", "R22"});
            return {
                type = roblox.PropertyTypes.OptionalCFrame,
                value = datatypes.CFrame.Deserialize(
                    res.X, res.Y, res.Z,
                    res.R00, res.R01, res.R02,
                    res.R10, res.R11, res.R12,
                    res.R20, res.R21, res.R22
                ),
            }
        end
        return {
            type = roblox.PropertyTypes.OptionalCFrame,
            value = nil,
        }
    end,
    ["UniqueId"] = function(inst: roblox.Instance, prop: xml.Node): roblox.Property
        assert(type(prop.children) == "string", "property without text");
        assert(#prop.children == 32, "invalid UniqueId");
        assert(prop.children:match("^[0-9a-fA-F]+$"), "invalid UniqueId hex value");
        local random = prop.children:sub(1, 16);
        local time = tonumber(prop.children:sub(16, 24), 16) or error("failed to parse hex");
        local index = tonumber(prop.children:sub(24, 32), 16) or error("failed to parse hex");
        local pos = 0
        local random_buf = buffer.create(8);
        random:gsub("..", function(hex)
            buffer.writeu8(random_buf, pos, tonumber(hex, 16) or error("unreachable"));
            pos += 1;
            return "";
        end);
        return {
            type = roblox.PropertyTypes.UniqueId,
            value = datatypes.UniqueId.Deserialize(random_buf, index, time),
        }
    end,
    ["Font"] = function(inst: roblox.Instance, prop: xml.Node): roblox.Property
        local family_node = findNode(prop, "Family") or {
            children = {
                {
                    tag = "url",
                    children = "rbxasset://fonts/families/SourceSansPro.json",
                }
            },
        };
        local weight_text = readAnyNode(prop, "Weight") or "400";
        local style_text = readAnyNode(prop, "Style") or "Normal";
        assert(family_node, "Font missing Family");
        assert(type(family_node.children) == "table", "Family without children");
        local family = readNode(family_node :: any, "url");
        local weight = tonumber(weight_text) or error("failed to parse int");
        local cacheId_node = findNode(prop, "CachedFaceId");
        local cacheId = "";
        if (cacheId_node) then
            assert(type(cacheId_node.children) == "table", "CachedFaceId without children");
            cacheId = readNode(cacheId_node, "url");
        end
        local font = datatypes.Enums.DataType.FontStyle[style_text] or error("invalid Font Style");
        return {
            type = roblox.PropertyTypes.Font,
            value = datatypes.Font.Deserialize(family, weight, font.Value, cacheId),
        }
    end,
    ["SecurityCapabilities"] = function(inst: roblox.Instance, prop: xml.Node): roblox.Property
        -- WARNING: precision loss
        assert(type(prop.children) == "string", "property without text");
        local value = tonumber(prop.children) or error("failed to parse int64");
        return {
            type = roblox.PropertyTypes.SecurityCapabilities,
            value = int64.to_buffer(int64.from_f64(value)),
        }
    end,
    ["Content"] = function(inst: roblox.Instance, prop: xml.Node): roblox.Property
        assert(type(prop.children) == "table", "property without children");
        local url_node = findNode(prop, "url");
        local url: string? = nil;
        if (url_node) then
            assert(type(url_node.children) == "string", "url without text");
            url = url_node.children;
        end
        return {
            type = roblox.PropertyTypes.Content,
            value = datatypes.Content.Deserialize(
                if (url) then 1 else 0,
                url,
                nil
            ),
        }
    end,
    ["ContentId"] = function(inst: roblox.Instance, prop: xml.Node): roblox.Property
        assert(type(prop.children) == "table", "property without children");
        local url_node = findNode(prop, "url");
        local url: string = "";
        if (url_node) then
            assert(type(url_node.children) == "string", "url without text");
            url = url_node.children;
        end
        return {
            type = roblox.PropertyTypes.String,
            value = url,
        }
    end,
}

local function deserialize(slice: buffer): Document
    if (buffer.len(slice) < 5) then
        error("Bad slice length");
    end
    local xml_doc = xml.parse(slice);
    assert(xml_doc, "failed to parse XML");
    assert(xml_doc.tag == "roblox", "invalid XML format");
    assert(type(xml_doc.children) == "table", "invalid roblox XML format");

    local ref_counter = 0;
    local instances: {roblox.Instance} = {};
    local class_map: {[string]: roblox.Class} = {};
    local ref_map: {[string]: {ref: number, instance: roblox.Instance}} = {};
    local metadata: {[string]: string} = {};
    local sharedstrings: {[string]: roblox.SharedString} = {};

    local post_ref: {roblox.Property} = {};

    for i = #xml_doc.children, 1, -1 do
        local child = xml_doc.children[i];
        if (child.tag == "SharedStrings") then
            assert(type(child.children) == "table", "SharedStrings without children");
            for _, str_node in child.children do
                if (str_node.tag ~= "SharedString") then
                    continue;
                end
                local md5 = str_node.attributes.md5;
                assert(md5, "SharedString without md5");
                assert(type(str_node.children) == "string", "SharedString without text");
                sharedstrings[md5] = base64.decode(str_node.children:gsub("\n", ""));
            end
            break;
        end
    end

    for _, child in xml_doc.children do
        local parent_stack: {{node: xml.Node, ref: number}} = {};
        walk(child, function(node: xml.Node)
            if (node.tag == "Meta") then
                assert(#parent_stack == 0, "Meta cannot have parent");
                local name = node.attributes.name;
                assert(name, "Meta without name");
                assert(type(node.children) == "string", "Meta without text");
                metadata[name] = node.children;
            elseif (node.tag == "External") then
                assert(#parent_stack == 0, "External cannot have parent");
            elseif (node.tag == "SharedStrings") then
                return false; -- already processed
            elseif (node.tag == "Properties") then
                local item = parent_stack[#parent_stack];
                assert(item, "Properties without parent");
                assert(type(node.children) == "table", "Properties without children");
                local instance = instances[item.ref];
                assert(instance, "unreachable");
                local class_api = reflection:GetClass(instance.className);
                assert(class_api, `Unknown class '{instance.className}'`);
                
                for _, prop_node in node.children do
                    local prop_name = prop_node.attributes.name;
                    assert(prop_name, "Property without name");
                    local prop_api = findPropertyFromClass(class_api, prop_name);
                    if (not prop_api) then
                        log(`{DES_TAG} Unknown property '{instance.className}.{prop_name}', skipping property (outdated?)`);
                        continue;
                    end
                    if (prop_api.ValueType.Category == "Class") then
                        assert(type(prop_node.children) == "string", "Ref property without text");
                        local is_null = prop_node.children:lower() == "null";
                        local existing = ref_map[prop_node.children];
                        instance.properties[prop_name] = {
                            type = roblox.PropertyTypes.Ref,
                            value = if (existing) then
                                    existing.ref
                                elseif (is_null) then
                                    nil
                                else
                                    prop_node.children,
                        }
                        if (not existing and not is_null) then
                            table.insert(post_ref, instance.properties[prop_name]);
                        end
                        continue;
                    elseif (prop_api.ValueType.Category == "Enum") then
                        if (prop_node.tag ~= "token") then
                            error(`Property type mismatch for '{instance.className}.{prop_name}' (expected 'token', got '{prop_node.tag}')`);
                        end
                        local enum = datatypes.Enums.DataType[prop_api.ValueType.Name];
                        if (enum) then
                            assert(type(prop_node.children) == "string", "Enum property without text");
                            local default = getDefaultEnum(enum, prop_api);
                            local items = enum:GetEnumItems();
                            local value = tonumber(prop_node.children);
                            local store = default;
                            for _, e in items do
                                if (e.Value == value) then
                                    store = e;
                                    break;
                                end
                            end
                            if (not store) then
                                error(`Invalid EnumArrayId: {value or "<none>"} ({enum.Name}) for {instance.className}.{prop_name} [{enum.Default}]`);
                            end
                            instance.properties[prop_name] = {
                                type = roblox.PropertyTypes.Enum,
                                value = store,
                            }
                        end
                    else
                        local names = TRANSLATE_CLASS_PROP[prop_api.ValueType.Name] or prop_api.ValueType.Name;
                        if (prop_node.tag ~= names and (typeof(names) ~= "table" or not table.find(names, prop_node.tag))) then
                            error(`Property type mismatch for '{instance.className}.{prop_name}' (expected '{prop_api.ValueType.Name}', got '{prop_node.tag}')`);
                        end;
                        local decoder_name = prop_api.ValueType.Name;
                        if (decoder_name == "SharedString") then
                            assert(type(prop_node.children) == "string", "SharedString property without text");
                            instance.properties[prop_name] = {
                                type = roblox.PropertyTypes.SharedString,
                                value = prop_node.children,
                            }
                            if (not sharedstrings[prop_node.children]) then
                                error(`{DES_TAG} Missing SharedString '{prop_node.children}' ('{instance.className}.{prop_name}')`);
                            end
                            continue
                        elseif (decoder_name == "NetAssetRef") then
                            assert(type(prop_node.children) == "string", "NetAssetRef property without text");
                            instance.properties[prop_name] = {
                                type = roblox.PropertyTypes.SharedString,
                                value = prop_node.children,
                            }
                            if (not sharedstrings[prop_node.children]) then
                                error(`{DES_TAG} Missing NetAssetRef '{prop_node.children}' ('{instance.className}.{prop_name}')`);
                            end
                            continue
                        end
                        local decoder = PropertyDeserializerMap[decoder_name];
                        if (not decoder) then
                            error(`No decoder for property type '{decoder_name}' ('{instance.className}.{prop_name}')`);
                        end
                        instance.properties[prop_name] = decoder(instance, prop_node, prop_api);
                    end
                end
                return false;
            elseif (node.tag == "Item") then
                local class_name = node.attributes.class;
                local referent = node.attributes.referent;
                assert(class_name, "Item without class");
                assert(referent, "Item without ref");

                local class_doc = class_map[class_name];
                if (not class_doc) then
                    local class_api = reflection:GetClass(class_name);
                    if (not class_api) then
                        log(`{DES_TAG} Unknown class '{class_name}', skipping instance`);
                        return false;
                    end
                    class_doc = {
                        index = 0,
                        name = node.attributes.class,
                        isService = if (class_api and class_api.Tags and table.find(class_api.Tags, "Service")) then true else false,
                        instances = {},
                    };
                    class_map[node.attributes.class] = class_doc;
                end

                ref_counter += 1;
                local parent = parent_stack[#parent_stack];
                local instance: roblox.Instance = {
                    className = class_name,
                    referent = ref_counter,
                    parent = if (parent) then parent.ref else nil,
                    properties = {},
                };

                ref_map[referent] = {instance = instance, ref = ref_counter};
                instances[ref_counter] = instance;
                table.insert(class_doc.instances, ref_counter);
                table.insert(parent_stack, {node = node, ref = ref_counter});

                return true;
            end
            return false;
        end, function(node: xml.Node)
            if (node.tag == "Item") then
                assert(#parent_stack > 0, "unreachable");
                table.remove(parent_stack);
            end
        end);
    end

    local sharedstring_array: {roblox.SharedString} = {};
    for key, sstr in sharedstrings do
        table.insert(sharedstring_array, sstr);
    end

    for _, prop in post_ref do
        assert(type(prop.value) == "string", "unreachable");
        local existing = ref_map[prop.value];
        if (existing) then
            prop.value = existing.ref;
        else
            log(`{DES_TAG} Missing ref '{prop.value}'`);
            prop.value = nil;
        end
    end

    local array_classes: {roblox.Class} = {};
    local class_counter = 0;
    for _, class in class_map do
        class_counter += 1;
        table.insert(array_classes, class);
        class.index = class_counter;
    end

    return {
        info = {
            version = 0,
            instances = #instances,
            classes = #array_classes,
            reserved = buffer.create(8),
        },
        classes = array_classes,
        instances = instances,
        sharedstrings = sharedstrings,
        metadata = metadata,
        signatures = nil,
    }
end

return {
    serialize = serialize;
    deserialize = deserialize;
    debug = function(callback: (...any) -> ())
        log = callback::any;
    end
};
