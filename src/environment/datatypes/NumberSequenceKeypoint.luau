local NumberSequenceKeypoint = {}
NumberSequenceKeypoint.__index = NumberSequenceKeypoint
NumberSequenceKeypoint.ClassName = "NumberSequenceKeypoint"

function NumberSequenceKeypoint.new(t, v)
	assert(type(t) == "number", "bad argument #1 to 'NumberSequenceKeypoint.new' (number expected)")
	assert(type(v) == "number", "bad argument #2 to 'NumberSequenceKeypoint.new' (number expected)")

	return setmetatable({
		Time = t,
		Value = v,
	}, NumberSequenceKeypoint)
end

function NumberSequenceKeypoint:ToTable()
	return {
		type = "NumberSequenceKeypoint",
		Time = self.Time,
		Value = self.Value,
	}
end

function NumberSequenceKeypoint.FromTable(tbl)
	assert(tbl.type == "NumberSequenceKeypoint")
	return NumberSequenceKeypoint.new(tbl.Time, tbl.Value)
end

return NumberSequenceKeypoint
