
local height = 4
height = height-1
local isOpen = false
while true do
    if redstone.getInput("back") and not isOpen then
        for i = 1, height do
            turtle.digUp()
            turtle.up()
        end
        turtle.digUp()
        for i = 1, height do
            turtle.down()
        end
        isOpen = true
    elseif isOpen and not redstone.getInput("back") then
        for i = 1, height do
            turtle.up()
        end
        for i = 1, height do
            turtle.placeUp()
            turtle.down()
        end
        turtle.placeUp()
        isOpen = false
    end
    sleep(0)
end