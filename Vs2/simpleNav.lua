local pid = require("PID")

local sides = {
    posX = "back",
    posY = "top",
    posZ = "left",
    negX = "front",
    negY = "bottom",
    negZ = "right"
}

local function goTo(tX, tY, tZ)
    local pos = ship.getWorldspacePosition()

    local x = pos.x
    local y = pos.y
    local z = pos.z

    local xPid = pid.makePID(0.01,0.003,0.005,tX,x)
    local yPid = pid.makePID(0.01,0.003,0.005,tY,y)
    local zPid = pid.makePID(0.01,0.003,0.005,tZ,z)

    local success = false

    while true do
        pos = ship.getWorldspacePosition()

        x = pos.x
        y = pos.y
        z = pos.z

        xPid.current = x
        yPid.current = y
        zPid.current = z

        local xRes = pid.PID(xPid)
        local yRes = pid.PID(yPid)
        local zRes = pid.PID(zPid)

        xRes = yRes * 5
        yRes = yRes * 5
        zRes = yRes * 5

        if xRes > 15 then
            xRes = 15
        elseif xRes < -15 then
            xRes = -15
        end

        if yRes > 15 then
            yRes = 15
        elseif yRes < -15 then
            yRes = -15
        end

        if zRes > 15 then
            zRes = 15
        elseif zRes < -15 then
            zRes = -15
        end

        if xRes < 0 then
            redstone.setAnalogOutput(sides.posX,math.abs(xRes))
            redstone.setAnalogOutput(sides.posX,math.abs(0))
        else
            redstone.setAnalogOutput(sides.posX,math.abs(0))
            redstone.setAnalogOutput(sides.posX,math.abs(xRes))
        end

        if yRes > 0 then
            redstone.setAnalogOutput(sides.posY,math.abs(yRes))
            redstone.setAnalogOutput(sides.negY,math.abs(0))
        else
            redstone.setAnalogOutput(sides.posY,math.abs(0))
            redstone.setAnalogOutput(sides.negY,math.abs(yRes))
        end

        if zRes < 0 then
            redstone.setAnalogOutput(sides.posZ,math.abs(zRes))
            redstone.setAnalogOutput(sides.negZ,math.abs(0))
        else
            redstone.setAnalogOutput(sides.posZ,math.abs(0))
            redstone.setAnalogOutput(sides.negZ,math.abs(zRes))
        end

        sleep(0.05)
    end
end

local tX, tY, tZ = ...

goTo(tX,tY,tZ)