local util = require("util")
local version = "V0.1.4"

local parser = require("stringMathParser")
local lev = require("levenshteinDistance")

local inventory = peripheral.wrap("right")
local chat = peripheral.wrap("top")

local prefix = "happy"

local furnace_intake = peripheral.wrap("minecraft:chest_22")

local storage = "minecraft:barrel_2"

local storage_intake = peripheral.wrap("minecraft:chest_35")

local chests = table.pack(peripheral.find("minecraft:chest"))
local chest_names = {}
for i = 1, #chests do
    table.insert(chest_names,peripheral.getName(chests[i]))
end

local function findItemInventory(item_name,count)
    local list = inventory.list()
    for slot, item in pairs(list) do
        if item.name == item_name and item.count >= count then
            return true, {slot=slot,name=item_name,count=item.count,maxStackSize = item.maxStackSize}
        end
    end
    return false, nil
end

local function findItem(item_name,count)
    for i = 1, #chests do
        local list = chests[i].list()
        for slot, item in pairs(list) do
            if item.name == "minecraft:dirt" then
                print(lev.levenshtein(item.name,item_name))
            end
            if lev.levenshtein(item.name,item_name) < 3 and item.count >= count then
                return true, {slot=slot,name=item.name,count=item.count,chest = chest_names[i]}
            end
        end
    end
    return false, nil
end

local function searchItems(item_name)
    local results = {}
    for i = 1, #chests do
        local list = chests[i].list()
        for slot, item in pairs(list) do
            if string.find(item.name, item_name, 1, true) then
                if type(results[item.name]) == "nil" then
                    results[item.name] = item.count
                else
                    results[item.name] = results[item.name] + item.count
                end
            end
        end
    end
    return results
end

local function getItemCount(item_name)
    local count = 0
    for i = 1, #chests do
        local list = chests[i].list()
        for slot, item in pairs(list) do
            if item.name == item_name then
                count = count + item.count
            end
        end
    end
    return count
end

util.title("Storage Assistant",version)
print("Starting Happy")
while true do
    local event, username, message, uuid, isHidden = os.pullEvent("chat")
    local storage_p = peripheral.wrap(storage)
    if username == inventory.getOwner() then
        local words = string.gmatch(message, "%S+")
        local arg1 = words()
        local arg2 = words()
        local arg3 = words()
        local arg4 = words()
        local arg5 = words()
        if type(arg1) ~= "nil" then
            if arg1 == prefix then
                if type(arg2) ~= "nil" then
                    if arg2 == "request" then
                        if type(arg3) ~= "nil" then
                            local count = 0
                            if type(arg4) ~= "nil" then
                                count = tonumber(arg4)
                                for i = 1, math.ceil(count/64) do
                                    local successful,item_data = findItem(arg3,count%65)
                                    if successful then
                                        local sub_count = 0
                                        if i == math.ceil(count/64) then
                                            if item_data.count < count%65 then
                                                sub_count = item_data.count
                                            else
                                                sub_count = count%65
                                            end
                                        else
                                            sub_count = 64
                                        end
                                        storage_p.pullItems(item_data.chest,item_data.slot,sub_count)
                                        inventory.addItemToPlayer("up",{name=item_data.name,count=sub_count})
                                        chat.sendMessageToPlayer("Found requested item: "..item_data.name, inventory.getOwner(),prefix)
                                    else
                                        chat.sendMessageToPlayer("Could not find the requested item.", inventory.getOwner(),prefix)
                                    end
                                end
                            else
                                local successful,item_data = findItem(arg3,1)
                                if successful then
                                    storage_p.pullItems(item_data.chest,item_data.slot)
                                    inventory.addItemToPlayer("up",{name=item_data.name,count=item_data.count})
                                    chat.sendMessageToPlayer("Found requested item: "..item_data.name, inventory.getOwner(),prefix)
                                else
                                    chat.sendMessageToPlayer("Could not find the requested item.", inventory.getOwner(),prefix)
                                end

                            end
                        end
                    elseif arg2 == "deposit" then
                        if type(arg3) ~= "nil" then
                            local count = 0
                            if type(arg4) ~= "nil" then
                                count = tonumber(arg4)
                                for i = 1, math.ceil(count/64) do
                                    local successful,item_data = findItemInventory(arg3,count%65)
                                    if successful then
                                        local sub_count = 0
                                        if i == math.ceil(count/64) then
                                            if item_data.count < count%65 then
                                                sub_count = item_data.count
                                            else
                                                sub_count = count%65
                                            end
                                        else
                                            sub_count = 64
                                        end
                                        inventory.removeItemFromPlayer("up",{name=item_data.name,count=sub_count})
                                        if type(storage_p) ~= "nil" then
                                            for i = 1, 27 do
                                                storage_intake.pullItems(storage,i)
                                            end
                                        end
                                        chat.sendMessageToPlayer("Deposited requested item: "..item_data.name, inventory.getOwner(),prefix)
                                    else
                                        chat.sendMessageToPlayer("Could not deposit the requested item.", inventory.getOwner(),prefix)
                                    end
                                end
                            else
                                local successful,item_data = findItemInventory(arg3,1)
                                if successful then
                                    inventory.removeItemFromPlayer("up",{name=item_data.name,count=item_data.count})
                                    if type(storage_p) ~= "nil" then
                                        for i = 1, 27 do
                                            storage_intake.pullItems(storage,i)
                                        end
                                    end
                                else

                                end
                            end
                        else
                            local item_data = inventory.getItemInHand()
                            inventory.removeItemFromPlayer("up",{name=item_data.name,count=item_data.count})
                            if type(storage_p) ~= "nil" then
                                for i = 1, 27 do
                                    storage_intake.pullItems(storage,i)
                                end
                            end
                        end
                    elseif arg2 == "amount" then
                        if type(arg3) ~= "nil" then
                            local count = getItemCount(arg3)
                            if count > 0 then
                                chat.sendMessageToPlayer("Found "..tostring(count).." "..arg3, inventory.getOwner(),prefix)
                            else
                                chat.sendMessageToPlayer("No items with the name "..arg3.." exist.", inventory.getOwner(),prefix)
                            end
                        end
                    elseif arg2 == "search" then
                        if type(arg3) ~= "nil" then
                            local results = searchItems(arg3)
                            local owner = inventory.getOwner()
                            for item, count in pairs(results) do
                                chat.sendMessageToPlayer("Item: "..item.." | Count: "..tostring(count), owner,prefix)
                                sleep(1)
                            end
                        end
                    elseif arg2 == "smelt" then
                        if type(arg3) ~= "nil" then
                            local count = 0
                            if type(arg4) ~= "nil" then
                                count = tonumber(arg4)
                                for i = 1, math.ceil(count/64) do
                                    local successful,item_data = findItem(arg3,count%65)
                                    if successful then
                                        local sub_count = 0
                                        if i == math.ceil(count/64) then
                                            if item_data.count < count%65 then
                                                sub_count = item_data.count
                                            else
                                                sub_count = count%65
                                            end
                                        else
                                            sub_count = 64
                                        end
                                        furnace_intake.pullItems(item_data.chest,item_data.slot,sub_count)
                                        chat.sendMessageToPlayer("Smelting requested item: "..item_data.name, inventory.getOwner(),prefix)
                                    else
                                        chat.sendMessageToPlayer("Could not smelt the requested item.", inventory.getOwner(),prefix)
                                    end
                                end
                            else
                                local successful,item_data = findItem(arg3,1)
                                if successful then
                                    furnace_intake.pullItems(item_data.chest,item_data.slot)
                                    chat.sendMessageToPlayer("Smelting requested item: "..item_data.name, inventory.getOwner(),prefix)
                                else
                                    chat.sendMessageToPlayer("Could not smelt the requested item.", inventory.getOwner(),prefix)
                                end

                            end
                        end
                    elseif arg2 == "compute" then
                        if type(arg3) ~= "nil" then
                            local result = parser.parseMath(arg3)
                            chat.sendMessageToPlayer("Res: "..result, inventory.getOwner(),prefix)
                        end
                    elseif arg2 == "help" then
                        chat.sendMessageToPlayer("Command | Description", inventory.getOwner(),prefix)
                        sleep(1)
                        chat.sendMessageToPlayer("Amount | Gets the amount of a specific item.", inventory.getOwner(),prefix)
                        sleep(1)
                        chat.sendMessageToPlayer("Request | Requests a specific item with an optional amount.", inventory.getOwner(),prefix)
                        sleep(1)
                        chat.sendMessageToPlayer("Deposit | Deposit an item from your inv with an optional amount.", inventory.getOwner(),prefix)
                        sleep(1)
                        chat.sendMessageToPlayer("Search | Search for items using partial item names.", inventory.getOwner(),prefix)
                        sleep(1)
                        chat.sendMessageToPlayer("Smelt | Smelts the selected item Ex: smelt minecraft:stone 15.", inventory.getOwner(),prefix)

                    end
                end
            end
        end
    end
end