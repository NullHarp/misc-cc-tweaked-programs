local util = require("util")
local ver = "V0.1.0"

local default_location = "main"

local protoARC = require("protoARC")

local name, version, description, location = ...

if type(name) == "nil" then
    error("Missing name",0)
end
util.title("Entry Modifier",ver)
local index = protoARC.getFileIndex()

for i,v in pairs(index) do
    if v.name == name then
        print("Modifiying Entry: "..name)
        print("Current Version: "..v.version)
        print("Input new version (or leave blank to skip)")
        local new_version = read()
        print("Current Description: "..v.description)
        print("Input new description (or leave blank to skip)")
        local new_description = read()
        print("Current location: "..v.location)
        print("Input new location (or leave blank to skip)")
        local new_location = read()
        local entry = {
            name = name,
            version = new_version,
            description = new_description,
            location = new_location
        }
        protoARC.replaceIndexEntry(entry)
        print("Updated Index entry "..name)
    end
end