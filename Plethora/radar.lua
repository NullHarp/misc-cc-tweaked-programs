local entityScanner = peripheral.find("manipulator")
local monitor = peripheral.find("monitor")

monitor.setTextScale(1)

local sizeX, sizeY = monitor.getSize()
local centerX, centerY = sizeX/2, sizeY/2

while true do
    local scanData = entityScanner.sense(8)
    monitor.clear()
    monitor.setCursorPos(centerX,centerY)
    monitor.write("O")
    for _, entityData in pairs(scanData) do
        monitor.setCursorPos(centerX+entityData.x,centerY+entityData.z)
        monitor.write("X")
    end
end