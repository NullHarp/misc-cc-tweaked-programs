local modules = peripheral.find("neuralInterface")

if type(modules) == "nil" then
    error("Neural Interface not found.",0)
end
if not modules.hasModule("plethora:glasses") then
    error("Overlay Glasses module not found.",0)
end
if not modules.hasModule("plethora:sensor") then
    error("Entity Sensor module not found.",0)
end

local canvas = modules.canvas3d()
canvas.clear()
local layer = canvas.create()
while true do
    layer.clear()
    layer.recenter()
    local data = modules.sense()
    for i,v in pairs(data) do
        local next_pos = {}
        next_pos.x = v.x + v.motionX * 0.05
        next_pos.y = v.y + v.motionY * 0.05
        next_pos.z = v.z + v.motionZ * 0.05
        local frame = layer.addFrame({next_pos.x,next_pos.y+1,next_pos.z})
        frame.setDepthTested(false)
        frame.addText({0,0},v.name)
        local b = {}
        if (v.name == "awesomehome7_dj" or v.name == "NullHarp" or v.name == "Blista__Compact") and v.name ~= modules.getName() then
            b = layer.addBox(next_pos.x-0.125,next_pos.y-0.125+0.5,next_pos.z-0.125,0.25,0.25,0.25,0x00ff0080)
        elseif v.key == "minecraft:player" and v.name ~= modules.getName() then
            b = layer.addBox(next_pos.x-0.125,next_pos.y-0.125+0.5,next_pos.z-0.125,0.25,0.25,0.25,0xff000080)
        elseif v.name ~= modules.getName() then
            b = layer.addBox(next_pos.x-0.125,next_pos.y-0.125+0.5,next_pos.z-0.125,0.25,0.25,0.25,0x0000ff80)
        end
        if type(b) ~="nil" then
            b.setDepthTested(false)
        end
    end
    sleep(0)
end
