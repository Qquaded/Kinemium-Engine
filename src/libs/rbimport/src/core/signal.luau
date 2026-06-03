--!strict
local task = require("@polyfill").task;

type Connection = {
    ["@next"]: Connection?,
    ["@previous"]: Connection?,
    ["@callback"]: (...any) -> (),
    Connected: boolean,
    Disconnect: (self: Connection) -> (),
};

local signal = {};
signal.__index = signal;

local function is(value: any): boolean
    return type(value) == "table" and getmetatable(value) == signal;
end

function signal.new(): Signal
    return setmetatable({
        ["@head"] = nil::Connection?,
        fire = {}::{{any}},
        queue = {}::{Connection},
        processing = false,
        firing = false,
    }, signal);
end

signal.is = is;

export type Signal = typeof(signal.new());

local function disconnect(connection: Connection)
    connection.Connected = false;
    connection["@callback"] = nil::any;
    if (connection["@previous"]) then
        connection["@previous"]["@next"] = connection["@next"];
    end
    if (connection["@next"]) then
        connection["@next"]["@previous"] = connection["@previous"];
    end
    local signal = connection["@signal"];
    if (signal["@head"] == connection) then
        signal["@head"] = connection["@next"];
    end
end

local function applyConnectionToNode(self: Signal, connection: Connection)
    local current = self["@head"];
    connection["@next"] = current;
    if (current) then
        current["@previous"] = connection;
    end
    self["@head"] = connection;
end

function signal.Connect(self: Signal, callback: (...any) -> ()): Connection
    assert(is(self), "invalid self");
    assert(type(callback) == "function", "argument #1 must be a function");
    assert(self.fire, "Signal is destroyed");
    local connection: Connection = {
        ["@signal"] = self,
        ["@callback"] = callback,
        Connected = true,
        Disconnect = disconnect,
    };
    if (self.firing) then
        table.insert(self.queue, connection);
        return connection;
    end
    applyConnectionToNode(self, connection);
    return connection;
end

function signal.Once(self: Signal, callback: (...any) -> ()): Connection
    local connection;
    connection = signal.Connect(self, function(...)
        connection:Disconnect();
        callback(...);
    end);
    return connection;
end

function signal.Wait(self: Signal): ...any
    local thread = coroutine.running();
    local connection;
    connection = signal.Connect(self, function(...)
        connection:Disconnect();
        task.spawn(thread, ...);
    end);
    return coroutine.yield();
end

local function processFireQueue(self: Signal)
    if (self.processing) then
        return;
    end
    self.processing = true;
    local queue = self.fire;
    while #queue > 0 do
        self.firing = true;
        local args = table.remove(queue, 1)::{any};
        local current = self["@head"];
        while current do
            task.spawn(current["@callback"], unpack(args));
            current = current["@next"];
        end
        self.firing = false;
        for _, connection in self.queue do
            applyConnectionToNode(self, connection);
        end
        table.clear(self.queue);
    end
    table.clear(self.fire);
    self.processing = false;
end

function signal.Fire(self: Signal, ...)
    table.insert(self.fire, {...});
    processFireQueue(self);
end

function signal.Destroy(self: Signal)
    local current = self["@head"];
    while current do
        current:Disconnect();
        current = current["@next"];
    end
    table.clear(self.fire);
    table.clear(self.queue);
    self["@head"] = nil;
    self.fire = nil::any;
end

return signal;
