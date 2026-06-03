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

local start_time = os.time()
local start_clock = os.clock()

local DateTime = {
    UnixTimestamp = (nil :: any) :: number,
    UnixTimestampMillis = (nil :: any) :: number,
}

DateTime.__type = "DateTime"
DateTime.__index = function(self: RobloxDateTime, key: string): any
    if (key == "UnixTimestamp") then
        return self.UnixTimestampMillis // 1000;
    end
    return DateTime[key];
end
DateTime.__newindex = function(self: RobloxDateTime, key: string, value: any): ()
    error(`DateTime is read-only`);
end
DateTime.__tostring = function(self: RobloxDateTime): string
    return tostring(self.UnixTimestampMillis);
end

DateTime.__eq = function(left: RobloxDateTime, right: RobloxDateTime): boolean
    return left.UnixTimestampMillis == right.UnixTimestampMillis;
end

function DateTime.toUniversalTime(self: RobloxDateTime): TimeDictionary
    error("Not implemented");
end

function DateTime.ToLocalTime(self: RobloxDateTime): TimeDictionary
    error("Not implemented");
end

function DateTime.FormatLocalTime(self: RobloxDateTime, formatString: string?, locale: string?): string
    error("Not implemented");
end

function DateTime.FormatUniversalTime(self: RobloxDateTime, formatString: string?, locale: string?): string
    error("Not implemented");
end

function DateTime.ToIsoDate(self: RobloxDateTime): string
    error("Not implemented");
end

type RobloxDateTime = typeof(DateTime);

local function newDateTime(timestampMillis: number): RobloxDateTime
    return setmetatable({
        UnixTimestampMillis = timestampMillis,
    }, DateTime) :: any
end

return {
    now = function(): RobloxDateTime
        return newDateTime(((start_time + (os.clock() - start_clock)) * 1000)// 1)
    end,
    fromUnixTimestamp = function(unixTimestamp: number): RobloxDateTime
        return newDateTime((unixTimestamp // 1) * 1000);
    end,
    fromUnixTimestampMillis = function(unixTimestampMillis: number): RobloxDateTime
        return newDateTime(unixTimestampMillis // 1);
    end,
    fromUniversalTime = function(
        year: number?,
        month: number?,
        day: number?,
        hour: number?,
        minute: number?,
        second: number?,
        millisecond: number?
    ): RobloxDateTime
        error("Not implemented");
    end,
    fromLocalTime = function(
        year: number?,
        month: number?,
        day: number?,
        hour: number?,
        minute: number?,
        second: number?,
        millisecond: number?
    ): RobloxDateTime
        error("Not implemented");
    end,
    fromIsoDate = function(isoDate: string): RobloxDateTime
        error("Not implemented");
    end,
};
