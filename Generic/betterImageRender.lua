local image_name, compressed = ...
compressed = compressed or false
local image = paintutils.loadImage(image_name..".nfp")

local monitor = require("connectedMonitor")
if not monitor.loadRows("virtual_monitor") then
    local rows = {
        {"monitor_101","monitor_102","monitor_103","monitor_104","monitor_105","monitor_106","monitor_107","monitor_108","monitor_109","monitor_110","monitor_111"},
        {"monitor_90","monitor_91","monitor_92","monitor_93","monitor_94","monitor_95","monitor_96","monitor_97","monitor_98","monitor_99","monitor_100"},
        {"monitor_6","monitor_7", "monitor_36", "monitor_37", "monitor_38", "monitor_39", "monitor_40", "monitor_41", "monitor_42", "monitor_43", "monitor_44"},
        {"monitor_8","monitor_9", "monitor_45", "monitor_46", "monitor_47", "monitor_48", "monitor_49", "monitor_50", "monitor_51", "monitor_52", "monitor_53"},
        {"monitor_10","monitor_11", "monitor_54", "monitor_55", "monitor_56", "monitor_57", "monitor_58", "monitor_59", "monitor_60", "monitor_61", "monitor_62"},
        {"monitor_12","monitor_13", "monitor_63", "monitor_64", "monitor_65", "monitor_66", "monitor_67", "monitor_68", "monitor_69", "monitor_70", "monitor_71"},
        {"monitor_14","monitor_15", "monitor_72", "monitor_73", "monitor_74", "monitor_75", "monitor_76", "monitor_77", "monitor_78", "monitor_79", "monitor_80"},
        {"monitor_16","monitor_17", "monitor_81", "monitor_82", "monitor_83", "monitor_84", "monitor_85", "monitor_86", "monitor_87", "monitor_88", "monitor_89"}
    }
    monitor.setRows(rows)
    monitor.saveRows("virtual_monitor")
end

monitor.setTextScale(1)
monitor.setBackgroundColor(colors.black)
monitor.setTextColor(colors.white)
monitor.setTextScale(0.5)
monitor.clear()
monitor.setCursorPos(1,1)

local startTime = os.clock()
local pauseTime = startTime+5

local yCount = 1

if compressed then
    for i = 1, #image, 2 do
        local rowPixels = ""
        local rowTextColor = ""
        local rowBgColor = ""
        monitor.setCursorPos(1,yCount)
        for colIndex, pixel in pairs(image[i]) do
            startTime = os.clock()
            if pixel == 0 then
                break
            end
            if type(image[i+1]) == "nil" then
                --monitor.blit("\135",colors.toBlit(pixel),colors.toBlit(colors.black))
                rowPixels = rowPixels.."\135"
                rowTextColor = rowTextColor..colors.toBlit(pixel)
                rowBgColor = rowBgColor..colors.toBlit(colors.black)
            else
                --monitor.blit("\135",colors.toBlit(pixel),colors.toBlit(image[i+1][colIndex]))
                rowPixels = rowPixels.."\135"
                rowTextColor = rowTextColor..colors.toBlit(pixel)
                rowBgColor = rowBgColor..colors.toBlit(image[i+1][colIndex])
            end
            if startTime >= pauseTime then
                sleep(0)
                pauseTime = startTime+5
            end
        end
        monitor.blit(rowPixels,rowTextColor,rowBgColor)
        yCount = yCount + 1
    end
else
    for rowIndex, row in pairs(image) do
        local rowPixels = ""
        local rowTextColor = ""
        for colIndex, pixel in pairs(row) do
            startTime = os.clock()
            monitor.setCursorPos(colIndex,rowIndex)
            if pixel == 0 then
                break
            end
            monitor.blit("X",colors.toBlit(pixel),colors.toBlit(pixel))
            if startTime >= pauseTime then
                sleep(0)
                pauseTime = startTime+5
            end
        end
    end
end
