local monitor = peripheral.find("monitor")

if not ship then
    error("The computer is not located on a vs2 ship or vs:cc is not installed!")
end

monitor.clear()

while true do
    local vel = ship.getVelocity()

    local speed = math.sqrt(vel.x^2 + vel.y^2 + vel.z^2)
    local floored_speed = math.floor(speed)

    local pos = ship.getWorldspacePosition()
    local floored_pos = {}

    floored_pos.x = math.floor(pos.x)
    floored_pos.y = math.floor(pos.y)
    floored_pos.z = math.floor(pos.z)

    local yaw = ship.getYaw()
    local yaw_degrees = math.deg(yaw)
    local floored_yaw = math.floor(yaw_degrees)

    monitor.setCursorPos(1,1)
    monitor.clearLine()

    monitor.write("Pos:   "..tostring(floored_pos.x).." "..tostring(floored_pos.y).." "..tostring(floored_pos.z))
    
    monitor.setCursorPos(1,2)
    monitor.clearLine()
    monitor.write("Speed: "..tostring(floored_speed))
    sleep(0)
end