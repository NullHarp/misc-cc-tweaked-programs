local x = 4
local z = 4
for cZ = 1, z do
    for cX = 1, x-1 do
        turtle.forward()
        turtle.forward()
        turtle.forward()
        turtle.forward()
        turtle.digDown()
    end
    if cZ ~= z then
        if cZ % 2 == 1 then
            turtle.turnRight()
            turtle.forward()
            turtle.forward()
            turtle.forward()
            turtle.forward()
            turtle.digDown()
            turtle.turnRight()
        else
            turtle.turnLeft()
            turtle.forward()
            turtle.forward()
            turtle.forward()
            turtle.forward()
            turtle.digDown()
            turtle.turnLeft()
        end
    end
end