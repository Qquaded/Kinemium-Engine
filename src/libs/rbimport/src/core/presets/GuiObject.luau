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

addEvent("InputBegan");
addEvent("InputChanged");
addEvent("InputEnded");
addEvent("MouseEnter");
addEvent("MouseLeave");
addEvent("MouseMoved");
addEvent("MouseWheelBackward");
addEvent("MouseWheelForward");
addEvent("SelectionGained");
addEvent("SelectionLost");
addEvent("TouchLongPress");
addEvent("TouchPan");
addEvent("TouchPinch");
addEvent("TouchRotate");
addEvent("TouchSwipe");
addEvent("TouchTap");

return impl;