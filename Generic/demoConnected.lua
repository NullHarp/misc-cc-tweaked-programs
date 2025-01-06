local monitor = require("connectedMonitor")

local button = require("buttonAPI")

button.newButton(monitor,"main",80,5,"Bobby","bob",colors.white,colors.black,colors.lightGray,false,30,30)

local rows = {{"monitor_4", "monitor_5"}, {"monitor_2", "monitor_3"}}
monitor.setRows(rows)

monitor.setBackgroundColor(colors.black)
monitor.setTextColor(colors.white)
monitor.clear()
monitor.setTextScale(1)

while true do
    button.drawButtons("main")
    local side, event, x, y = monitor.getTouch()
    local pressed = button.processButtons(x,y,"main")
    pressed = pressed or ""
    print(pressed)
    button.drawButtons("main",pressed)
    sleep(0.1)
end