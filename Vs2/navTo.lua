local pid = require("PID")
local pDet = peripheral.find("playerDetector")
local autoNav = require("autoNav")

local player = ...


while true do
    local data = pDet.getPlayerPos(player)
    local x,y,z = data.x,data.y,data.z
    local relative_angle, distance = autoNav.calculateHeading(x,y,z)
    term.clear()
    term.setCursorPos(1,1)
    autoNav.simulateNav(x,y,z)
    print(math.floor(relative_angle).."* deg")
    print(math.floor(distance).." dist")
    sleep()
end