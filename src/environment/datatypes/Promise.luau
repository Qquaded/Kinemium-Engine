-- Kinemium Promise by devcell

local Promise = {}
Promise.__index = Promise

local PENDING = 0
local FULFILLED = 1
local REJECTED = 2
local CANCELED = 3

local function defer(fn)
	coroutine.wrap(fn)()
end

local function isPromise(v)
	return type(v) == "table" and getmetatable(v) == Promise
end

local function isCallable(v)
	return type(v) == "function" or (type(v) == "table" and getmetatable(v) and getmetatable(v).__call)
end

function Promise.new(executor)
	local self = setmetatable({}, Promise)

	self._state = PENDING
	self._value = nil
	self._handlers = {}
	self._cancelHook = nil

	local function resolve(value)
		if self._state ~= PENDING then
			return
		end

		if isPromise(value) then
			value:_then(resolve, reject)
			return
		end

		self._state = FULFILLED
		self._value = value

		local handlers = self._handlers
		self._handlers = nil

		for _, h in ipairs(handlers) do
			defer(function()
				h.onFulfilled(value)
			end)
		end
	end

	local function reject(reason)
		if self._state ~= PENDING then
			return
		end

		self._state = REJECTED
		self._value = reason

		local handlers = self._handlers
		self._handlers = nil

		for _, h in ipairs(handlers) do
			defer(function()
				h.onRejected(reason)
			end)
		end
	end

	local function onCancel(fn)
		self._cancelHook = fn
	end

	local ok, err = pcall(function()
		executor(resolve, reject, onCancel)
	end)

	if not ok then
		reject(err)
	end

	return self
end

function Promise:_then(onFulfilled, onRejected)
	return Promise.new(function(resolve, reject)
		local function handleFulfilled(value)
			if not isCallable(onFulfilled) then
				resolve(value)
				return
			end

			local ok, result = pcall(onFulfilled, value)
			if ok then
				resolve(result)
			else
				reject(result)
			end
		end

		local function handleRejected(reason)
			if not isCallable(onRejected) then
				reject(reason)
				return
			end

			local ok, result = pcall(onRejected, reason)
			if ok then
				resolve(result)
			else
				reject(result)
			end
		end

		if self._state == PENDING then
			table.insert(self._handlers, {
				onFulfilled = handleFulfilled,
				onRejected = handleRejected,
			})
		elseif self._state == FULFILLED then
			defer(function()
				handleFulfilled(self._value)
			end)
		elseif self._state == REJECTED then
			defer(function()
				handleRejected(self._value)
			end)
		elseif self._state == CANCELED then
			reject("Promise was canceled")
		end
	end)
end

Promise.andThen = Promise._then
Promise["then"] = Promise._then

function Promise:catch(onRejected)
	return self:_then(nil, onRejected)
end

function Promise:finally(onFinally)
	return self:_then(function(v)
		if isCallable(onFinally) then
			onFinally()
		end
		return v
	end, function(e)
		if isCallable(onFinally) then
			onFinally()
		end
		error(e, 0)
	end)
end

function Promise:cancel()
	if self._state ~= PENDING then
		return false
	end

	self._state = CANCELED
	self._value = "canceled"

	self._handlers = nil

	if self._cancelHook then
		pcall(self._cancelHook)
	end

	return true
end

function Promise:isCanceled()
	return self._state == CANCELED
end

function Promise:isPending()
	return self._state == PENDING
end

function Promise:isFulfilled()
	return self._state == FULFILLED
end

function Promise:isRejected()
	return self._state == REJECTED
end

function Promise:isSettled()
	return self._state ~= PENDING
end

function Promise.resolve(value)
	if isPromise(value) then
		return value
	end
	return Promise.new(function(resolve)
		resolve(value)
	end)
end

function Promise.reject(reason)
	return Promise.new(function(_, reject)
		reject(reason)
	end)
end

function Promise.all(promises)
	return Promise.new(function(resolve, reject)
		if type(promises) ~= "table" then
			reject("Promise.all expects a table")
			return
		end

		local results = {}
		local remaining = #promises

		if remaining == 0 then
			resolve(results)
			return
		end

		local rejected = false

		for i, p in ipairs(promises) do
			local promise = isPromise(p) and p or Promise.resolve(p)

			promise:_then(function(v)
				if rejected then
					return
				end
				results[i] = v
				remaining = remaining - 1
				if remaining == 0 then
					resolve(results)
				end
			end, function(err)
				if rejected then
					return
				end
				rejected = true
				reject(err)
			end)
		end
	end)
end

function Promise.race(promises)
	return Promise.new(function(resolve, reject)
		if type(promises) ~= "table" then
			reject("Promise.race expects a table")
			return
		end

		if #promises == 0 then
			return
		end

		local settled = false

		for _, p in ipairs(promises) do
			local promise = isPromise(p) and p or Promise.resolve(p)

			promise:_then(function(v)
				if not settled then
					settled = true
					resolve(v)
				end
			end, function(err)
				if not settled then
					settled = true
					reject(err)
				end
			end)
		end
	end)
end

function Promise.any(promises)
	return Promise.new(function(resolve, reject)
		if type(promises) ~= "table" then
			reject("Promise.any expects a table")
			return
		end

		if #promises == 0 then
			reject("No promises provided")
			return
		end

		local errors = {}
		local remaining = #promises
		local resolved = false

		for i, p in ipairs(promises) do
			local promise = isPromise(p) and p or Promise.resolve(p)

			promise:_then(function(v)
				if not resolved then
					resolved = true
					resolve(v)
				end
			end, function(err)
				if resolved then
					return
				end
				errors[i] = err
				remaining = remaining - 1
				if remaining == 0 then
					reject({ errors = errors, message = "All promises rejected" })
				end
			end)
		end
	end)
end

function Promise.allSettled(promises)
	return Promise.new(function(resolve, reject)
		if type(promises) ~= "table" then
			reject("Promise.allSettled expects a table")
			return
		end

		local results = {}
		local remaining = #promises

		if remaining == 0 then
			resolve(results)
			return
		end

		for i, p in ipairs(promises) do
			local promise = isPromise(p) and p or Promise.resolve(p)

			promise
				:_then(function(v)
					results[i] = { status = "fulfilled", value = v }
				end, function(e)
					results[i] = { status = "rejected", reason = e }
				end)
				:finally(function()
					remaining = remaining - 1
					if remaining == 0 then
						resolve(results)
					end
				end)
		end
	end)
end

function Promise.delay(ms, value)
	return Promise.new(function(resolve)
		defer(function()
			local start = os.clock()
			while (os.clock() - start) * 1000 < ms do
			end
			resolve(value)
		end)
	end)
end

function Promise.await(promise)
	if not isPromise(promise) then
		promise = Promise.resolve(promise)
	end

	local co = coroutine.running()
	if not co then
		error("Promise.await must be called inside a coroutine", 2)
	end

	local settled = false

	promise:_then(function(v)
		if not settled then
			settled = true
			coroutine.resume(co, true, v)
		end
	end, function(e)
		if not settled then
			settled = true
			coroutine.resume(co, false, e)
		end
	end)

	local ok, value = coroutine.yield()
	if not ok then
		error(value, 2)
	end
	return value
end

function Promise.promisify(fn)
	return function(...)
		local args = { ... }
		return Promise.new(function(resolve, reject)
			table.insert(args, function(err, ...)
				if err then
					reject(err)
				else
					resolve(...)
				end
			end)
			fn(table.unpack(args))
		end)
	end
end

return Promise
