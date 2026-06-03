-- description: "Lets you fire and recieve signals."
local signal = require("@Kinemium.signal")

local propTable = {}

return {
	class = "BindableEvent",
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

		-- description: "Shoulds simulate."
		-- args: "fn: function, priority: number"
		-- returns: "Connection"
		function instance:Connect(fn, priority)
			return bindableSignal:Connect(fn, priority)
		end

		return instance
	end,
	inherit = function(tble)
		for prop, val in pairs(propTable) do
			tble[prop] = val
		end
	end,
}
