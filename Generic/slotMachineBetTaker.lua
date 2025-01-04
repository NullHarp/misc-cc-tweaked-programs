local modem = peripheral.find("modem")

modem.open(255)

local storage = require("storageAPI")
storage.refresh(false)

local turtle_name = modem.getNameLocal()

local function selectItem(item_name)
    for i = 1, 16 do
        local item_data = turtle.getItemDetail(i)
        if type(item_data) ~= "nil" then
            if item_data.name == item_name then
                turtle.select(i)
                return true, item_data.count, i
            else
                turtle.dropUp()
            end
        end
    end
    return false
end


local function findBet()
    local foundBet = false
    while not foundBet do
        local success, reason = turtle.suckUp()
        local foundItem, count, slot = selectItem("numismatic-overhaul:gold_coin")
        if foundItem then
            if type(count) ~= "nil" and type(slot) ~= "nil" then
                storage.importItems(turtle_name,slot,count)
            end
            local packet = {
                type = "startGame",
                betCount = count
            }
            print("found diamond(s)",count,slot)
            modem.transmit(255,255,packet)
            foundBet = true
        end
    end
end

local payoutCount = 0

local function awaitResults()
    payoutCount = 0
    local noResults = true
    while noResults do
        local event, side, channel, replyChannel, message, distance = os.pullEvent("modem_message")
        if type(message) == "table" then
            if message.type == "gameFinished" then
                if type(message.payoutCount) ~= "nil" then
                    payoutCount = message.payoutCount
                    payoutCount = math.ceil(payoutCount)
                    noResults = false
                end
            end
        end
    end
end

local function givePayout()
    if payoutCount > 0 then
        if storage.getItemCount("numismatic-overhaul:gold_coin") >= payoutCount then
            for i = 1, payoutCount do
                storage.exportItems(turtle_name,"numismatic-overhaul:gold_coin",1,1)
            end
        end
        while selectItem("numismatic-overhaul:gold_coin") do
            local foundItem, count, slot = selectItem("numismatic-overhaul:gold_coin")
            if count > 64 then
                count = 64                
            end
            turtle.dropUp(count)
        end
    end
end

while true do
    findBet()
    print("Found bet")
    awaitResults()
    print("Got results")
    givePayout()
    print("Gave payout")
    sleep(6)
end
