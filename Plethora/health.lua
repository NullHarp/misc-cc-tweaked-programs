local modules = peripheral.wrap("back")
local last_health = 20
while true do
    local data = modules.getMetaOwner()
    local health = data.health
    if health < last_health then
        print(last_health-health.." damage taken")
    end
    sleep(0)
end    
