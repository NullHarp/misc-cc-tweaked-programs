local backend = require("IRC_backend")
local buttonAPI = require("buttonAPI")

local monitor = peripheral.wrap("top")
local debug_monitor = peripheral.wrap("monitor_1")

local sizeX, sizeY = term.getSize()

term.clear()
term.setCursorPos(1,1)

buttonAPI.newButton(term.current(),"Controls",1,1,"PlaceUp","placeUp",colors.white,colors.black,colors.lightGray)
buttonAPI.newButton(term.current(),"Controls",1,3,"Place","place",colors.white,colors.black,colors.lightGray)
buttonAPI.newButton(term.current(),"Controls",1,5,"PlaceDown","placeDown",colors.white,colors.black,colors.lightGray)

buttonAPI.newButton(term.current(),"Controls",12,1,"DigUp","digUp",colors.white,colors.black,colors.lightGray)
buttonAPI.newButton(term.current(),"Controls",12,3,"Dig","dig",colors.white,colors.black,colors.lightGray)
buttonAPI.newButton(term.current(),"Controls",12,5,"DigDown","digDown",colors.white,colors.black,colors.lightGray)

buttonAPI.newButton(term.current(),"Controls",1,7,"DropUp","dropUp",colors.white,colors.black,colors.lightGray)
buttonAPI.newButton(term.current(),"Controls",1,9,"Drop","drop",colors.white,colors.black,colors.lightGray)
buttonAPI.newButton(term.current(),"Controls",1,11,"DropDown","dropDown",colors.white,colors.black,colors.lightGray)

buttonAPI.newButton(term.current(),"Controls",12,7,"SuckUp","suckUp",colors.white,colors.black,colors.lightGray)
buttonAPI.newButton(term.current(),"Controls",12,9,"Suck","suck",colors.white,colors.black,colors.lightGray)
buttonAPI.newButton(term.current(),"Controls",12,11,"SuckDown","suckDown",colors.white,colors.black,colors.lightGray)

buttonAPI.newButton(term.current(),"Controls",1,sizeY-2,"SelectLeft","selectLeft",colors.white,colors.black,colors.lightGray)
buttonAPI.newButton(term.current(),"Controls",1,sizeY,"SelectRight","selectRight",colors.white,colors.black,colors.lightGray)

buttonAPI.newButton(term.current(),"Controls",1,sizeY-1,"Select","select",colors.white,colors.black,colors.lightGray)

buttonAPI.newButton(term.current(),"Controls",sizeX-#"refresh"+1,sizeY,"Refresh","refresh",colors.white,colors.black,colors.lightGray)
buttonAPI.newButton(term.current(),"Controls",sizeX-#"exit"+1,1,"exit","exit",colors.white,colors.black,colors.lightGray)

local ws = backend.ws
local err = backend.err

local fuelLevel = -1
local fuelLimit = -1

local selectedSlot = -1
local selector = 1

local inventory = ""
local spliced_inventory = {}

local username = "turtleContExtd"
local nickname = "ControlerExtended"
local realname = "Hi, I am a bot!"

local buttonToCommandMap = {
    place = "P",
    placeUp = "PU",
    placeDown = "PD",

    dig = "Di",
    digUp = "DiU",
    digDown = "DiD",

    drop = "Dp 64",
    dropUp = "DpU 64",
    dropDown = "DpD 64",

    suck = "S 64",
    suckUp = "SU 64",
    suckDown = "SD 64"
}

local function sendCommand(command)
    ws.send("PRIVMSG Gumpai :"..command)
    if debug_monitor then
        local old_term = term.redirect(debug_monitor)
        print(command)
        term.redirect(old_term)
    end
end

local function seperate_inventory()
    spliced_inventory = {}
    local i = 0
    for item in string.gmatch(inventory, '([^,]+)') do
        i = i +1
        spliced_inventory[i] = {}
        if tonumber(item) then
            spliced_inventory[i].count = 0
            spliced_inventory[i].name = "minecraft:air"
        else
            local name_start, _, _ = string.find(item,".",1,true)
            local count = string.sub(item,1,name_start-1)
            local name = string.sub(item,name_start+1)
            spliced_inventory[i].count = tonumber(count)
            spliced_inventory[i].name = name
        end
    end
end

local function moveSelector(moveDir)
    if selector + moveDir > 16 then
        selector = 16
    elseif selector + moveDir < 1 then
        selector = 1
    else
        selector = selector + moveDir
    end
end

local function drawDisplay()
    monitor.clear()
    monitor.setCursorPos(1,1)
    local old_term = term.redirect(monitor)
    print("Fuel:",fuelLevel,"/",fuelLimit)
    print("Selected:",selectedSlot)
    print("Selector:",selector)
    print("Inventory:")
    if #spliced_inventory > 0 then
        for index, item in pairs(spliced_inventory) do
            if item.count > 0 then
                print("Slot",index,"Name:",item.name,"Count:",item.count)
            end
        end
    end
    term.redirect(old_term)
end

local function refreshData()
    sleep(0.3)
    sendCommand("GFLev")
    sleep(0.3)
    sendCommand("GSelSlot")
    sleep(0.3)
    sendCommand("Inventory")
end

local function drawScreen()
    while true do
        drawDisplay()
        buttonAPI.drawButtons("Controls")
        local event, button, x, y = os.pullEvent("mouse_click")
        local pressedButton = buttonAPI.processButtons(x,y,"Controls")
        if buttonToCommandMap[pressedButton] then
            sendCommand (buttonToCommandMap[pressedButton])
        elseif pressedButton == "selectLeft" then
            moveSelector(-1)
        elseif pressedButton == "selectRight" then
            moveSelector(1)
        elseif pressedButton == "select" then
            sendCommand("Sel "..tostring(selector))
            sleep(0.1)
            sendCommand("GSelSlot")
        elseif pressedButton == "refresh" then
            refreshData()
        elseif pressedButton == "exit" then
            ws.send("QUIT")
            ws.close()
            error("Closing")
        end
        buttonAPI.drawButtons("Controls")
        drawDisplay()
        sleep(0)
    end
end

local function receive()
    while true do
        local message = ws.receive()
        if message then
            local msg_data, message_destination, cmd, numeric, message_origin = backend.processRawMessage(message)
            if cmd and not numeric then
                local origin_client, origin_nick
                if message_origin then
                    origin_client, origin_nick = backend.processMessageOrigin(message_origin)
                end

                if cmd == "NOTICE" then
                    local words = string.gmatch(msg_data, "%S+")
                    local args = {}

                    for arg in words do
                        table.insert(args,arg)
                    end

                    local command = args[1]
                    local data = string.sub(msg_data,#command+2)

                    if command == "GFLim" then
                        fuelLimit = tonumber(args[3])
                    elseif command == "GFLev" then
                        fuelLevel = tonumber(args[3])
                    elseif command == "GSelSlot" then
                        selectedSlot = tonumber(args[3])
                    elseif command == "Inventory" then
                        inventory = data
                        sleep(0.2)
                        seperate_inventory()
                    end
                    drawDisplay()
                end
            end
        end
    end
end

local function init()
    sleep(2)
    refreshData()
    sleep(0.3)
    sendCommand("GFLim")
end

monitor.setTextScale(1)
monitor.clear()
monitor.setCursorPos(1,1)

ws.send("USER " .. username .. " unused unused " .. realname)
ws.send("NICK " .. nickname)
backend.accountData.nickname = nickname

parallel.waitForAll(receive,drawScreen,init)