local zpath = zune.fs.path
local zjoin = zpath.join

local EXECUTABLE_NAME = "KinemiumRuntime"
local COMPRESSION = "zstd"

local root = zjoin("src")
local entry = zjoin(root, "main.luau")

local bin = zjoin("build")

local include = {
	zjoin(root, "**", "*.luau*"),
}

local assets = {
	zjoin("**", ".luaurc"),
	zjoin(root, "assets", "**"),
	zjoin(root, "projects.toml"),
	zjoin(root, "sandboxed", "**"),
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
	copyLibraries(lib_ext, dir, zpath.join(root, "external"))

	print("Copying assets")
	zune.fs.copy(zjoin(root, "assets"), zjoin(dir, "assets"), true)
	table.insert(l_args, "--out=" .. l_exec)

	print("Bundling: zune " .. table.concat(l_args, " "))

	local exec: ProcessRunResult = zune.process.run(zune.fs.getExePath(), l_args)
	if not exec.ok then
		error("could not bundle executable: " .. tostring(exec.stderr))
	end
	print("successfully bundled at " .. l_exec)
end

if b_windows or zune.platform.os == "windows" then
	buildExecutable("windows_x86-64", ".exe", "dll")
end

if b_macos or zune.platform.os == "macos" then
	buildExecutable("macos_x86-64", ".app", "dll")
end

-- Zune's Linux release is compiled for Debian.
if b_debian or zune.platform.os == "linux" then
	buildExecutable("debian_x86-64", "", "so")
end

-- There is no progress on proper FreeBSD support despite
-- an available native Zune executable.
-- Linux compatibility may need to be enabled by the user,
-- since the .so libraries are re-used from Linux.
if b_freebsd or zune.platform.os == "freebsd" then
	buildExecutable("freebsd_x86-64", "", "so")
end
