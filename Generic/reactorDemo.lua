local reactor = require("reactor")
local pid = require("PID")

local fuelBlocks = 8
local fuelIngots = fuelBlocks * 9
local fuelNuggets = fuelIngots * 9

local energyReserve = 1000000000

local injectionRate = 1000000
local extractionRate = 0

local targetShield = 35
local targetSaturation = 20

local injectionPid = pid.makePID(0.001,0.001,0.4,targetShield*1000000,0)
local extractionPid = pid.makePID(0.003,0.1,0.4,targetSaturation*10000000,0)

local isNetPositive = false

local speedMode = false

local time = os.clock()
local endTime = time

local tick = 0

local function printTemp(sLabel,temp)
    term.write(sLabel.." ")
    if temp > 10000 then
        term.setTextColor(colors.magenta)
    elseif temp > 8000 then
        term.setTextColor(colors.red)
    elseif temp > 6000 then
        term.setTextColor(colors.orange)
    elseif temp > 2000 then
        term.setTextColor(colors.yellow)
    elseif temp < 2000 and temp > 100 then
        term.setTextColor(colors.lightBlue)
    else
        term.setTextColor(colors.cyan)
    end
    print(tostring(temp).." *C")
    term.setTextColor(colors.white)
end

local function printState(sLabel,state)
    term.write(sLabel.." ")
    if state == "INVALID" then
        term.setTextColor(colors.gray)
    elseif state == "COLD" then
        term.setTextColor(colors.cyan)
    elseif state == "COOLING" then
        term.setTextColor(colors.lightBlue)
    elseif state == "WARMING_UP" then
        term.setTextColor(colors.yellow)
    elseif state == "RUNNING" then
        term.setTextColor(colors.white)
    elseif state == "STOPPING" then
        term.setTextColor(colors.lightGray)
    elseif state == "BEYOND_HOPE" then
        term.setTextColor(colors.magenta)
    end
    print(state)
    term.setTextColor(colors.white)
end

local function printBool(sLabel,bValue)
    term.write(sLabel.." ")
    if bValue then
        term.setTextColor(colors.green)
    else
        term.setTextColor(colors.red)
    end
    print(tostring(bValue))
    term.setTextColor(colors.white)
end

local function roundDecimal(num,place)
    place = place or 10
    return math.floor(num*place)/place
end

local function insertEnergy(energy)
    if energy > 0 then
        energyReserve = energyReserve + energy
        return energy
    else
        return 0
    end
end

local function extractEnergy(energy)
    if energy > 0 then
        if energyReserve - energy > 0 then
            energyReserve = energyReserve - energy
            return energy
        else
            local removed = energyReserve - energy + energy
            energyReserve = 0
            return removed
        end
    else
        return 0
    end
end

local function draw(data)
    term.clear()
    term.setCursorPos(1,1)
    printState("State:",reactor.getReactorState())
    print()
    printTemp("Temp:",math.floor(data.temperature))
    print()
    print("Sat:",tostring(roundDecimal(data.saturation/data.maxSaturation,100)*100).."%")
    print("Sat:",math.floor(data.saturation))
    --print("Max Sat:",math.floor(data.maxSaturation))
    print()
    print("Shield:",tostring(roundDecimal(data.shieldCharge/data.maxShieldCharge,100)*100).."%")
    print("Shield:",math.floor(data.shieldCharge))
    --print("Max Shield:",math.floor(data.maxShieldCharge))
    print()
    print("Field Input Rate:",math.floor(data.fieldInputRate))
    print("Generation Rate:",math.floor(data.generationRate))
    print("Injection Rate:",math.floor(injectionRate))
    print("Extraction Rate:",math.floor(extractionRate))
    print()
    printBool("Is Net Positive:",isNetPositive)
    print("Net Output:",math.floor(extractionRate-injectionRate))
    print()
    term.write("Total Energy: "..tostring(math.floor(energyReserve/1000000)).." MrF "..tostring(tick))
end

local data = reactor.getData()

reactor.setFuel(fuelNuggets * 16)
draw(data)
reactor.attemptInit()
draw(data)
reactor.chargeReactor()
draw(data)

sleep(1)

local safteyShutdown = false

while true do
    time = os.clock()
    reactor.updateCoreLogic()
    data = reactor.getData()
    reactor.injectEnergy(extractEnergy(injectionRate))
    insertEnergy(reactor.removeEnergy(extractionRate))
    if injectionRate > extractionRate then
        isNetPositive = false
    else
        isNetPositive = true
    end
    if reactor.canActivate() and not safteyShutdown then
        reactor.activateReactor()
        injectionRate = 500000
        extractionRate = 0
    end
    if reactor.getReactorState() == "RUNNING" or reactor.getReactorState() == "STOPPING" then
        -- Update PID inputs
        injectionPid.current = data.shieldCharge
        extractionPid.current = data.saturation
        
        -- Get PID outputs
        local resInj = pid.PID(injectionPid)
        local resExt = pid.PID(extractionPid)
    
        injectionRate = math.max(injectionRate + resInj, 0)
        if reactor.getReactorState() == "STOPPING" then
            extractionRate = 0
        else
            extractionRate = math.max(extractionRate - resExt, 0)
        end
    end
    if reactor.getReactorState() == "BEYOND_HOPE" then
        draw(data)
        error()
    end
    if data.temperature > 8500 then
        safteyShutdown = true
        reactor.shutdownReactor()
    end
    
    if speedMode then
        if time >= endTime then
            draw(data)
            sleep(0)
            endTime = time+0.5
        end
    else
        draw(data)
        sleep(0)
    end
    tick = tick + 1
end