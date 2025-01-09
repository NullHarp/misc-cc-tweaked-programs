local offset = 0
local bubble = require("bubbleSort")
local button = require("buttonAPI")
local util = require("util")
local storage = require("storageAPI")

local craftingService = false
local smeltingService = false
local finerPeripheralsServices = {
    holographicService = false
}

local holopgraph
if finerPeripheralsServices.holographicService then
    holopgraph = peripheral.find("holographic_item_display")
end

local shuttingDown = false

local version = "V0.1.0"

util.title("S.T.A.C.K",version)

---Modem used to comunicate with services on the local network, and to get the turtles local name
local modem = peripheral.find("modem")
--Opens channel 255 for comunication with services
modem.open(255)

local ignored = {"sc-goodies:iron_chest_2"}
local import = {"minecraft:chest_1"}
print("Configuring ignored chests.")
storage.setIgnoredChests(ignored)
print("Configuring import chests.")
storage.setImportChests(import)
print("Checking if display name index exists.")
if not storage.loadDisplayNames() then
    print("Could not find display name index, manually indexing.")
    storage.refresh(true)
    print("Index complete, saving index for future use.")
    storage.saveDisplayNames()
else
    print("Found index, proceding.")
    storage.refresh(false)
end

---Item id of the currently selected item
local selected_item_name = ""

--- What chest to insert items into to be processed by autoFurnace.lua (not included)
local furnace_intake = "minecraft:chest_2"

---Currently typed search input
local input = ""
local old_input = "1"

---Currently typed item count input
local inputCount = ""
local old_inputCount = "1"

---The currently pressed button in buttonAPI
local pressedButton = ""

local sizeX, sizeY = term.getSize()

local slotLock = false

---The overlay UI used for extracting and smelting items
local menuUI = window.create(term.native(),5,3,sizeX-8,sizeY-4)
menuUI.setVisible(false)

local menuSizeX, menuSizeY = menuUI.getSize()

---Creates the buttons for the overlay UI for extracting / smelting items
button.newButton(menuUI,"main",1,menuSizeY,"Request","request",colors.white,colors.black,colors.lightGray)
if smeltingService then
    button.newButton(menuUI,"main",menuSizeX-4,menuSizeY, "Smelt", "smelt", colors.white,colors.black,colors.lightGray)
end

local craftButtonMinX = 0
local craftButtonMaxX = 0

local protected_slots = {}

if type(turtle) == "nil" then
    error("Not a turtle, exiting")
end

---The turtles name on the network
local turtle_name = modem.getNameLocal()

---Are we in craft mode or not (defaults to false)
local craftMode = false
---Are we in the menu or not (defaults to false)
local inMenu = false

---The currently selected item index, is not consistent
local selection = 1
local old_selection = 0

local results = storage.searchItems("")
---The recipes are stored here if the recipe module is active on the network
local recipes = {}

---Draws the extraction overlay UI
local function drawMenu()
    menuUI.redraw()
    menuUI.setBackgroundColor(colors.lightGray)
    menuUI.clear()
    menuUI.setCursorPos(1,1)
    menuUI.setTextColor(colors.white)
    menuUI.setBackgroundColor(colors.gray)
    menuUI.clearLine()
    menuUI.write("Interaction")
    if type(storage.getDisplayName(selected_item_name)) ~= "nil" then
        menuUI.setCursorPos(menuSizeX-#storage.getDisplayName(selected_item_name)-#" "-#tostring(storage.getItemCount(selected_item_name))+1,1)
        menuUI.write(storage.getDisplayName(selected_item_name).." "..storage.getItemCount(selected_item_name))
    else
        menuUI.setCursorPos(menuSizeX-#selected_item_name-#" "-#tostring(storage.getItemCount(selected_item_name)),1)
        menuUI.write(selected_item_name.." "..storage.getItemCount(selected_item_name))
    end
    menuUI.setCursorPos(1,menuSizeY-1)
    menuUI.setBackgroundColor(colors.white)
    if inputCount == "" then
        menuUI.setTextColor(colors.lightGray)
        menuUI.write("64")
    else
        menuUI.setTextColor(colors.black)
        menuUI.write(inputCount)
    end
    menuUI.setBackgroundColor(colors.white)
    button.drawButtons("main",pressedButton)
end

---Draws the background for the main UI
local function drawBackground()
    term.setCursorBlink(false)
    term.setBackgroundColor(colors.lightBlue)
    term.clear()
    term.setCursorPos(1,1)
    term.setBackgroundColor(colors.white)
    term.clearLine()
    term.setBackgroundColor(colors.blue)
    term.setCursorPos(sizeX-14,2)
    term.setTextColor(colors.white)
    term.clearLine()
    term.write("Item \149 Count")
    term.setCursorPos(1,1)
    term.setBackgroundColor(colors.white)
    if input == "" then
        term.setTextColor(colors.lightGray)
        term.write("Type to search...")
    else
        term.setTextColor(colors.black)
        term.write(input)
    end
    term.setTextColor(colors.black)
    term.setCursorPos(sizeX-4,1)
    craftButtonMinX = sizeX-4
    craftButtonMaxX = sizeX
    if not craftMode then
        term.setBackgroundColor(colors.green)
        term.write("Items")
    else
        term.setBackgroundColor(colors.red)
        term.write("Craft")
    end
    term.setBackgroundColor(colors.white)
end

---Draws data in the main UI
---@param data table Numerically indexed table of tables with the values item.name (string) and item.count (number)
local function drawResults(data)
    if not shuttingDown then
        term.setCursorPos(1,3)
        term.setBackgroundColor(colors.lightBlue)
        term.setTextColor(colors.white)
        local counter = 3
        for index, item in pairs(data) do
            if counter <= sizeY+offset and counter-3 >= offset and item.name ~= "n"  then
                if type(storage.getDisplayName(item.name)) ~= "nil" then
                    term.setCursorPos(sizeX-#storage.getDisplayName(item.name)-10,counter-offset)
                else
                    term.setCursorPos(sizeX-#item.name-10,counter-offset)
                end
                if counter == selection+2 then
                    term.setBackgroundColor(colors.blue)
                    term.clearLine()
                    selected_item_name = item.name
                else
                    term.setBackgroundColor(colors.lightBlue)
                    term.clearLine()
                end
                if type(storage.getDisplayName(item.name)) ~= "nil" then
                    term.write(storage.getDisplayName(item.name).." \149 "..tostring(item.count))
                else
                    term.write(item.name.." \149 "..tostring(item.count))
                end
            end
            if item.name ~= "n" then
                counter = counter + 1
            end
        end
        term.setBackgroundColor(colors.white)
        term.setTextColor(colors.black)
    else
        term.clear()
    end
end

local function request(item_name, count)
    -- Request button
    slotLock = true
    count = tonumber(count) or 64
    if count > storage.getItemCount(item_name) then
        count = storage.getItemCount(item_name)
    end
    if type(tonumber(count)) ~= "nil" then
        term.setCursorPos(1,1)
        local freeSlot = -1
        for i = 1, 16 do
            if type(protected_slots[i]) ~= "nil" then
                if protected_slots[i].name == item_name then
                    if protected_slots[i].count + tonumber(count) <= 64 then
                        protected_slots[i].count = protected_slots[i].count + tonumber(count)
                        freeSlot = i
                        break
                    elseif protected_slots[i].count ~= 64 then
                        protected_slots[i].count = 64
                        local transfer = tonumber(count)-protected_slots[i].count
                        table.insert(protected_slots,i+1,{name = item_name, count = transfer})
                        freeSlot = i
                        break
                    end
                end
            else
                table.insert(protected_slots,i,{name = item_name, count = tonumber(count)})
                freeSlot = i
                break
            end
        end
        storage.exportItems(turtle_name,item_name,tonumber(count),freeSlot)
        drawMenu()
    end
    slotLock = false
end

---Handles clicks on the UI, such as pressing buttons
local function clickLoop()
    while not shuttingDown do
        pressedButton = ""
        local event, bt, x, y = os.pullEvent("mouse_click")
        pressedButton = button.processButtons(x,y,"main")
        if y == 1 and x >= craftButtonMinX and x <= craftButtonMaxX and not inMenu and craftingService then
            if craftMode then
                craftMode = false
            else
                craftMode = true
            end
            selection = 1
            old_selection = 0
            offset = 0
            if craftMode then
                modem.transmit(255,255,{type="getRecipes"})
                local event, side, channel, replyChannel, message, distance = os.pullEvent("modem_message")
                if channel == 255 and replyChannel == 255 then
                    if type(message.type) ~= "nil" then
                        if message.type == "recipes" then
                            recipes = message.response
                        end
                    end
                end
            end
        elseif inMenu then
            if pressedButton == "smelt" then
                -- Smelt button
                if type(tonumber(inputCount)) ~= "nil" and smeltingService then
                    storage.exportItems(furnace_intake,selected_item_name,tonumber(inputCount))
                end
            elseif pressedButton == "request" then
                -- Request button
                request(selected_item_name,inputCount)
            end
        end
    end
end

---Handles 'key' / 'scroll' events to control what is currently selected
local function selectionLoop()
    while not shuttingDown do
        local event, arg1, arg2, arg3 = os.pullEvent("key")
        if event == "key" then
            if not inMenu then
                if arg1 == keys.f1 then
                    shuttingDown = true
                    inMenu = false
                    inputCount = ""
                    old_selection = 0
                    menuUI.setVisible(false)
                elseif arg1 == keys.down and selection < results.n then
                    selection = selection + 1
                    if selection > sizeY-2 then
                        offset = offset + 1
                    end
                elseif arg1 == keys.up then
                    selection = selection - 1
                    if offset > 0 then
                        offset = offset - 1
                    end
                elseif arg1 == keys.enter then
                    if craftMode and craftingService then
                        modem.transmit(255,255,{type="queueRecipe",recipe_name=selected_item_name,count=1})
                    else
                        inMenu = true
                        menuUI.setVisible(true)
                        old_selection = 0
                    end
                elseif arg1 == keys.backspace then
                    input = string.sub(input,1,#input-1)
                else
                    local success, char = pcall(string.char,arg1)
                    if success then
                        if #input < 15 then
                            input = input .. char
                        end
                        input = string.lower(input)
                    end
                end
            else
                if arg1 == keys.f1 then
                    inMenu = false
                    inputCount = ""
                    old_selection = 0
                    menuUI.setVisible(false)
                elseif arg1 == keys.backspace then
                    inputCount = string.sub(inputCount,1,#inputCount-1)
                elseif arg1 == keys.enter then
                    pressedButton = "request"
                    sleep(0.1)
                    pressedButton = ""
                    request(selected_item_name,inputCount)
                else
                    local success, char = pcall(string.char,arg1)
                    if success then
                        if type(tonumber(char)) ~= "nil" then
                            inputCount = inputCount .. char
                            if tonumber(inputCount) > 64 then
                                inputCount = "64"
                            end
                        end
                    end
                end
            end
        elseif event == "mouse_scroll" then
            offset = offset + arg1
        end

        if selection > results.n then
            selection = results.n
        end

        if selection < 1 then
            selection = 1
        end
        if offset < 0 then
            offset = 0
        end
        sleep(0)
    end
end

---Refreshes the internal item index as it can be changed by outside action and we dont want to error
local function refreshLoop()
    while not shuttingDown do
        storage.refresh()
        sleep(5)
    end
end

---Handles importing items from the turtles inventory while not importing items that S.T.A.C.K exported
local function importLoop()
    while not shuttingDown do
        for i = 1, 16 do
            if not slotLock then
                if type(protected_slots[i]) == "nil" then
                    if turtle.getItemCount(i) > 0 then
                        storage.importItems(turtle_name,i,64)
                    end
                end
            end
        end
        sleep(0)
    end
end

---Ran when turtle inventory events are found, used to remove no longer protected slots
local function inventoryUpdateLoop()
    while not shuttingDown do
        os.pullEvent("turtle_inventory")
        for i = 16, 1, -1 do
            if not slotLock then
                if type(protected_slots[i]) ~= "nil" then
                    local details = turtle.getItemDetail(i)
                    if type(details) ~= "nil" then
                        if protected_slots[i].name ~= details.name or protected_slots[i].count ~= details.count then
                            table.remove(protected_slots,i)
                        end
                    else
                        table.remove(protected_slots,i)
                    end
                end
            end
        end
    end
end

---Manages displaying of the UI and makes sure everything is visible correctly
local function displayLoop()
    while not shuttingDown do
        button.drawButtons("main",pressedButton)
        if input ~= old_input or selection ~= old_selection or inputCount ~= old_inputCount then
            drawBackground()
            if craftMode then
                results = {}
                for i,v in pairs(recipes) do
                    if i == "n" then
                        results[i] = v
                    else
                        results[i] = v.count
                    end
                end
            else
                results = storage.searchItems(input)
            end
            drawResults(bubble.sort(results))
            drawMenu()
            term.setCursorPos(#input+1,1)
            if not inMenu then
                term.setCursorBlink(true)
            else
                term.setCursorBlink(false)
            end
        end
        old_input = input
        old_selection = selection
        old_inputCount = inputCount
        sleep(0)
    end
end

local function serviceHandler()
    local old_selected_item_name = "123"
    while true do
        if finerPeripheralsServices.holographicService then
            if holopgraph.getOperationCooldown() == 0 then
                if selected_item_name ~= old_selected_item_name then
                    holopgraph.setItem(selected_item_name)
                end
                old_selected_item_name = selected_item_name
            end
        end
        storage.importFromChests()
        sleep(0)
    end
end

drawBackground()
drawResults(bubble.sort(results))

---Activates the core runtime loops
parallel.waitForAny(displayLoop,selectionLoop,clickLoop,refreshLoop,importLoop,inventoryUpdateLoop,serviceHandler)
term.setBackgroundColor(colors.black)
term.setTextColor(colors.white)
shell.run("clear")
shell.run("shell")
--error(setmetatable({}, { __tostring = function() return "Interface exited" end }), 0)