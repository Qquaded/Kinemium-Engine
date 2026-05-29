-- description: "Represents a BindableFunction in the environment."
local propTable = {
	OnInvoke = nil,
}

return {
	class = "BindableFunction",
	-- description: "Initializes the BindableFunction instance."
	-- args: "instance: table, renderer: number, game: table"
	-- returns: "table"
	callback = function(instance, renderer, game)
		instance:SetProperties(propTable)

		instance.Name = "BindableFunction"

		-- description: "Invokes."
		-- args: "...: any"
		function instance:Invoke(...)
			if type(instance.OnInvoke) == "function" then
				return instance.OnInvoke(...)
			else
				error("OnInvoke is not a function")
			end
		end

		return instance
	end,
	-- description: "Inherits the properties of the BindableFunction class."
	-- args: "tble: table"
	inherit = function(tble)
		for prop, val in pairs(propTable) do
			tble[prop] = val
		end
	end,
}
