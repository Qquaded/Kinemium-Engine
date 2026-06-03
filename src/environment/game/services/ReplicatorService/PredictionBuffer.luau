local PredictionBuffer = {}
PredictionBuffer.__index = PredictionBuffer

function PredictionBuffer.new(maxEntries)
	local max = maxEntries or 128
	return setmetatable({
		maxEntries = max,
		order = table.create(max),
		entries = {},
		head = 0,
		count = 0,
	}, PredictionBuffer)
end

function PredictionBuffer:Push(sequence, payload)
	if self.entries[sequence] ~= nil then
		self.entries[sequence] = payload
		return
	end

	self.entries[sequence] = payload

	if self.count == self.maxEntries then
		local oldest = self.order[self.head + 1]
		self.entries[oldest] = nil
		self.head = (self.head + 1) % self.maxEntries
		self.order[(self.head + self.count - 1) % self.maxEntries + 1] = sequence
	else
		self.order[(self.head + self.count) % self.maxEntries + 1] = sequence
		self.count += 1
	end
end

function PredictionBuffer:Acknowledge(sequence)
	while self.count > 0 do
		local oldest = self.order[self.head + 1]
		if oldest <= sequence then
			self.entries[oldest] = nil
			self.head = (self.head + 1) % self.maxEntries
			self.count -= 1
		else
			break
		end
	end
end

function PredictionBuffer:GetLatest()
	if self.count == 0 then
		return nil
	end

	local latestSequence = self.order[(self.head + self.count - 1) % self.maxEntries + 1]
	return self.entries[latestSequence]
end

function PredictionBuffer:GetLatestSequence()
	if self.count == 0 then
		return nil
	end

	return self.order[(self.head + self.count - 1) % self.maxEntries + 1]
end

function PredictionBuffer:GetAtOrBefore(sequence)
	local bestSequence = nil
	for i = 0, self.count - 1 do
		local entrySequence = self.order[(self.head + i) % self.maxEntries + 1]
		if entrySequence and entrySequence <= sequence and (bestSequence == nil or entrySequence > bestSequence) then
			bestSequence = entrySequence
		end
	end

	if bestSequence == nil then
		return nil
	end

	return self.entries[bestSequence]
end

return PredictionBuffer
