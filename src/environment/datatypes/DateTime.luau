local DateTime = {}
DateTime.__index = DateTime

function DateTime.now()
	return DateTime.fromUnixTimestamp(os.time())
end

function DateTime.fromUnixTimestamp(timestamp)
	local self = setmetatable({}, DateTime)
	self.UnixTimestamp = timestamp
	self.UnixTimestampMillis = timestamp * 1000
	return self
end

function DateTime.fromIsoDate(isoDate)
	-- Basic ISO 8601 parser (YYYY-MM-DDTHH:MM:SSZ)
	local pattern = "(%d+)-(%d+)-(%d+)T(%d+):(%d+):(%d+)Z"
	local year, month, day, hour, min, sec = isoDate:match(pattern)

	if not year then
		return nil
	end

	local time = os.time({
		year = tonumber(year) or 1970,
		month = tonumber(month) or 1,
		day = tonumber(day) or 1,
		hour = tonumber(hour) or 0,
		min = tonumber(min) or 0,
		sec = tonumber(sec) or 0,
	})

	return DateTime.fromUnixTimestamp(time)
end

function DateTime:ToIsoDate()
	return os.date("!%Y-%m-%dT%H:%M:%SZ", self.UnixTimestamp)
end

function DateTime:FormatLocalTime(formatString, locale)
	return os.date(formatString, self.UnixTimestamp)
end

function DateTime:FormatUniversalTime(formatString, locale)
	return os.date("!" .. formatString, self.UnixTimestamp)
end

function DateTime.fromUnixTimestampMillis(ms)
	local self = setmetatable({}, DateTime)
	self.UnixTimestampMillis = ms
	self.UnixTimestamp = math.floor(ms / 1000)
	return self
end

function DateTime:AddSeconds(seconds)
	return DateTime.fromUnixTimestamp(self.UnixTimestamp + seconds)
end

function DateTime:AddMinutes(minutes)
	return self:AddSeconds(minutes * 60)
end

function DateTime:AddHours(hours)
	return self:AddSeconds(hours * 3600)
end

function DateTime:AddDays(days)
	return self:AddSeconds(days * 86400)
end

function DateTime:Difference(other)
	return self.UnixTimestamp - other.UnixTimestamp
end

function DateTime:IsBefore(other)
	return self.UnixTimestamp < other.UnixTimestamp
end

function DateTime:IsAfter(other)
	return self.UnixTimestamp > other.UnixTimestamp
end

function DateTime:IsEqual(other)
	return self.UnixTimestamp == other.UnixTimestamp
end

function DateTime:ToLocalTable()
	return os.date("*t", self.UnixTimestamp)
end

function DateTime:ToUniversalTable()
	return os.date("!*t", self.UnixTimestamp)
end

function DateTime:ToUnixTimestampMillis()
	return self.UnixTimestampMillis
end

function DateTime.fromLocalDate(tbl)
	return DateTime.fromUnixTimestamp(os.time(tbl))
end

function DateTime.nowMillis()
	return DateTime.fromUnixTimestampMillis(os.time() * 1000)
end

function DateTime:ToTable()
	return {
		type = "DateTime",
		UnixTimestamp = self.UnixTimestamp,
		UnixTimestampMillis = self.UnixTimestampMillis,
	}
end

function DateTime.FromTable(tbl)
	assert(tbl.type == "DateTime", "Table is not a DateTime")
	return DateTime.fromUnixTimestamp(tbl.UnixTimestamp)
end

function DateTime:__tostring()
	return self:ToIsoDate()
end

return DateTime
