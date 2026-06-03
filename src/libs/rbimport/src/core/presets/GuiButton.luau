--!strict
local Event = require("../instance/event");

local impl = {};
impl.method = {};
impl.property = {};
impl.property.get = {};
impl.property.set = {};

local function addEvent(name: string)
    impl.property.get[name] = Event.generate(name);
end

addEvent("Activated");
addEvent("MouseButton1Click");
addEvent("MouseButton1Down");
addEvent("MouseButton1Up");
addEvent("MouseButton2Click");
addEvent("MouseButton2Down");
addEvent("MouseButton2Up");

return impl;