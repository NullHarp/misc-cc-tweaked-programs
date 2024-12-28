local modules = peripheral.wrap("back")

local function a()
    while true do
        local data = modules.getMetaOwner()
        if data.health < 10 then
            shell.run("kill", 0.5)
        end
    end
end
local function b()
    while true do
        local event, key, is_held = os.pullEvent("key")
        if key == keys.t then
            shell.run("kill", 0.5)
        end
    end
end

parallel.waitForAny(a,b)