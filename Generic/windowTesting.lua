local buttoner = require("buttonAPI")
local windows = require("windowAPI")

local sizeX, sizeY = term.getSize()

local windowMaxX,windowMaxY = 15, 10

local currentWindow = ""
local currentButton = ""
local currentTerminal = nil

windows.newWindow(term.native(),1,1,windowMaxX,windowMaxY,true,"winder")
windows.newWindow(term.native(),3,1,windowMaxX,windowMaxY,true,"winder2")
windows.newWindow(term.native(),5,1,windowMaxX,windowMaxY,true,"winder3")
windows.newWindow(term.native(),7,1,windowMaxX,windowMaxY,true,"winder4")
windows.newWindow(term.native(),9,1,windowMaxX,windowMaxY,true,"winder5")

local windowCount = 0
local wins = windows.getWindows()
for windowId, windowData in pairs(wins) do
    windowCount = windowCount + 1
    buttoner.newButton(windowData.terminal,windowId,1,windowMaxY,"Bob","bob",colors.lightGray,colors.black,colors.gray)
    buttoner.newButton(windowData.terminal,windowId,windowMaxX,1,"X","closeWindow",colors.red,colors.black,colors.gray)
    
    buttoner.newButton(term.native(),"main",windowCount*5-4,sizeY,"Win"..windowCount,windowId,colors.lightGray,colors.black,colors.gray)
end

local function drawBackground()
    term.setBackgroundColor(colors.black)
    term.clear()
    term.setCursorPos(1,sizeY)
    term.setBackgroundColor(colors.lightBlue)
    term.clearLine()
    buttoner.drawButtons("main")
end

windows.drawWindows(true,currentWindow,currentButton)

local function dragManager()
    while true do
        local event, button, x, y = os.pullEvent("mouse_drag")
        for windowId, windowData in pairs(windows.getWindows()) do
            if windowData.isDragging then
                local newX = x - windows.getWindow(windowId).dragOffsetX
                local newY = y - windows.getWindow(windowId).dragOffsetY
                windows.moveWindow(windowId, newX, newY)
                drawBackground()
                windows.drawWindows(true,currentWindow,currentButton)
            end
        end
        sleep(0)
    end
end

local function clickHandler()
    while true do
        local event, button, x, y = os.pullEvent()
        if event == "mouse_click" then
            for windowId, windowData in pairs(windows.getWindows()) do
                local win = windowData.terminal
                local winX, winY = win.getPosition()
                if x >= winX and x <= winX+windowMaxX and y == winY then
                    windowData.isDragging = true
                    windowData.dragOffsetX = x - winX
                    windowData.dragOffsetY = y - winY
                    windows.updateWindow(windowId,windowData)
                end
            end
            currentTerminal = nil
            for windowId, windowData in pairs(windows.getWindows()) do
                currentButton, currentTerminal = buttoner.processButtons(x,y,windowId)
                if type(currentTerminal) ~= "nil" then
                    if string.find(currentButton,"closeWindow") then
                        currentTerminal.setVisible(false)
                        drawBackground()
                        windows.drawWindows(true,currentWindow,currentButton)
                    elseif currentButton ~= "" then
                        currentWindow = windowId
                        windows.drawWindows(true,currentWindow,currentButton)
                    end
                    currentButton = ""
                end
            end
        elseif event == "mouse_up" then
            for windowId, windowData in pairs(windows.getWindows()) do
                windowData.isDragging = false
                windows.updateWindow(windowId,windowData)
            end
            currentButton = ""
        end
    end
end

local function taskbar()
    while true do
        local event, button, x, y = os.pullEvent("mouse_click")
        local currentButtonMain, currentTerminalMain = buttoner.processButtons(x,y,"main")
        buttoner.drawButtons("main",currentButtonMain)
        if currentButtonMain ~= "" then
            local wins = windows.getWindows()
            if type(wins[currentButtonMain]) ~= "nil" then

                wins[currentButtonMain].terminal.setVisible(true)
                windows.updateWindow(currentButtonMain,wins[currentButtonMain])
            end
        end
        sleep(0)
        currentButtonMain = ""
        buttoner.drawButtons("main",currentButtonMain)
    end
end

local native = term.native()

local function program()
    while true do
        local win = windows.getWindow("winder")
        term.redirect(win.terminal)
        shell.run("shell")
    end

end

local function main()
    term.redirect(native)
    parallel.waitForAll(dragManager, clickHandler, taskbar)
end

parallel.waitForAll(program,main)