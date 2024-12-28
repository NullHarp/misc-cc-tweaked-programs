local util = require("util")
local version = "V0.1.0"

local default_location = "main"

local protoARC = require("protoARC")

local name, version, description, location = ...

local entry = {
    name = "",
    version = "V0.1.0",
    description = "",
    location = default_location
}

if type(name) == "nil" then
    print("Format: name, version(optional), description(optional), location(optional)")
    error("Missing name",0)
end
entry.name = name
if type(version) ~= "nil" then
    entry.version = version
end
if type(description) ~= "nil" then
    entry.description = description
end
if type(location) ~= "nil" then
    entry.location = location
end
protoARC.addIndexEntry(entry)