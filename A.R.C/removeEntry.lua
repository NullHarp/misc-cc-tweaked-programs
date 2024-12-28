local util = require("util")
local version = "V0.1.0"

local default_location = "main"

local protoARC = require("protoARC")

local name, version, description, location = ...

if type(name) == "nil" then
    error("Missing name",0)
end
protoARC.removeIndexEntry(name)
print("Removed entry "..name.." from the index.")