local button = require("buttonAPI")

local monitor = peripheral.find("monitor")
monitor.setTextScale(1)
monitor.setBackgroundColor(colors.black)
monitor.setTextColor(colors.white)
monitor.clear()
monitor.setCursorPos(1,1)

local current_code = ""
local password = "6969"

button.newButton(monitor,"keypad",2,1,"1","1",colors.lightGray,colors.white,colors.gray)
button.newButton(monitor,"keypad",4,1,"2","2",colors.lightGray,colors.white,colors.gray)
button.newButton(monitor,"keypad",6,1,"3","3",colors.lightGray,colors.white,colors.gray)
button.newButton(monitor,"keypad",2,3,"4","4",colors.lightGray,colors.white,colors.gray)
button.newButton(monitor,"keypad",4,3,"5","5",colors.lightGray,colors.white,colors.gray)
button.newButton(monitor,"keypad",6,3,"6","6",colors.lightGray,colors.white,colors.gray)
button.newButton(monitor,"keypad",2,5,"7","7",colors.lightGray,colors.white,colors.gray)
button.newButton(monitor,"keypad",4,5,"8","8",colors.lightGray,colors.white,colors.gray)
button.newButton(monitor,"keypad",6,5,"9","9",colors.lightGray,colors.white,colors.gray)


while true do
    button.drawButtons("keypad")
    local event, side, x, y = os.pullEvent("monitor_touch")
    if side == peripheral.getName(monitor) then
        local pressed = button.processButtons(x,y,"keypad")
        if pressed then
            button.drawButtons("keypad",pressed)
            current_code = current_code..pressed
            if #current_code >= #password and current_code ~= password then
                print("Access Denied!")
                current_code = ""
            elseif current_code == password then
                print("Access Granted!")
                redstone.setOutput("right",true)
                sleep(3)
                redstone.setOutput("right",false)
                current_code = ""
            end
        end
        sleep(0.1)
    end
end
