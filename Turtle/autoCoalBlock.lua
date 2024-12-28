local source = peripheral.wrap("minecraft:chest_0")
local output = peripheral.wrap("minecraft:chest_0")

local local_name = "turtle_1"

while true do
    for i = 1, source.size() do
        local data = source.getItemDetail(i)
        if type(data) ~= "nil" then
            if data.name == "minecraft:coal" then
                source.pushItems(local_name,i)
                break
            end
        end
    end
    local count = turtle.getItemCount(1)
    if count >= 9 then
        for i = 1, 11 do
            if i ~= 4 and i ~= 8 then
                turtle.transferTo(i,count/9)
            end
        end
        turtle.select(16)
        turtle.craft(count/9)
        output.pullItems(local_name,16)
        turtle.dropUp()
        turtle.select(1)
    end
end