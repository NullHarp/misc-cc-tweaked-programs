local monitor = require("connectedMonitor")

local virt_monitor, program_name, scale = ...
scale = scale or 1
scale = tonumber(scale)
if not monitor.loadRows(virt_monitor) then
    error("Not a valid virtual monitor.")
end

monitor.setTextScale(scale)
term.redirect(monitor)

local function program()
    shell.run(program_name)
end

local function simTouch()
    while true do
        monitor.simulateMouse()
    end
end

parallel.waitForAll(program,simTouch)