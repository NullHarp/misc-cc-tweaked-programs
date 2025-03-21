local quat = require("quat")
local pid = require("PID")

local stabilizers = {
    pitchUp = "front",
    pitchDown = "back",
    rollRight = "right",
    rollLeft = "left"
}


local pitchPid = pid.makePID(0.01,0,0,180,0)
local rollPid = pid.makePID(0.01,0,0,180,0)

while true do
    local rotData = ship.getQuaternion()

    local pitch, yaw, roll = quat.quaternionToEuler(rotData.w,rotData.x,rotData.y,rotData.z)
    pitchPid.current = pitch
    rollPid.current = roll
    local pitchRes = pid.PID(pitchPid)
    local rollRes = pid.PID(rollPid)
    if pitchRes > 15 then
        pitchRes = 15
    elseif pitchRes < -15 then
        pitchRes = -15
    end

    if pitchRes < 0 then
        redstone.setAnalogOutput(stabilizers.pitchDown,0)
        redstone.setAnalogOutput(stabilizers.pitchUp,pitchRes)
    else
        redstone.setAnalogOutput(stabilizers.pitchDown,math.abs(pitchRes))
        redstone.setAnalogOutput(stabilizers.pitchUp,0)
    end

    if rollRes > 15 then
        rollRes = 15
    elseif rollRes < -15 then
        rollRes = -15
    end

    if rollRes > 0 then
        redstone.setAnalogOutput(stabilizers.rollLeft,0)
        redstone.setAnalogOutput(stabilizers.rollRight,rollRes)
    else
        redstone.setAnalogOutput(stabilizers.rollLeft,math.abs(rollRes))
        redstone.setAnalogOutput(stabilizers.rollRight,0)
    end
    print(pitchRes)
    print(rollRes)
    sleep(0)
end