local Enum = require("@EnumMap")

local TweenInfo = {}
TweenInfo.__index = TweenInfo

function TweenInfo.new(time, easingStyle, easingDirection, repeatCount, reverses, delayTime)
	local self = setmetatable({}, TweenInfo)

	self.Time = time or 1.0
	self.EasingStyle = easingStyle or Enum.EasingStyle.Quad
	self.EasingDirection = easingDirection or Enum.EasingDirection.Out
	self.RepeatCount = repeatCount or 0
	self.Reverses = reverses or false
	self.DelayTime = delayTime or 0

	return self
end

function TweenInfo:ToTable()
	return {
		type = "TweenInfo",
		Time = self.Time,
		EasingStyle = self.EasingStyle,
		EasingDirection = self.EasingDirection,
		RepeatCount = self.RepeatCount,
		Reverses = self.Reverses,
		DelayTime = self.DelayTime,
	}
end

function TweenInfo.FromTable(tbl)
	assert(tbl.type == "TweenInfo", "Table is not a TweenInfo")
	return TweenInfo.new(tbl.Time, tbl.EasingStyle, tbl.EasingDirection, tbl.RepeatCount, tbl.Reverses, tbl.DelayTime)
end

return TweenInfo
