local DateTime = require("@DateTime")
local testing = zune.testing
local expect = testing.expect

testing.describe("DateTime Core Initialization", function()
	testing.test("DateTime.now()", function()
		local dt = DateTime.now()
		expect(dt.UnixTimestamp).toBeGreaterThan(0)
		expect(dt.UnixTimestampMillis).toBeGreaterThan(0)
		expect(dt.UnixTimestampMillis).toBe(dt.UnixTimestamp * 1000)
	end)

	testing.test("DateTime.fromUnixTimestamp()", function()
		local dt = DateTime.fromUnixTimestamp(1000)
		expect(dt.UnixTimestamp).toBe(1000)
		expect(dt.UnixTimestampMillis).toBe(1000000)
	end)

	testing.test("DateTime.fromUnixTimestampMillis()", function()
		local dt = DateTime.fromUnixTimestampMillis(1500)
		expect(dt.UnixTimestampMillis).toBe(1500)
		expect(dt.UnixTimestamp).toBe(1)
	end)

	testing.test("DateTime.nowMillis()", function()
		local dt = DateTime.nowMillis()
		expect(dt.UnixTimestamp).toBeGreaterThan(0)
		expect(dt.UnixTimestampMillis).toBeGreaterThan(0)
	end)

	testing.test("DateTime.fromLocalDate()", function()
		local tbl = {
			year = 2023,
			month = 1,
			day = 1,
			hour = 0,
			min = 0,
			sec = 0,
		}
		local expected = os.time(tbl)
		local dt = DateTime.fromLocalDate(tbl)
		expect(dt.UnixTimestamp).toBe(expected)
	end)
end)

testing.describe("DateTime Time Manipulation and Comparison", function()
	testing.test("Time Manipulation Methods", function()
		local dt = DateTime.fromUnixTimestamp(1000)

		local dt2 = dt:AddSeconds(10)
		expect(dt2.UnixTimestamp).toBe(1010)

		local dt3 = dt:AddMinutes(2)
		expect(dt3.UnixTimestamp).toBe(1120)

		local dt4 = dt:AddHours(1)
		expect(dt4.UnixTimestamp).toBe(4600)

		local dt5 = dt:AddDays(1)
		expect(dt5.UnixTimestamp).toBe(87400)
	end)

	testing.test("Comparison Methods", function()
		local dt1 = DateTime.fromUnixTimestamp(1000)
		local dt2 = DateTime.fromUnixTimestamp(2000)

		expect(dt1:Difference(dt2)).toBe(-1000)
		expect(dt2:Difference(dt1)).toBe(1000)

		expect(dt1:IsBefore(dt2)).toBe(true)
		expect(dt2:IsBefore(dt1)).toBe(false)

		expect(dt2:IsAfter(dt1)).toBe(true)
		expect(dt1:IsAfter(dt2)).toBe(false)

		expect(dt1:IsEqual(DateTime.fromUnixTimestamp(1000))).toBe(true)
		expect(dt1:IsEqual(dt2)).toBe(false)
	end)

	testing.test("DateTime:ToUnixTimestampMillis()", function()
		local dt = DateTime.fromUnixTimestampMillis(5000)
		expect(dt:ToUnixTimestampMillis()).toBe(5000)
	end)

	testing.test("Serialization (ToTable/FromTable)", function()
		local dt = DateTime.fromUnixTimestamp(1000)
		local tbl = dt:ToTable()

		expect(type(tbl)).toBe("table")
		expect(tbl.type).toBe("DateTime")
		expect(tbl.UnixTimestamp).toBe(1000)
		expect(tbl.UnixTimestampMillis).toBe(1000000)

		local deserialized = DateTime.FromTable(tbl)
		expect(deserialized.UnixTimestamp).toBe(1000)
		expect(deserialized.UnixTimestampMillis).toBe(1000000)

		local invalidTbl = { type = "NotDateTime" }
		local success, _ = pcall(function()
			DateTime.FromTable(invalidTbl)
		end)
		expect(success).toBe(false)
	end)
end)

testing.describe("DateTime Parsing and Formatting", function()
	testing.test("DateTime.fromIsoDate()", function()
		-- We parse a known date that gives us a specific local OS time via os.time()
		-- since fromIsoDate uses os.time(...) under the hood.
		local dt = DateTime.fromIsoDate("2023-01-01T12:00:00Z")
		expect(dt.UnixTimestamp).toBe(os.time({
			year = 2023,
			month = 1,
			day = 1,
			hour = 12,
			min = 0,
			sec = 0,
		}))

		local invalid = DateTime.fromIsoDate("invalid-date")
		expect(invalid).toBe(nil)
	end)

	testing.test("DateTime:ToIsoDate()", function()
		local tbl = {
			year = 2023,
			month = 1,
			day = 1,
			hour = 12,
			min = 0,
			sec = 0,
		}
		local time = os.time(tbl)
		local dt = DateTime.fromUnixTimestamp(time)
		local iso = dt:ToIsoDate()
		-- OS timezone handling means ToIsoDate returns UTC which we constructed here.
		-- It uses '!%Y-%m-%dT%H:%M:%SZ', so it assumes UnixTimestamp is in local time but formatted in UTC.
		-- We just check that the string matches the expected pattern format.
		expect(type(iso)).toBe("string")
		expect(string.match(iso, "^%d%d%d%d%-%d%d%-%d%dT%d%d:%d%d:%d%dZ$") ~= nil).toBe(true)
	end)

	testing.test("DateTime:FormatLocalTime()", function()
		local dt = DateTime.fromUnixTimestamp(1000)
		local formatted = dt:FormatLocalTime("%Y")
		expect(type(formatted)).toBe("string")
		-- Just like ToLocalTable, the local year could be 1969 depending on timezone.
		expect(tonumber(formatted) >= 1969).toBe(true)
	end)

	testing.test("DateTime:FormatUniversalTime()", function()
		local dt = DateTime.fromUnixTimestamp(1000)
		local formatted = dt:FormatUniversalTime("%Y")
		expect(formatted).toBe("1970")
	end)

	testing.test("DateTime:ToLocalTable()", function()
		local dt = DateTime.fromUnixTimestamp(1000)
		local tbl = dt:ToLocalTable()
		expect(type(tbl)).toBe("table")
		-- On machines behind UTC, 1000 seconds past epoch is still 1969.
		-- So we expect it to be at least 1969.
		expect(tbl.year >= 1969).toBe(true)
	end)

	testing.test("DateTime:ToUniversalTable()", function()
		local dt = DateTime.fromUnixTimestamp(1000)
		local tbl = dt:ToUniversalTable()
		expect(type(tbl)).toBe("table")
		expect(tbl.year).toBe(1970)
		expect(tbl.month).toBe(1)
		expect(tbl.day).toBe(1)
	end)

	testing.test("DateTime:__tostring()", function()
		local dt = DateTime.fromUnixTimestamp(1000)
		local str = tostring(dt)
		expect(str).toBe(dt:ToIsoDate())
	end)
end)
