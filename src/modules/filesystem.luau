local filesystem = {}

local zunefs = zune.fs
local zembed = require("@zembed")

local SANDBOX_PREFIX = "src/sandboxed"
local EMBEDDED_SANDBOX_PREFIX = "build/.embedded/src/sandboxed"
local EMBEDDED_SOURCE_SUFFIX = ".kinesrc"

local function normalizePath(path)
	return string.gsub(path, [[\]], "/")
end

local function embeddedSandboxBase(path)
	path = normalizePath(path)
	if path == SANDBOX_PREFIX or path:sub(1, #SANDBOX_PREFIX + 1) == SANDBOX_PREFIX .. "/" then
		return EMBEDDED_SANDBOX_PREFIX .. path:sub(#SANDBOX_PREFIX + 1)
	end
	return path
end

local function virtualSandboxPath(path)
	path = normalizePath(path)
	if path:sub(1, #EMBEDDED_SANDBOX_PREFIX) == EMBEDDED_SANDBOX_PREFIX then
		path = SANDBOX_PREFIX .. path:sub(#EMBEDDED_SANDBOX_PREFIX + 1)
	end
	return path:gsub(EMBEDDED_SOURCE_SUFFIX .. "$", "")
end

function filesystem.entryloop(path, callback)
	if not zembed.IsEmbedded() then
		local entries = zunefs.entries(path)
		if entries then
			for _, entry in pairs(entries) do
				callback(entry, entries)
			end
		end
	else
		path = normalizePath(path)
		local embeddedPath = embeddedSandboxBase(path)
		local entries = {}
		local seen = {}

		for _, filePath in pairs(zembed.GetFilesUnder(embeddedPath) or {}) do
			if not seen[filePath] then
				seen[filePath] = true
				table.insert(entries, {
					path = virtualSandboxPath(filePath),
					readPath = filePath,
				})
			end
		end

		for _, scriptPath in pairs(zembed.GetScriptsUnder(path) or {}) do
			if not seen[scriptPath] then
				seen[scriptPath] = true
				table.insert(entries, {
					path = scriptPath,
					readPath = scriptPath,
				})
			end
		end

		if entries then
			for _, embeddedEntry in pairs(entries) do
				local name = zunefs.path.basename(embeddedEntry.path)
				local stat = zunefs.stat(embeddedEntry.readPath)
				local kind = if stat.kind ~= "none" then stat.kind else "file"
				callback({
					kind = kind,
					path = embeddedEntry.path,
					readPath = embeddedEntry.readPath,
					name = name,
				}, entries)
			end
		end
	end
	return true
end

function filesystem.walk(path, callback)
	local entries = zunefs.entries(path)
	if entries then
		for _, entry in pairs(entries) do
			callback(entry, entries)
		end
	end
	return true
end

function filesystem.entries(path)
	return zunefs.entries(path)
end

function filesystem.makeDir(path)
	zunefs.makeDir(path)
end

function filesystem.removeDir(path)
	zunefs.deleteDir(path)
end

function filesystem.remove(path)
	zunefs.deleteFile(path)
end

function filesystem.createFolder(path, name)
	local combined = path .. "/" .. name
	if not filesystem.exists(combined) then
		zunefs.makeDir(combined)
	end
	return combined
end

function filesystem.createFile(path, name, data)
	local combined = path .. "/" .. name
	if not filesystem.exists(combined) then
		zunefs.writeFile(combined, data)
	end
	return combined
end

function filesystem.rename(oldPath: string, newPath: string, overwrite: boolean?)
	zunefs.move(oldPath, newPath, overwrite)
end

function filesystem.kind(path)
	return zunefs.stat(path).kind
end

function filesystem.exists(path)
	return zunefs.stat(path).kind ~= "none"
end

function filesystem.read(file)
	return zunefs.readFile(file)
end

function filesystem.write(path, data)
	zunefs.writeFile(path, data)
end

return filesystem
