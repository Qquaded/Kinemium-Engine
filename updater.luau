local process = zune.process
local fs = zune.fs

local function clone()
	process.run("git", {
		"clone",
		"--depth",
		"1",
		"https://github.com/Qquaded/Kinemium-Engine.git",
	})
end

local function clearDir(dir)
	for _, entry in pairs(fs.entries(dir)) do
		if entry.name == "updater.luau" then
			continue
		end
		local path = dir .. "/" .. entry.name
		pcall(function(...)
			fs.deleteDir(path)
		end)
		pcall(function(...)
			fs.removeFile(path)
		end)
	end
end

local dir = fs.realPath("./")
print(dir)
print("UPDATER: Kinemium Engine not installed, Installing..")
clearDir("./")
clone()

local function unpackFolder(src, dest)
	local entries = fs.entries(src)
	for _, entry in pairs(entries) do
		if entry.name ~= ".git" then
			local path = src .. "/" .. entry.name
			local destPath = dest .. "/" .. entry.name
			fs.copy(path, destPath, true)
		end
	end
end

unpackFolder("./Kinemium-Engine", "./")
print("UPDATER: Unpacked Kinemium-Engine into main directory")
