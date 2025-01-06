local cursorX, cursorY = 1, 1 -- Global cursor for the virtual monitor

local buffer = {}

local monitors = {}
local monitor_names = {}

local vm_id = "virtual_monitor"

local function setRows(rows)
    monitor_names = rows
    monitors = {}
    for i, v in pairs(monitor_names) do
        monitors[i] = {}
        for i2, v2 in pairs(v) do
            monitors[i][i2] = peripheral.wrap(v2)
        end
    end
end

local function executeAll(func,...)
    
    for index, row in pairs(monitors) do
        for _, monitor in pairs(row) do
            monitor[func](...)
        end
    end
end

local function getMonitorIndexAndLocalPos(x, y)
    local offsetY = y
    local targetRow, targetCol = 1, 1
    local localX, localY = x, y

    -- Determine the row based on the Y position
    for rowIndex, row in ipairs(monitors) do
        local rowHeight = select(2, row[1].getSize())
        if offsetY > rowHeight then
            offsetY = offsetY - rowHeight
        else
            targetRow = rowIndex
            localY = offsetY
            break
        end
    end

    -- Determine the column based on the X position
    local offsetX = x
    for colIndex, monitor in ipairs(monitors[targetRow]) do
        local colWidth = select(1, monitor.getSize())
        if offsetX > colWidth then
            offsetX = offsetX - colWidth
        else
            targetCol = colIndex
            localX = offsetX
            break
        end
    end

    return targetRow, targetCol, localX, localY
end

local function getGlobalPosFromLocal(rowIndex, colIndex, localX, localY)
    local globalX, globalY = 1, 1

    -- Add the Y offset for previous rows
    for i = 1, rowIndex - 1 do
        local rowHeight = select(2, monitors[i][1].getSize())
        globalY = globalY + rowHeight
    end

    -- Add the Y offset for the current row (up to the localY position)
    globalY = globalY + localY - 1

    -- Add the X offset for previous columns
    for i = 1, colIndex - 1 do
        local colWidth = select(1, monitors[rowIndex][i].getSize())
        globalX = globalX + colWidth
    end

    -- Add the X offset for the current column (up to the localX position)
    globalX = globalX + localX - 1

    return globalX, globalY
end


-- Calculate total width and height of the virtual monitor
local function getSize()
    local width = 0
    local height = 0
    for _, row in pairs(monitors) do
        local rowWidth = 0
        local rowHeight = 0
        for _, mon in pairs(row) do
            local monWidth, monHeight = mon.getSize()
            rowWidth = rowWidth + monWidth
            rowHeight = monHeight
        end
        width = math.max(width, rowWidth)
        height = height + rowHeight
    end
    return width, height
end

-- Set cursor position within the virtual monitor
local function setCursorPos(x, y)
    cursorX, cursorY = x, y
    local row, col, localX, localY = getMonitorIndexAndLocalPos(x,y)
    monitors[row][col].setCursorPos(localX,localY)
end

-- Write text to the virtual monitor
local function write(text)
    local remainingText = tostring(text)

    while #remainingText > 0 do
        -- Determine the current monitor row and column based on cursor position
        local offsetY = cursorY
        local currentRow, currentCol = 1, 1

        -- Find the current monitor row
        for rowIndex, row in ipairs(monitors) do
            local rowHeight = select(2, row[1].getSize())
            if offsetY > rowHeight then
                offsetY = offsetY - rowHeight
            else
                currentRow = rowIndex
                break
            end
        end

        -- Find the current monitor column
        local offsetX = cursorX
        for colIndex, monitor in ipairs(monitors[currentRow]) do
            local colWidth = select(1, monitor.getSize())
            if offsetX > colWidth then
                offsetX = offsetX - colWidth
            else
                currentCol = colIndex
                break
            end
        end

        -- Get the current monitor and its dimensions
        local currentMonitor = monitors[currentRow][currentCol]
        local monWidth, monHeight = currentMonitor.getSize()

        -- Calculate how much text can fit in the remaining space on the current monitor
        local availableSpace = monWidth - offsetX + 1
        local toWrite = remainingText:sub(1, availableSpace)

        -- Write the text to the current monitor
        currentMonitor.setCursorPos(offsetX, offsetY)
        currentMonitor.write(toWrite)
        remainingText = remainingText:sub(#toWrite + 1)

        -- Update the virtual cursor position
        cursorX = cursorX + #toWrite
        local virtualWidth, virtualHeight = getSize()
        if cursorX > virtualWidth then
            cursorX = 1
            cursorY = cursorY + 1
        end

        -- Stop if the cursor moves beyond the virtual monitor's height
        if cursorY > virtualHeight then
            break
        end
    end
end

local function clear()
    buffer = {}
    executeAll("clear")
end

local function clearLine()
    local row, col = getMonitorIndexAndLocalPos(cursorX,cursorY)
    for i, v in pairs(monitors[row]) do
        v.setCursorPos(1,cursorY)
        v.clearLine()
    end
end

local function getCursorPos()
    return cursorX, cursorY
end

local function setTextScale(scale)
    if scale > 5 or scale < 0.5 then
        error("Scale must be less than 5 and greater than 0.5")
    else
        executeAll("setTextScale",scale)
    end
end

local function getTextScale()
    return monitors[1][1].getTextScale()
end

local function getTextColor()
    return monitors[1][1].getTextColor()
end

local function getTextColour()
    return monitors[1][1].getTextColor()
end

local function setTextColor(color)
    executeAll("setTextColor",color)
end

local function setTextColour(color)
    executeAll("setTextColor",color)
end

local function getBackgroundColor()
    return monitors[1][1].getBackgroundColor()
end

local function getBackgroundColour()
    return monitors[1][1].getBackgroundColour()
end

local function setBackgroundColor(color)
    executeAll("setBackgroundColor",color)
end

local function setBackgroundColour(colour)
    executeAll("setBackgroundColour",colour)
end

local function isColor()
    return monitors[1][1].isColor()
end

local function isColour()
    return monitors[1][1].isColour()
end

local function getCursorBlink()
    local row, col = getMonitorIndexAndLocalPos(cursorX,cursorY)
    monitors[row][col].getCursorBlink()
end

local function setCursorBlink(blink)
    local row, col = getMonitorIndexAndLocalPos(cursorX,cursorY)
    monitors[row][col].setCursorBlink(blink)
end

local function blit(text, textColour, backgroundColour)
    local remainingText = tostring(text)
    local remainingTextColour = tostring(textColour)
    local remainingBackgroundColour = tostring(backgroundColour)

    while #remainingText > 0 do
        -- Determine the current monitor row and column based on cursor position
        local offsetY = cursorY
        local currentRow, currentCol = 1, 1

        -- Find the current monitor row
        for rowIndex, row in ipairs(monitors) do
            local rowHeight = select(2, row[1].getSize())
            if offsetY > rowHeight then
                offsetY = offsetY - rowHeight
            else
                currentRow = rowIndex
                break
            end
        end

        -- Find the current monitor column
        local offsetX = cursorX
        for colIndex, monitor in ipairs(monitors[currentRow]) do
            local colWidth = select(1, monitor.getSize())
            if offsetX > colWidth then
                offsetX = offsetX - colWidth
            else
                currentCol = colIndex
                break
            end
        end

        -- Get the current monitor and its dimensions
        local currentMonitor = monitors[currentRow][currentCol]
        local monWidth, monHeight = currentMonitor.getSize()

        -- Calculate how much text can fit in the remaining space on the current monitor
        local availableSpace = monWidth - offsetX + 1
        local toWrite = remainingText:sub(1, availableSpace)
        local toColor = remainingTextColour:sub(1, availableSpace)
        local toBgColor = remainingBackgroundColour:sub(1, availableSpace)

        -- Write the text to the current monitor
        currentMonitor.setCursorPos(offsetX, offsetY)
        currentMonitor.blit(toWrite,toColor,toBgColor)
        remainingText = remainingText:sub(#toWrite + 1)
        remainingTextColour = remainingTextColour:sub(#toColor + 1)
        remainingBackgroundColour = remainingBackgroundColour:sub(#toBgColor + 1)

        -- Update the virtual cursor position
        cursorX = cursorX + #toWrite
        local virtualWidth, virtualHeight = getSize()
        if cursorX > virtualWidth then
            cursorX = 1
            cursorY = cursorY + 1
        end

        -- Stop if the cursor moves beyond the virtual monitor's height
        if cursorY > virtualHeight then
            break
        end
    end
end

local function scroll(y)
    --This is "Temporary" until I implement a custom version of it specifically for this
    executeAll("scroll",y)
end

local function getTouch()
    local touched = false
    while not touched do
        local event, side, x, y = os.pullEvent("monitor_touch")
        for row, v in pairs(monitor_names) do
            for col, name in pairs(v) do
                if side == name then
                    touched = true
                    local globalX, globalY = getGlobalPosFromLocal(row,col,x,y)
                    os.queueEvent("monitor_touch", vm_id, globalX,globalY)
                    return event, vm_id, globalX, globalY
                end
            end
        end
        sleep(0)
        return event, side, x, y
    end
end

local function simulateMouse()
    local touched = false
    while not touched do
        local event, side, x, y = os.pullEvent("monitor_touch")
        for row, v in pairs(monitor_names) do
            for col, name in pairs(v) do
                if side == name then
                    touched = true
                    local globalX, globalY = getGlobalPosFromLocal(row,col,x,y)
                    os.queueEvent("mouse_click", 1, globalX, globalY)
                end
            end
        end
        sleep(0)
    end
end

local function setPaletteColor(...)
    executeAll("setPaletteColor",...)
end

local function setPaletteColour(...)
    executeAll("setPaletteColour",...)
end

local function getPaletteColor(c)
    return monitors[1][1].getPaletteColor(c)
end

local function getPaletteColour(c)
    return monitors[1][1].getPaletteColour(c)
end

local function loadRows(virt_monitor_id)
    ---VMC aka Virtual Monitor C(i forget what the C stands for)
    if not fs.exists(virt_monitor_id..".vmc") then
        return false
    else
        local file = fs.open(virt_monitor_id..".vmc","r")
        local file_data = file.readAll()
        file.close()
        local tbl = textutils.unserialiseJSON(file_data)
        setRows(tbl)
        vm_id = virt_monitor_id
        return true
    end
end

local function saveRows(virt_monitor_id)
    local file = fs.open(virt_monitor_id..".vmc","w")
    local json = textutils.serialiseJSON(monitor_names)
    file.write(json)
    file.close()
    return true
end

return {
    setRows = setRows,
    loadRows = loadRows,
    saveRows = saveRows,
    setTextScale = setTextScale,
    getTextScale = getTextScale,
    write = write,
    scroll = scroll,
    getCursorPos = getCursorPos,
    setCursorPos = setCursorPos,
    getCursorBlink = getCursorBlink,
    setCursorBlink = setCursorBlink,
    getSize = getSize,
    clear = clear,
    clearLine = clearLine,
    getTextColour = getTextColour,
    getTextColor = getTextColor,
    setTextColour = setTextColour,
    setTextColor = setTextColor,
    getBackgroundColour = getBackgroundColour,
    getBackgroundColor = getBackgroundColor,
    setBackgroundColour = setBackgroundColour,
    setBackgroundColor = setBackgroundColor,
    isColour = isColour,
    isColor = isColor,
    blit = blit,
    getTouch = getTouch,
    simulateMouse = simulateMouse,
    getPaletteColour = getPaletteColour,
    getPaletteColor = getPaletteColor,
    setPaletteColour = setPaletteColour,
    setPaletteColor = setPaletteColor
}