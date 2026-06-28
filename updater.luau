local process = zune.process
local fs = zune.fs
local io = zune.io

local logo = [[
            @@@@@@@@@@@@@@@@@@            
         @@@@@@   @    @   @@@@@@         
      @@@@    @            @    @@@@      
     @@@-@                      @-@@@     
   @@@                              @@@   
  @@@@======   @@@@    @@@@=========%@@@  
 @@@   -...= @@@@@@    @-.........-   @@@ 
@@@@@  =...:@@@@@@@    -..........=   @@@@
@@     =....@@@@@@@  .=:.....-....=     @@
@@     =....@@@@@@  ==......@@....=     @@
@@@    =....@@@@  --...--=@@@@....=    @@@
@      =....@@@@.::..:==  @@@@....=      @
@@@    =....@+.......=       @:...=    @@@
@@     =..............        =...=     @@
@@     =.............-==@@    =...=     @@
@@@@@  =-::::...::.......:@@@@=:::=  @@@@@
 @@@    ....===@@@@:......:@@ .....   @@@ 
  @@@=@        @@@@@@@@@@@@        @+@@@  
   @@@                              @@@   
    @@@@.@                      @.@@@@    
      @@@@    @            @    @@@@      
         @@@@@@   @    @   @@@@@@         
            @@@@@@@@@@@@@@@@@@            
]]

--  ANSI Colors

local isTTY = io.terminal.isTTY

local c = {
	reset = isTTY and "\27[0m" or "",
	bold = isTTY and "\27[1m" or "",
	dim = isTTY and "\27[2m" or "",
	red = isTTY and "\27[31m" or "",
	green = isTTY and "\27[32m" or "",
	yellow = isTTY and "\27[33m" or "",
	cyan = isTTY and "\27[36m" or "",
	white = isTTY and "\27[97m" or "",
}

local function colored(color, text)
	return color .. text .. c.reset
end

--  Logging

local out = io.stdout
local err = io.stderr

local function write(s)
	out:write(s)
end
local function writeln(s)
	out:write((s or "") .. "\n")
end

local function log(msg)
	writeln(colored(c.cyan, "[Kinemium] ") .. msg)
end

local function log_ok(msg)
	writeln(colored(c.green, "  ✓ ") .. msg)
end

local function log_warn(msg)
	writeln(colored(c.yellow, "  ⚠ ") .. msg)
end

local function log_err(msg)
	err:write(colored(c.red, "  ✗ ") .. msg .. "\n")
end

local function log_step(msg)
	writeln(colored(c.dim, "  → ") .. msg)
end

local function log_section(title)
	writeln()
	writeln(colored(c.bold, colored(c.white, " " .. title .. " ")))
end

local function die(msg)
	log_err(msg)
	process.exit(1)
end

--  I/O Helpers

local function io_confirm(msg)
	write(colored(c.cyan, "[?] ") .. msg .. colored(c.dim, " (y/n) "))
	local line = io.stdin:read()
	if line == nil then
		writeln()
		return false
	end
	return line:match("^%s*[yY]") ~= nil
end

local function io_input(msg, default)
	write(colored(c.cyan, "[?] ") .. msg)
	if default then
		write(colored(c.dim, " [" .. default .. "]"))
	end
	write(": ")
	local line = io.stdin:read()
	if line == nil then
		writeln()
		return default
	end
	line = line:match("^%s*(.-)%s*$")
	return (line ~= "" and line) or default
end

--  Constants

local REPO_URL = "https://github.com/Qquaded/Kinemium-Engine.git"
local REPO_DIR = "../Kinemium-Engine"
local DEFAULT_BRANCH = "main"
local BACKUP_TAG = "__kinemium_pre_update"

--  Git Helpers

local function git_run(args, opts)
	opts = opts or {}
	opts.cwd = opts.cwd or REPO_DIR
	return process.run("git", args, opts)
end

local function git_out(args)
	local r = git_run(args)
	if r.code ~= 0 then
		return nil
	end
	return r.stdout:match("^%s*(.-)%s*$")
end

local function git_check()
	return fs.stat(REPO_DIR .. "/.git").kind == "directory"
end

local function current_branch()
	return git_out({ "rev-parse", "--abbrev-ref", "HEAD" })
end

local function current_hash(short)
	if short then
		return git_out({ "rev-parse", "--short", "HEAD" })
	end
	return git_out({ "rev-parse", "HEAD" })
end

local function remote_hash(branch)
	-- fetch silently first so refs are fresh
	git_run({ "fetch", "origin", "--quiet" })
	return git_out({ "rev-parse", "origin/" .. branch })
end

local function list_tags()
	local r = git_run({ "tag", "--sort=-creatordate" })
	if r.code ~= 0 or r.stdout == "" then
		return {}
	end
	local tags = {}
	for tag in r.stdout:gmatch("[^\n]+") do
		table.insert(tags, tag)
	end
	return tags
end

--  Actions

local function action_clone(branch, dry_run)
	log_section("Clone")
	log_step("Repository : " .. REPO_URL)
	log_step("Branch     : " .. branch)
	log_step("Target     : " .. REPO_DIR)
	if dry_run then
		log_warn("Dry-run: skipping clone.")
		return
	end
	log("Cloning…")
	local proc = process.create("git", {
		"clone",
		"--progress",
		"--depth",
		"1",
		"--branch",
		branch,
		REPO_URL,
		REPO_DIR,
	}, { stdout = out, stderr = err })
	local result = proc:wait()
	if result.code ~= 0 then
		die("Clone failed (exit " .. result.code .. ")")
	end
	log_ok("Clone complete.")
end

local function action_update(branch, dry_run)
	log_section("Update")
	if not git_check() then
		die(REPO_DIR .. " exists but is not a git repository.")
	end

	local local_hash = current_hash(true)
	local local_full = current_hash(false)
	local cur_branch = current_branch()
	log_step("Current branch : " .. (cur_branch or "?"))
	log_step("Current commit : " .. (local_hash or "?"))

	-- Check for uncommitted changes
	local status = git_run({ "status", "--porcelain" })
	if status.stdout and status.stdout:match("%S") then
		log_warn("Uncommitted local changes detected  these will be preserved (untracked files safe).")
	end

	-- Fetch and compare
	log_step("Fetching from origin…")
	local fetch = git_run({ "fetch", "origin", branch, "--quiet" })
	if fetch.code ~= 0 then
		die("Fetch failed:\n" .. fetch.stderr)
	end

	local remote_full = git_out({ "rev-parse", "origin/" .. branch })
	if remote_full == local_full then
		log_ok("Already up to date (" .. (local_hash or "?") .. ").")
		return
	end

	-- Show what's incoming
	local log_range = (local_full or "") .. "..origin/" .. branch
	local incoming = git_run({ "log", "--oneline", "--no-walk", log_range })
	if incoming.stdout and incoming.stdout:match("%S") then
		log_step("Incoming commits:")
		for line in incoming.stdout:gmatch("[^\n]+") do
			writeln(colored(c.dim, "     " .. line))
		end
	end

	if dry_run then
		log_warn("Dry-run: skipping update.")
		return
	end

	-- Tag a rollback point before touching anything
	log_step("Tagging rollback point as '" .. BACKUP_TAG .. "'…")
	git_run({ "tag", "--force", BACKUP_TAG })

	-- Apply update (checkout tracked files from origin)
	log_step("Applying update (branch: " .. branch .. ")…")
	local checkout = git_run({ "checkout", "origin/" .. branch, "--", "." })
	if checkout.code ~= 0 then
		die("Update failed:\n" .. checkout.stderr)
	end

	local new_hash = git_out({ "rev-parse", "--short", "HEAD" }) or "?"
	log_ok("Update complete. Now at " .. new_hash .. ".")
end

local function action_rollback(dry_run)
	log_section("Rollback")
	if not git_check() then
		die(REPO_DIR .. " is not a git repository.")
	end

	-- Prefer the pre-update backup tag, fall back to asking for a tag/hash
	local target = git_out({ "rev-parse", "--verify", BACKUP_TAG })
	if target then
		log_step("Rolling back to pre-update snapshot (" .. BACKUP_TAG .. ")…")
	else
		-- Let user pick a tag
		local tags = list_tags()
		if #tags == 0 then
			die("No tags or rollback snapshot found. Cannot roll back.")
		end
		log("Available tags (newest first):")
		for i, t in ipairs(tags) do
			writeln(colored(c.dim, "  " .. i .. ") ") .. t)
			if i >= 10 then
				writeln(colored(c.dim, "  …"))
				break
			end
		end
		local choice = io_input("Tag number to roll back to", "1")
		local idx = tonumber(choice)
		if not idx or not tags[idx] then
			die("Invalid selection.")
		end
		target = tags[idx]
		log_step("Rolling back to tag: " .. target)
	end

	if dry_run then
		log_warn("Dry-run: skipping rollback.")
		return
	end

	local checkout = git_run({ "checkout", target, "--", "." })
	if checkout.code ~= 0 then
		die("Rollback failed:\n" .. checkout.stderr)
	end
	log_ok("Rollback complete.")
end

--  Argument Parsing

local args = process.args or {}
local opts = {
	branch = nil,
	action = nil, -- "clone" | "update" | "rollback" | "status"
	dry_run = false,
	yes = false,
}

local i = 1
while i <= #args do
	local v = args[i]
	if v == "--branch" or v == "-b" then
		i += 1
		opts.branch = args[i]
	elseif v == "--dry-run" or v == "-n" then
		opts.dry_run = true
	elseif v == "--yes" or v == "-y" then
		opts.yes = true
	elseif v == "clone" or v == "update" or v == "rollback" or v == "status" then
		opts.action = v
	end
	i += 1
end

--  Main

-- Print logo (skip if not a TTY to keep piped output clean)
if isTTY then
	write(colored(c.cyan, logo))
end

-- Dry-run banner
if opts.dry_run then
	writeln(colored(c.yellow, "  ⚠  DRY-RUN MODE  no changes will be made\n"))
end

-- Status shortcut
if opts.action == "status" then
	log_section("Status")
	if not git_check() then
		log_warn("Repository not found at " .. REPO_DIR)
	else
		local branch = current_branch() or "?"
		local hash = current_hash(true) or "?"
		log_ok("Repository : " .. REPO_DIR)
		log_step("Branch     : " .. branch)
		log_step("Commit     : " .. hash)
		local tags = list_tags()
		if #tags > 0 then
			log_step("Latest tag : " .. tags[1])
		end
	end
	process.exit(0)
end

-- Rollback shortcut
if opts.action == "rollback" then
	action_rollback(opts.dry_run)
	process.exit(0)
end

-- Determine flow: clone vs update
local repo_exists = fs.stat(REPO_DIR).kind ~= "none"

if opts.action == "clone" or not repo_exists then
	if repo_exists and opts.action ~= "clone" then
		-- Directory exists but no .git  warn
		log_warn(REPO_DIR .. " already exists but may not be a git repo.")
	end
	if not opts.yes then
		if not io_confirm("Install Kinemium Engine to '" .. REPO_DIR .. "'?") then
			log("Cancelled.")
			process.exit(0)
		end
	end
	local branch = opts.branch or io_input("Branch", DEFAULT_BRANCH)
	action_clone(branch, opts.dry_run)
elseif opts.action == "update" or repo_exists then
	if not opts.yes then
		if not io_confirm("Update Kinemium Engine at '" .. REPO_DIR .. "'?") then
			log("Cancelled.")
			process.exit(0)
		end
	end
	local branch = opts.branch or io_input("Branch", current_branch() or DEFAULT_BRANCH)
	action_update(branch, opts.dry_run)
end

process.exit(0)
