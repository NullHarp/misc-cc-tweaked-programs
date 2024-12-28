local util = require("util")
local version = "V0.1.2"

local modem = peripheral.find("modem")

if type(modem) == "nil" then
    error("Modem not found",0)
end

local function send(id,filename)
    local file = fs.open(filename,"r")
    local data = file.readAll()
    file.close()
    local msg = {name = filename,data = data}
    rednet.send(id,textutils.serialiseJSON(msg),"FTP")
end

local function receive(loop)
    util.title("File Transfer Program",version)
    local got_file = false
    while not got_file or loop do
        local event, sender, message, protocol = os.pullEvent("rednet_message")
        if protocol == "FTP" then
            if type(message) ~= "nil" then
                local msg = textutils.unserialiseJSON(message)
                print("Received file: "..msg.name)
                if fs.exists(msg.name) then
                    print("File Already Exists, Overwrite?")
                    print("y/N")
                    local choice = read()
                    choice = string.lower(choice)
                    if choice == "y" then
                        local file = fs.open(msg.name,"w")
                        file.write(msg.data)
                        file.close()
                        print("File Overwritten: "..msg.name)
                    else
                        print("File Unchanged: "..msg.name)
                    end
                else
                    local file = fs.open(msg.name,"w")
                    file.write(msg.data)
                    file.close()
                end

                got_file = true
            end
        end
        sleep(0)
    end
end

local mode,filename,id,side = ...
if type(side) == "nil" then
    side = "top"
end
if type(mode) == "nil"then
    error("Missing Mode",0)
end
if type(filename) == "nil" and mode == "send" then
    error("Filename",0)
end
rednet.open(side)
if mode == "send" then
    id = tonumber(id)
    print("Sending")
    send(id,filename)
elseif mode == "receive" then
    receive(true)
end
rednet.close(side)