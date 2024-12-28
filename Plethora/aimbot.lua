local util = require("util")

local target = ...

local modules = peripheral.wrap("back")
while true do
    local data = modules.sense()
    for i,v in pairs(data) do
        if (v.name == target or type(target) == "nil") and v.name ~= modules.getName() and v.name ~= "entity.minecraft.item" and v.name ~= "entity.minecraft.marker" then
            local meta = modules.getMetaOwner()
            local next_pos = {}
            next_pos.x = v.x + v.motionX
            next_pos.y = v.y + v.motionY
            next_pos.z = v.z + v.motionZ

            local adjusted_pos = {}
            adjusted_pos.x = next_pos.x - (meta.motionX)
            adjusted_pos.y = next_pos.y - (meta.motionY)
            adjusted_pos.z = next_pos.z - (meta.motionZ)

            local yaw, pitch = util.calculateYawPitch(adjusted_pos.x,adjusted_pos.y,adjusted_pos.z)
            modules.look(-yaw,-pitch)
            local error = pcall(modules.swing)
            print(v.name)
        end
    end
    sleep(0)
end
