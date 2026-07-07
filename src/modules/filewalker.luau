local fw = {}
local fs = zune.fs
local task = zune.task

function fw.Walk(start, callback)
	local entries = fs.entries(start)
	for _, entry in pairs(entries) do
		local path = start .. "/" .. entry.name
		entry.stem = fs.path.stem(path)
		entry.extension = fs.path.extension(path)
		entry.parentdir = fs.path.dirname(path)

		if entry.kind == "directory" then
			callback(path, entry)
			task.spawn(function()
				fw.Walk(path, callback)
			end)
			continue
		else
			callback(path, entry)
		end
	end
end

return fw
