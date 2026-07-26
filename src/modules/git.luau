local git = {}

local process = zune.process
local fs = require("@filesystem")

local git_exe = "C:\\Program Files\\Git\\bin\\git.exe"

function git:InitProject(path)
	local ok, result = process.run(git_exe, {
		"init",
	}, {
		cwd = path,
	})

	fs.createFile(path .. "/.gitignore")

	if ok then
		return true
	else
		print(ok)

		return result
	end
end

function git:Add(toAdd, path)
	local ok, result = process.run(git_exe, {
		"add",
		toAdd,
	}, {
		cwd = path,
	})

	if ok then
		print(ok)

		return true
	else
		return result
	end
end

function git:RemoteAdd(remote, link, path)
	local ok, result = process.run(git_exe, {
		"remote",
		"add",
		remote,
		link,
	}, {
		cwd = path,
	})

	if ok then
		print(ok)

		return true
	else
		return result
	end
end

function git:Commit(message, path)
	local ok, result = process.run(git_exe, {
		"commit",
		"-m",
		message,
	}, {
		cwd = path,
	})

	if ok then
		print(ok)

		return true
	else
		return result
	end
end

function git:Push(path)
	local ok, result = process.run(git_exe, {
		"push",
		"-u",
		"origin",
		"master",
	}, {
		cwd = path,
	})

	if ok then
		print(ok)
		return true
	end

	return result
end

local function truncate(text, maxLen)
	maxLen = maxLen or 30
	if #text > maxLen then
		return text:sub(1, maxLen) .. "..."
	end
	return text
end

function git:GetCommits(path, limit)
	limit = limit or 100

	local ok, result = process.run(git_exe, {
		"log",
		"--pretty=format:%H|%P|%D|%s",
		"--decorate=full",
		"-" .. tostring(limit),
	}, {
		cwd = path,
	})

	if not ok then
		return result
	end

	result = ok

	local commits = {}

	for line in result.stdout:gmatch("[^\r\n]+") do
		local hash, parents, refs, subject = line:match("^(.-)|(.-)|(.-)|(.*)$")
		if hash and hash ~= "" then
			local parentCount = 0
			for _ in parents:gmatch("%S+") do
				parentCount += 1
			end

			local entry = {
				text = subject,
				type = "default",
				icon = "commit",
			}

			local tagName, branchName

			if refs and refs ~= "" then
				for ref in refs:gmatch("[^,]+") do
					ref = ref:match("^%s*(.-)%s*$")

					if ref:match("^tag: ") then
						tagName = tagName or ref:match("^tag: refs/tags/(.+)$") or ref:match("^tag: (.+)$")
					elseif ref:match("^HEAD %-> refs/heads/") then
						branchName = branchName or ref:gsub("^HEAD %-> refs/heads/", "")
					elseif ref:match("^refs/heads/") then
						branchName = branchName or ref:gsub("^refs/heads/", "")
					elseif ref:match("^refs/remotes/") then
						branchName = branchName or ref:gsub("^refs/remotes/", "")
					end
				end
			end

			if tagName then
				entry.type = "tag"
				entry.icon = "tag"
				entry.tag = tagName
			elseif branchName then
				entry.type = "branch"
				entry.icon = "branch"
				entry.branch = branchName
			elseif parentCount > 1 then
				entry.type = "merge"
				entry.icon = "merge"
			end

			table.insert(commits, entry)
		end
	end

	return commits
end

function git:Status(path)
	local ok, result = process.run(git_exe, {
		"status",
		"--porcelain",
	}, {
		cwd = path,
	})

	if not ok then
		return result
	end

	result = ok

	local changes = {}
	for line in result.stdout:gmatch("[^\r\n]+") do
		local statusCode, file = line:match("^(..)%s(.+)$")
		if statusCode then
			table.insert(changes, {
				status = statusCode,
				file = file,
			})
		end
	end

	return changes
end

return git
