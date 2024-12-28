local util = require("util")
local version = "V0.1.0"

local protoARC = require("protoARC")

local monitor = peripheral.find("monitor")

local file_locations = protoARC.getStoragePaths()

term.redirect(monitor)
monitor.setTextScale(0.5)
while true do
    term.setTextColor(colors.white)
    util.title("Storage Monitor for Cent. ARC Serv.",version,false)
    for index, value in pairs(file_locations) do
        local capacity
        if fs.getDrive(value) == "hdd" then
            capacity = 1000000
        else
            capacity = 125000
        end
        local free_space = fs.getFreeSpace(value)
        local remain = capacity-free_space
        print(index)
        local posX,posY = term.getCursorPos()
        util.progressBar(1,posY,remain,capacity,50,colors.red,colors.green)
    end

    sleep(1)
end