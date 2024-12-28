---Represents which direction the turtle is facing
---0 = NORTH / NegZ
---1 = WEST / NegX
---2 = SOUTH / PosZ
---3 = EAST / PosX
local direction = 0
local pos = {x=0,y=0,z=0}

local dig_blacklist = {}

local function standardizeLocalCoordinates(offset)
    local standardX, standardY, standardZ

    if direction == 1 then -- East
        standardX = offset.x
        standardY = offset.y
        standardZ = offset.z
    elseif direction == 2 then -- South
        standardX = -offset.z
        standardY = offset.y
        standardZ = offset.x
    elseif direction == 3 then -- West
        standardX = -offset.x
        standardY = offset.y
        standardZ = -offset.z
    elseif direction == 0 then -- North
        standardX = offset.z
        standardY = offset.y
        standardZ = -offset.x
    else
        error("Invalid facing direction")
    end

    return {x=standardX, y=standardY, z=standardZ}
end

---Saves the currently loaded position and direction
local function saveData()
    local data = {
        direction = direction,
        pos = pos
    }
    local data_json = textutils.serialiseJSON(data)
    local file = fs.open(".turtUtil/info.json","w")
    file.write(data_json)
    file.close()
end

---Loads the currently stored position and direction
---@return boolean success
local function loadData()
    if fs.exists(".turtUtil/info.json") then
        local file = fs.open(".turtUtil/info.json","r")
        local data_json = file.readAll()
        local data = textutils.unserialiseJSON(data_json)
        direction = data.direction
        pos = data.pos
        return true
    else
        return false
    end
end

---Sets the current position
---@param position table
local function setPos(position)
    pos = position
    saveData()
end

---Sets the current direction
---@param dir integer
local function setDirection(dir)
    direction = dir
    saveData()
end

---Sets the digging blacklist filter
---@param blacklist any
local function setBlacklist(blacklist)
    dig_blacklist = blacklist
end

---Returns the current position
---@return table currentPosition
local function getPos()
    return pos
end

---Returns the current direction being faced
---@return integer currentDirection
local function getDirection()
    return direction
end

---Digs in front of the turtle
local function dig()
    local isBlock,block = turtle.inspect()
    if isBlock then
        if type(dig_blacklist[block.name]) == "nil" then
            turtle.dig()
        end
    end
end

---Digs above the turtle
local function digUp()
    local isBlock,block = turtle.inspectUp()
    if isBlock then
        if type(dig_blacklist[block.name]) == "nil" then
            turtle.digUp()
        end
    end
end

---Digs below the turtle
local function digDown()
    local isBlock,block = turtle.inspectDown()
    if isBlock then
        if type(dig_blacklist[block.name]) == "nil" then
            turtle.digDown()
        end
    end
end

---Turns the turtle left
local function turnLeft()
    if turtle.turnLeft() then
        direction = (direction - 1) % 4
        saveData()
        dig()
        return true
    end
    return false
end

---Turns the turtle right
---@return boolean success
local function turnRight()
    if turtle.turnRight() then
        direction = (direction + 1) % 4
        saveData()
        dig()
        return true
    end
    return false
end

---Turns the turtle to face a specific direction
---@param dir integer
local function turnToFace(dir)
    local dirOffset = (dir - direction) % 4
    if dirOffset == 0 then
        return -- Already facing the desired direction
    end

    if dirOffset == 1 or dirOffset == -3 then
        turnRight() -- Turn right 90 degrees
    elseif dirOffset == 3 or dirOffset == -1 then
        turnLeft() -- Turn left 90 degrees
    elseif dirOffset == 2 then
        turnRight()
        turnRight() -- Turn around (180 degrees)
    end

    direction = dir%4
    saveData()
end

---Moves the turtle upwards
---@return boolean success
local function up()
    if turtle.up() then
        pos.y = pos.y + 1
        saveData()
        return true
    end
    return false
end

---Moves the turtle downwards
---@return boolean success Did the movement succeed
local function down()
    if turtle.down() then
        pos.y = pos.y - 1
        saveData()
        return true
    end
    return false
end

---Moves the turtle forwards
---@return boolean success Did the movement succeed
local function forward()
    local isBlock,block = turtle.inspect()
    if isBlock then
        if block.name == "minecraft:gravel" or block.name == "minecraft:sand" then
            while block.name == "minecraft:gravel" or block.name == "minecraft:sand" do
                isBlock,block = turtle.inspect()
                dig()
            end
        elseif block.name == "minecraft:bedrock" then
            digUp()
            up()
        end
    end
    if turtle.forward() then
        if direction == 0 then
            pos.z = pos.z - 1
        elseif direction == 1 then
            pos.x = pos.x + 1
        elseif direction == 2 then
            pos.z = pos.z + 1
        elseif direction == 3 then
            pos.x = pos.x - 1
        end
        saveData()
        return true
    end
    return false
end

---Moves the turtle backwards
---@return boolean success Did the movement succeed
local function back()
    if turtle.back() then
        if direction == 0 then
            pos.z = pos.z + 1
        elseif direction == 1 then
            pos.x = pos.x - 1
        elseif direction == 2 then
            pos.z = pos.z - 1
        elseif direction == 3 then
            pos.x = pos.x + 1
        end
        saveData()
        return true
    end
    return false
end

---Goes to the specified locate coordinate position
---@param position table A table representing the local x y and z target position
local function goTo(position)
    if position.x < 0 then
        turnToFace(3)
    elseif position.x > 0 then
        turnToFace(1)
    end
    if position.x ~= 0 then
        for cX = 1, math.abs(position.x) do
            dig()
            forward()
        end
    end
    if position.y < 0 then
        for cY = 1, math.abs(position.y) do
            digDown()
            down()
        end
    elseif position.y > 0 then
        for cY = 1, math.abs(position.y) do
            digUp()
            up()
        end
    end
    if position.z < 0 then
        turnToFace(0)
    elseif position.z > 0 then
        turnToFace(2)
    end
    if position.z ~= 0 then
        for cZ = 1, math.abs(position.z) do
            dig()
            forward()
        end
    end
end

---Swap the left peripheral for a new one in the inventory
---@param new_upgrade string Item name of the new peripheral
local function swapLeft(new_upgrade)
    for i = 1, 16 do
        local item_data = turtle.getItemDetail(i)
        if type(item_data) ~= "nil" then
            if item_data.name == new_upgrade then
                turtle.select(i)
                turtle.equipLeft()
                return
            end
        end
    end
    turtle.select(1)
end

---Does the turtle have all slots full of at least one item.
---@return boolean isFull Is the Inventory currently full or not
local function fullInventory()
    for i = 1, 16 do
        local num = turtle.getItemCount(i)
        if num == 0 then
            return false
        end
    end
    return true
end

---Does the turtle have less than 10% maximum fuel
---@return boolean isLowFuel Do we have less than 10% maximum fuel
local function lowFuel()
    return turtle.getFuelLevel() < (turtle.getFuelLimit()*0.1)
end

---Deposits the turtles inventory into the chest in-front of it
local function dropoff()
    for i = 1, 16 do
        local item_data = turtle.getItemDetail(i)
        if type(item_data) ~= "nil" then
            if item_data.name ~= "computercraft:wireless_modem_advanced" then
                turtle.select(i)
                turtle.drop()
            end
        end
    end
    turtle.select(1)
end

---Figures out turtles current facing and recalibrates it so that North is direction 0
---@return boolean sucess Did the action succeed
local function recalibrateOrientation()
    swapLeft("computercraft:wireless_modem_advanced")
    local posX, posY, posZ = gps.locate()
    dig()
    forward()
    local posX2, posY2, posZ2 = gps.locate()
    back()
    local offset = {}
    if type(posX) ~= "nil" and type(posX2) ~= "nil" then
        offset.x = posX2 - posX
        offset.y = posY2 - posY
        offset.z = posZ2 - posZ
        if offset.x == 1 then
            turnLeft()
        elseif offset.x == -1 then
            turnRight()
        elseif offset.z == 1 then
            turnLeft()
            turnLeft()
        end
        direction = 0
        swapLeft("minecraft:diamond_pickaxe")
        pos.x = posX
        pos.y = posY
        pos.z = posZ
        saveData()
        return true
    else
        return false
    end
end

---Finds a specific item in the turtles inventory
---@param item_name string The name of the item
---@return boolean success Did we select the item we were searching for
local function selectItem(item_name)
    for i = 1, 16 do
        local item_data = turtle.getItemDetail(i)
        if type(item_data) ~= "nil" then
            if item_data.name == item_name then
                turtle.select(i)
                return true
            end
        end
    end
    return false
end

return {
    saveData = saveData,
    loadData = loadData,
    setBlacklist = setBlacklist,
    setDirection = setDirection,
    setPos = setPos,
    getDirection = getDirection,
    getPos = getPos,
    dig = dig,
    digUp = digUp,
    digDown = digDown,
    turnLeft = turnLeft,
    turnRight = turnRight,
    turnToFace = turnToFace,
    down = down,
    up = up,
    forward = forward,
    back = back,
    swapLeft = swapLeft,
    recalibrateOrientation = recalibrateOrientation,
    lowFuel = lowFuel,
    dropoff = dropoff,
    fullInventory = fullInventory,
    goTo = goTo,
    selectItem = selectItem,
    standardizeLocalCoordinates = standardizeLocalCoordinates
}