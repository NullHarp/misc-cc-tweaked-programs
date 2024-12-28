while true do
    if turtle.getItemCount() < 16 then
        for i = 1, 16 do
            if turtle.getItemCount(i) >= 16 then
                turtle.select(i)
                break
            end
        end
    end
    for i = 1, 16 do
        turtle.placeUp()
        turtle.forward()
    end
    turtle.down()
    turtle.down()
    turtle.down()
    turtle.down()
    turtle.down()
    turtle.turnLeft()
    turtle.turnLeft()
end
