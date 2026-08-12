-- Renderer agnostic library for Kinemium

local lib = {}

local fs = zune.fs
local adapters = "./adapters/"
local typedefs = require("./Argon/typedefs")

return require("./Argon/adapters/sdl3/lib")
