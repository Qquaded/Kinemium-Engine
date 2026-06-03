--!strict
--!native
--!optimize 2

type TimeDictionary = {
    Year: number,
    Month: number,
    Day: number,
    Hour: number,
    Minute: number,
    Second: number,
    Millisecond: number,
}

local lune_datetime = require("@lune/datetime") :: any;

local DateTime = {
    UnixTimestamp = (nil :: any) :: number,
    UnixTimestampMillis = (nil :: any) :: number,
    __internal = (nil :: any) :: any,
}

DateTime.__type = "DateTime"
DateTime.__index = function(self: RobloxDateTime, key: string): any
    if (key == "UnixTimestamp") then
        return self.__internal.unixTimestamp;
    elseif (key == "UnixTimestampMillis") then
        return self.__internal.unixTimestampMillis;
    end
    return DateTime[key];
end
DateTime.__newindex = function(self: RobloxDateTime, key: string, value: any): ()
    error(`DateTime is read-only`);
end
DateTime.__tostring = function(self: RobloxDateTime): string
    return tostring(self.__internal.unixTimestampMillis);
end

DateTime.__eq = function(left: RobloxDateTime, right: RobloxDateTime): boolean
    return left.__internal.unixTimestampMillis == right.__internal.unixTimestampMillis;
end

function DateTime.toUniversalTime(self: RobloxDateTime): TimeDictionary
    local time = self.__internal:toUniversalTime()
    return {
        Year = time.year,
        Month = time.month,
        Day = time.day,
        Hour = time.hour,
        Minute = time.minute,
        Second = time.second,
        Millisecond = time.millisecond,
    }
end

function DateTime.ToLocalTime(self: RobloxDateTime): TimeDictionary
    local time = self.__internal:toLocalTime()
    return {
        Year = time.year,
        Month = time.month,
        Day = time.day,
        Hour = time.hour,
        Minute = time.minute,
        Second = time.second,
        Millisecond = time.millisecond,
    }
end

function DateTime.FormatLocalTime(self: RobloxDateTime, formatString: string?, locale: string?): string
    return self.__internal:formatLocalTime(formatString or "%Y-%m-%d %H:%M:%S");
end

function DateTime.FormatUniversalTime(self: RobloxDateTime, formatString: string?, locale: string?): string
    return self.__internal:formatUniversalTime(formatString or "%Y-%m-%d %H:%M:%S");
end

function DateTime.ToIsoDate(self: RobloxDateTime): string
    return self.__internal:toIsoDate()
end

type RobloxDateTime = typeof(DateTime);

local function newDateTime(internal: any): RobloxDateTime
    return setmetatable({
        __internal = internal,
    }, DateTime) :: any
end

local datetime = {};

function datetime.now(): RobloxDateTime
    return newDateTime(lune_datetime.now());
end

function datetime.fromUnixTimestamp(unixTimestamp: number): RobloxDateTime
	return newDateTime(lune_datetime.fromUnixTimestamp(unixTimestamp));
end

function datetime.fromUnixTimestampMillis(unixTimestampMillis: number): RobloxDateTime
   return newDateTime(lune_datetime.fromUnixTimestampMillis(unixTimestampMillis));
end

function datetime.fromUniversalTime(
    year: number?,
    month: number?,
    day: number?,
    hour: number?,
    minute: number?,
    second: number?,
    millisecond: number?
): RobloxDateTime
    return newDateTime(lune_datetime.fromUniversalTime({
        year = year or 1970,
        month = month or 1,
        day = day or 1,
        hour = hour or 0,
        minute = minute or 0,
        second = second or 0,
        millisecond = millisecond or 0
    }));
end

function datetime.fromLocalTime(
    year: number?,
    month: number?,
    day: number?,
    hour: number?,
    minute: number?,
    second: number?,
    millisecond: number?
): RobloxDateTime
    return newDateTime(lune_datetime.fromLocalTime({
        year = year or 1970,
        month = month or 1,
        day = day or 1,
        hour = hour or 0,
        minute = minute or 0,
        second = second or 0,
        millisecond = millisecond or 0
    }));
end

function datetime.fromIsoDate(isoDate: string): RobloxDateTime
    return newDateTime(lune_datetime.fromIsoDate(isoDate));
end

return datetime;
