local redstone_int = peripheral.wrap("back")

local directions = {
    forward = "front",
    backward = "up",
    left = "right",
    right = "left"
}

local function getRelativeAngle(targetYaw, currentYaw)
    local diff = (targetYaw - currentYaw + 180) % 360 - 180
    return diff
end


local function calculateHeading(targetX, targetY, targetZ)
    
    -- Get current ship position and orientation
    local pos = ship.getWorldspacePosition()
    local rot = ship.getEulerAnglesXYZ()

    if not pos or not rot then
        error("Could not retrieve position or rotation from ship")
    end

    -- Compute deltas to target
    local dx = targetX - pos.x
    local dz = targetZ - pos.z

    -- Horizontal distance only (ignoring Y)
    local distance = math.sqrt(dx * dx + dz * dz)

    -- Calculate absolute target yaw angle (0° = +Z, clockwise)
    local targetYaw = math.deg(math.atan2(dx, dz))  -- atan2(x, z) = 0 when facing +Z
    if targetYaw < 0 then targetYaw = targetYaw + 360 end

    -- Convert current yaw to degrees
    local currentYaw = math.deg(rot.y)  -- double check your system uses .z for yaw

    -- Compute relative angle (how much to turn from current to target)
    local relativeAngle = (targetYaw - currentYaw + 180) % 360 - 180
    return relativeAngle, distance
end

local function simulateNav(targetX, targetY, targetZ)
    local relative_angle, distance = calculateHeading(targetX, targetY, targetZ)

    local deadzone = 2       -- Degrees: don't turn if almost aligned
    local maxAngle = 90      -- Max angle to scale redstone strength
    local maxStrength = 15   -- Max redstone signal

    local turnLeft = 0
    local turnRight = 0

    if relative_angle > deadzone then
        turnRight = math.min(math.floor((relative_angle / maxAngle) * maxStrength), maxStrength)
        turnLeft = 0
    elseif relative_angle < -deadzone then
        turnLeft = math.min(math.floor((-relative_angle / maxAngle) * maxStrength), maxStrength)
        turnRight = 0
    else
        -- Stop turning when aligned
        turnLeft = 0
        turnRight = 0
    end

    -- Apply redstone outputs
    redstone_int.setAnalogOutput(directions.left, turnRight)
    redstone_int.setAnalogOutput(directions.right, turnLeft)
end


return {simulateNav=simulateNav,calculateHeading=calculateHeading}