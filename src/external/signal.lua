-- KinemiumSignal.lua
local Signal = {}
Signal.__index = Signal

-- connection object
local Connection = {}
Connection.__index = Connection

function Connection.new(signal, fn, priority)
	local self = setmetatable({}, Connection)
	self._signal = signal
	self._fn = fn
	self.Connected = true
	self.Priority = priority or 0
	return self
end

function Connection:Disconnect()
	if not self.Connected then
		return
	end
	self.Connected = false
	local sig = self._signal
	if sig and sig._connections then
		for i = #sig._connections, 1, -1 do
			if sig._connections[i] == self then
				table.remove(sig._connections, i)
				break
			end
		end
	end
	self._signal = nil
	self._fn = nil
end

function Connection:Fire(...)
	if self.Connected and self._fn then
		local ok, err = pcall(self._fn, ...)
		if not ok then
			print(err)
		end
	end
end

function Connection:SetPriority(priority)
	self.Priority = priority
	if self._signal then
		self._signal:_sortConnections()
	end
end

-- signal container
function Signal.new()
	local self = setmetatable({}, Signal)
	self._connections = {}
	self._prevState = {}
	self._paused = false
	self._queuedFires = {}
	self._filters = {}
	self._middlewares = {}
	self._history = {}
	self._historyLimit = 10
	self._debugMode = false
	return self
end

function Signal:Connect(fn, priority)
	local conn = Connection.new(self, fn, priority)
	table.insert(self._connections, conn)
	self:_sortConnections()
	return conn
end

function Signal:Once(fn)
	local conn
	conn = self:Connect(function(...)
		conn:Disconnect()
		fn(...)
	end)
	return conn
end

function Signal:Wait(timeout)
	local thread = coroutine.running()
	local conn
	local timedOut = false

	conn = self:Connect(function(...)
		if not timedOut then
			conn:Disconnect()
			task.spawn(thread, true, ...)
		end
	end)

	if timeout then
		task.delay(timeout, function()
			if conn.Connected then
				timedOut = true
				conn:Disconnect()
				task.spawn(thread, false)
			end
		end)
	end

	return coroutine.yield()
end

function Signal:Fire(...)
	if self._paused then
		table.insert(self._queuedFires, { ... })
		return
	end

	local args = { ... }

	-- Apply filters
	for _, filter in ipairs(self._filters) do
		local shouldContinue, modifiedArgs = filter(table.unpack(args))
		if not shouldContinue then
			return
		end
		if modifiedArgs then
			args = modifiedArgs
		end
	end

	-- Apply middlewares
	for _, middleware in ipairs(self._middlewares) do
		args = { middleware(table.unpack(args)) }
	end

	-- Store in history
	if self._historyLimit > 0 then
		table.insert(self._history, 1, { os.clock(), args })
		if #self._history > self._historyLimit then
			table.remove(self._history)
		end
	end

	if self._debugMode then
		print(string.format("[Signal Debug] Firing with %d args to %d listeners", #args, #self._connections))
	end

	for _, conn in ipairs(self._connections) do
		conn:Fire(table.unpack(args))
	end
end

function Signal:FireDeferred(...)
	local args = { ... }
	task.defer(function()
		self:Fire(table.unpack(args))
	end)
end

function Signal:FireParallel(...)
	local args = { ... }
	for _, conn in ipairs(self._connections) do
		task.spawn(function()
			conn:Fire(table.unpack(args))
		end)
	end
end

function Signal:Pause()
	self._paused = true
end

function Signal:Resume()
	self._paused = false
	for _, args in ipairs(self._queuedFires) do
		self:Fire(table.unpack(args))
	end
	self._queuedFires = {}
end

function Signal:IsPaused()
	return self._paused
end

function Signal:AddFilter(filterFn)
	table.insert(self._filters, filterFn)
	return function()
		for i, f in ipairs(self._filters) do
			if f == filterFn then
				table.remove(self._filters, i)
				break
			end
		end
	end
end

function Signal:AddMiddleware(middlewareFn)
	table.insert(self._middlewares, middlewareFn)
	return function()
		for i, m in ipairs(self._middlewares) do
			if m == middlewareFn then
				table.remove(self._middlewares, i)
				break
			end
		end
	end
end

function Signal:GetHistory(count)
	count = count or #self._history
	local result = {}
	for i = 1, math.min(count, #self._history) do
		table.insert(result, self._history[i])
	end
	return result
end

function Signal:SetHistoryLimit(limit)
	self._historyLimit = limit
	while #self._history > limit do
		table.remove(self._history)
	end
end

function Signal:ClearHistory()
	self._history = {}
end

function Signal:SetDebugMode(enabled)
	self._debugMode = enabled
end

function Signal:DisconnectAll()
	for i = #self._connections, 1, -1 do
		self._connections[i]:Disconnect()
	end
	self._connections = {}
end

function Signal:GetConnectionCount()
	return #self._connections
end

function Signal:FireOncePerPress(id, currentState, ...)
	if not self._prevState[id] then
		self._prevState[id] = 0
	end

	local state = 0
	if type(currentState) == "boolean" then
		state = currentState and 1 or 0
	elseif type(currentState) == "number" then
		state = (currentState ~= 0) and 1 or 0
	else
		error("FireOncePerPress: currentState must be boolean or number")
	end

	if state == 1 and self._prevState[id] == 0 then
		self:Fire(...)
	end

	self._prevState[id] = state
end

function Signal:ConnectThrottled(fn, cooldown)
	local lastFire = 0
	return self:Connect(function(...)
		local now = os.clock()
		if now - lastFire >= cooldown then
			lastFire = now
			fn(...)
		end
	end)
end

function Signal:ConnectDebounced(fn, delay)
	local scheduled = nil
	return self:Connect(function(...)
		local args = { ... }
		if scheduled then
			task.cancel(scheduled)
		end
		scheduled = task.delay(delay, function()
			fn(table.unpack(args))
			scheduled = nil
		end)
	end)
end

function Signal:ConnectConditional(condition, fn)
	return self:Connect(function(...)
		if condition(...) then
			fn(...)
		end
	end)
end

function Signal:Map(transformFn)
	local mappedSignal = Signal.new()
	self:Connect(function(...)
		local result = { transformFn(...) }
		mappedSignal:Fire(table.unpack(result))
	end)
	return mappedSignal
end

function Signal:Merge(otherSignal)
	local mergedSignal = Signal.new()
	self:Connect(function(...)
		mergedSignal:Fire(...)
	end)
	otherSignal:Connect(function(...)
		mergedSignal:Fire(...)
	end)
	return mergedSignal
end

function Signal:_sortConnections()
	table.sort(self._connections, function(a, b)
		return a.Priority > b.Priority
	end)
end

function Signal:Destroy()
	self:DisconnectAll()
	self._prevState = {}
	self._queuedFires = {}
	self._filters = {}
	self._middlewares = {}
	self._history = {}
	setmetatable(self, nil)
end

function Signal:__tostring()
	return ("Signal(%d listeners, %s)"):format(#self._connections, self._paused and "paused" or "active")
end

return Signal
