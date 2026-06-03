local dom = require("@self/dom");
local manager = require("@self/core/manager");
local reflection = require("@self/reflection");
local polyfill = require("@polyfill");

local module = {};

module.dom = dom;
module.manager = manager;
module.reflection = reflection;
module.polyfill = polyfill;

function module.deserializePlace(contents: string | buffer)
    local content = if (type(contents) == "string") then buffer.fromstring(contents) else contents;
    local docs = dom.deserialize(content);
    return manager.placeFromDom(docs);
end

function module.deserializeModel(contents: string | buffer)
    local content = if (type(contents) == "string") then buffer.fromstring(contents) else contents;
    local docs = dom.deserialize(content);
    return manager.modelFromDOM(docs);
end

function module.serializePlace(dataModel: any, xml: boolean?): buffer
    local docs = manager.domFromPlace(dataModel);
    return dom.serialize(docs, if (xml) then "XML" else "BINARY");
end

function module.serializeModel(instances: {any}, xml: boolean?): buffer
    local docs = manager.domFromModel(instances);
    return dom.serialize(docs, if (xml) then "XML" else "BINARY");
end

function module.getReflectionDatabase(): reflection.ReflectionDatabase
    return reflection;
end

return module;
