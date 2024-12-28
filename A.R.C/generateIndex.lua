local util = require("util")
local version = "V0.1.0"

local protoARC = require("protoARC")
util.title("Index Generator",version)
local files_and_folders = fs.list("/data/")
local index = {}
for i,v in pairs(files_and_folders) do
    if not fs.isDir("/data/"..v) then
        local entry = {
            name = v,
            version = "V0.1.0",
            description = "",
            location = ""
        }
        table.insert(index,entry)
    end
end
local entry_json = textutils.serialiseJSON(index,{compact = false})

local file = fs.open("generated_info.json","w")
file.write(util.prettyPrintJSON(entry_json))
file.close()
print("Outputed to file generated_info.json")
print("Generated "..#index.." entries")
