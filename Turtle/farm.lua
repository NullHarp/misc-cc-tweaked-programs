local x,z = ...

x = tonumber(x)-1
z = tonumber(z)

local function moveForward()
    local isBlock, data = turtle.inspectDown()
    turtle.suckUp()
    if isBlock then
        if data.name == "minecraft:wheat" then
            if data.state.age == 7 then
                turtle.digDown()
                for i = 1, 16 do
                    turtle.select(i)
                    local item_data = turtle.getItemDetail(i)
                    if type(item_data) ~= "nil" then
                        if item_data.name == "minecraft:wheat_seeds" then
                            turtle.placeDown()
                        end
                    end
                end
                turtle.select(1)
            end
        end
    end
    turtle.forward()
end

while true do
    for cZ = 1, z do
        for cX = 1, x do
            moveForward()
        end
        if cZ ~= z then
            if cZ % 2 == 1 then
                turtle.turnRight()
                moveForward()
                turtle.turnRight()
            else
                turtle.turnLeft()
                moveForward()
                turtle.turnLeft()
            end
        end
    end
    turtle.turnRight()
    for i = 1, z do
        turtle.forward()
    end
    turtle.turnLeft()
    for i = 1, 16 do
        turtle.select(i)
        turtle.drop()
    end
    turtle.turnRight()
    turtle.turnRight()
    sleep(60)
end