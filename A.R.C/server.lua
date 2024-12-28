local util = require("util")
local version = "V0.1.0"

local protoARC = require("protoARC")

local modem = peripheral.wrap("modem_5")

local file_locations = protoARC.getStoragePaths()

modem.open(protoARC.request_channel)
util.title("A.R.C Server",version,false)
local event, side, channel, replyChannel, message, distance
while true do
    util.title("A.R.C Server",version,true)
    event, side, channel, replyChannel, message, distance = os.pullEvent("modem_message")
    if channel == protoARC.request_channel then
        local success,data = pcall(textutils.unserialiseJSON,message)
        if success then
            if data.type == "req_index" then
                print("Got request for index")
                local index = protoARC.getFileIndex()
                protoARC.sendFileIndex(modem,index,data.id)
                print("Sent file index to id "..data.id)
            elseif data.type == "req_file" then
                local index = protoARC.getFileIndex()
                for i,v in pairs(index) do
                    if v.name == data.filename then
                        print("Found requested file: "..data.filename.." in location: "..v.location)
                        if v.location ~= "remote" then
                            local file = fs.open(file_locations[v.location]..data.filename,"r")
                            local file_data = file.readAll()
                            local file_info = {
                                data = file_data,
                                name = v.name,
                                version = v.version,
                                description = v.description
                            }
                            file.close()
                            protoARC.sendFile(modem,file_info,data.id)
                            print("Sent requested file to id "..data.id)
                        else
                            print("File is stored in another server, dropping request.")
                        end

                    end
                end
            elseif data.type == "req_file_info" then
                local index = protoARC.getFileIndex()
                for i,v in pairs(index) do
                    if v.name == data.filename then
                        print("Found requested file info: "..data.filename)
  
                        local file_info = {
                            name = v.name,
                            version = v.version,
                            description = v.description
                        }
                        protoARC.sendFileInfo(modem,file_info,data.id)
                        print("Sent requested file info to id "..data.id)
                    end
                end
            end
        end
    end
end