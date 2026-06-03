local process = zune.process

local ZUNE_BIN = zune.fs.getExePath()

assert(not zune.compiled, "bundled not supported")

-- run tests
require("./tester")
