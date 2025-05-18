local pid = require("PID")
local autoNav = require("autoNav")

local x,y,z = ...

while true do
    local relative_angle, distance = autoNav.calculateHeading(x,y,z)
    term.clear()
    term.setCursorPos(1,1)
    autoNav.simulateNav(x,y,z)
    print(math.floor(relative_angle).."* deg")
    print(math.floor(distance).." dist")
    if distance < 30 then
        break
    end
    sleep()
end