local input_chest = peripheral.wrap("front")
local output_chest = peripheral.wrap("top")

while true do
    turtle.suck()
    local count = turtle.getItemCount(1)
    if count > 3 then
        turtle.transferTo(2,count/3)
        turtle.transferTo(3,count/3)
        turtle.select(16)
        turtle.craft(count/3)
        turtle.dropUp()
        turtle.select(1)
    end
end