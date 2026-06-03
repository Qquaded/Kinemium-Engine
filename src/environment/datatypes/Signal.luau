local KinemiumSignal = require("@Kinemium.signal")

export type Signal = {
	Connect: (self: Signal, fn: (...any) -> any, priority: number?) -> Connection,
	Once: (self: Signal, fn: (...any) -> any) -> Connection,
	Wait: (self: Signal, timeout: number?) -> any,
	Fire: (self: Signal, ...any) -> (),
	FireDeferred: (self: Signal, ...any) -> (),
	DisconnectAll: (self: Signal) -> (),
	Destroy: (self: Signal) -> (),
}

export type Connection = {
	Disconnect: (self: Connection) -> (),
	Fire: (self: Connection, ...any) -> (),
	SetPriority: (self: Connection, priority: number) -> (),
	Connected: boolean,
	Priority: number,
}

local Signal = {}

-- Wrapper functions for type generation
function Signal.new()
	return KinemiumSignal.new()
end

function Signal.wrap(signal)
	return signal
end

return KinemiumSignal
