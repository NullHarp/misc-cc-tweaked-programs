while true do
    if turtle.getItemCount() < 4 then
        for i = 1, 4 do
            if turtle.getItemCount(i) >= 4 then
                turtle.select(i)
                break
            end
        end
    end
    for i = 1, 4 do
        turtle.place()
        turtle.down()
    end
end
