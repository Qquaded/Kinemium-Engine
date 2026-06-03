--!strict
--!native
local polyfill = require("@polyfill");

local blake2 = polyfill.blake2;
local base64 = polyfill.base64;

local object = require("./object");

local dom = require("../dom");
local datatypes = require("../datatypes");

local reflection = require("../reflection");

local Enum = datatypes.Enums.DataType;

type Instance = any;
type DataModel = any;

local manager = {};

manager.datatypes = {
    Vector3 = datatypes.Vector3.DataType,
    Vector2 = datatypes.Vector2.DataType,
    CFrame = datatypes.CFrame.DataType,
    Color3 = datatypes.Color3.DataType,
    BrickColor = datatypes.BrickColor.DataType,
    UDim = datatypes.UDim.DataType,
    UDim2 = datatypes.UDim2.DataType,
    Ray = datatypes.Ray.DataType,
    Rect = datatypes.Rect.DataType,
    NumberRange = datatypes.NumberRange.DataType,
    NumberSequence = datatypes.NumberSequence.DataType,
    NumberSequenceKeypoint = datatypes.NumberSequenceKeypoint.DataType,
    ColorSequence = datatypes.ColorSequence.DataType,
    ColorSequenceKeypoint = datatypes.ColorSequenceKeypoint.DataType,
    PhysicalProperties = datatypes.PhysicalProperties.DataType,
    Axes = datatypes.Axes.DataType,
    Faces = datatypes.Faces.DataType,
    Enum = Enum,

    DateTime = datatypes.DateTime,
};

function manager.instanceFromDOM(instance: dom.DOMInstance): Instance?
    local className = instance.className;
    local class = reflection:GetClass(className);
    if (not class) then
        return nil
    end
    local obj = object.dom(instance);
    object.LoadDefaultProperties(obj, instance.className);
    return obj::any;
end

function manager.instancesFromDOM(doc: dom.DOM): {Instance}
    local instances = table.create(doc.info.instances);
    for _, instance in doc.instances do
        instances[instance.referent] = manager.instanceFromDOM(instance);
    end
    local valid = doc.info.instances;
    for _, instance in doc.instances do
        local object = instances[instance.referent];
        if (not object) then
            continue;
        end
        if (instance.parent) then
            local parent = instances[instance.parent];
            if (not parent) then
                print("[rbx-manager] Parent instance not found (instance dropped)");
                instances[instance.referent] = nil;
                continue;
            end
            rawset(object :: any, "@parent", parent);
            table.insert(rawget(parent :: any, "@children") :: any, object);
            valid -= 1;
        end
    end
    for _, instance in instances do
        for name, property in (instance :: any)["@instance"].properties do
            if (property.type == dom.roblox.PropertyTypes.Ref and property.value) then
                property.value = instances[property.value];
            elseif (property.type == dom.roblox.PropertyTypes.Content and property.value) then
                if (type(property.value.Object) == "number") then
                    property.value.Object = instances[property.value.Object];
                end
            elseif (property.type == dom.roblox.PropertyTypes.SharedString and property.value) then
                property.value = doc.sharedstrings[property.value];
            end
        end
    end
    local list: {Instance} = table.create(valid);
    for _, instance in instances do
        if (instance and rawget(instance :: any, "@parent") == nil) then
            table.insert(list, instance);
        end
    end
    return list;
end

function manager.modelFromDOM(doc: dom.DOM): {Instance}
    return manager.instancesFromDOM(doc);
end

function manager.placeFromDom(doc: dom.DOM): DataModel
    local datamodel = object.raw("DataModel");
    datamodel["@instance"].properties["Name"] = {
        value = "DataModel",
        type = dom.roblox.PropertyTypes.String,
    };
    local instances = manager.instancesFromDOM(doc);
    for _, instance in instances do
        rawset(instance::any, "@parent", datamodel);
        table.insert(datamodel["@children"], instance);
    end
    return datamodel::any;
end

function manager.domFromInstances(
    descendants: {Instance},
    descendants_map: {[Instance]: number},
    ignoreParent: Instance?
): dom.DOM
    local sharedstrings: {[string]: string} = {};
    local cached_sharedstrings: {[string]: string} = {};

    local instances: {dom.DOMInstance} = table.create(#descendants);
    local classes: {dom.DOMClass} = {}; do
        local map = {};
        local index = 1;
        for i, descendant in descendants do
            local instance = (descendant::any)["@instance"];
            local class_name = instance.className;
            local class: dom.DOMClass = map[class_name];
            if (not class) then
                local class_api = reflection:GetClass(class_name);
                if (not class_api) then
                    error(`Unknown class '{class_name}', cannot serialize`);
                end
                class = {
                    index = index;
                    name = class_name,
                    instances = {},
                    isService = table.find(class_api.Tags or {}, "Service") ~= nil,
                };
                index += 1;
                map[class_name] = class;
                table.insert(classes, class::any);
            end
            --[[Generate DOMInstance]] do
                local dom_instance = table.clone(instance);
                dom_instance.referent = i;
                dom_instance.properties = table.clone(dom_instance.properties);
                for name, property in instance.properties do
                    if (not property.type) then
                        continue;
                    end
                    local value = property.value;
                    if (property.type == dom.roblox.PropertyTypes.Ref and value) then
                        value = descendants_map[value];
                        if (not value) then
                            error(`Reference to non-existent instance at '{descendant:GetFullName()}' (from another DataModel?)`);
                        end
                    elseif (property.type == dom.roblox.PropertyTypes.Content and value) then
                        if (value.SourceType == Enum.ContentSourceType.Object) then
                            if (value.Object) then
                                value = descendants_map[value.Object];
                                if (not value) then
                                    error(`Content.Object Reference to non-existent instance at '{descendant:GetFullName()}' (from another DataModel?)`);
                                end
                            else
                                value = nil;
                            end
                        end
                    elseif (property.type == dom.roblox.PropertyTypes.SharedString) then
                        local data = property.value;
                        local hash_base64 = cached_sharedstrings[data];
                        if (not hash_base64) then
                            hash_base64 = blake2.b128(data, "base64");
                            cached_sharedstrings[data] = hash_base64;
                        end
                        sharedstrings[hash_base64] = data;
                        value = hash_base64;
                    else
                        continue;
                    end
                    dom_instance.properties[name] = {
                        value = value,
                        type = property.type,
                    };
                end
                local parent = rawget(descendant :: any, "@parent");
                if (parent and parent ~= ignoreParent) then
                    dom_instance.parent = descendants_map[parent];
                    assert(dom_instance.parent, "Parent instance not found (failed to reference)");
                else
                    dom_instance.parent = nil :: any;
                end
                instances[i] = dom_instance;
            end
            table.insert(class.instances, i);
        end
    end

    return {
        info = {
            version = 0,
            instances = #instances,
            classes = #classes,
            reserved = buffer.create(8),
        },
        instances = instances,
        classes = classes,
        metadata = {},
        sharedstrings = sharedstrings,
    };
end

function manager.domFromPlace(datamodel: DataModel): dom.DOM
    assert(
        object.is(datamodel) and datamodel:IsA("DataModel"),
        "argument #1 must be a DataModel instance"
    );
    local descendants_map = {};
    local descendants = datamodel:GetDescendants(); do
        local filtered = table.create(#descendants);
        local index = 1;
        for _, descendant in descendants do
            local properties = (rawget(descendant :: any, "@instance") :: any).properties;
            if (properties["Archivable"] == nil or properties["Archivable"].value == true) then
                table.insert(filtered, descendant);
                descendants_map[descendant] = index;
                index += 1;
            end
        end
        descendants = filtered;
    end
    return manager.domFromInstances(descendants, descendants_map, datamodel);
end

function manager.domFromModel(instances: {Instance}): dom.DOM
    assert(type(instances) == "table", "argument #1 must be a table of Instances");
    local descendants = {};
    local descendants_map = {};
    local index = 1;
    for _, instance in instances do
        assert(
            object.is(instance) and instance:IsA("Instance"),
            "value must be an Instance"
        );
        table.insert(descendants, instance);
        descendants_map[instance] = index;
        index += 1;
        for _, descendant in instance:GetDescendants() do
            local properties = (rawget(descendant :: any, "@instance") :: any).properties;
            if (properties["Archivable"] == nil or properties["Archivable"].value == true) then
                table.insert(descendants, descendant);
                descendants_map[descendant] = index;
                index += 1;
            end
        end
    end
    return manager.domFromInstances(descendants, descendants_map);
end

function manager.applyPatches()
    local patches = require("./patches");
    for class, property_patch in patches do
        local existing = object.presets[class];
        if (not existing) then
            local impl = {};
            impl.method = {};
            impl.property = {
                get = {};
                set = {};
            };
            existing = impl;
            object.presets[class] = existing;
        end
        if (not existing.property) then
            existing.property = {
                get = {};
                set = {};
            };
        end
        for property, patch in property_patch :: any do
            if (patch.get) then
                existing.property.get[property] = function(self)
                    return patch.get(self, property);
                end;
            end
            if (patch.set) then
                existing.property.set[property] = function(self, value)
                    return patch.set(self, property, value);
                end;
            end
            if (patch.loader) then
                existing.loader = existing.loader or {};
                existing.loader[property] = function(self, property_value)
                    return patch.loader(self, property, property_value);
                end;
            end
        end
    end
end

local instance = {};

local function instanceNew(className: string, parent: Instance?): Instance
    return object.new(className, parent);
end
local function instanceCreate(className: string): Instance
    return object.create(className);
end

instance.new = (instanceNew :: any) :: (className: string, parent: Instance?) -> Instance;
instance.create = (instanceCreate :: any) :: (className: string) -> Instance;

manager.Instance = instance;

manager.typeof = function(value: any)
    if (object.is(value)) then
        return "Instance";
    end
    return typeof(value);
end;

manager.type = function(value: any)
    if (object.is(value)) then
        return "userdata";
    end
    return type(value);
end;

manager.implementProperty = function(
    className: string,
    propertyName: string,
    get_callback: (instance: Instance) -> any,
    set_callback: (instance: Instance, value: any) -> ()
)
    assert(type(className) == "string", "className must be a string");
    assert(type(propertyName) == "string", "propertyName must be a string");
    assert(type(get_callback) == "function", "get_callback must be a function");
    assert(type(set_callback) == "function", "set_callback must be a function");
    local existing = object.presets[className];
    if (not existing) then
        local impl = {};
        impl.method = {};
        impl.property = {
            get = {};
            set = {};
        };
        existing = impl;
        object.presets[className] = existing;
    end
    if (not existing.property) then
        existing.property = {
            get = {};
            set = {};
        };
    end
    existing.property.get[propertyName] = get_callback;
    existing.property.set[propertyName] = set_callback;
end;

manager.implementMethod = function(
    className: string,
    methodName: string,
    callback: (instance: Instance, ...any) -> any
)
    assert(type(className) == "string", "className must be a string");
    assert(type(methodName) == "string", "methodName must be a string");
    assert(type(callback) == "function", "get_callback must be a function");
    local existing = object.presets[className];
    if (not existing) then
        local impl = {};
        impl.method = {};
        existing = impl;
        object.presets[className] = existing;
    end
    if (not existing.method) then
        existing.method = {};
    end
    existing.method[methodName] = callback;
end;

return manager;
