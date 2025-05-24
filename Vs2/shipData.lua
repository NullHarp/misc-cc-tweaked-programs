if not ship then
    error("Not on ship / cc vs not installed.")
end

--How many degrees to offset the yaw to account for the internal "front" of the ship
local axisOffset = 180

local monitor = peripheral.wrap("monitor_2")

local function wrapTo180(yaw)
    -- Invert Minecraft yaw to make clockwise positive
    yaw = -yaw
    -- Wrap into [-180, 180]
    return ((yaw + 180) % 360) - 180
end

local function yawToCardinal(yaw)
    if yaw > 135 and yaw < -135 then
        return "North"
    elseif yaw > -135 and yaw < -45 then
        return "East"
    elseif yaw > -45 and yaw < 45 then
        return "South"
    else
        return "West"
    end
end


while true do
    local rotation = ship.getEulerAnglesXYZ()
    local yaw = wrapTo180(math.deg(rotation.y))
    local dir = yawToCardinal(yaw)
    monitor.clear()
    monitor.setCursorPos(1,1)
    monitor.write("Angle: "..tostring(math.floor(yaw).."\n"))
    monitor.write("Facing: "..dir)
    sleep(0)
end