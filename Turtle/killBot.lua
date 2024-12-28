local turtUtil = require("turtUtil")
local util = require("util")
local version = "V0.1.4"

---Represents which direction the turtle is facing
---0 = SOUTH / PosZ
---1 = WEST / NegX
---2 = NORTH / NegZ
---3 = EAST / PosX
local direction = 0
local pos = {x=0,y=0,z=0}

local home = {x=123,y=52,z=45,direction=2}

local cursed_scanner = true

local scanner = peripheral.find("universal_scanner")
--local scanner = peripheral.find("geoScanner")
if type(scanner) == "nil" then
    error("Could not find Scanner")
end

local function main()
    while true do
        pos = turtUtil.getPos()
        direction = turtUtil.getDirection()
        if scanner.getCooldown("portableUniversalScan") == 0 then
            local data,error = scanner.scan("entity",8)
            if error ~= "scanBlocks is on cooldown" then
                local results = {}
                for index, value in ipairs(data) do
                    if value.name ~= "NullHarp" then
                        table.insert(results,value)
                    end
                end
                local smallest_distance = 100
                local smallest_distance_pos = {}
                for index, value in ipairs(results) do
                    local distance = math.sqrt(value.x^2 + value.y^2 + value.z^2)
                    if distance < smallest_distance then
                        smallest_distance = distance
                        smallest_distance_pos.x = value.x
                        smallest_distance_pos.y = value.y
                        smallest_distance_pos.z = value.z
                    end
                end
                if type(smallest_distance_pos.x) ~= "nil" then
                    turtUtil.goTo(turtUtil.standardizeLocalCoordinates(smallest_distance_pos))
                end
                if #results < 1 then
                    local randX = math.random(1,5)
                    for x = 1, randX do
                        turtUtil.dig()
                        turtUtil.forward()
                    end
                end
            end
        end
        sleep(0)
    end 
end

local function attack()
    while true do
        turtle.attack()
        sleep(0)
    end
end

parallel.waitForAll(main,attack)