---The current state of the reactor
---Can be INVALID, COLD, COOLING, WARMING_UP, RUNNING, STOPPING, and BEYOND_HOPE
local reactorState = "INVALID"

---Has the startup initalization been completed
local startupInit = false
---Is fail-safe mode enabled
local failSafeMode = false

---How much fuel can be reacted to in the reactor
local reactableFuel = 0.0
---How much fuel has already been used
local convertedFuel = 0.0

---Current saturation of the core
local saturation = 0.0
---The maximum saturation of the core (computed live)
local maxSaturation = 0.0

---Current charge of the shield
local shieldCharge = 0.0
---The maximum charge of the shield (computed live)
local maxShieldCharge = 0.0

---The temperature of the reactor
local temperature = 20.0
---The maximum temperature of the reactor
local MAX_TEMPERATURE = 10000

---The amount of energy currently being generated
local generationRate = 0.0

local tempDrainFactor = 0.0

local fieldDrain = 0.0
---Amount of energy required to maintain the current field strength
local fieldInputRate = 0.0

---Rate at which fuel is being consumed
local fuelUseRate = 0.0


--Initializes the reactor if it is not
local function initStartup()
    if not startupInit then
        local totalFuel = reactableFuel + convertedFuel
        maxShieldCharge = (totalFuel * 96.45061728395062 * 100)
        maxSaturation = ((totalFuel * 96.45061728395062 * 1000))
        if saturation > maxSaturation then
            saturation = maxSaturation
        end
        
        if shieldCharge > maxShieldCharge then
            shieldCharge = maxShieldCharge
        end
        startupInit = true
        print("Reactor: Startup Init COMPLETE")
    end
end

---Can the reactor begin charging the shield and sat
---@return boolean
local function canCharge()
    if reactorState ==  "BEYOND_HOPE" then
        return false
    end
    return (reactorState == "COLD" or reactorState == "COOLING") and reactableFuel + convertedFuel >= 144
end

---Can the reactor begin full activation after charging
---@return boolean
local function canActivate()
    if reactorState == "BEYOND_HOPE" then
        return false
    end
    return (reactorState == "WARMING_UP" or reactorState == "STOPPING") and temperature >= 2000 and ((saturation >= maxSaturation/2 and shieldCharge >= maxShieldCharge / 2) or reactorState == "STOPPING")
end

---Can the reactor currently be stopped from its current operation
---@return boolean
local function canStop()
    if reactorState == "BEYOND_HOPE" then
        return false
    end
    return reactorState == "RUNNING" or reactorState == "WARMING_UP" 
end

---Begin charging the reactor
local function chargeReactor()
    if canCharge() then
        reactorState = "WARMING_UP"
    end
end

---Begin primary activation of reactor
local function activateReactor()
    if canActivate() then
        reactorState = "RUNNING"
    end
end

---Begin shutdown of primary operation of reactor
local function shutdownReactor()
    if canStop() then
        reactorState = "STOPPING"
    end
end

---Toggle fail-safe mode
local function toggleFailSafe()
    failSafeMode = not failSafeMode
end

---Update the offline state of the reactor
local function updateOfflineState()
    local distribution = math.random(1,10)/10
    if temperature > 20 then
        temperature = temperature - 0.5
    end
    if shieldCharge > 0 then
        shieldCharge = shieldCharge - (maxShieldCharge * 0.0005 * distribution)
    elseif shieldCharge < 0 then
        shieldCharge = 0
    end
    if saturation > 0 then
        saturation = shieldCharge - (maxSaturation * 0.000002 * distribution)
    elseif saturation < 0 then
        saturation = 0
    end
end

---Update the online state of the reactor
local function updateOnlineState()
    ---How saturated the core is with energy
    local coreSat = saturation / maxSaturation
    ---Inverse of the core saturation
    local negCSat = (1 - coreSat) * 99
    local temp50 = math.min((temperature / MAX_TEMPERATURE)* 50, 99)
    ---Combination of reactable fuel and converted fuel to get the total
    local tFuel = convertedFuel + reactableFuel
    ---What level of fuel conversion are we on
    local convLVL = ((convertedFuel / tFuel) * 1.3) - 0.3

    ---I forgor what this is
    local tempOffset = 444.7

    ---Caclulates the exponential temperature rise
    local tempRiseExpo = (negCSat^3) / (100 - negCSat) + tempOffset

    ---Calculates the resistance that naturally occurs with higher temp
    local tempRiseResist = (temp50^4) / (100 - temp50)

    ---Caclulates the rise of the temperature based off the resistance, conversion level, and exponential temperature rise
    local riseAmount = (tempRiseExpo - (tempRiseResist * (1.0 - convLVL)) + convLVL * 1000) / 10000

    if reactorState == "STOPPING" and convLVL < 1 then
        if temperature <= 2001 then
            reactorState = "COOLING"
            startupInit = false;
            return;
        end
        if saturation >= maxSaturation * 0.99 and reactableFuel > 0 then
            temperature = temperature - 1.0 - convLVL;
        else
            temperature = temperature + riseAmount * 10;
        end
    else
        temperature = temperature + riseAmount * 10;
    end

    ---The base of the maximum RF/t
    local baseMaxRFt = math.floor((maxSaturation / 1000.0) * 1.5 * 10)
    ---The maximum rft based off the base of the maximum and the current conversion level
    local maxRFt = math.floor((baseMaxRFt * (1.0 + (convLVL * 2))))
    ---How much energy is actually being generated
    generationRate = (1.0 - coreSat) * maxRFt
    ---Raises the saturation by the generation rate, since saturation is like a "energy buffer"
    saturation = saturation + generationRate

    tempDrainFactor = 
        (temperature > 8000) and (1 + ((temperature - 8000) * (temperature - 8000) * 0.0000025)) or
        (temperature > 2000) and 1 or
        (temperature > 1000) and ((temperature - 1000) / 1000) or
        0    fieldDrain = math.floor(math.min(tempDrainFactor * math.max(0.01, (1.0 - coreSat)) * (baseMaxRFt / 10.923556), 900719925474099))

    local fieldNegPercent = 1.0 - (shieldCharge / maxShieldCharge)
    ---Amount of energy required to be injected to maintain current field strength
    fieldInputRate = fieldDrain / fieldNegPercent
    ---Current charge of the shield
    shieldCharge = shieldCharge - math.min(fieldDrain, shieldCharge)

    ---The current rate of fuel consumption based off the temperature drain factor and the core saturation
    fuelUseRate = tempDrainFactor * (1.0 - coreSat) * (0.001 * 5)
    if reactableFuel > 0 then
        convertedFuel = convertedFuel + fuelUseRate;
        reactableFuel = reactableFuel - fuelUseRate;
    end

    ---Should the reactor trigger a full system meltdown
    if (shieldCharge <= 0) and temperature > 2000 and reactorState ~= "BEYOND_HOPE" then
        reactorState = "BEYOND_HOPE"
    end
end

---Simulates a tick of reactor operations
local function updateCoreLogic()
    local sat
    if reactorState == "INVALID" then
        updateOfflineState()
    elseif reactorState == "COLD" then
        updateOfflineState()
    elseif reactorState == "WARMING_UP" then
        initStartup()
    elseif reactorState == "RUNNING" then
        updateOnlineState()
        
        if failSafeMode and temperature < 2500 and saturation / maxSaturation >= 0.99 then
            shutdownReactor()
        end
    elseif reactorState == "STOPPING" then
        updateOnlineState()
        
        if temperature <= 2000 then
            reactorState = "COOLING"
        end
    elseif reactorState == "COOLING" then
        updateOfflineState()
        
        if temperature <= 100 then
            reactorState = "COLD"
        end
    end
end

---Attempts to initialize the reactor structure
local function attemptInit()
    if reactorState == "INVALID" then
        if temperature <= 100 then
            reactorState = "COLD"
        else
            reactorState = "COOLING"
        end
    end
end

---Injects energy into the reactor core
---@param energy integer How much energy
---@return integer successful_injection_amount
local function injectEnergy(energy)
    local received = 0
    if reactorState == "WARMING_UP" then
        ---The reactor has not initialized yet so we can't inject energy
        if not startupInit then
            return 0
        end
        if shieldCharge < maxShieldCharge/2 then
            received = math.min(energy, (maxShieldCharge/2) - shieldCharge + 1)
            shieldCharge = shieldCharge + received
            if shieldCharge > maxShieldCharge / 2 then
                shieldCharge = maxShieldCharge / 2
            end
        elseif saturation < maxSaturation/2 then
            received = math.min(energy, (maxSaturation / 2) - saturation)
            saturation = saturation + received
        elseif temperature < 2000 then
            received = energy
            temperature = temperature + received / 1000.0 + (reactableFuel  * 10)
            if temperature > 2500 then
                temperature = 2500
            end
        end
    elseif reactorState == "RUNNING" then
        local tempFactor = 1
    
        if temperature > 15000 then
            tempFactor = 1 - math.min(1, (temperature - 15000) / 10000)
        end
        shieldCharge = shieldCharge + math.min((energy * (1 - (shieldCharge / maxShieldCharge))), maxShieldCharge - shieldCharge) * tempFactor
        if shieldCharge > maxShieldCharge then
            shieldCharge = maxShieldCharge
        end
        
        return energy
    end
    return received
end

---Extracts energy from the reactor core
---@param energy integer How much energy
---@return number successful_extraction_amount
local function removeEnergy(energy)
    if reactorState == "RUNNING" or reactorState == "STOPPING" then
        if saturation - energy > 0 then
            saturation = saturation - energy
            return energy
        else
            return 0
        end
    else
        return 0
    end
end

---Gets reactor info
---@return table data Data associated with the reactor, such as sat and shield
local function getReactorInfo()
    local data = {
        temperature = temperature,
        fieldStrength = shieldCharge,
        maxFieldStrength = maxShieldCharge,
        energySaturation = saturation,
        maxEnergySaturation = maxSaturation,
        fuelConversion = convertedFuel,
        maxFuelConversion = reactableFuel+convertedFuel,
        generationRate = generationRate,
        fieldDrainRate = fieldInputRate,
        fuelConversionRate = fuelUseRate,
        status = reactorState
    }
    return data
end

---Sets the amount of reactable fuel
local function setFuel(fuel)
    reactableFuel = fuel
end

local intake = {}
local outlet = {}

function intake.setOverrideEnabled(state)
    ---Filler function to keep parity with normal reactor
end

function intake.setFlowOverride(integer)
    injectEnergy(integer)
end

function outlet.setOverrideEnabled(state)
    ---Filler function to keep parity with normal reactor
end

function outlet.setFlowOverride(integer)
    removeEnergy(integer)
end

return {
    intake = intake,
    outlet = outlet,
    setFuel = setFuel,
    attemptInit = attemptInit,
    canActivate = canActivate,
    canCharge = canCharge,
    canStop = canStop,
    activateReactor = activateReactor,
    chargeReactor = chargeReactor,
    shutdownReactor = shutdownReactor,
    updateCoreLogic = updateCoreLogic,
    getReactorInfo = getReactorInfo,
}