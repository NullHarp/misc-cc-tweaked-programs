local input = peripheral.wrap("minecraft:chest_3")
local storage = "minecraft:chest_1"
local furnace_input = "minecraft:chest_2"

local furnace_filter = {
    ["minecraft:raw_iron"] = "",
    ["minecraft:raw_gold"] = "",
    ["minecraft:raw_copper"] = ""
}


while true do
    local list = input.list()
    for slot, item in pairs(list) do
        if type(furnace_filter[item.name]) ~= "nil" then
            input.pushItems(furnace_input,slot)
        else
            input.pushItems(storage,slot)
        end
    end
    sleep(0)
end