local target = ...
local function calculateYawPitch(x, y, z)
    -- Calculate yaw (rotation around the y-axis)
    local yaw = math.atan2(x, z)
    
    -- Calculate distance on the xz-plane
    local distanceXZ = math.sqrt(x * x + z * z)
    
    -- Calculate pitch (rotation around the x-axis)
    local pitch = math.atan2(y, distanceXZ)
    
    -- Convert radians to degrees
    local yawDegrees = math.deg(yaw)
    local pitchDegrees = math.deg(pitch)
    
    return yawDegrees, pitchDegrees
end
local modules = peripheral.wrap("back")
local yaw, pitch
while true do
    local data = modules.sense()
    for i,v in pairs(data) do
        if v.name == target then
            local meta = modules.getMetaOwner()
            local next_pos = {}
            next_pos.x = v.x + v.motionX * 0.05
            next_pos.y = v.y + v.motionY * 0.05
            next_pos.z = v.z + v.motionZ * 0.05

            local adjusted_pos = {}
            adjusted_pos.x = next_pos.x - (meta.motionX * 0.05)
            adjusted_pos.y = next_pos.y - (meta.motionY * 0.05)
            adjusted_pos.z = next_pos.z - (meta.motionZ * 0.05)

            yaw, pitch = calculateYawPitch(adjusted_pos.x,adjusted_pos.y,adjusted_pos.z)
            modules.look(-yaw,-pitch)
            
            print(v.name)
        end
    end
    sleep(0)
end
