local reactor = peripheral.find("draconic_reactor")

---Name of the flow gate that injects energy into the reactor
local flow_gate_intake = peripheral.wrap("flow_gate_0")
---Name of the flow gate the removes energy from the reactor
local flow_gate_outlet = peripheral.wrap("flow_gate_1")
local pid = require("PID")

local data = reactor.getReactorInfo()

local injectionRate = 1000000
local extractionRate = 1000000

local targetShield = 40
local targetSaturation = 20
local targetTemperature = 7500

local injectionPid = pid.makePID(0.001,0.01,0.05,targetShield*1000000,0)
local extractionPid = pid.makePID(0.003,0.1,0.05,targetSaturation*10000000,0)
local temperaturePid = pid.makePID(0.006,0.1,0.05,targetTemperature,20)

local isNetPositive = false

local safteyShutdown = false

flow_gate_intake.setOverrideEnabled(true)
flow_gate_outlet.setOverrideEnabled(true)

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

local function draw(data)
    term.clear()
    term.setCursorPos(1,1)
    local rFuel, cFuel = data.maxFuelConversion - data.fuelConversion, data.fuelConversion
    printState("State:",string.upper(data.status))
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
end

while true do
    data = reactor.getReactorInfo()
    flow_gate_intake.setFlowOverride(injectionRate)
    flow_gate_outlet.setFlowOverride(extractionRate)
    if injectionRate > extractionRate then
        isNetPositive = false
    else
        isNetPositive = true
    end
    if data.status == "running" or data.status == "stopping" then
        -- Update PID inputs
        injectionPid.current = data.fieldStrength
        extractionPid.current = data.energySaturation
        temperaturePid.current = data.temperature
        -- Get PID outputs
        local resInj = pid.PID(injectionPid)
        local resExt = pid.PID(extractionPid)
        local resSat = pid.PID(temperaturePid)

        extractionPid.target = math.min(math.max(extractionPid.target - resSat*100, 10*10000000), 96*10000000)
        
        if roundDecimal(data.energySaturation/data.maxEnergySaturation,100)*100 <= 98 then
            injectionRate = math.max(injectionRate + resInj, 0)
        end
        if data.status == "stopping" then
            extractionRate = 0
        else
            if roundDecimal(data.energySaturation/data.maxEnergySaturation,100)*100 <= 98 then
                extractionRate = math.max(extractionRate - resExt, 0)
            end
        end
    elseif data.status == "beyond_hope" then
        draw(data)
        error("You might want to run now!")
    end
    local rFuel, cFuel = data.maxFuelConversion - data.fuelConversion, data.fuelConversion
    local tFuel = data.maxFuelConversion
    local convLVL = ((cFuel / tFuel) * 1.3) - 0.3

    if convLVL > 0.95 and not safteyShutdown then
        safteyShutdown = true
        reactor.shutdownReactor()
    elseif safteyShutdown and data.status == "cold" then
        draw(data)
        error("Saftey shutdown complete, exiting.")
    end
    draw(data)
    sleep(0)
end