local Disposable = {}
Disposable.__index = Disposable

function Disposable.new()
	return setmetatable({
		_tasks = {},
		_destroyed = false,
	}, Disposable)
end

function Disposable:Add(task, methodName)
	assert(task ~= nil, "Cannot add nil task to Disposable")

	if self._destroyed then
		Disposable.CleanupTask(task, methodName)
		return
	end

	table.insert(self._tasks, { task = task, method = methodName })
end

function Disposable:Remove(task)
	for i = #self._tasks, 1, -1 do
		if self._tasks[i].task == task then
			table.remove(self._tasks, i)
			return
		end
	end
end

function Disposable.CleanupTask(task, methodName)
	if getmetatable(task) == Disposable then
		task:Destroy()
		return
	end

	if type(task) == "function" then
		pcall(task)
		return
	end

	local method = methodName or (type(task) == "table" and (task.Destroy or task.disconnect))
	if method and type(task[method]) == "function" then
		pcall(task[method], task)
		return
	end

	if type(task.disconnect) == "function" then
		pcall(task.disconnect, task)
	end
end

function Disposable:CleanUpAll()
	for i = #self._tasks, 1, -1 do
		local t = table.remove(self._tasks, i)
		Disposable.CleanupTask(t.task, t.method)
	end
end

function Disposable:Destroy()
	if self._destroyed then
		return
	end
	self._destroyed = true

	for i = #self._tasks, 1, -1 do
		local t = table.remove(self._tasks, i)
		Disposable.CleanupTask(t.task, t.method)
	end
end

function Disposable:IsDestroyed()
	return self._destroyed
end

return Disposable
