local doors = {
    "redstoneIntegrator_0"
}

local lockdown = {enabled=false}

function lockdown.initPeripherals()
    lockdown.peripherals = {}
    for _, v in pairs(doors) do
        lockdown.peripherals[v] = peripheral.wrap(v)
    end
end

function lockdown.activate()
    lockdown.enabled = true
    for _, door in pairs(lockdown.peripherals) do
        door.setOutput("front",true)
    end
end

function lockdown.deactivate()
    lockdown.enabled = false
    for _, door in pairs(lockdown.peripherals) do
        door.setOutput("front",false)
    end
end

lockdown.initPeripherals()
sleep(5)
lockdown.activate()
sleep(10)
lockdown.deactivate()