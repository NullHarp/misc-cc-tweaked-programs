local monitor = require("connectedMonitor")
monitor.loadRows("virtual_monitor")

local function sim()
    while true do
        monitor.simulateMouse()
        sleep(0)
    end
end

local function main()
    local event, mouse, x, y = os.pullEvent("mouse_click")
    print(x,y)
    sleep(0)
end

parallel.waitForAll(sim,main)