local util = require("util")

local pwr = ...
pwr = tonumber(pwr)

local modules = peripheral.wrap("back")
while true do
    local data = modules.sense()
    for i,v in pairs(data) do
        if v.name ~= "Item" and v.name ~= "entity.plethora.laser" and v.name ~= modules.getName() and v.name ~= "Experience Orb" and v.name ~= "Falling Block" and v.name ~= "Arrow" then
            local yaw, pitch = util.calculateYawPitch(v.x,v.y,v.z)
            modules.fire(-yaw,-pitch,pwr)
            print(v.name)
        end
    end
    sleep(0)
end