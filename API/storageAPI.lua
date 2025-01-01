local lev = require("levenshteinDistance")

local chest_types = {"minecraft:chest","sc-goodies:diamond_chest"}

local chests = {}
local chest_names = {}

local ignore_chests = {}
local import_chests = {}

---Contains all items and associated data in the network
local item_index = {}
---Contains all item counts for each item in the network
local itemCounts = {}

---Contains references to the display name for every item id in the system
local displayNameIndex = {}

---Sets what chests the system should ignore
---@param ignoredChests table Chests to ignore
local function setIgnoredChests(ignoredChests)
    ignore_chests = {}
    for i,v in pairs(ignoredChests) do
        ignore_chests[v] = true
    end
end

---Sets what chests import into the system
---@param importChests table Chests to import from
local function setImportChests(importChests)
    import_chests = {}
    for i,v in pairs(importChests) do
        import_chests[v] = true
    end
end

---Saves the current item index
---@return boolean success Did we save the index
local function saveStorageIndex()
    local file = fs.open("/itemIndex.json","w")
    local json_data = textutils.serialiseJSON(item_index)
    file.write(json_data)
    file.close()
    return true
end

local function saveDisplayNames()
    local file = fs.open("/displayNames.json","w")
    local json_data = textutils.serialiseJSON(displayNameIndex)
    file.write(json_data)
    file.close()
    return true
end

---Loads the saved item index to the current one
---@return boolean success Did we load the index
local function loadStorageIndex()
    if fs.exists("/itemIndex.json") then
        local file = fs.open("/itemIndex.json","r")
        local json_data = file.readAll()
        file.close()
        item_index = textutils.unserialiseJSON(json_data)
        return true
    else
        return false
    end
end

local function loadDisplayNames()
    if fs.exists("/displayNames.json") then
        local file = fs.open("/displayNames.json","r")
        local json_data = file.readAll()
        file.close()
        displayNameIndex = textutils.unserialiseJSON(json_data)
        return true
    else
        return false
    end
end

---Returns the chest peripherals
---@return table chests
local function getChests()
    return chests
end

---Returns the chest names
---@return table chest_names
local function getChestNames()
    return chest_names
end

---Updates the chests and chest_names indexs
local function indexChests()
    chests = {}
    for i1 = 1, #chest_types do
        for i,v in pairs(table.pack(peripheral.find(chest_types[i1]))) do
            if type(v) ~= "number" then
                if type(ignore_chests[peripheral.getName(v)]) == "nil" then
                    table.insert(chests,v)
                end
            end
        end
    end
    chest_names = {}
    for i = 1, #chests do
        local name = peripheral.getName(chests[i])
        table.insert(chest_names,name)
    end
end

---Finds the first avaliable chest with a free slot
---@return boolean success Did we find a free slot in a chest
---@return table|nil chestPeripheral The chest peripheral with a free slot, or nil
---@return table|nil avaliableSlots How many slots are free, or nil
local function findAvaliableChest()
    for i = 1, #chests do
        if table.maxn(chests[i].list()) < chests[i].size() then
            return true, chests[i], chests[i].size() - table.maxn(chests[i].list())
        end
    end
    return false, nil, nil
end

---Helper function to quickly complete all coroutines given
---@param coroutines table
local function executeCorutines(coroutines,shouldSleep)
    shouldSleep = shouldSleep or false
    -- Resume all coroutines
    while #coroutines > 0 do
        for i3 = #coroutines, 1, -1 do
            local co = coroutines[i3]
            local success, err = coroutine.resume(co)
            if not success then
                print("Error in coroutine:", err)
            end

            -- Check if the coroutine is dead and remove it from the list
            if coroutine.status(co) == "dead" then
                table.remove(coroutines, i3)
            end
        end
        if shouldSleep then
            sleep(0)
        end
    end
end

---Updates all items and their associated data in the item index
---@param updateDisplayNameIndex? boolean optional (and slow)
local function updateItemIndex(updateDisplayNameIndex)
    updateDisplayNameIndex = updateDisplayNameIndex or false
    item_index = {}
    local function createCoroutines()
        local coroutines = {}
        local lists = {}
        for i2, v2 in pairs(chests) do
            if type(v2) == "table" then
                table.insert(lists,v2.list())
            end
        end
        for i = 1, #chests do
            local co = coroutine.create(function()
                local list = lists[i]
                for slot, item in pairs(list) do
                    if type(item) ~= "nil" then
                        table.insert(item_index,{slot=slot,name=item.name,count=item.count,chest = chest_names[i],chest_index = i,chest_p=chests[i]})  
                    end
                end
            end)
            coroutines[#coroutines + 1] = co
        end
        return coroutines
    end
    

    -- Create coroutines
    local coroutines = createCoroutines()
    executeCorutines(coroutines)
    if updateDisplayNameIndex then
        for i = 1, #item_index do
            local item = item_index[i]
            if type(displayNameIndex[item.name]) == "nil" then
                local details = chests[item.chest_index].getItemDetail(item.slot)
                displayNameIndex[item.name] = details.displayName
            end
        end
    end
end

---Gets the display name for the specified item name
---@param item_name string Item id
---@return string|nil displayName Display name of specified item id, or nil
local function getDisplayName(item_name)
    return displayNameIndex[item_name]
end

---Finds a item and its associated data.
---@param item_name string Name of item
---@param count integer How many of the item
---@param fuzzySearch? boolean should fuzzy search be used (defaults to false)
---@return boolean  success Did we find a item meeting the requirements
---@return table|nil item_data Data related to the found item, or returns nil
local function findItem(item_name,count,fuzzySearch)
    fuzzySearch = fuzzySearch or false
    for i = #item_index, 1, -1 do
        local item = item_index[i]
        if (item.name == item_name or (fuzzySearch and lev.levenshtein(item.name,item_name) < 3)) and item.count >= count then
            local real_data = chests[item_index[i].chest_index].getItemDetail(item.slot)
            if type(real_data) == "nil" then
                table.remove(item_index,i)
                break
            end
            if real_data.count ~= item_index[i].count then
                item_index[i].count = real_data.count
                if item_index[i].count < count then
                    break
                end
            end
            if real_data.name ~= item_index[i].name then
                item_index[i].name = real_data.name
                break
            end
            return true, item_index[i]
        end
    end
    return false, nil
end

---Updates all item counts for items in the system
local function updateItemCounts()
    itemCounts = {}
    for i = 1, #item_index do
        local item = item_index[i]
        if type(itemCounts[item.name]) ~= "nil" then
            itemCounts[item.name] = itemCounts[item.name] + item.count
        else
            itemCounts[item.name] = item.count
        end
    end
end


---Gets the item count of a specific item
---@param item_name string Name of item
---@return integer count How many of the item were found
local function getItemCount(item_name)
    local count = 0
    if type(itemCounts[item_name]) ~= "nil" then
        count = itemCounts[item_name]
    end
    return count
end


---Searches for items with the item_name key
---@param item_name string Name of item
---@return table results Name and count of found items, plus field n representing the size
local function searchItems(item_name)
    local results = {}
    local size = 0
    for item,count in pairs(itemCounts) do
        if string.find(item, item_name, 1, true) then
            results[item] = count
            size = size + 1
        end
    end
    results.n = size
    return results
end

---Imports items from a specific slot of a provided chest
---@param fromChest string Name of chest
---@param slot integer Valid slot
---@param count integer How many of the item
local function importItems(fromChest, slot, count)
    local success, output = findAvaliableChest()
    if success then
        local chest_index = 0
        for i = #item_index, 1, -1 do
            if item_index[i].chest == peripheral.getName(output) then
                chest_index = item_index[i].chest_index
                table.remove(item_index,i)
            end
        end
        local i = chest_index
        local transferredCount = output.pullItems(fromChest,slot,count,1)
        if transferredCount == 0 then
            transferredCount = output.pullItems(fromChest,slot,count)
        end
        local list = output.list()
        for s, item in pairs(list) do
            table.insert(item_index,{slot=s,name=item.name,count=item.count,chest = chest_names[i],chest_index = i,chest_p=chests[i]})  
        end
    end
    updateItemCounts()
end

---Exports items to a specific chest with an optional specific slot and count
---@param toChest string Name of chest
---@param item_name string Valid item name
---@param count? integer Count (defaults to 64)
---@param toSlot? integer The Slot to export to (defaults to 1)
local function exportItems(toChest, item_name, count, toSlot)
    count = count or 64
    toSlot = toSlot or 1
    local success, item_data = findItem(item_name,count)
    if success then
        local transferCount = chests[item_data.chest_index].pushItems(toChest,item_data.slot,count,toSlot)
        if transferCount == 0 then
            transferCount = chests[item_data.chest_index].pushItems(toChest,item_data.slot,count)
        end
        for i = #item_index, 1, -1 do
            local item = item_index[i]
            if item_data.chest == item.chest and item_data.chest_index == item.chest_index and item_data.slot == item.slot and item_data.count == item.count then
                item.count = item.count - transferCount
                itemCounts[item.name] = itemCounts[item.name] - transferCount
                if item.count == 0 then
                    table.remove(item_index,i)
                elseif item.count < 0 then
                    table.remove(item_index,i)
                    break
                else
                    item_index[item.name] = item.count
                end
                return true
            end
        end
    else
        return false
    end
end

---Imports all items from all import_chests specified in the filter
local function importFromChests()
    local success,output, slots = findAvaliableChest()
    local avaliableSlots = slots
    for i = 1, #import_chests do
        local list = peripheral.call(import_chests[i],"list")
        for slot, item in pairs(list) do
            if avaliableSlots == 0 then
                success,output, slots = findAvaliableChest()
            end
            if success then
                avaliableSlots = avaliableSlots - 1
                importItems(import_chests[i],slot,item.count)
            end
        end
    end
end

---Refrehes the chest index and updates all item counts
---@param updateDisplayNameIndex? boolean optional (and sloww)
local function refresh(updateDisplayNameIndex)
    updateDisplayNameIndex = updateDisplayNameIndex or false
    local success = loadStorageIndex()
    if not success then
        --print("StorageAPI: Existing save not found.")
    end
    -- First we get all the chests in the network
    indexChests()
    -- Then we have to index all the item data like the count and locations
    updateItemIndex(updateDisplayNameIndex)
    -- Finally we update the overall item counts for every item type
    -- We have to do this last because it realies on the item index being accurate first
    updateItemCounts()
end

return {
    saveDisplayNames = saveDisplayNames,
    loadDisplayNames = loadDisplayNames,
    getDisplayName = getDisplayName,
    importItems = importItems,
    exportItems = exportItems,
    refresh = refresh,
    setIgnoredChests = setIgnoredChests,
    setImportChests = setImportChests,
    indexChests = indexChests,
    findAvaliableChest = findAvaliableChest,
    importFromChests = importFromChests,
    findItem = findItem,
    updateItemIndex = updateItemIndex,
    getItemCount = getItemCount,
    searchItems = searchItems,
    updateItemCounts = updateItemCounts
}