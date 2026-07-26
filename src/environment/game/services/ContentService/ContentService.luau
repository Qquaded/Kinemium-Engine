--[[
api:
    ContentService:Get(url)
    ContentService:GetAsync(url)
    ContentService:Preload(urls)
    ContentService:IsCached(url)
    ContentService:GetPath(url)
    ContentService:Invalidate(url)
    ContentService:ClearCache()
    ContentService:GetMetadata(url)
    ContentService:SetCacheLimit(bytes)
]]

local Instance = require("@Instance")

local ContentService = Instance.new("GuiStackService")
local Enum = require("@EnumMap")

ContentService.ExplorerHidden = true
ContentService._Intents = Enum.PluginIntents.Network

local net = zune.net
local fs = zune.fs
local adapter = require("@RaylibAdapter")

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

local function hash(str: string): string
	local h = 2166136261

	for i = 1, #str do
		h = bit32.bxor(h, string.byte(str, i))
		h = (h * 16777619) % 2 ^ 32
	end

	return string.format("%08x", h)
end

local function getExtension(url: string)
	return url:match("%.([a-zA-Z0-9]+)$") or "bin"
end

ContentService.InitRenderer = function(renderer, renderer_signal)
	ContentService:SetProperties({
		Hash = hash,
	})

	function ContentService:GetBinary(url, maxSize)
		local res = request(url, {
			method = "GET",
			headers = { ["Accept"] = "application/octet-stream, */*" },
			max_body_size = maxSize or (50 * 1024 * 1024),
		}, true)

		if not res.ok then
			error(`Download failed ({res.status_code})`)
		end

		return res.body
	end

	function ContentService:Get(url, maxSize)
		local id = hash(url)
		local ext = getExtension(url)
		local dest = "./src/cache/" .. id .. "." .. ext

		-- cache folder
		if fs.stat("./src/cache").kind == "none" then
			fs.makeDir("./src/cache")
		end

		-- check file cache
		if fs.stat(dest).kind ~= "none" then
			return fs.readFile(dest)
		end

		-- download
		local res = request(url, {
			method = "GET",
			headers = { ["Accept"] = "application/octet-stream, */*" },
			max_body_size = maxSize or (50 * 1024 * 1024),
		}, true)

		if not res.ok then
			error(`Download failed ({res.status_code})`)
		end

		fs.writeFile(dest, res.body :: buffer)
		return res.body
	end

	renderer_signal:Connect(function(route, dt) end)
end

return ContentService
