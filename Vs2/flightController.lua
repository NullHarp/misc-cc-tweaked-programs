local pid = require("PID")

local x, y, z = gps.locate()

local yPid = pid.makePID(0.01,0.003,0.005,130,y)

local function main()
    while true do
        x, y, z = gps.locate()
        if y then
            yPid.current = y
        end
        local yRes = pid.PID(yPid)
        yRes = yRes * 10
        if yRes > 15 then
            yRes = 15
        elseif yRes < -15 then
            yRes = -15
        end
        if yRes > 0 then
            redstone.setAnalogOutput("top",math.abs(yRes))
        else
            redstone.setAnalogOutput("top",0)
        end
        sleep(0.05)
    end
end

local function newY()
    while true do
        local newY = read()
        newY = tonumber(newY)
        yPid.target = newY
        sleep(0)
    end
end

parallel.waitForAll(main,newY)