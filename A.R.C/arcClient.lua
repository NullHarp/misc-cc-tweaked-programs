local util = require("util")
local protoARC = require("protoARC")

local modem = peripheral.find("modem")
modem.open(protoARC.reply_channel)

local mode, filename = ...



if mode == "index" then
    local index = protoARC.requestIndex(modem)
    for i,v in pairs(index) do
        textutils.pagedPrint(v.name.." "..v.version)
        textutils.pagedPrint("  "..v.description)
        textutils.pagedPrint("")
    end
elseif mode == "info" then
    local file_data = protoARC.requestFileInfo(modem,filename)
    print("Received requested file info "..filename)
    print(file_data.name.." "..file_data.version)
    print("  "..file_data.description)
elseif mode == "request" then
    local file_data = protoARC.requestFile(modem,filename)
    local file = fs.open(file_data.name,"w")
    file.write(file_data.file_data)
    file.close()
    print("Saved requested file "..file_data.name)
else
    print("Usage: Mode: index,info,request Filename: valid index file")
end