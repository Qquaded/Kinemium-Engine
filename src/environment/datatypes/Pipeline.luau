local Pipeline = {}
Pipeline.__index = Pipeline

local Pipelines = {}

function Pipeline.Get(name)
	local pipeline = Pipelines[name]

	if not pipeline then
		pipeline = setmetatable({
			_queue = {},
			_consumer = nil,
		}, Pipeline)

		Pipelines[name] = pipeline
	end

	return pipeline
end

function Pipeline:Push(...)
	if self._consumer then
		self._consumer(...)
	else
		table.insert(self._queue, table.pack(...))
	end
end

function Pipeline:Consume(callback)
	self._consumer = callback

	for i = 1, #self._queue do
		callback(table.unpack(self._queue[i], 1, self._queue[i].n))
	end

	table.clear(self._queue)
end

function Pipeline:GetPending()
	return self._queue
end

function Pipeline:Clear()
	table.clear(self._queue)
end

function Pipeline:Destroy()
	self:Clear()
	self._consumer = nil

	for name, pipeline in pairs(Pipelines) do
		if pipeline == self then
			Pipelines[name] = nil
			break
		end
	end
end

return Pipeline
