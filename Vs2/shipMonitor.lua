local monitor = peripheral.find("monitor")

if not ship then
    error("The computer is not located on a vs2 ship or vs:cc is not installed!")
end

monitor.clear()

while true do
    local vel = ship.getVelocity()
    local pos = ship.getWorldspacePosition()
    monitor.setCursorPos(1,1)
    monitor.clearLine()
    monitor.write("Pos:   "..tostring(math.floor(pos.x)).." "..tostring(math.floor(pos.y)).." "..tostring(math.floor(pos.z)))
    monitor.setCursorPos(1,2)
    monitor.write("Speed: "..tostring(math.floor(math.sqrt(vel.x^2 + vel.y^2 + vel.z^2))))
    sleep(0)
end