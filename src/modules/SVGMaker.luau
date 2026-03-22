local svgmaker = {}
local fs = zune.fs
local net = zune.net

export type SVGOptions = {
	Color: Color3,
	Size: Vector3,
}

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

function svgmaker.WriteSVG(path, name, content)
	fs.writeFile(path .. "/" .. name .. ".svg", content)
end

function svgmaker.GitHubBlobToRaw(url: string): string
	local parts = url:match("^https://github.com/(.+)$")
	if not parts then
		error("Invalid GitHub URL")
	end

	local user, repo, blob, branch, filepath = parts:match("^([^/]+)/([^/]+)/([^/]+)/([^/]+)/(.*)$")
	if not (user and repo and blob == "blob" and branch and filepath) then
		error("URL not in expected blob format")
	end

	return string.format("https://raw.githubusercontent.com/%s/%s/%s/%s", user, repo, branch, filepath)
end

function svgmaker:GetSVGAndWrite(link, name, path, color3)
	local res = request(link, {
		method = "GET",
		headers = {
			["Accept"] = "application/octet-stream, */*",
			["Connection"] = "keep-alive",
		},
		max_body_size = 1024 * 1024 * 10000,
	}, true)

	if res.ok == true then
		local contentBuf = res.body

		if color3 then
			local hex = string.format(
				"#%02X%02X%02X",
				math.floor(color3.R * 255),
				math.floor(color3.G * 255),
				math.floor(color3.B * 255)
			)

			local bufferString = buffer.tostring(contentBuf)

			bufferString = bufferString:gsub('fill="[^"]*"', 'fill="' .. hex .. '"')
			bufferString = bufferString:gsub('stroke="[^"]*"', 'stroke="' .. hex .. '"')

			contentBuf = buffer.fromstring(bufferString)
		end

		svgmaker.WriteSVG(path, name, contentBuf)
	end
end

return svgmaker
