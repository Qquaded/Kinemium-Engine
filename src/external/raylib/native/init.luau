--!strict
local fs = zune.fs
local ffi = zune.ffi
local net = zune.net
local serde = zune.serde
local platform = zune.platform

local tar = require("./lib/tar")
local zip = require("./lib/zip")

local RAYLIB_VERSION = `5.5`
local RAYLIB_URL = `https://github.com/raysan5/raylib/releases`

local function request(link: string, options: any, bytes: boolean?): HttpResponse<buffer | string>
	local res = net.http.request(link, options, bytes)
	if res.status_code == 302 or res.status_code == 301 then
		local location = res.headers["location"]
		if location then
			return request(location, options, bytes)
		else
			error("Redirection without location")
		end
	end
	return res
end

local LIBRARY_PATH: string
if zune.compiled then
	local dir = fs.path.dirname(fs.getExePath()) or "."
	LIBRARY_PATH = fs.path.resolve(dir, `raylib.{ffi.suffix}`)
else
	local BIN_LOCATION = zune.require.navigate("@self/bin")

	if fs.stat(BIN_LOCATION).kind ~= "directory" then
		fs.makeDir(BIN_LOCATION)
	end

	local BIN_MAP = {
		["linux-x86_64"] = "linux_amd64",
		["macos-aarch64"] = "macos",
		["macos-x86_64"] = "macos",
		["windows-x86_64"] = "win64_mingw-w64",
	}

	local LIB_PATHS = {
		"/lib/libraylib.so", -- linux
		"/lib/libraylib.dylib", -- macos
		"/lib/raylib.dll", -- windows
	}

	local store = `{platform.os}-{platform.cpu.arch}`
	local mapped = BIN_MAP[store] or store
	local file = `raylib-{RAYLIB_VERSION}_{mapped}`

	if fs.stat(`{BIN_LOCATION}/{file}.{ffi.suffix}`).kind == "none" then
		print(`Downloading '{file}'...`)

		local archive: buffer?
		for _, ext in { ".tar.gz", ".zip" } do
			local link = `{RAYLIB_URL}/download/{RAYLIB_VERSION}/{file}{ext}`
			local res = request(link, {
				method = "GET",
				headers = {
					["Accept"] = "application/octet-stream, */*",
					["Connection"] = "keep-alive",
				},
				max_body_size = 1024 * 1024 * 10, -- 10 MB
			}, true)
			if not res.ok then
				continue
			end
			archive = res.body :: buffer
			break
		end

		if not archive then
			print(`Failed to download raylib for {mapped}, not found.`)
			print(`  It is likely that your platform is not supported.`)
			error("Aborting.")
		end

		if zip.is(archive) then
			local files = zip.read(archive)
			for name, data in files do
				local location = string.sub(name, #file + 1, -1)
				if table.find(LIB_PATHS, location) then
					fs.writeFile(`{BIN_LOCATION}/{file}.{ffi.suffix}`, data)
					break
				end
			end
		else
			local decompressed = serde.gzip.decompress(archive)
			local files = tar.read(decompressed)
			for name, data in files do
				local location = string.sub(name, #file + 1, -1)
				if table.find(LIB_PATHS, location) then
					fs.writeFile(`{BIN_LOCATION}/{file}.{ffi.suffix}`, data)
					break
				end
			end
		end
	end

	LIBRARY_PATH = `{BIN_LOCATION}/{file}.{ffi.suffix}`
end

assert(fs.stat(LIBRARY_PATH).kind == "file", `Raylib library not found at path: {LIBRARY_PATH}`)

local raylib = require("@self/raylib")
local core = require("@self/core")
local shapes = require("@self/shapes")
local textures = require("@self/textures")
local text = require("@self/text")
local models = require("@self/models")
local audio = require("@self/audio")
local rlgl = require("@self/rlgl")
local rmath = require("@self/rmath")

local function combine(...: { [string]: any })
	local list = { ... }
	local first = table.remove(list, 1)
	assert(first)
	local result = table.clone(first)
	for _, tbl in list do
		for k, v in tbl do
			result[k] = v
		end
	end
	return result
end

local export = {}

export.const = raylib
export.lib = ffi.dlopen(
	LIBRARY_PATH,
	combine(core.def, shapes.def, textures.def, text.def, audio.def, models.def, rmath.defs, rlgl.def)
) :: {
	GetSymbol: (self: FFILibrary, symbol: string) -> FFIPointer?,
} & core.Fns & shapes.Fns & textures.Fns & text.Fns & audio.Fns & models.Fns & rmath.Fns & rlgl.Fns

return export
