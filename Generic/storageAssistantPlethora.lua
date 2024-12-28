local util = require("util")
local version = "V0.1.4"

local storage = require("storageAPI")
local parser = require("stringMathParser")
local lev = require("levenshteinDistance")

local modem = peripheral.find("modem")
modem.open(0)

local inventory_manager = peripheral.wrap("manipulator_3")
local equipment = inventory_manager.getEquipment()
local inventory = inventory_manager.getInventory()
local chat = peripheral.find("chatBox")

local prefix = "happy"

local furnace_intake = peripheral.wrap("minecraft:chest_2")

local function findItemInventory(item_name,count)
    local list = inventory.list()
    for slot, item in pairs(list) do
        if item.name == item_name and item.count >= count then
            return true, {slot=slot,name=item_name,count=item.count,maxStackSize = item.maxStackSize}
        end
    end
    return false, nil
end

util.title("Storage Assistant",version)
print("Starting Happy")
while true do
    storage.refresh()
    local event, username, message, uuid, isHidden = os.pullEvent("chat")
    local storage_p = peripheral.wrap("storage")
    if username == inventory_manager.getName() then
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
                                    local successful,item_data = storage.findItem(arg3,count%65)
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
                                        inventory.pullItems(item_data.chest,item_data.slot,sub_count)
                                        chat.sendMessageToPlayer("Found requested item: "..item_data.name, inventory_manager.getName(),prefix)
                                    else
                                        chat.sendMessageToPlayer("Could not find the requested item.", inventory_manager.getName(),prefix)
                                    end
                                end
                            else
                                local successful,item_data = storage.findItem(arg3,1)
                                if successful then
                                    inventory.pullItems(item_data.chest,item_data.slot)
                                    chat.sendMessageToPlayer("Found requested item: "..item_data.name, inventory_manager.getName(),prefix)
                                else
                                    chat.sendMessageToPlayer("Could not find the requested item.", inventory_manager.getName(),prefix)
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
                                        local avaliable = storage.findAvaliableChest()
                                        inventory.pushItems(peripheral.getName(avaliable),item_data.slot,sub_count)
                                        chat.sendMessageToPlayer("Deposited requested item: "..item_data.name, inventory_manager.getName(),prefix)
                                    else
                                        chat.sendMessageToPlayer("Could not deposit the requested item.", inventory_manager.getName(),prefix)
                                    end
                                end
                            else
                                local successful,item_data = findItemInventory(arg3,1)
                                if successful then
                                    local avaliable = storage.findAvaliableChest()
                                    inventory.pushItems(peripheral.getName(avaliable),item_data.slot,item_data.count)
                                end
                            end
                        else
                            local equipment_list = equipment.list()
                            local item_data = equipment_list[1]
                            local avaliable = storage.findAvaliableChest()
                            equipment.pushItems(peripheral.getName(avaliable),1,item_data.count)
                        end
                    elseif arg2 == "amount" then
                        if type(arg3) ~= "nil" then
                            local count = storage.getItemCount(arg3)
                            if count > 0 then
                                chat.sendMessageToPlayer("Found "..tostring(count).." "..arg3, inventory_manager.getName(),prefix)
                            else
                                chat.sendMessageToPlayer("No items with the name "..arg3.." exist.", inventory_manager.getName(),prefix)
                            end
                        end
                    elseif arg2 == "search" then
                        if type(arg3) ~= "nil" then
                            local results = storage.searchItems(arg3)
                            local owner = inventory_manager.getName()
                            for item, count in pairs(results) do
                                print(count)
                                chat.sendMessageToPlayer("Item: "..item.." | Count: "..tostring(count/2), owner,prefix)
                                sleep(1)
                            end
                        end
                    elseif arg2 == "smelt" then
                        if type(arg3) ~= "nil" then
                            local count = 0
                            if type(arg4) ~= "nil" then
                                count = tonumber(arg4)
                                for i = 1, math.ceil(count/64) do
                                    local successful,item_data = storage.findItem(arg3,count%65)
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
                                        chat.sendMessageToPlayer("Smelting requested item: "..item_data.name, inventory_manager.getName(),prefix)
                                    else
                                        chat.sendMessageToPlayer("Could not smelt the requested item.", inventory_manager.getName(),prefix)
                                    end
                                end
                            else
                                local successful,item_data = storage.findItem(arg3,1)
                                if successful then
                                    furnace_intake.pullItems(item_data.chest,item_data.slot)
                                    chat.sendMessageToPlayer("Smelting requested item: "..item_data.name, inventory_manager.getName(),prefix)
                                else
                                    chat.sendMessageToPlayer("Could not smelt the requested item.", inventory_manager.getName(),prefix)
                                end

                            end
                        end
                    elseif arg2 == "compute" then
                        if type(arg3) ~= "nil" then
                            local result = parser.parseMath(arg3)
                            chat.sendMessageToPlayer("Res: "..result, inventory_manager.getName(),prefix)
                        end
                    elseif arg2 == "craft" then
                        if type(arg3) ~= "nil" then
                            if type(arg4) == "nil" then
                                arg4 = 1
                            end
                            local packet = {
                                type = "queueRecipe",
                                recipe_name = arg3,
                                count = tonumber(arg4)
                            }
                            print("bb")
                            modem.transmit(0,0,packet)
                        end
                    elseif arg2 == "help" then
                        chat.sendMessageToPlayer("Command | Description", inventory_manager.getName(),prefix)
                        sleep(1)
                        chat.sendMessageToPlayer("Amount | Gets the amount of a specific item.", inventory_manager.getName(),prefix)
                        sleep(1)
                        chat.sendMessageToPlayer("Request | Requests a specific item with an optional amount.", inventory_manager.getName(),prefix)
                        sleep(1)
                        chat.sendMessageToPlayer("Deposit | Deposit an item from your inv with an optional amount.", inventory_manager.getName(),prefix)
                        sleep(1)
                        chat.sendMessageToPlayer("Search | Search for items using partial item names.", inventory_manager.getName(),prefix)
                        sleep(1)
                        chat.sendMessageToPlayer("Smelt | Smelts the selected item Ex: smelt minecraft:stone 15.", inventory_manager.getName(),prefix)

                    end
                end
            end
        end
    end
end