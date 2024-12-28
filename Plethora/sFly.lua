local modules = peripheral.wrap("back")

local factor = ...
factor = tonumber(factor)
if factor < 0.5 or factor > 4 then
    error("Out of range: 0.5 - 4")
end
while true do
    local event, key, is_held = os.pullEvent("key")
    local data = modules.getMetaOwner()
    if key == keys.space then
        modules.launch(0,-90,factor)
        sleep(1)
    elseif key == keys.leftShift then
        for i = 1, 5 do
            modules.launch(data.yaw,data.pitch,factor)
        end
        sleep(0.01)
    end
end
