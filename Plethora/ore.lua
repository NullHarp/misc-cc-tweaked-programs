local modules = peripheral.wrap("back")

local canvas = modules.canvas3d()
canvas.clear()
local layer = canvas.create()

local target = ...

while true do
    local data = modules.scan()
    local meta_data = modules.getMetaOwner()
    local within = meta_data.withinBlock
    layer.clear()
    layer.recenter()
    for i,ore in pairs(data) do
        if ore.name == target then
            local b = layer.addBox(ore.x-within.x,ore.y-within.y,ore.z-within.z,1,1,1,0x00ff0080)
            b.setDepthTested(false)
        end
    end
    sleep(1)
end