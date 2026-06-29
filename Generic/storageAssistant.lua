local util = require("util")
local version = "V0.1.4"

local storage = require("storageAPI")
local parser = require("stringMathParser")
local lev = require("levenshteinDistance")

local modem = peripheral.find("modem")
modem.open(0)

local inventory_manager = peripheral.wrap("inventory_manager_2")
local uuid, owner = inventory_manager.getOwner()
local chat = peripheral.find("chat_box")

local prefix = "happy"

local furnace_intake = peripheral.wrap("minecraft:chest_2")

local function findItemInventory(item_name,item_count)
    local list = inventory_manager.list()
    for slot, item in pairs(list) do
        if item.name == item_name and item.count >= item_count then
            return true, {slot=slot,name=item_name,count=item.count,maxStackSize = item.maxStackSize}
        end
    end
    return false, nil
end

local function request(item_name,item_count)
    item_count = item_count or 1
    item_count = tonumber(item_count)

    for i = 1, math.ceil(item_count/64) do
        local successful,item_data = storage.findItem(item_name,item_count%65)
        if successful then
            local sub_count = 0
            if i == math.ceil(item_count/64) then
                if item_data.count < item_count%65 then
                    sub_count = item_data.count
                else
                    sub_count = item_count%65
                end
            else
                sub_count = 64
            end
            inventory_manager.pullItems(item_data.chest,{fromSlot=item_data.slot,count=sub_count})
            chat.sendMessageToPlayer("Found requested item: "..item_data.name, owner,{prefix=prefix})
        else
            chat.sendMessageToPlayer("Could not find the requested item.", owner,{prefix=prefix})
        end
    end
end

local function deposit(item_name,item_count)
    item_count = item_count or 1
    item_count = tonumber(item_count)
    if not item_name then
        local item_data = inventory_manager.getItemInHand()
        if item_data then
            local isAvaliable, avaliable = storage.findAvaliableChest()
            if isAvaliable then
                inventory_manager.pushItems(peripheral.getName(avaliable),{fromSlot=inventory_manager.getHandSlot(),count=item_data.count})
            end
        end
        return
    end

    for i = 1, math.ceil(item_count/64) do
        local successful,item_data = findItemInventory(item_name,item_count%65)
        if successful then
            local sub_count = 0
            if i == math.ceil(item_count/64) then
                if item_data.count < item_count%65 then
                    sub_count = item_data.count
                else
                    sub_count = item_count%65
                end
            else
                sub_count = 64
            end
            local isAvaliable, avaliable = storage.findAvaliableChest()
            if isAvaliable then
                inventory_manager.pushItems(peripheral.getName(avaliable),{fromSlot=item_data.slot,count=sub_count})
            end
            chat.sendMessageToPlayer("Deposited requested item: "..item_data.name, owner,{prefix=prefix})
        else
            chat.sendMessageToPlayer("Could not deposit the requested item.", owner,{prefix=prefix})
        end
    end
end

local function amount(item_name)
    local item_count = storage.getItemCount(item_name)
    if item_count > 0 then
        chat.sendMessageToPlayer("Found "..tostring(item_count).." "..item_name, owner,{prefix=prefix})
    else
        chat.sendMessageToPlayer("No items with the name "..item_name.." exist.", owner,{prefix=prefix})
    end
end

local function search(item_name)
    local results = storage.searchItems(item_name)
    for item, count in pairs(results) do
        if item ~= "n" then
            print(count)
            chat.sendMessageToPlayer("Item: "..item.." | Count: "..tostring(count), owner,{prefix=prefix})
            sleep(1)
        end
    end
end

local function smelt(item_name,item_count)
    item_count = item_count or 1
    item_count = tonumber(item_count)

    for i = 1, math.ceil(item_count/64) do
        local successful,item_data = storage.findItem(item_name,item_count%65)
        if successful then
            local sub_count = 0
            if i == math.ceil(item_count/64) then
                if item_data.count < item_count%65 then
                    sub_count = item_data.count
                else
                    sub_count = item_count%65
                end
            else
                sub_count = 64
            end
            furnace_intake.pullItems(item_data.chest,item_data.slot,sub_count)
            chat.sendMessageToPlayer("Smelting requested item: "..item_data.name, owner,{prefix=prefix})
        else
            chat.sendMessageToPlayer("Could not smelt the requested item.", owner,{prefix=prefix})
        end
    end
end

local function compute(equation)
    local result = parser.parseMath(equation)
    chat.sendMessageToPlayer("Res: "..result, owner,{prefix=prefix})
end

local function craft(item_name, item_count)
    item_count = item_count or 1
    item_count = tonumber(item_count)

    local packet = {
        type = "queueRecipe",
        recipe_name = item_name,
        count = tonumber(item_count)
    }
    modem.transmit(0,0,packet)
end

util.title("Storage Assistant",version)
print("Starting Happy")
print(owner)
while true do
    storage.refresh()
    local event, uuid, username, message, isHidden, utf8 = os.pullEvent("chat")
    if username == owner then
        local words = string.gmatch(message, "%S+")
        local prefix_arg = words()
        local command = words()
        local arg1 = words()
        local arg2 = words()
        if prefix_arg == prefix then
            if command == "request" and arg1 then
                request(arg1,arg2)
            elseif command == "deposit" then
                deposit(arg1,arg2)
            elseif command == "amount" and arg1 then
                amount(arg1)
            elseif command == "search" and arg1 then
                search(arg1)
            elseif command == "smelt" and arg1 then
                smelt(arg1,arg2)
            elseif command == "compute" and arg1 then
                compute(arg1)
            elseif command == "craft" and arg1 then
                craft(arg1,arg2)
            elseif command == "help" then
                chat.sendMessageToPlayer("Command | Description", owner,{prefix=prefix})
                sleep(1)
                chat.sendMessageToPlayer("Amount | Gets the amount of a specific item.", owner,{prefix=prefix})
                sleep(1)
                chat.sendMessageToPlayer("Request | Requests a specific item with an optional amount.", owner,{prefix=prefix})
                sleep(1)
                chat.sendMessageToPlayer("Deposit | Deposit an item from your inv with an optional amount.", owner,{prefix=prefix})
                sleep(1)
                chat.sendMessageToPlayer("Search | Search for items using partial item names.", owner,{prefix=prefix})
                sleep(1)
                chat.sendMessageToPlayer("Smelt | Smelts the selected item Ex: smelt minecraft:stone 15.", owner,{prefix=prefix})
                sleep(1)
                chat.sendMessageToPlayer("Compute | Computes the sum of the equation.", owner,{prefix=prefix})
            end
        end
    end
end