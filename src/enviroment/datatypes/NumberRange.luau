local NumberRange = {}
NumberRange.__index = NumberRange

function NumberRange.new(minVal, maxVal)
	minVal = minVal or 0
	if maxVal == nil then
		maxVal = minVal
	end
	return setmetatable({
		Min = minVal,
		Max = maxVal,
	}, NumberRange)
end

function NumberRange:__tostring()
	return string.format("NumberRange(%g, %g)", self.Min, self.Max)
end

function NumberRange:ToTable()
	return {
		type = "NumberRange",
		Min = self.Min,
		Max = self.Max,
	}
end

function NumberRange.FromTable(tbl)
	assert(tbl.type == "NumberRange")
	return NumberRange.new(tbl.Min, tbl.Max)
end

return NumberRange
