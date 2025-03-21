local function quaternionToEuler(w, x, y, z)
    -- Yaw (rotation around the Y-axis in Minecraft)
    local yaw = math.atan2(2 * (w * y + x * z), 1 - 2 * (y * y + z * z))

    -- Pitch (rotation around the X-axis in Minecraft)
    local pitch = math.asin(math.max(-1, math.min(1, 2 * (w * x - y * z)))) -- Clamping to avoid NaN

    -- Roll (rotation around the Z-axis, not usually used in Minecraft)
    local roll = math.atan2(2 * (w * z + x * y), 1 - 2 * (x * x + z * z))

    -- Convert from radians to degrees
    return math.deg(pitch), math.deg(yaw), math.deg(roll)
end

return {quaternionToEuler = quaternionToEuler}