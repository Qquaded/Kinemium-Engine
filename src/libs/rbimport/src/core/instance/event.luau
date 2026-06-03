local Signal = require("../signal");

local function eventGenerator(name: string)
    return function(self: any)
        local event = self["@events"][name];
        if (not event) then
            event = Signal.new();
            self["@events"][name] = event;
        end
        return event;
    end
end

return {
    generate = eventGenerator;
}