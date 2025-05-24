local scanner = peripheral.find("r")
local monitor = peripheral.wrap("monitor_12")

monitor.setTextScale(1)

local sizeX, sizeY = monitor.getSize()
local centerX, centerY = sizeX/2, sizeY/2

local scan_size = 512

while true do
    local scanData = scanner.scanForShips(scan_size)
    monitor.clear()
    monitor.setCursorPos(centerX,centerY)
    monitor.write("O")
    for _, shipData in pairs(scanData) do
        local pos = shipData.pos
        local our_pos = ship.getWorldspacePosition()
        local localized_pos_x = pos.x - our_pos.x
        local localized_pos_z = pos.z - our_pos.z
        monitor.setCursorPos(centerX+((localized_pos_x/scan_size)*sizeX),centerY+((localized_pos_z/scan_size)*sizeY))
        monitor.write("X")
    end
end