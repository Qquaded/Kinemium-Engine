local UDim = { __type = "UDim" }
UDim.__index = UDim

-- Constructor
function UDim.new(scale, offset)
	return setmetatable({
		Scale = scale or 0,
		Offset = offset or 0,
	}, UDim)
end

function UDim.__add(a, b)
	return UDim.new(a.Scale + b.Scale, a.Offset + b.Offset)
end

function UDim.__sub(a, b)
	return UDim.new(a.Scale - b.Scale, a.Offset - b.Offset)
end

function UDim.__mul(a, b)
	if type(b) == "number" then
		return UDim.new(a.Scale * b, a.Offset * b)
	elseif type(a) == "number" then
		return UDim.new(a * b.Scale, a * b.Offset)
	else
		error("UDim can only multiply by a number")
	end
end

function UDim.__div(a, b)
	if type(b) == "number" then
		return UDim.new(a.Scale / b, a.Offset / b)
	else
		error("UDim can only divide by a number")
	end
end

function UDim.__tostring(u)
	return string.format("UDim(Scale: %f, Offset: %d)", u.Scale, u.Offset)
end

function UDim:Clone()
	return UDim.new(self.Scale, self.Offset)
end

function UDim:ToPixels(total)
	return self.Scale * total + self.Offset
end

function UDim:ToTable()
	return {
		type = "UDim",
		Scale = self.Scale,
		Offset = self.Offset,
	}
end

function UDim.FromTable(tbl)
	assert(tbl.type == "UDim")
	return UDim.new(tbl.Scale, tbl.Offset)
end

return UDim
