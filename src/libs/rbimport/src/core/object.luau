--!strict
local dom = require("../dom");
local datatypes = require("./datatypes");
local dom_datatypes = require("../datatypes");
local reflection = require("../reflection");

local presets = require("./presets");

local Signal = require("./signal");

type Signal = Signal.Signal;
type Instance = any;

local object = {};

local function isObject(value: any): boolean
    return type(value) == "table" and getmetatable(value) == object;
end
object.is = isObject;

local PROXY_MAP = newproxy(true);

getmetatable(PROXY_MAP).__index = reflection.API_CLASS_MAP;

local function blankFromClass(className: string): object
    local class = reflection:GetClass(className);
    if (not class) then
        error(`Class "{className}" not found (maybe outdated?)`);
    end
    local is_service =
        if (class.Tags) then
            table.find(class.Tags, "Service") ~= nil
        else
            false;
    return setmetatable({
        ["@instance"] = {
            className = className,
            referent = -1,
            properties = {},
            parent = nil,
            isService = is_service,
        }::dom.DOMInstance,
        ["@children"] = {},
        ["@events"] = {}::{[string]: Signal},
        ["@parent"] = nil::object?,
        ["@destroyed"] = false,
        ["@internal_map"] = PROXY_MAP,
    }, object);
end

function object.dom(dom: dom.DOMInstance): object
    local blank = blankFromClass(dom.className);
    blank["@instance"] = dom;
    return blank;
end

function object.raw(className: string): object
    return blankFromClass(className);
end

export type object = typeof(blankFromClass(""));

local TYPE_MAP = {
    ["BinaryString"] = "String",
    ["ContentId"] = "String",
    ["int64"] = "Int64",
    ["bool"] = "Bool",
    ["string"] = "String",
    ["float"] = "Float",
    ["double"] = "Double",
    ["int"] = "Int",
};

local DEFAULT_TYPE_MAP = {
    ["BinaryString"] = function(className: string, superclass: string, property: string, default: string?)
        if (default and default ~= "__api_dump_class_not_creatable__") then
            return default;
        end
        return "";
    end,
    ["ContentId"] = function(className: string, superclass: string, property: string, default: string?)
        if (default and default ~= "__api_dump_class_not_creatable__") then
            return default;
        end
        return "";
    end,
    ["int64"] = function(className: string, superclass: string, property: string, default: string?)
        return buffer.create(8);
    end,
    ["bool"] = function(className: string, superclass: string, property: string, default: string?)
        if (not default) then
            return false;
        end
        return default ~= "false";
    end,
    ["string"] = function(className: string, superclass: string, property: string, default: string?)
        if (property == "Name") then
            return className;
        end
        if (default and default ~= "__api_dump_class_not_creatable__") then
            return default;
        end
        return "";
    end,
    ["float"] = function(className: string, superclass: string, property: string, default: string?)
        if (default and default ~= "__api_dump_class_not_creatable__") then
            local num = tonumber(default);
            if (num) then
                return num;
            end
        end
        return 0;
    end,
    ["double"] = function(className: string, superclass: string, property: string, default: string?)
        if (default and default ~= "__api_dump_class_not_creatable__") then
            local num = tonumber(default);
            if (num) then
                return num;
            end
        end
        return 0;
    end,
    ["int"] = function(className: string, superclass: string, property: string, default: string?)
        if (default and default ~= "__api_dump_class_not_creatable__") then
            local num = tonumber(default);
            if (num) then
                return math.floor(num);
            end
        end
        return 0;
    end,
};

local DEFAULT_VALUE = {
    ["NumberRange"] = function(default: string?)
        if (not default) then
            return datatypes.NumberRange.new(0, 0);
        end
        local min, max = unpack(default:split(" "));
        local nmin = tonumber(min) or 0;
        return datatypes.NumberRange.new(nmin, tonumber(max) or nmin);
    end,
    ["ColorSequence"] = function(default: string?)
        if (not default) then
            return datatypes.ColorSequence.new(datatypes.Color3.new(1, 1, 1));
        end
        local points = {};
        for time, r, g, b, envople in default:gmatch("(%d+) (%d+) (%d+) (%d+) (%d+) ") do
            local time_n = tonumber(time) or 0;
            local r_n = tonumber(r) or 0;
            local g_n = tonumber(g) or 0;
            local b_n = tonumber(b) or 0;
            local envople_n = tonumber(envople) or 0;
            table.insert(points, datatypes.ColorSequenceKeypoint.new(time_n, dom_datatypes.Color3.DataType.fromRGB(r_n, g_n, b_n), envople_n));
        end
        return datatypes.ColorSequence.new(points);
    end,
    ["UDim"] = function(default: string?)
        -- if (not default) then
        -- end
        return datatypes.UDim.new(0, 0);
    end,
};

local function getSpecialDefaultPropertyHandler(className: string, name: string)
    local class = reflection:GetClass(className);
    if (not class) then
        error("Class not found");
    end
    local preset = presets[className];
    if (preset and preset.default) then
        local handler = preset.default[name];
        if (handler) then
            return handler;
        end
    end
    if (class.Superclass == "<<<ROOT>>>") then
        return;
    end
    return getSpecialDefaultPropertyHandler(class.Superclass, name);
end

local function getSpecialPropertyLoadHandler(className: string, name: string)
    local class = reflection:GetClass(className);
    if (not class) then
        error("Class not found");
    end
    local preset = presets[className];
    if (preset and preset.loader) then
        local handler = preset.loader[name];
        if (handler) then
            return handler;
        end
    end
    if (class.Superclass == "<<<ROOT>>>") then
        return;
    end
    return getSpecialPropertyLoadHandler(class.Superclass, name);
end

local IGNORE_PROPERTIES_TYPE = {
    "SecurityCapabilities",
    "PhysicalProperties",
    -- TODO: add support for these
    "Region3",
    "Region3int16",
};

local MAPPED_TYPE = {
    ["BinaryString"] = "Primitive",
    ["ContentId"] = "Primitive",
}

local function loadDefaultProperties(self: object, className: string)
    local instance = self["@instance"];
    local class = reflection:GetClass(className);
    if (not class) then
        error("Class not found");
    end
    local properties = instance.properties;
    local post_load = {};
    for _, member in class.Members do
        if (member.MemberType ~= "Property") then
            continue;
        end
        local customLoader = getSpecialPropertyLoadHandler(className, member.Name);
        if (customLoader) then
            table.insert(post_load, function(self)
                customLoader(
                    self,
                    (properties[member.Name]::any)
                );
            end);
            continue;
        end
        if (
            properties[member.Name]
            or (member.Name == "ClassName" and member.ValueType.Name == "string" and member.ValueType.Category == "Primitive")
        ) then
            continue;
        end

        local customDefault = getSpecialDefaultPropertyHandler(className, member.Name);
        if (customDefault ~= nil and type(customDefault) == "string") then
            continue;
        end

        if (
            member.Default == "__api_dump_write_only_property__"
            or (member.Tags and (
                table.find(member.Tags, "Deprecated")
                or table.find(member.Tags, "NotScriptable")
            ))
        ) then
            continue;
        end

        local default = nil;
        local serializeId = dom.roblox.PropertyTypes[member.ValueType.Name];
        local Category = MAPPED_TYPE[member.ValueType.Name] or member.ValueType.Category;
        if (Category == "Enum") then
            serializeId = dom.roblox.PropertyTypes.Enum;
            local enum = datatypes.Enums[member.ValueType.Name];
            if (enum) then
                local item = enum[member.Default];
                if (item) then
                    default = item;
                else
                    default = enum:GetEnumItems()[1];
                end
            else
                error(`Enum '{member.ValueType.Name}' not found`);
            end
        elseif (Category == "Primitive") then
            serializeId = dom.roblox.PropertyTypes[TYPE_MAP[member.ValueType.Name]];
            if (DEFAULT_TYPE_MAP[member.ValueType.Name]) then
                default = DEFAULT_TYPE_MAP[member.ValueType.Name](instance.className, className, member.Name, member.Default);
            end
        elseif (Category == "DataType") then
            local datatype = datatypes[member.ValueType.Name];
            if (datatype) then
                local custom = DEFAULT_VALUE[member.ValueType.Name];
                if (custom and member.Default ~= "__api_dump_class_not_creatable__") then
                    default = custom(member.Default);
                else
                    local ok, err = pcall(datatype.load);
                    if (ok) then
                        default = err;
                    else
                        if (not table.find(IGNORE_PROPERTIES_TYPE, member.ValueType.Name)) then
                            print(member.ValueType.Name, err);
                        end
                    end
                end
            else
                if (not table.find(IGNORE_PROPERTIES_TYPE, member.ValueType.Name)) then
                    print(`[rbx-manager] DataType '{member.ValueType.Name}' not supported`);
                end
                continue;
            end
        elseif (Category == "Class") then
            serializeId = dom.roblox.PropertyTypes.Ref;
            default = nil;
        end
        if (not serializeId) then
            continue;
        end

        if (customDefault) then
            if (type(customDefault) == "function") then
                default = customDefault(self, datatypes, default);
            end
        end

        if (default == nil) then
            continue
        end

        properties[member.Name] = {
            type = serializeId,
            value = default,
        };
    end
    if (class.Superclass ~= "<<<ROOT>>>") then
        loadDefaultProperties(self, class.Superclass);
    end
    for _, post in post_load do
        post(self);
    end
end

function object.LoadDefaultProperties(self: object, className: string)
    loadDefaultProperties(self, className);
end

function object.create(className: string): Instance
    local class = reflection:GetClass(className);
    if (not class) then
        error("Class not found");
    end

    local object = object.raw(className);

    loadDefaultProperties(object, className);

    return object::any;
end

function object.new(className: string, parent: Instance?): Instance
    local class = reflection:GetClass(className);
    if (not class) then
        error("Class not found");
    end
    if (class.Tags and table.find(class.Tags, "NotCreatable")) then
        error("Class is not creatable");
    end

    local object = object.raw(className);

    assert(parent == nil or isObject(parent), "Parent must be an instance");

    loadDefaultProperties(object, className);

    (object::any).Parent = parent;

    return object::any;
end

object.presets = presets;

local function resolveGetProperty(self: object, className: string, key: string): (boolean, any?)
    local class = reflection:GetClass(className);
    if (not class) then
        return false, nil;
    end
    local preset = presets[className];
    local handler, method;
    if (preset) then
        handler =
            if (preset.property and preset.property.get) then
                preset.property.get[key]
            else
                nil;
        method =
            if (preset.method) then
                preset.method[key]
            else
                nil;
    end
    if (handler and method) then
        error(`[object] Property and Method duplicate name conflict '{key}' in '{className}'`);
    end
    if (not handler and not method) then
        if (class.Superclass == "<<<ROOT>>>") then
            return false, nil;
        end
        local resolved, result = resolveGetProperty(self, class.Superclass, key);
        if (resolved) then
            return true, result;
        end
    end
    if (handler) then
        return true, handler(self)::any
    elseif (method) then
        assert(not self["@destroyed"], "Object is destroyed");
        return true, method;
    else
        local raw = self["@instance"].properties[key];
        if (raw) then
            return true, raw.value;
        end
        return false, nil;
    end
end

local function gettypeof(value: any)
    return if (type(value) == "table" and type(getmetatable(value)) == "table") then
        getmetatable(value).__type or type(value)
    else
        type(value);
end

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

local SET_PROPERTY_BUFFER = buffer.create(8);
local SET_MAP = {
    [dom.roblox.PropertyTypes.Unknown] = function(prop: dom.DOMProperty, value: any, _: string, _: string): ()
        error("Cannot set Unknown property");
    end,
    [dom.roblox.PropertyTypes.String] = function(prop: dom.DOMProperty, value: any, _: string, propertyName: string): ()
        if (type(value) ~= "string" and type(value) ~= "number") then
            error(`Unable to assign property {propertyName}. string expected, got {gettypeof(value)}`);
        end
        prop.value = tostring(value);
    end,
    [dom.roblox.PropertyTypes.Bool] = function(prop: dom.DOMProperty, value: any, _: string, _: string): ()
        prop.value = if (value) then true else false;
    end,
    [dom.roblox.PropertyTypes.Int] = function(prop: dom.DOMProperty, value: any, _: string, _: string): ()
        local num = 0
        if (type(value) ~= "number") then
            if (type(value) == "string") then
                local converted = tonumber(value);
                if (converted) then
                    num = converted;
                else
                    print(`value of type string cannot be converted to a number`);
                end
            else
                print(`value of type {gettypeof(value)} cannot be converted to a number`);
            end
        else
            num = value;
        end
        buffer.writei32(SET_PROPERTY_BUFFER, 0, num);
        prop.value = buffer.readi32(SET_PROPERTY_BUFFER, 0);
    end,
    [dom.roblox.PropertyTypes.Float] = function(prop: dom.DOMProperty, value: any, _: string, _: string): ()
        local num = 0
        if (type(value) ~= "number") then
            if (type(value) == "string") then
                local converted = tonumber(value);
                if (converted) then
                    num = converted;
                else
                    print(`value of type string cannot be converted to a number`);
                end
            else
                print(`value of type {gettypeof(value)} cannot be converted to a number`);
            end
        else
            num = value;
        end
        buffer.writef32(SET_PROPERTY_BUFFER, 0, num);
        prop.value = buffer.readf32(SET_PROPERTY_BUFFER, 0);
    end,
    [dom.roblox.PropertyTypes.Double] = function(prop: dom.DOMProperty, value: any, _: string, _: string): ()
        local num = 0
        if (type(value) ~= "number") then
            if (type(value) == "string") then
                local converted = tonumber(value);
                if (converted) then
                    num = converted;
                else
                    print(`value of type string cannot be converted to a number`);
                end
            else
                print(`value of type {gettypeof(value)} cannot be converted to a number`);
            end
        else
            num = value;
        end
        prop.value = num;
    end,
    [dom.roblox.PropertyTypes.UDim] = function(prop: dom.DOMProperty, value: any, _: string, propertyName: string): ()
        if (not dom_datatypes.UDim.Is(value)) then
            error(`Unable to assign property {propertyName}. UDim expected, got {gettypeof(value)}`);
        end
        prop.value = value;
    end,
    [dom.roblox.PropertyTypes.Enum] = function(prop: dom.DOMProperty, value: any, _: string, propertyName: string): ()
        local enumType = prop.value.EnumType;
        local new = prop.value;
        if (type(value) == "table") then
            if (type(getmetatable(value)) == "table" or getmetatable(value).__type == "EnumItem") then
                if (tostring(enumType) ~= tostring(value.EnumType)) then
                    error(`Unable to assign property {propertyName}. EnumItem of type {tostring(enumType)}, got an EnumItem of type {tostring(value.EnumType)}`);
                end
            else
                error(`Unable to assign property {propertyName}. EnumItem, number, or string expected, got {gettypeof(value)}`);
            end
        elseif (type(value) == "string") then
            local found = enumType[value];
            if (not found) then
                error(`Unable to assign property {propertyName}. Invalid value "{tostring(value)}" for enum {tostring(enumType)}`);
            end
            new = found;
        elseif (type(value) == "number") then
            local found = nil;
            for _, item in enumType:GetEnumItems() do
                if (item.Value == value) then
                    found = item;
                    break;
                end
            end
            if (not found) then
                error(`Unable to assign property {propertyName}. Invalid value {tostring(value)} for enum {tostring(enumType)}`);
            end
            new = found;
        else
            error(`Unable to assign property {propertyName}. EnumItem, number, or string expected, got {gettypeof(value)}`);
        end
        prop.value = new;
    end,
    [dom.roblox.PropertyTypes.Ref] = function(prop: dom.DOMProperty, value: any, className: string, propertyName: string): ()
        if (value ~= nil and not isObject(value)) then
            error(`Unable to assign property {propertyName}. Instance or nil expected, got {gettypeof(value)}`);
        end
        local class = reflection:GetClass(className);
        assert(class, "Class not found");
        local member = findPropertyFromClass(class, propertyName);
        assert(member, "Property not found");
        assert(member.ValueType.Category == "Class", "Property is not a reference");
        if (not value:IsA(member.ValueType.Category)) then
            error(`Expected {member.ValueType.Category} got {value.ClassName} for {className}.{propertyName}.`);
        end
        prop.value = value;
    end,
    [dom.roblox.PropertyTypes.Int64] = function(prop: dom.DOMProperty, value: any, _: string, propertyName: string): ()
        error(`Unable to assign property {propertyName}. Int64 not implemented`);
    end,
    [dom.roblox.PropertyTypes.SharedString] = function(prop: dom.DOMProperty, value: any, _: string, propertyName: string): ()
        if (type(value) ~= "string") then
            error(`Unable to assign property {propertyName}. string expected, got {gettypeof(value)}`);
        end
        prop.value = value;
    end,
    [dom.roblox.PropertyTypes.OptionalCFrame] = function(prop: dom.DOMProperty, value: any, _: string, propertyName: string): ()
        if (value ~= nil and not dom_datatypes.CFrame.Is(value)) then
            error(`Unable to assign property {propertyName}. CFrame or nil expected, got {gettypeof(value)}`);
        end
        prop.value = value;
    end,
}

local function generateSetDataType(datatype: any)
    return function(prop: dom.DOMProperty, value: any, _: string, propertyName: string): ()
        if (not datatype.Is(value)) then
            error(`Unable to assign property {propertyName}. {datatype.DataType.__type} expected, got {gettypeof(value)}`);
        end
        prop.value = value;
    end
end

SET_MAP[dom.roblox.PropertyTypes.UDim] = generateSetDataType(dom_datatypes.UDim);
SET_MAP[dom.roblox.PropertyTypes.UDim2] = generateSetDataType(dom_datatypes.UDim2);
SET_MAP[dom.roblox.PropertyTypes.Ray] = generateSetDataType(dom_datatypes.Ray);
SET_MAP[dom.roblox.PropertyTypes.Faces] = generateSetDataType(dom_datatypes.Faces);
SET_MAP[dom.roblox.PropertyTypes.Axes] = generateSetDataType(dom_datatypes.Axes);
SET_MAP[dom.roblox.PropertyTypes.BrickColor] = generateSetDataType(dom_datatypes.BrickColor);
SET_MAP[dom.roblox.PropertyTypes.Color3] = generateSetDataType(dom_datatypes.Color3);
SET_MAP[dom.roblox.PropertyTypes.Vector2] = generateSetDataType(dom_datatypes.Vector2);
SET_MAP[dom.roblox.PropertyTypes.Vector3] = generateSetDataType(dom_datatypes.Vector3);
SET_MAP[dom.roblox.PropertyTypes.CFrame] = generateSetDataType(dom_datatypes.CFrame);
SET_MAP[dom.roblox.PropertyTypes.Vector3int16] = generateSetDataType(dom_datatypes.Vector3int16);
SET_MAP[dom.roblox.PropertyTypes.NumberSequence] = generateSetDataType(dom_datatypes.NumberSequence);
SET_MAP[dom.roblox.PropertyTypes.ColorSequence] = generateSetDataType(dom_datatypes.ColorSequence);
SET_MAP[dom.roblox.PropertyTypes.NumberRange] = generateSetDataType(dom_datatypes.NumberRange);
SET_MAP[dom.roblox.PropertyTypes.Rect] = generateSetDataType(dom_datatypes.Rect);
SET_MAP[dom.roblox.PropertyTypes.PhysicalProperties] = generateSetDataType(dom_datatypes.PhysicalProperties);
SET_MAP[dom.roblox.PropertyTypes.Color3uint8] = generateSetDataType(dom_datatypes.Color3);
SET_MAP[dom.roblox.PropertyTypes.UniqueId] = generateSetDataType(dom_datatypes.UniqueId);
SET_MAP[dom.roblox.PropertyTypes.Font] = generateSetDataType(dom_datatypes.Font);
SET_MAP[dom.roblox.PropertyTypes.Content] = generateSetDataType(dom_datatypes.Content);

local function resolveSetProperty(self: object, className: string, key: string, value: any)
    if (self["@destroyed"]) then
        error("Object is destroyed");
    end
    local class = reflection:GetClass(className);
    if (not class) then
        return;
    end
    local preset = presets[className];
    local handler =
        if (preset and preset.property and preset.property.set) then
            preset.property.set[key]
        else
            nil;
    if (not handler) then
        if (class.Superclass ~= "<<<ROOT>>>") then
            if (resolveSetProperty(self, class.Superclass, key, value)) then
                return true;
            end
        end
        local prop = self["@instance"].properties[key];
        if (prop) then
            local set_handler = SET_MAP[prop.type];
            if (set_handler) then
                set_handler(prop, value, className, key);
                return;
            end
            error(`No set handler for property '{key}' on class '{className}'`);
        else
            error(`Property '{key}' does not exist on class '{className}'`);
        end
    end
    handler(self, value);
    return true;
end

local function checkRecursion(self: object, parent: object?): boolean
    local search: object? = parent;
    while search do
        if (search == self) then
            return true;
        end
        assert(search);
        search = rawget(search::any, "@parent");
    end
    return false;
end

function object.__tostring(self: object)
    local name = self["@instance"].properties["Name"];
    return `<instance {tostring(if (name) then name.value else self["@instance"].className)}>`;
end

function object.__index(self: object, key: string)
    assert(type(key) == "string", "Index must be string");
    if (key == "Parent") then
        return rawget(self::any, "@parent");
    end
    local resolved, result = resolveGetProperty(self, self["@instance"].className, key);
    if (not resolved) then
        if (self:IsA("Instance")) then
            local res = self:FindFirstChild(key);
            if (res == nil) then
                error(`{key} is not a valid member of {self:GetFullName()}`);
            end
            result = res;
        end
    end
    return result;
end

function object.__newindex(self: object, key: string, value: any)
    assert(type(key) == "string", "Index must be string");
    if (key == "Parent") then
        assert(value == nil or (isObject(value) and value:IsA("Instance")), "Parent must be an instance");
        local parent = rawget(self::any, "@parent");
        if (parent == value) then
            return;
        end
        if (checkRecursion(self, value)) then
            error("Parent cannot be a child of itself");
        end
        local descendant_added_signals = {};
        local descendant_removing_signals = {};
        local ancestry_changed_signal = self["@events"]["AncestryChanged"]::Signal?;
        local old_parent_event_signal;
        local new_parent_event_signal;
        if (parent) then
            local children_idx = table.find(parent["@children"], self);
            if (children_idx) then
                table.remove(parent["@children"], children_idx);
            else
                error("Child not found in parent (Internal Error)");
            end
            old_parent_event_signal = parent["@events"]["ChildRemoved"]::Signal?;
            while parent do
                local signal = parent["@events"]["DescendantRemoving"]::Signal?;
                if (signal) then
                    table.insert(descendant_removing_signals, signal);
                end
                parent = parent.Parent;
            end
        end
        if (value) then
            table.insert(value["@children"], self);
            new_parent_event_signal = value["@events"]["ChildAdded"]::Signal?;
            local new_parent = value;
            while new_parent do
                local signal = new_parent["@events"]["DescendantAdded"]::Signal?;
                if (signal) then
                    table.insert(descendant_added_signals, signal);
                end
                new_parent = new_parent.Parent;
            end
        end
        rawset(self::any, "@parent", value);

        if (ancestry_changed_signal) then
            ancestry_changed_signal:Fire(self, parent);
        end
        if (old_parent_event_signal) then
            old_parent_event_signal:Fire(self);
        end
        if (new_parent_event_signal) then
            new_parent_event_signal:Fire(self);
        end
        for _, signal in descendant_removing_signals do
            signal:Fire(self);
        end
        for _, signal in descendant_added_signals do
            signal:Fire(self);
        end
        return;
    end
    resolveSetProperty(self, self["@instance"].className, key, value);
end

for _, preset: any in presets do
    preset.object = object;
end

return object;
