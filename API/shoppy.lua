--NullHarp 2025 M.I.T License
--Shoppy, shops made easy

local storage = require("storageAPI")
local buttons = require("buttonAPI")

local items = {}

local modem = peripheral.find("modem")

local shop_monitor = {}

local turtle_name = modem.getNameLocal()

local importBlock = false
local insertedFunds = 0

local pressedBuyButton = ""
local pressedFundsButton = ""

local isShopInitialized = false

---Internal helper function for finding items
---@param item_name string In the format of a minecraft id, ex minecraft:dirt
---@return boolean foundItem Did we find an item with that name
---@return integer|nil item_count Returns the count of the found item, or nil
---@return integer|nil slot Returns the slot of the found item, or nil
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
    return false, nil, nil
end

---Adds an item to the shop's item index
---@param item_name string In the format of a minecraft id, ex minecraft:dirt
---@param count integer How many of the item do you get for purchasing it
---@param cost integer How much money does the item cost
local function addItem(item_name, count, cost)
    items[item_name] = {count=count,cost=cost}
end

---Initalizes the shop if it isint already
local function constructShop()
    if not isShopInitialized then
        storage.refresh(true)
        local yOffset = 1
        for item_name, item in pairs(items) do
            buttons.newButton(shop_monitor,"buy",1,yOffset,"Buy",item_name,colors.green,colors.white,colors.red)
            yOffset = yOffset + 1
        end
        local sizeX, sizeY = shop_monitor.getSize()
        buttons.newButton(shop_monitor,"funds",1,sizeY,"Export Funds","exportMoney",colors.green,colors.white,colors.red)
    end
end

---Draws the shop UI
local function drawShop()
    local sizeX, sizeY = shop_monitor.getSize()
    local yOffset = 1
    for item, itemData in pairs(items) do
        shop_monitor.setCursorPos(5,yOffset)
        shop_monitor.setTextColor(colors.black)
        if yOffset % 2 == 0 then
            shop_monitor.setBackgroundColor(colors.lightGray)
        else
            shop_monitor.setBackgroundColor(colors.white)
        end
        shop_monitor.clearLine(yOffset)
        shop_monitor.write(storage.getDisplayName(item).." x "..tostring(itemData.count).." | Cost: "..tostring(itemData.cost).." In Stock: "..tostring(storage.getItemCount(item)))
        yOffset = yOffset + 1
    end
    local text = "Current Funds: "..tostring(insertedFunds)
    shop_monitor.setCursorPos(sizeX-#text,sizeY)
    shop_monitor.setBackgroundColor(colors.gray)
    shop_monitor.setTextColor(colors.lightGray)
    shop_monitor.clearLine()
    shop_monitor.write(text)
    buttons.drawButtons("buy",pressedBuyButton)
    buttons.drawButtons("funds",pressedFundsButton)
end

---Processes payments via the button API
local function processBuy()
    while true do
        drawShop()
        local event, side, x , y = os.pullEvent("monitor_touch")
        if side == peripheral.getName(shop_monitor) then
            pressedBuyButton = buttons.processButtons(x,y,"buy")
            pressedBuyButton = pressedBuyButton or ""
            pressedFundsButton = buttons.processButtons(x,y,"funds")
            pressedFundsButton = pressedFundsButton or ""
            if pressedBuyButton ~= "" then
                drawShop()
                if storage.getItemCount(pressedBuyButton) >= items[pressedBuyButton].count then
                    --Procede with purchasing because we have more then the minimum
                    if insertedFunds >= items[pressedBuyButton].cost then
                        local success = storage.exportItems(turtle_name,pressedBuyButton,items[pressedBuyButton].count,1)
                        if success then
                            local foundItem, count, slot = selectItem(pressedBuyButton)
                            if foundItem then
                                turtle.select(slot)
                                turtle.drop(count)
                                insertedFunds = insertedFunds - items[pressedBuyButton].cost
                            end
                        end
                    end
                end
                pressedBuyButton = ""
            end
            if pressedFundsButton ~= "" then
                drawShop()
                if pressedFundsButton == "exportMoney" then
                    local success = storage.exportItems(turtle_name,"numismatic-overhaul:gold_coin",insertedFunds,1)
                    if success then
                        importBlock = true
                        turtle.select(1)
                        if insertedFunds > 64 then
                            turtle.drop(64)
                            turtle.drop()
                        else
                            turtle.drop(insertedFunds)
                        end
                        insertedFunds = 0
                        importBlock = false
                    end
                end
                pressedFundsButton = ""
            end
        end
    end
end

---Collects money placed in front of the turtle and ejects everything else
local function processFunds()
    while true do
        turtle.suck()
        for i = 1, 16 do
            local itemData = turtle.getItemDetail()
            if type(itemData) ~= "nil" then
                if itemData.name ~= "numismatic-overhaul:gold_coin" then
                    turtle.select(i)
                    turtle.drop()
                else
                    if not importBlock then
                        insertedFunds = insertedFunds + itemData.count
                        storage.importItems(turtle_name,i,itemData.count)
                        drawShop()
                    end
                end
            end
        end
    end
end

---Gets the shop items table containing the name, count, and cost
---@return table shop_items
local function getItems()
    return items
end

---Sets the monitor for the shop to display on
---@param monitor table Monitor peripheral
local function setShopMonitor(monitor)
    shop_monitor = monitor
end


--Example usage of the api:
--addItem("minecraft:dirt",4,1)
--constructShop()

--parallel.waitForAll(processBuy,processFunds)

return {
    setShopMonitor = setShopMonitor,
    addItem = addItem,
    getItems = getItems,
    constructShop = constructShop,
    processBuy = processBuy,
    processFunds = processFunds
}