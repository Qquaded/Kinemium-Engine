--!strict
local fs = zune.fs
local net = zune.net
local serde = zune.serde
local platform = zune.platform

local zip = require("./Downloader/lib/zip")
local tar = require("./Downloader/lib/tar")

export type ExtractFilter = (path: string) -> boolean
export type RenameRule = (path: string) -> string?

local Downloader = {}

local function request(url: string, options: any, bytes: boolean)
	local res = net.http.request(url, options, bytes)
	if res.status_code == 301 or res.status_code == 302 then
		local loc = res.headers["location"]
		if not loc then
			error("HTTP redirect without Location header")
		end
		return request(loc, options, bytes)
	end
	return res
end

function Downloader.download(url: string, dest: string, maxSize: number?)
	print(`Downloading {url}`)

	local res = request(url, {
		method = "GET",
		headers = {
			["Accept"] = "application/octet-stream, */*",
		},
		max_body_size = maxSize or (1024 * 1024 * 1024), -- 1GB default
	}, true)

	if not res.ok then
		error(`Download failed ({res.status_code})`)
	end

	fs.writeFile(dest, res.body :: buffer)
	return res.body
end

function Downloader.extract(archive: buffer, outDir: string, filter: ExtractFilter?, rename: RenameRule?)
	if fs.stat(outDir).kind ~= "directory" then
		fs.makeDir(outDir)
	end

	if zip.is(archive) then
		for path, data in zip.read(archive) do
			if path == [[bin\]] then
				continue
			end
			if filter and not filter(path) then
				continue
			end

			local name = rename and rename(path) or path
			if not name then
				continue
			end

			local out = fs.path.resolve(outDir, name)
			local dir = fs.path.dirname(out)

			if dir and fs.stat(dir).kind ~= "directory" then
				fs.makeDir(dir, true)
			end

			local success, result = pcall(function(...)
				fs.writeFile("./" .. string.gsub(out, [[\]], "/"), data)
			end)
			if not success then
				print("Failed to write " .. path .. "; Result: ", result)
			end
		end
		return true
	end

	-- tar.gz
	local decompressed = serde.gzip.decompress(archive)
	for path, data in tar.read(decompressed) do
		if filter and not filter(path) then
			continue
		end

		local name = rename and rename(path) or path
		if not name then
			continue
		end

		local out = fs.path.resolve(outDir, name)
		local dir = fs.path.dirname(out)
		if dir and fs.stat(dir).kind ~= "directory" then
			fs.makeDir(dir, true)
		end
	end
end

function Downloader.downloadAndExtract(url: string, outDir: string, filter: ExtractFilter?, rename: RenameRule?)
	local res = request(url, {
		method = "GET",
		headers = {
			["Accept"] = "application/octet-stream, */*",
			["Connection"] = "keep-alive",
		},
		max_body_size = 1024 * 1024 * 10000,
	}, true)

	if not res.ok then
		error(`Download failed ({res.status_code})`)
	end

	print("Successfully downloaded zip! http result: ", res.ok)

	repeat
		task.wait()
	until Downloader.extract(res.body :: buffer, outDir, filter, rename)
	return true
end

return Downloader
