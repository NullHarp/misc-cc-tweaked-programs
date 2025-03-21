local turtUtil = require("turtUtil")
local util = require("util")
local version = "V0.1.5"

---Represents which direction the turtle is facing
---0 = NORTH / NegZ
---1 = EAST / PosX
---2 = SOUTH / PosZ
---3 = WEST / NegX
local direction = 0
local pos = {x=0,y=0,z=0}

local home = {x=8424,y=63,z=10524,direction=2}

local universal = false
local useGps = false

local scanner = nil

if universal then
    scanner = peripheral.find("universal_scanner")
else
    scanner = peripheral.find("geoScanner")
end

if type(scanner) == "nil" then
    error("Could not find Scanner")
end

local junkItemFilter = {
    "minecraft:gravel",
    "minecraft:flint",
    "minecraft:coarse_dirt",
    "minecraft:dirt",
    "blockus:limestone",
    "blockus:bluestone",
    "minecraft:smooth_basalt"
}

local dig_blacklist = {
    ["computercraft:turtle_normal"] = "",
    ["computercraft:turtle_advanced"] = ""
}

turtUtil.setBlacklist(dig_blacklist)

local file = fs.open("jobs.json","r")
local file_data = file.readAll()
local jobs = textutils.unserialiseJSON(file_data)

local initialFuel = turtle.getFuelLevel()
if type(jobs[1].target) == "nil" then
    error("Target block not specified.",0)
end
if type(jobs[1].targetY) == "nil" then
    error("Target Y Level not specified.",0)
end

local function updateJobs()
    local file = fs.open("jobs.json","w")
    local jobs_json = textutils.serialiseJSON(jobs)
    file.write(util.prettyPrintJSON(jobs_json))
    file.close()
    print("Saved current job status to file.")
end

if not turtUtil.loadData() and useGps then
    print("No positional data found, recalibrating via GPS.")
    local failed_attempts = 0
    while not turtUtil.recalibrateOrientation() do
        failed_attempts = failed_attempts + 1
        print("Initial Recalibration Failed, Trying again in 5 Seconds!")
        turtUtil.recalibrateOrientation()
        sleep(5)
    end
    if failed_attempts > 0 then
        print("Successful recalibration after "..failed_attempts)
    end
elseif not useGps then
    print("No Positional data found, setting position via home pos.")
    turtUtil.setDirection(home.direction)
    turtUtil.setPos({x=home.x,y=home.y,z=home.z})
end

local function removeJunk()
    for i, item in pairs(junkItemFilter) do
        if turtUtil.selectItem(item) then
            turtle.drop()
        end
    end
end

util.title("Bari-Tony",version)
while #jobs > 0 do
    direction = turtUtil.getDirection()
    pos = turtUtil.getPos()
    
    if jobs[1].offsetPos.x ~= 0  and jobs[1].offsetPos.y ~= 0 and jobs[1].offsetPos.z ~= 0 and jobs[1].status ~= "in-progress" then
        print("Going to override coords.")
        pos = turtUtil.getPos()
        turtUtil.goTo({x=jobs[1].offsetPos.x-pos.x,y=jobs[1].offsetPos.y-pos.y,z=jobs[1].offsetPos.z-pos.z})
    elseif not turtUtil.fullInventory() and not turtUtil.lowFuel() and jobs[1].status == "queued" then
        pos = turtUtil.getPos()
        local randX = math.random(-40,40)
        if pos.y > jobs[1].targetY or pos.y < jobs[1].targetY then
            turtUtil.goTo({x=randX,y=jobs[1].targetY-pos.y,z=15})
        end
    end
    if jobs[1].status == "queued" then
        jobs[1].status = "in-progress"
        print("Updated current job status to "..jobs[1].status)
        updateJobs()
    end
    print("Starting job to mine "..jobs[1].target.." at Y-Level "..jobs[1].targetY.." at offset coords "..jobs[1].offsetPos.x.." "..jobs[1].offsetPos.y.." "..jobs[1].offsetPos.z)
    while not turtUtil.fullInventory() and not turtUtil.lowFuel() do
        removeJunk()
        pos = turtUtil.getPos()
        direction = turtUtil.getDirection()
        local cooldown = -1
        if universal then
            cooldown = scanner.getCooldown("portableUniversalScan")
        else
            cooldown = scanner.getOperationCooldown("scanBlocks")
        end
        if cooldown == 0 then
            local data, error = nil, nil
            if universal then
                data,error = scanner.scan("block",8)
            else
                data,error = scanner.scan(8)
            end
            if not error then
                local results = {}
                for index, value in ipairs(data) do
                    if value.name == jobs[1].target then
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
                    if universal then
                        turtUtil.goTo(turtUtil.standardizeLocalCoordinates(smallest_distance_pos))
                    else
                        turtUtil.goTo(smallest_distance_pos)
                    end
                end
                if #results < 1 then
                    if pos.y > jobs[1].targetY or pos.y < jobs[1].targetY then
                        turtUtil.goTo({x=0,y=jobs[1].targetY-pos.y,z=0})
                    end
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
    pos = turtUtil.getPos()
    print("Current Pos",pos.x,pos.y,pos.z)
    print("Home Pos: "..home.x.." "..home.y.." "..home.z)
    jobs[1].status = "complete"
    updateJobs()
    pos = turtUtil.getPos()
    while pos.x ~= home.x or pos.y ~= home.y or pos.z ~= home.z do
        pos = turtUtil.getPos()
        local offset = {}
        offset.x = home.x - pos.x
        offset.y = home.y - pos.y
        offset.z = home.z - pos.z
        turtUtil.goTo(offset)
    end
    turtUtil.turnToFace(home.direction)
    turtUtil.up()
    turtUtil.up()
    print("Depositing aquired materials.")
    turtUtil.dropoff()
    turtUtil.down()
    turtUtil.down()
    local finalFuel = turtle.getFuelLevel()
    print("Job to mine "..jobs[1].target.." complete.")
    local usedFuel = initialFuel-finalFuel
    print("Used "..tostring(usedFuel).." fuel ("..tostring(math.ceil(usedFuel/88.8888888889)).." pieces of coal")   
    table.remove(jobs,1)
    updateJobs()
end
print("All Jobs complete, shutting down program!")