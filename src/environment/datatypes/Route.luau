local Route = {}

Route.routes = {}
Route.middlewares = {}
Route.hooks = { onAdd = {}, onRemove = {} }

local function routeToPattern(path)
	local pattern = path:gsub(":[^/]+", "([^/]+)") -- :param => capture
	pattern = pattern:gsub("%*", "(.*)") -- wildcard *
	return "^" .. pattern .. "$"
end

Route.cleanup = nil

function Route.add(path, handler)
	assert(type(path) == "string", "Route path must be a string")
	assert(type(handler) == "function", "Handler must be a function")

	local pattern = routeToPattern(path)
	Route.routes[path] = { handler = handler, pattern = pattern }

	for _, fn in ipairs(Route.hooks.onAdd) do
		fn(path)
	end
end

function Route.remove(path)
	Route.routes[path] = nil
	for _, fn in ipairs(Route.hooks.onRemove) do
		fn(path)
	end
end

function Route.clear()
	for path in pairs(Route.routes) do
		Route.remove(path)
	end
end

function Route.count()
	local n = 0
	for _ in pairs(Route.routes) do
		n = n + 1
	end
	return n
end

function Route.list()
	local keys = {}
	for k in pairs(Route.routes) do
		table.insert(keys, k)
	end
	return keys
end

function Route.has(path)
	return Route.routes[path] ~= nil
end

function Route.use(fn)
	assert(type(fn) == "function", "Middleware must be a function")
	table.insert(Route.middlewares, fn)
end

function Route.on(event, fn)
	assert(event == "onAdd" or event == "onRemove", "Invalid event")
	assert(type(fn) == "function", "Hook must be a function")
	table.insert(Route.hooks[event], fn)
end

function Route.handle(path, ...)
	for _, mw in ipairs(Route.middlewares) do
		local stop = mw(path, ...)
		if stop then
			return stop
		end
	end

	for _, route in pairs(Route.routes) do
		local captures = { path:match(route.pattern) }
		if #captures > 0 then
			if Route.cleanup then
				Route.cleanup()
				Route.cleanup = nil
			end

			local result = route.handler(table.unpack(captures), ...)

			if type(result) == "function" then
				Route.cleanup = result
			end

			return result
		end
	end

	return nil, "404: Route not found"
end

function Route.deselect()
	if Route.cleanup then
		Route.cleanup()
		Route.cleanup = nil
	end
end

function Route.callSafe(path, ...)
	local ok, result = pcall(Route.handle, path, ...)
	if ok then
		return result
	else
		return nil, result
	end
end

return Route
