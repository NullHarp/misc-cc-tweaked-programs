local storage = require("storageAPI")

local service_channel = 255
local service_response_channel = service_channel

local timeout = 5

local modem = peripheral.find("modem")
modem.open(service_channel)

local function issueRequest(package,response_type)
    modem.transmit(service_channel,service_response_channel,package)
    local timer_id = os.startTimer(timeout)
    while true do
        local event, arg2, channel, replyChannel, message, distance = os.pullEvent("modem_message")
        if event == "modem_message" then
            if type(message) == "table" then
                if type(message.type) ~= "nil" then
                    if message.type == response_type then
                        if message.success then
                            return true, message
                        else
                            return false, "Operation Failed!"
                        end
                    end
                end
            end
        elseif event == "timer" and arg2 == timer_id then
            return false, "Timeout!"
        end
    end
end

local function refresh()
    local package = {
        type = "requestRefresh"
    }
    local success, data = issueRequest(package,"refreshResponse")
    return success
end

local function requestItemCount(item_name)
    item_name = item_name or ""
    local package = {
        type = "requestItemCount",
        message = item_name
    }
    local success, data = issueRequest(package,"itemCountResponse")
    if success then
        return true, data.count
    else
        return false, nil
    end
end

local function requestItem(item_name,count,fuzzySearch)
    fuzzySearch = fuzzySearch or false
    item_name = item_name or ""
    local package = {
        type = "requestItem",
        name = item_name,
        count = count,
        fuzzySearch = fuzzySearch
    }
    local success, data = issueRequest(package,"itemResponse")
    if success then
        return true, data.item_data
    else
        return false, nil
    end
end

local function requestExport(toChest, item_name, count, toSlot)
    if type(toChest) == "nil" or type(item_name) == "nil" then
        return false, nil
    end
    count = count or -1
    toSlot = toChest or -1
    local package = {
        type = "requestExport",
        toChest = toChest,
        name = item_name,
        count = count,
        toSlot = toSlot
    }
    local success, data = issueRequest(package,"exportResponse")
    if success then
        return true, data.transfer_count
    else
        return false, nil
    end
end

local function requestImport(fromChest, slot, count)
    if type(fromChest) == "nil"then
        return false, nil
    end
    count = count or -1
    slot = slot or -1
    fromChest = fromChest or ""
    local package = {
        type = "requestImport",
        fromChest = fromChest,
        slot = slot,
        count = count,
    }
    local success, data = issueRequest(package,"importResponse")
    if success then
        return true, data.transfer_count
    else
        return false, nil
    end
end

local function pushIgnoredChests(ignoredChests)
    local package = {
        type = "pushIgnoredChests",
        ignoredChests = ignoredChests,
    }
    local success, data = issueRequest(package,"ignoredChestsResponse")
    if success then
        return true
    else
        return false
    end
end

local function pushImportChests(importChests)
    local package = {
        type = "pushImportedChests",
        importChests = importChests,
    }
    local success, data = issueRequest(package,"importedChestsResponse")
    if success then
        return true
    else
        return false
    end
end