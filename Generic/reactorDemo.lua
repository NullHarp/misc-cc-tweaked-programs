local reactor = require("reactor")

local flow_gate_intake = reactor.intake
local flow_gate_outlet = reactor.outlet
local pid = require("PID")

local fuelBlocks = 8
local fuelIngots = fuelBlocks * 9
local fuelNuggets = fuelIngots * 9

local energyReserve = 1000000000

local injectionRate = 1000000
local extractionRate = 0

local targetShield = 60
local targetSaturation = 20
local targetTemperature = 7000

local injectionPid = pid.makePID(0.001,0.01,0.05,targetShield*1000000,0)
local extractionPid = pid.makePID(0.003,0.1,0.05,targetSaturation*10000000,0)
local temperaturePid = pid.makePID(0.006,0.1,0.05,targetTemperature,20)

local isNetPositive = false

local speedMode = true

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
    local rFuel, cFuel = data.maxFuelConversion - data.fuelConversion, data.fuelConversion
    printState("State:",data.status)
    print(((cFuel / (cFuel+rFuel)) * 1.3) - 0.3)
    printTemp("Temp:",math.floor(data.temperature))
    print()
    print("Sat:",tostring(roundDecimal(data.energySaturation/data.maxEnergySaturation,100)*100).."%")
    print("Sat:",math.floor(data.energySaturation))
    --print("Max Sat:",math.floor(data.maxEnergySaturation))
    print()
    print("Shield:",tostring(roundDecimal(data.fieldStrength/data.maxFieldStrength,100)*100).."%")
    print("Shield:",math.floor(data.fieldStrength))
    --print("Max Shield:",math.floor(data.maxFieldStrength))
    print()
    print("Field Input Rate:",math.floor(data.fieldDrainRate))
    print("Generation Rate:",math.floor(data.generationRate))
    print("Injection Rate:",math.floor(injectionRate))
    print("Extraction Rate:",math.floor(extractionRate))
    print()
    printBool("Is Net Positive:",isNetPositive)
    print("Net Output:",math.floor(extractionRate-injectionRate))
    print(tostring(math.floor(tick/20/60/60*100)/100).." hours")
    term.write("Total Energy: "..tostring(math.floor(energyReserve/1000000)).." MrF ")
end

local data = reactor.getReactorInfo()

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
    data = reactor.getReactorInfo()
    data.status = string.upper(data.status)
    flow_gate_intake.setFlowOverride(injectionRate)
    extractEnergy(injectionRate)
    flow_gate_outlet.setFlowOverride(extractionRate)
    insertEnergy(extractionRate)
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
    if data.status == "RUNNING" or data.status == "STOPPING" then
        -- Update PID inputs
        injectionPid.current = data.fieldStrength
        extractionPid.current = data.energySaturation
        temperaturePid.current = data.temperature
        -- Get PID outputs
        local resInj = pid.PID(injectionPid)
        local resExt = pid.PID(extractionPid)
        local resSat = pid.PID(temperaturePid)

        extractionPid.target = math.min(math.max(extractionPid.target - resSat*100, 10*10000000), 96*10000000)
    
        injectionRate = math.max(injectionRate + resInj, 0)
        if data.status == "STOPPING" then
            extractionRate = 0
        else
            extractionRate = math.max(extractionRate - resExt, 0)
        end
    end
    if data.status == "BEYOND_HOPE" then
        draw(data)
        error()
    end
    local rFuel, cFuel = data.maxFuelConversion - data.fuelConversion, data.fuelConversion
    local tFuel = data.maxFuelConversion
    local convLVL = ((cFuel / tFuel) * 1.3) - 0.3

    if convLVL > 0.95 then
        safteyShutdown = true
        reactor.shutdownReactor()
    end

    if safteyShutdown and data.status == "COLD" then
        draw(data)
        error()
    end
    
    if speedMode then
        if time >= endTime then
            draw(data)
            sleep(0)
            endTime = time+2
        end
    else
        draw(data)
        sleep(0)
    end
    tick = tick + 1
end