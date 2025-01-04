local blockScanner = peripheral.find("manipulator")
local monitor = peripheral.find("monitor")

monitor.setTextScale(1)

local sizeX, sizeY = monitor.getSize()
local centerX, centerY = sizeX/2, sizeY/2

local targetY = 1

local function control()
    while true do
        local event, key, isHeld = os.pullEvent("key")
        if key == keys.left then
            targetY = targetY-1
        elseif key == keys.right then
            targetY = targetY+1
        end
    end
end

local function display()
    while true do
        local scanData = blockScanner.scan(16)
        monitor.clear()
        monitor.setCursorPos(centerX,centerY)
        monitor.write("O")
        for _, blockData in pairs(scanData) do
            if blockData.name ~= "minecraft:air" then
                if blockData.y == targetY+1 then
                    monitor.setCursorPos(centerX+blockData.x,centerY+blockData.z)
                    monitor.setBackgroundColor(colors.white)
                    monitor.write("X")
                elseif blockData.y == targetY then
                    monitor.setCursorPos(centerX+blockData.x,centerY+blockData.z)
                    monitor.setBackgroundColor(colors.lightGray)
                    monitor.write("X")
                elseif blockData.y == targetY-1 then
                    monitor.setCursorPos(centerX+blockData.x,centerY+blockData.z)
                    monitor.setBackgroundColor(colors.gray)
                    monitor.write("X")
                elseif blockData.y == targetY-2 then
                    monitor.setCursorPos(centerX+blockData.x,centerY+blockData.z)
                    monitor.setBackgroundColor(colors.black)
                    monitor.write("X")
                end
            end
            monitor.setBackgroundColor(colors.black)
        end
        sleep(5)
    end
end

parallel.waitForAll(display,control)