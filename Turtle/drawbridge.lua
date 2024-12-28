
local length = 6

local isOpen = false
while true do
    if redstone.getInput("back") and not isOpen then
        for i = 1, length do
            turtle.forward()
            turtle.placeUp()
        end
        for i = 1, length do
            turtle.back()
        end
        isOpen = true
    elseif isOpen and not redstone.getInput("back") then
        for i = 1, length do
            turtle.forward()
        end
        for i = 1, length do
            turtle.digUp()
            turtle.back()
        end
        isOpen = false
    end
    sleep(0)
end