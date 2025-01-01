local buttoner = require("buttonAPI")

local windows_objects = {}

local function newWindow(terminal, startX, startY, width, height, startVisible, windowId)
    local win = window.create(terminal, startX, startY, width, height, startVisible)
    local windowData = {
        terminal = win,
        minX = startX,
        minY = startY,
        maxX = startX+width-1,
        maxY = startY+height-1,
        width = width,
        height = height,
        isDragging = false,
        dragOffsetX = 0,
        dragOffsetY = 0
    }
    windows_objects[windowId] = windowData
end

local function moveWindow(windowId,newX,newY)
    local win = windows_objects[windowId].terminal
    win.reposition(newX, newY)
    windows_objects[windowId].minX = newX
    windows_objects[windowId].minY = newY
    windows_objects[windowId].maxX = newX + windows_objects[windowId].width
    windows_objects[windowId].maxY = newY + windows_objects[windowId].height
end

local function drawWindows(hasButtons,currentWindow,currentButton)
    hasButtons = hasButtons or false
    currentWindow = currentWindow or ""
    currentButton = currentButton or ""
    for windowID, windowData in pairs(windows_objects) do
        local win = windowData.terminal
        win.setBackgroundColor(colors.white)
        win.clear()
        win.setBackgroundColor(colors.lightGray)
        win.setCursorPos(1, 1)
        win.clearLine()
        win.write(windowID)
        win.setBackgroundColor(colors.lightGray)
        if hasButtons then
            if currentWindow == windowID then
                buttoner.drawButtons(windowID,currentButton)
            else
                buttoner.drawButtons(windowID)
            end
        end
    end
end

local function getWindows()
    return windows_objects
end

local function getWindow(windowID)
    return windows_objects[windowID]
end

local function updateWindow(windowID,windowData)
    windows_objects[windowID] = windowData
end

return {moveWindow = moveWindow, newWindow = newWindow, drawWindows = drawWindows, getWindows = getWindows,getWindow = getWindow, updateWindow = updateWindow}