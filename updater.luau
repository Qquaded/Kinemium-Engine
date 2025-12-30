local process = zune.process
local io = zune.io
local fs = zune.fs

local function deriveHomeDir()
	local cwd = fs.realPath("./")
	cwd = cwd:gsub("\\", "/")
	if cwd:match("/%.Kinemium%-Engine") then
		return cwd:gsub("/%.Kinemium%-Engine.*$", "")
	end
	return cwd:match("(.+)/[^/]+$") or cwd
end

local ENGINE_DIR = deriveHomeDir() .. "/.Kinemium-Engine"

local function checkProcessResult(result, commandName)
	if type(result) == "table" then
		local success = result.ok == true or result.code == 0
		return success, result.code, result.stdout, result.stderr
	elseif type(result) == "number" then
		return result == 0, result, "", ""
	end
	return false, "unknown", "", ""
end

local function clone()
	print("UPDATER: Cloning repository...")
	local result = process.run("git", {
		"clone",
		"--depth",
		"1",
		"--branch",
		"main",
		"https://github.com/Qquaded/Kinemium-Engine.git",
		ENGINE_DIR,
	})
	local success, code = checkProcessResult(result, "clone")
	if not success then
		error("Git clone failed with exit code: " .. tostring(code))
	end
end

local function pull()
	print("UPDATER: Pulling latest changes...")
	local result = process.run("git", { "-C", ENGINE_DIR, "pull", "origin", "main" })
	local success, code = checkProcessResult(result, "pull")
	if not success then
		error("Git pull failed with exit code: " .. tostring(code))
	else
		print("UPDATER: Pull completed successfully")
	end
	return result
end

local dir = fs.realPath("./")
print("UPDATER: Engine install directory:", ENGINE_DIR)
local function isInstalled()
	local success, result = pcall(function()
		return fs.entries(ENGINE_DIR)
	end)
	return success and type(result) == "table"
end
local function isGitRepo(dir)
	local ok = pcall(function()
		return fs.entries(dir .. "/.git")
	end)
	return ok
end
local function clearDir(dir)
	for _, entry in pairs(fs.entries(dir)) do
		local path = dir .. "/" .. entry.name
		if entry.kind == "directory" then
			clearDir(path)
			local success, result = pcall(function()
				fs.deleteDir(path)
			end)
			if not success then
				warn(result)
			end
		else
			local success, result = pcall(function()
				fs.removeFile(path)
			end)
			if not success then
				warn(result)
			end
		end
	end
end

if isInstalled() then
	if isGitRepo(ENGINE_DIR) then
		print("UPDATER: Updating existing installation...")
		local currentCommit = process.run("git", { "-C", ENGINE_DIR, "rev-parse", "HEAD" })
		local _, _, currentHash = checkProcessResult(currentCommit)
		currentHash = currentHash and currentHash:match("^%s*(.-)%s*$") or "unknown"
		print("UPDATER: Current commit: " .. currentHash:sub(1, 8))
		print("UPDATER: Checking repository state...")
		local isShallow = process.run("git", { "-C", ENGINE_DIR, "rev-parse", "--is-shallow-repository" })
		local _, _, shallowCheck = checkProcessResult(isShallow)
		if shallowCheck and shallowCheck:match("true") then
			print("UPDATER: Converting shallow clone to full repository...")
			local unshallowResult = process.run("git", { "-C", ENGINE_DIR, "fetch", "--unshallow" })
			local unshallowSuccess, unshallowCode, _, unshallowErr = checkProcessResult(unshallowResult)
			if not unshallowSuccess then
				print("UPDATER: Warning - Could not unshallow repository: " .. (unshallowErr or ""))
			end
		end
		print("UPDATER: Fetching updates from remote...")
		local fetchResult = process.run("git", { "-C", ENGINE_DIR, "fetch", "origin" })
		local fetchSuccess, fetchCode, fetchOut, fetchErr = checkProcessResult(fetchResult)
		if not fetchSuccess then
			print("UPDATER: Failed to fetch updates (exit code: " .. tostring(fetchCode) .. ")")
			if fetchErr and fetchErr ~= "" then
				print("UPDATER: Error details: " .. fetchErr)
			end
			print("UPDATER: This might be a network issue or the repository is unavailable.")
			io.stdout:write("UPDATER: Try to continue anyway? (y/n): ")
			local answer = io.stdin:read():lower()
			if type(answer) == "string" then
				answer = answer:match("^%s*(.-)%s*$")
			end
			if answer ~= "y" and answer ~= "yes" then
				print("UPDATER: Update cancelled.")
				return
			end
		else
			print("UPDATER: Fetch completed successfully")
		end
		local branchResult = process.run("git", { "-C", ENGINE_DIR, "branch", "--show-current" })
		local _, _, branchName = checkProcessResult(branchResult)
		branchName = branchName and branchName:match("^%s*(.-)%s*$") or ""
		if branchName == "" then
			print("UPDATER: Repository is in detached HEAD state")
			print("UPDATER: Attempting to checkout main branch...")
			local checkoutResult = process.run("git", { "-C", ENGINE_DIR, "checkout", "main" })
			local checkoutSuccess, checkoutCode, _, checkoutErr = checkProcessResult(checkoutResult)
			if not checkoutSuccess then
				print("UPDATER: 'main' branch not found, trying 'master'...")
				checkoutResult = process.run("git", { "-C", ENGINE_DIR, "checkout", "master" })
				checkoutSuccess, checkoutCode, _, checkoutErr = checkProcessResult(checkoutResult)
				if not checkoutSuccess then
					print("UPDATER: Could not checkout a branch. Repository may be corrupted.")
					io.stdout:write("UPDATER: Would you like to delete and reinstall? (y/n): ")
					local answer = io.stdin:read():lower()
					if type(answer) == "string" then
						answer = answer:match("^%s*(.-)%s*$")
					end
					if answer == "y" or answer == "yes" then
						print("UPDATER: Removing corrupted installation...")
						clearDir(ENGINE_DIR)
						pcall(function() fs.deleteDir(ENGINE_DIR) end)
						clone()
						print("UPDATER: Re-Installation complete.")
						return
					else
						print("UPDATER: Update cancelled.")
						return
					end
				end
			end
			branchResult = process.run("git", { "-C", ENGINE_DIR, "branch", "--show-current" })
			_, _, branchName = checkProcessResult(branchResult)
			branchName = branchName and branchName:match("^%s*(.-)%s*$") or "unknown"
		end
		print("UPDATER: On branch: " .. branchName)
		local remoteCommit = process.run("git", { "-C", ENGINE_DIR, "rev-parse", "origin/" .. branchName })
		local _, _, remoteHash = checkProcessResult(remoteCommit)
		remoteHash = remoteHash and remoteHash:match("^%s*(.-)%s*$") or "unknown"
		print("UPDATER: Remote commit: " .. remoteHash:sub(1, 8))
		if currentHash == remoteHash then
			print("UPDATER: Already up to date!")
			return
		end
		local statusResult = process.run("git", { "-C", ENGINE_DIR, "status", "--porcelain" })
		local _, _, statusOutput = checkProcessResult(statusResult)
		local hasLocalChanges = statusOutput and statusOutput:match("%S") ~= nil
		if hasLocalChanges then
			print("UPDATER: Warning - Local changes detected")
			io.stdout:write("UPDATER: Discard local changes and update? (y/n): ")
			local answer = io.stdin:read():lower()
			if type(answer) == "string" then
				answer = answer:match("^%s*(.-)%s*$")
			end
			if answer ~= "n" and answer ~= "no" then
				print("UPDATER: Update cancelled.")
				return
			end
			local resetResult = process.run("git", { "-C", ENGINE_DIR, "reset", "--hard", "HEAD" })
			local resetSuccess, resetCode, _, resetErr = checkProcessResult(resetResult)
			if not resetSuccess then
				print("UPDATER: Git reset failed (exit code: " .. tostring(resetCode) .. ")")
				if resetErr and resetErr ~= "" then
					print("UPDATER: Error details: " .. resetErr)
				end
			end
		end

		print("UPDATER: Updating to latest version...")
		local pullResult = pull()
		local pullSuccess, pullCode, _, pullErr = checkProcessResult(pullResult)
		if not pullSuccess then
			print("UPDATER: Git pull failed (exit code: " .. tostring(pullCode) .. ")")
			if pullErr and pullErr ~= "" then
				print("UPDATER: Error details: " .. pullErr)
			end
			print("UPDATER: This could mean the repository is corrupted.")
			io.stdout:write("UPDATER: Would you like to delete and reinstall? (y/n): ")
			local answer = io.stdin:read():lower()
			if type(answer) == "string" then
				answer = answer:match("^%s*(.-)%s*$")
			end
			if answer == "y" or answer == "yes" then
				print("UPDATER: Removing corrupted installation...")
				clearDir(ENGINE_DIR)
				pcall(function() fs.deleteDir(ENGINE_DIR) end)
				clone()
				print("UPDATER: Re-Installation complete.")
			else
				print("UPDATER: Update cancelled. Installation may be in an inconsistent state.")
			end
		else
			local newCommit = process.run("git", { "-C", ENGINE_DIR, "rev-parse", "HEAD" })
			local _, _, newHash = checkProcessResult(newCommit)
			newHash = newHash and newHash:match("^%s*(.-)%s*$") or "unknown"
			print("UPDATER: Updated to commit: " .. newHash:sub(1, 8))
			print("UPDATER: Update complete!")
		end
	else 
		print("UPDATER: Installation is broken (not a valid git repository).")
		io.stdout:write("UPDATER: Delete and reinstall? (y/n): ")
		local answer = io.stdin:read():lower()
		if type(answer) == "string" then
			answer = answer:match("^%s*(.-)%s*$")
		end
		if answer ~= "y" and answer ~= "yes" then
			print("UPDATER: Update cancelled.")
			return
		end
		clearDir(ENGINE_DIR)
		pcall(function() fs.deleteDir(ENGINE_DIR) end)
		clone()
		print("UPDATER: Re-Installation complete.")
	end
else
	print("UPDATER: Installing Kinemium Engine...")
	clone()
	print("UPDATER: Installation complete.")
end