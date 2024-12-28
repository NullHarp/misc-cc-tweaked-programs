local table3D = {}

local direction = 0
local position = {x=0,y=0,z=0}

-- Function to set a value in the 3D table
local function set3D(x, y, z, value)
    table3D[x] = table3D[x] or {}
    table3D[x][y] = table3D[x][y] or {}
    table3D[x][y][z] = value
end

local function selectMaterial(material_name)
    for i = 1, 16 do
        local item_data = turtle.getItemDetail(i)
        if type(item_data) ~= "nil" then
            if item_data.name == material_name then
                turtle.select(i)
                return true
            end
        end
    end
    return false
end

---Gets a entry in the 3D position table
---@param x integer
---@param y integer
---@param z integer
---@return nil|string entry
local function get3D(x, y, z)
    return table3D[x] and table3D[x][y] and table3D[x][y][z] or nil
end

---Imports a metaverse formated json file into the table3D format
---@param file_name string
---@return table dimensions
---@return table materials_list
local function importScan(file_name)
    local offset = {x=0,y=0,z=0}
    local file = fs.open(file_name,"r")
    local file_data = file.readAll()
    file.close()
    local json_data = textutils.unserialiseJSON(file_data)

    local dimensions = {x=0,y=0,z=0}
    local materials_list = {}
    for i,block in pairs(json_data) do
        if block.block ~= "minecraft:air" then
            if offset.x > block.position.x then
                offset.x = block.position.x
            end
            if offset.y > block.position.y then
                offset.y = block.position.y
            end
            if offset.z > block.position.z then
                offset.z = block.position.z
            end
        end
    end
    for i,block in pairs(json_data) do
        if block.block ~= "minecraft:air" then
            if block.position.x - offset.x > dimensions.x then
                dimensions.x = block.position.x - offset.x
            end
            if block.position.y - offset.y > dimensions.y then
                dimensions.y = block.position.y - offset.y
            end
            if block.position.z - offset.z > dimensions.z then
                dimensions.z = block.position.z - offset.z
            end
            if type(materials_list[block.block]) == "nil" then
                materials_list[block.block] = 1
            else
                materials_list[block.block] = materials_list[block.block] + 1
            end
            set3D(block.position.x-offset.x,block.position.y-offset.y,block.position.z-offset.z,{name=block.block,orientation=block.orientation})  
        end

    end
    print(dimensions.x,dimensions.y,dimensions.z)
    return dimensions, materials_list
end

local function turnRight()
    direction = (direction+1)%4
    turtle.turnRight()
end

local function turnLeft()
    direction = (direction-1)%4
    turtle.turnLeft()
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
end

local function forward()
    if direction == 0 then
        position.x = position.x + 1
    elseif direction == 1 then
        position.z = position.z + 1
    elseif direction == 2 then
        position.x = position.x - 1
    elseif direction == 3 then
        position.z = position.z - 1
    end
    turtle.forward()
end

local function up()
    position.y = position.y + 1
    turtle.up()
end

local function newPath(dim,matts,awaitMaterials)
    for cY = 0, dim.y do
        if cY ~= dim.y then
            print("Layer: "..cY.."/"..dim.y)
        end
        for cZ = 0, dim.z do
            for cX = 0, dim.x do
                local entry = get3D(position.x,position.y,position.z)
                if type(entry) ~= "nil" then
                    local success = selectMaterial(entry.name)
                    if success then
                        local org_dir = direction
                        if entry.orientation == 0 then
                            turnToFace(1)
                        elseif entry.orientation == 22 then
                            turnToFace(2)
                        elseif entry.orientation == 10 then
                            turnToFace(3)
                        elseif entry.orientation == 16 then
                            turnToFace(0)
                        end
                        turtle.placeDown()
                        turnToFace(org_dir)
                    elseif awaitMaterials then
                        local response = ""
                        while not selectMaterial(entry.name) and response ~= "n" do
                            print("Please insert at least",matts[entry.name],entry.name," or type n to continue anyway.")
                            response = read()
                            selectMaterial(entry.name)
                        end
                        if response ~= "n" then
                            local org_dir = direction
                            if entry.orientation == 0 then
                                turnToFace(1)
                            elseif entry.orientation == 22 then
                                turnToFace(2)
                            elseif entry.orientation == 10 then
                                turnToFace(3)
                            elseif entry.orientation == 16 then
                                turnToFace(0)
                            end
                            turtle.placeDown()
                            turnToFace(org_dir)
                        end
                    end
                    matts[entry.name] = matts[entry.name] - 1
                end
                if cX ~= dim.x then
                    forward()
                end
            end
            if cZ ~= dim.z then
                if dim.z % 2 == 0 then
                    if cZ % 2 == 0 then
                        turnRight()
                        forward()
                        turnRight()
                    else
                        turnLeft()
                        forward()
                        turnLeft()
                    end
                else
                    if cY % 2 == 0 then
                        if cZ % 2 == 0 then
                            turnRight()
                            forward()
                            turnRight()
                        else
                            turnLeft()
                            forward()
                            turnLeft()
                        end
                    else
                        if cZ % 2 == 1 then
                            turnRight()
                            forward()
                            turnRight()
                        else
                            turnLeft()
                            forward()
                            turnLeft()
                        end
                    end
                end
            end
        end
        if cY ~= dim.y then
            up()
            turnLeft()
            turnLeft()
        end
    end
end

local file_name, awaitMaterials = ...

if type(file_name) == "nil" then
    error("Filename unspecified.")
end
if type(awaitMaterials) == "nil" then
    print("Await materials condition unspecified, defaulting to False.")
    awaitMaterials = false
else
    if awaitMaterials == "true" then
        awaitMaterials = true
    else
        awaitMaterials = false
    end
end

local dim, matts = importScan(file_name)

print("Required materials for construction:")
for i,v in pairs(matts) do
    textutils.pagedPrint(i.." | "..v)
end

print("Are you sure you have all the materials?")
local confirmation = read()
if string.lower(confirmation) == "y" then
    print("Starting Print...")
else
    error("Exited due to confirmation of not enough materials.")
end

newPath(dim,matts,awaitMaterials)