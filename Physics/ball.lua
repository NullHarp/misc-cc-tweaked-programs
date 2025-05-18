local pos = {x=0,y=0}
local direction = {x=1,y=1}

local sizeX, sizeY = term.getSize()

while true do
    pos.x = pos.x + direction.x
    pos.y = pos.y + direction.y
    if pos.x > sizeX then
        pos.x = sizeX
    elseif pos.y < 0 then
        pos.y = 0
    end
    if pos.y > sizeY then
        pos.y = sizeY
    elseif pos.y < 0 then
        pos.y = 0
    end
    if pos.y == sizeY or pos.y == 0 then
        direction.y = -direction.y
    end
    if pos.x == sizeX or pos.x == 0 then
        direction.x = -direction.x
    end
    term.clear()
    term.setCursorPos(pos.x,pos.y)
    term.write("o")
    sleep(0.05)
end