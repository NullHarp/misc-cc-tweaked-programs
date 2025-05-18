local pid = require("PID")
local motor_yaw = peripheral.wrap("create:creative_motor_0")
local motor_pitch = peripheral.wrap("create:creative_motor_1")
--Positive is left, negative is right

local blockReader = peripheral.wrap("right")

local function getRotation()
    local data = blockReader.getBlockData()
    return math.abs(data.CannonYaw), data.CannonPitch
end

local yawPid = pid.makePID(0.6,0.4,0.5,0,0)
local pitchPid = pid.makePID(0.6,0.4,0.5,0,0)

local currentPos = {x=10083,y=-10,z=160}

local function aimAtCoord(tX,tY,tZ)
    local dX = tX- currentPos.x
    local dY = tY - currentPos.y
    local dZ = tZ - currentPos.z

    local targetYaw = math.atan2(dX,dZ)
    return math.abs(math.deg(targetYaw))
end

local function getYFromX(x, v0, thetaDeg)
    local theta = math.rad(thetaDeg)
    local sinTheta = math.sin(theta)
    local cosTheta = math.cos(theta)

    -- Horizontal velocity component
    local vx = v0 * cosTheta
    -- Vertical velocity component
    local vy0 = v0 * sinTheta

    -- Estimated time to reach horizontal distance x
    local t = x / vx

    -- Effective vertical acceleration (gravity + estimated average drag)
    local g_eff = 0.05 + 0.01 * vy0

    -- y = vy0 * t - 0.5 * g_eff * t^2
    local y = vy0 * t - 0.5 * g_eff * t * t

    return y
end

-- Solves for initial speed v0 given x, y, and theta (in degrees)
local function getVelocityFromXY(x, y, thetaDeg)
    local theta = math.rad(thetaDeg)
    local sinTheta = math.sin(theta)
    local cosTheta = math.cos(theta)

    -- Avoid division by zero
    if cosTheta == 0 then
        return nil, "Angle is vertical; undefined horizontal motion."
    end

    -- We'll use an approximation for g_eff: assume g_eff = 0.05 + 0.01 * vy0,
    -- but since vy0 = v0 * sinTheta, we get g_eff = 0.05 + 0.01 * v0 * sinTheta
    -- This becomes a quadratic in terms of v0. To avoid that, we'll assume avg drag:
    local g_eff = 0.05 + 0.005  -- average case, tweak if needed

    -- Rearranged from y = tan(θ) * x - (g_eff * x^2) / (2 * v0^2 * cos^2(θ))
    -- Solve for v0^2:
    local tanTheta = math.tan(theta)
    local numerator = g_eff * x * x
    local denominator = 2 * (x * tanTheta - y)

    if denominator <= 0 then
        return nil, "Invalid parameters: denominator is zero or negative (target too high or close)."
    end

    local v0_squared = numerator / (denominator * cosTheta^2)
    if v0_squared < 0 then
        return nil, "No valid solution; target unreachable at that angle."
    end

    local v0 = math.sqrt(v0_squared)
    return v0
end

local function getFiringAnglesFromXY(x, y, v0)
    local g = 0.055  -- effective gravity (gravity + average drag)

    local v0_squared = v0 * v0
    local discriminant = v0_squared^2 - g * (g * x^2 + 2 * y * v0_squared)

    if discriminant < 0 then
        return nil, "Target unreachable with given velocity."
    end

    local sqrt_disc = math.sqrt(discriminant)

    -- Two possible solutions for tan(theta)
    local tanTheta1 = (v0_squared + sqrt_disc) / (g * x)
    local tanTheta2 = (v0_squared - sqrt_disc) / (g * x)

    -- Convert to angles in degrees
    local angle1 = math.deg(math.atan(tanTheta1))
    local angle2 = math.deg(math.atan(tanTheta2))

    return angle1, angle2
end

local tarX,tarY,tarZ = ...
tarX = tonumber(tarX)
tarY = tonumber(tarY)
tarY = tarY + 2
tarZ = tonumber(tarZ)

print(getVelocityFromXY(531,0,18.403681923279))
local angle_1,targetAngle = getFiringAnglesFromXY(currentPos.x-tarX,tarY,6.981831098845)
print(angle_1,targetAngle)
if type(targetAngle) == "string" then
    targetAngle = angle_1
end

while true do
    local yaw, pitch = getRotation()
    local targetYaw = aimAtCoord(tarX,tarY,tarZ)
    local pitchDifference = targetAngle - pitch
    local yawDifference = targetYaw - yaw

    yawPid.current = yawDifference
    pitchPid.current = pitchDifference
    local yawRes = pid.PID(yawPid)
    local pitchRes = pid.PID(pitchPid)
    motor_yaw.setScrollValue(yawRes)
    motor_pitch.setScrollValue(-pitchRes)

    --print(targetAngle,pitch,pitchDifference)
    --print(-pitchRes)
    print(targetYaw,targetAngle)
end

print(aimAtCoord(0,0,0))