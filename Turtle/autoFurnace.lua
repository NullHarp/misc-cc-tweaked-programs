local fuel = {
    ["minecraft:coal"] = "",
    ["minecraft:lava_bucket"] = ""
}

local input = peripheral.wrap("minecraft:chest_0")
local output = peripheral.wrap("sc-goodies:diamond_chest_10")

local furnaces = table.pack(peripheral.find("minecraft:furnace"))
local furnace_names = {}
for i = 1, #furnaces do
    table.insert(furnace_names,peripheral.getName(furnaces[i]))
end

local function main()
    print("Starting Main loop")
    while true do
        -- Iterate through every furnace in the table
        for i = 1, #furnaces do
            -- Make sure the index is actually a furnace peripheral
            if type(furnaces[i]) == "table" then
                local list = input.list()
                if type(list) == "table" then
                    for slot, item in pairs(list) do
                        local num = math.ceil(item.count / #furnaces)
                        if type(fuel[item.name]) == "nil" then
                            input.pushItems(furnace_names[i],slot,num*3,1)
                        elseif type(fuel[item.name]) ~= "nil" then
                            input.pushItems(furnace_names[i],slot,num,2)
                        end
                    end   
                end
                ---The portion of the program that handles taking items out of the furnaces
                output.pullItems(furnace_names[i],3)
            end
        end
        sleep(0)
    end
end

parallel.waitForAll(main)