local ValueCurveKey = {}
ValueCurveKey.__index = ValueCurveKey

local Enum = require("@EnumMap")

function ValueCurveKey.new(time, value, interpolation)
	return setmetatable({
		Time = time or 0,
		Value = value,
		Interpolation = interpolation or Enum.KeyInterpolationMode.Linear,
		LeftTangent = 0,
		RightTangent = 0,
	}, ValueCurveKey)
end

function ValueCurveKey:__tostring()
	return string.format(
		"ValueCurveKey(Time=%g, Value=%s, Interpolation=%d, LeftTangent=%g, RightTangent=%g)",
		self.Time,
		tostring(self.Value),
		self.Interpolation,
		self.LeftTangent,
		self.RightTangent
	)
end

function ValueCurveKey:SetRightTangent(tangent)
	if self.Interpolation ~= Enum.KeyInterpolationMode.Cubic then
		error("RightTangent can only be set for cubic interpolation")
	end
	self.RightTangent = tangent
end

function ValueCurveKey:SetLeftTangent(tangent)
	self.LeftTangent = tangent
end

function ValueCurveKey:ToTable()
	return {
		type = "ValueCurveKey",
		Time = self.Time,
		Value = self.Value,
		Interpolation = self.Interpolation,
		LeftTangent = self.LeftTangent,
		RightTangent = self.RightTangent,
	}
end

function ValueCurveKey.FromTable(tbl)
	assert(tbl.type == "ValueCurveKey", "Table is not a ValueCurveKey")
	local key = ValueCurveKey.new(tbl.Time, tbl.Value, tbl.Interpolation)
	key.LeftTangent = tbl.LeftTangent or 0
	key.RightTangent = tbl.RightTangent or 0
	return key
end

return ValueCurveKey
