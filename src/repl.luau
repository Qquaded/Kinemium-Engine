local wrapper = {}

local io = zune.io
local task = zune.task

function wrapper:init(callback)
	task.spawn(function()
		io.stdout:write("Kilang Terminal Initialized\n")

		while true do
			io.stdout:write("> ")

			local line = io.stdin:read()

			if line == nil then
				io.stdout:write("\n")
				break
			end

			if not line:match("^%s*$") then
				callback(line)
			else
				task.wait(0.1)
			end
		end
	end)
end

return wrapper
