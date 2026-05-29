-- description: "Represents a BindableEvent in the environment."
local signal = require("@Kinemium.signal")

local propTable = {}

return {
	class = "BindableEvent",
	-- description: "Initializes the BindableEvent instance."
	-- args: "instance: table, renderer: number, game: table"
	-- returns: "table"
	callback = function(instance, renderer, game)
		instance:SetProperties(propTable)

		local bindableSignal = signal.new()

		instance.Event = bindableSignal
		instance.Name = "BindableEvent"

		-- description: "Fires."
		-- args: "...: any"
		function instance:Fire(...)
			bindableSignal:Fire(...)
		end

		return instance
	end,
	-- description: "Inherits the properties of the BindableEvent class."
	-- args: "tble: table"
	inherit = function(tble)
		for prop, val in pairs(propTable) do
			tble[prop] = val
		end
	end,
}
