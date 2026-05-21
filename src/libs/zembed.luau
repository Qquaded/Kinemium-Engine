local fs = zune.fs
local lib = {}

local function normalizePath(path: string): string
	return (path:gsub([[\]], "/"))
end

local function stripCurrentPrefix(path: string): string
	return normalizePath(path):gsub("^%./", "")
end

local function isPathUnder(path: string, base: string): boolean
	local normalizedPath = stripCurrentPrefix(path)
	local normalizedBase = stripCurrentPrefix(base):gsub("/+$", "")

	return normalizedPath == normalizedBase or normalizedPath:sub(1, #normalizedBase + 1) == normalizedBase .. "/"
end

local function getEmbeddedUnder(entries: { string }, base: string): { string }
	local results = {}

	for _, entry in entries do
		if isPathUnder(entry, base) then
			table.insert(results, entry)
		end
	end

	return results
end

local function isAbsolutePath(path: string): boolean
	return path:match("^%a:[/\\]") ~= nil or path:sub(1, 1) == "/" or path:sub(1, 2) == [[\\]]
end

function lib.IsEmbedded()
	local result = fs.embeddedScripts()
	if result[1] then
		return true
	else
		return false
	end
end

function lib.ExecutableDir(): string
	local dir = fs.path.dirname(fs.getExePath()) or "."
	return fs.path.resolve(dir)
end

function lib.RuntimePath(path: string): string
	if lib.IsEmbedded() and not isAbsolutePath(path) then
		return fs.path.resolve(lib.ExecutableDir(), path)
	end
	return path
end

function lib.AssetPath(path: string): string
	if type(path) ~= "string" then
		return path
	end

	local normalized = normalizePath(path)
	local assetPath = normalized:match("^kineasset://(.+)$")

	if not assetPath then
		assetPath = normalized:match("^%.?/src/assets/(.+)$")
	end

	if not assetPath then
		assetPath = normalized:match("^%.?/assets/(.+)$")
	end

	if assetPath then
		if lib.IsEmbedded() then
			return fs.path.resolve(lib.ExecutableDir(), "assets", assetPath)
		end
		return fs.path.resolve("src", "assets", assetPath)
	end

	return path
end

function lib.Path(path: string): string
	return lib.AssetPath(path)
end

function lib.GetEmbeddedScripts()
	return fs.embeddedScripts()
end

function lib.GetEmbeddedFiles()
	return fs.embeddedFiles()
end

function lib.GetScriptsUnder(path: string): { string }
	return getEmbeddedUnder(lib.GetEmbeddedScripts(), path)
end

function lib.GetFilesUnder(path: string): { string }
	return getEmbeddedUnder(lib.GetEmbeddedFiles(), path)
end

function lib.GetScriptsThatHas(str)
	local scripts = lib.GetEmbeddedScripts()
	local results = {}
	local needle = normalizePath(str)

	for _, script in scripts do
		if string.find(normalizePath(script), needle, 1, true) then
			table.insert(results, script)
		end
	end

	return results
end

function lib.GetPathEmbedded()
	if lib.IsEmbedded() then
		return "../"
	else
		return "./"
	end
end

function lib.GetFilesThatHas(str)
	local scripts = fs.embeddedFiles()
	local results = {}
	local needle = normalizePath(str)

	for _, script in scripts do
		if string.find(normalizePath(script), needle, 1, true) then
			table.insert(results, script)
		end
	end

	return results
end

function lib.readFile(script)
	return fs.embedFile(script)
end

return lib
