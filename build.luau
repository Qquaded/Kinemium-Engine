local zpath = zune.fs.path
local zjoin = zpath.join

local EXECUTABLE_NAME = "KinemiumRuntime"
local COMPRESSION = "zstd"

local root = zjoin("src")
local entry = zjoin(root, "main.luau")

local bin = zjoin("build")
local sandboxEmbedRoot = zjoin(bin, ".embedded", root, "sandboxed")
local sandboxEmbedGlob = zjoin(sandboxEmbedRoot, "**")

local function normalizePath(path: string): string
	return (path:gsub([[\]], "/"))
end

local function collectScriptIncludes(path: string, includes: { string })
	if normalizePath(path) == "src/sandboxed" then
		return
	end

	for _, entry in pairs(zune.fs.entries(path)) do
		local entryPath = zjoin(path, entry.name)
		if entry.kind == "directory" then
			collectScriptIncludes(entryPath, includes)
		elseif entry.kind == "file" and (entry.name:match("%.luau$") or entry.name:match("%.lua$")) then
			table.insert(includes, entryPath)
		end
	end
end

local include = {}
collectScriptIncludes(root, include)

local assets = {
	zjoin("**", ".luaurc"),
	zjoin(root, "assets", "**"),
	zjoin(root, "projects.toml"),
	sandboxEmbedGlob,
}

local function flagExists(flag: string)
	local args = zune.process.args
	for _, v in pairs(args) do
		if v == "--" .. flag then
			return true
		end
	end
	return false
end

local ext = ""

local function copySandboxedSources(source: string, target: string)
	if zune.fs.stat(target).kind ~= "directory" then
		zune.fs.makeDir(target, true)
	end

	for _, entry in pairs(zune.fs.entries(source)) do
		local sourcePath = zjoin(source, entry.name)
		local targetPath = zjoin(target, entry.name)

		if entry.kind == "directory" then
			copySandboxedSources(sourcePath, targetPath)
		elseif entry.kind == "file" then
			zune.fs.writeFile(targetPath .. ".kinesrc", zune.fs.readFile(sourcePath))
		end
	end
end

local function copyLibraries(ext, bin, path)
	for _, f in pairs(zune.fs.entries(path)) do
		if f.kind == "directory" then
			copyLibraries(ext, bin, zjoin(path, f.name))
		elseif f.kind == "file" and zpath.globMatch(f.name, "*." .. ext) then
			local lib = zpath.join(path, f.name)
			print("Copying " .. f.name)
			zune.fs.copy(lib, zjoin(bin, f.name), true)
		end
	end
end

local b_windows = flagExists("windows")
local b_macos = flagExists("macos")
local b_debian = flagExists("debian")
local b_freebsd = flagExists("freebsd")

local anyPlatform = b_windows or b_macos or b_debian or b_freebsd

local b_args = {
	"bundle",
	entry,
	"--compression=" .. COMPRESSION,
	"--scripts",
}

table.move(include, 1, #include, #b_args + 1, b_args)
table.insert(b_args, "--files")
table.move(assets, 1, #assets, #b_args + 1, b_args)

if flagExists("releasefast") then
	print("JIT is enabled; pre-compiled bytecode; O2; g0")
	table.insert(b_args, "--release")
	table.insert(b_args, "-O2")
	table.insert(b_args, "-g0")
	table.insert(b_args, "--native")
elseif flagExists("release") then
	print("JIT is enabled; pre-compiled bytecode enabled")
	table.insert(b_args, "--release")
elseif flagExists("debugvm") then
	print("JIT is disabled; O0; g2")
	table.insert(b_args, "-g2")
	table.insert(b_args, "-O0")
	table.insert(b_args, "--no-jit")
	table.insert(b_args, "--debug")
else
	print("JIT is enabled; O1; g1")
end

local function buildExecutable(name, exec_ext, lib_ext)
	print(
		`Creating executable:\n\tPlatform: {name}\n\tExecutable file extension: {exec_ext}\n\tLibrary file extension: {lib_ext}`
	)

	local dir = zjoin(bin, name)
	if zune.fs.stat(dir).kind ~= "directory" then
		zune.fs.makeDir(dir, true)
	end

	local l_args = table.clone(b_args)
	local l_exec = zpath.join(dir, EXECUTABLE_NAME .. exec_ext)

	print("Copying libraries")
	copyLibraries(lib_ext, dir, "./vendor")

	print("Copying assets")
	copySandboxedSources(zjoin(root, "sandboxed"), sandboxEmbedRoot)
	zune.fs.copy(zjoin(root, "assets"), zjoin(dir, "assets"), true)

	table.insert(l_args, "--out=" .. l_exec)

	print("Bundling: zune " .. table.concat(l_args, " "))

	local exec: ProcessRunResult = zune.process.run(zune.fs.getExePath(), l_args)
	if not exec.ok then
		error("could not bundle executable: " .. tostring(exec.stderr))
	end

	local workingPath = zune.fs.getExePath()
	local read = zune.fs.readFile(workingPath, true)
	zune.fs.writeFile(zjoin(dir, "zune" .. exec_ext), read)

	local buildSrc = zune.fs.readFile("build.luau")
	zune.fs.writeFile(zjoin(dir, "build.luau"), buildSrc)

	print("successfully bundled at " .. l_exec)
end

if b_windows or (not anyPlatform and zune.platform.os == "windows") then
	buildExecutable("windows_x86-64", ".exe", "dll")
end

if b_macos or (not anyPlatform and zune.platform.os == "macos") then
	buildExecutable("macos_x86-64", ".app", "dylib")
end

if b_debian or (not anyPlatform and zune.platform.os == "linux") then
	buildExecutable("debian_x86-64", "", "so")
end

if b_freebsd or (not anyPlatform and zune.platform.os == "freebsd") then
	buildExecutable("freebsd_x86-64", "", "so")
end
