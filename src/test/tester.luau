local testing = zune.testing
local fs = zune.fs
local task = zune.task

testing.describe("Testing", function()
	local entries = fs.entries("./src/test")
	local sorted = {}
	for _, entry in pairs(entries) do
		table.insert(sorted, entry)
	end
	table.sort(sorted, function(a, b)
		return a.name < b.name
	end)
	for _, entry in pairs(sorted) do
		print(entry)
		if entry.kind == "file" then
			if entry.name == "tester.luau" then
				continue
			end

			if entry.name == "runner.luau" then
				continue
			end
			local path = "./" .. string.gsub(entry.name, ".luau", "")
			print("before require:", path)
			require(path)
			print("after require:", path)
		end
	end
end)
