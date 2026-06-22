-- description: "An object that can be used for running tasks in parallel."
local propTable = {
	Name = "Actor",
	BaseClass = "Model",
}

return {
	class = "Actor",

	callback = function(instance)
		instance:SetProperties(propTable)

		local bindedToMessage = {}
		local bindedToMessageParallel = {}

		local zune_task = zune.task

		-- description: "Sends a message to the actor's thread."
		-- args: "topic: string, ...: any"
		function instance:SendMessage(topic, ...)
			if bindedToMessage[topic] then
				for _, cb in ipairs(bindedToMessage[topic]) do
					if zune_task then
						zune_task.spawn(cb, ...)
					end
				end
			end
			if bindedToMessageParallel[topic] then
				for _, cb in ipairs(bindedToMessageParallel[topic]) do
					-- Parallel execution context simulation via desync
					if zune_task then
						zune_task.spawn(function(...)
							local thread = coroutine.running()
							if thread then
								zune_task.defer(thread)
								coroutine.yield()
							end
							cb(...)
						end, ...)
					end
				end
			end
		end

		local function createConnection(list, topic, callback)
			return {
				-- description: "Disconnects."
				Disconnect = function()
					local listeners = list[topic]
					if listeners then
						for i = #listeners, 1, -1 do
							if listeners[i] == callback then
								table.remove(listeners, i)
								break
							end
						end
					end
				end,
				Connected = true,
			}
		end

		-- description: "Binds to message."
		-- args: "topic: string, callback: function"
		function instance:BindToMessage(topic, callback)
			if not bindedToMessage[topic] then
				bindedToMessage[topic] = {}
			end
			table.insert(bindedToMessage[topic], callback)
			return createConnection(bindedToMessage, topic, callback)
		end

		-- description: "Binds to message parallel."
		-- args: "topic: string, callback: function"
		function instance:BindToMessageParallel(topic, callback)
			if not bindedToMessageParallel[topic] then
				bindedToMessageParallel[topic] = {}
			end
			table.insert(bindedToMessageParallel[topic], callback)
			return createConnection(bindedToMessageParallel, topic, callback)
		end

		return instance
	end,
	inherit = function(tble)
		for prop, val in pairs(propTable) do
			tble[prop] = val
		end
	end,
}
