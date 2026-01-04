local net = zune.net

local kinemium_http = {}

function kinemium_http:Init()
	net.http.serve({
		port = 6767,
		address = "0.0.0.0",
		request = function(req)
			-- req.url, req.method, req.headers, etc.
			return "son im crine how did you find this"
		end,
	})
end

return kinemium_http
