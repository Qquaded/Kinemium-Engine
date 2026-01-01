local fs = zune.fs
local lib = {}

function lib.IsEmbedded()
	local result = fs.embeddedScripts()
	if result[1] then
		return true
	else
		return false
	end
end

function lib.GetEmbeddedScripts()
	return fs.embeddedScripts()
end

function lib.GetEmbeddedFiles()
	return fs.embeddedFiles()
end

function lib.GetScriptsThatHas(str)
	local scripts = lib.GetEmbeddedScripts()
	local results = {}

	for _, script in scripts do
		if string.find(script, str) then
			table.insert(results, script)
		end
	end

	return results
end

function lib.GetFilesThatHas(str)
	local scripts = fs.embeddedFiles()
	local results = {}

	for _, script in scripts do
		if string.find(script, str) then
			table.insert(results, script)
		end
	end

	return results
end

function lib.readFile(script)
	return fs.embedFile(script)
end

return lib
