local ws = nil
local chatBox = nil

local hooks = {
    onMessage = {

    }
}

---Should ONLY be used for automatic-replies
---@param destination any
---@param response any
local function sendResponse(destination,response)
    if destination and response then
        ws.send("NOTICE "..destination.." :"..response)
    end
end

---Should ONLY be used for initiating-conversation
---@param destination any
---@param message any
local function sendMessage(destination,message)
    if destination and message then
        ws.send("PRIVMSG "..destination.." :"..message)
    end
end

local function getInventory()
    local slots = {}
    for i = 1, 16 do
        slots[i] = turtle.getItemDetail(i)
        slots[i] = slots[i] or false
    end

    local compact = ""

    for index, item in pairs(slots) do
        if item then
            compact = compact..tostring(item.count).."."..item.name..","
        else
            compact = compact.."0,"
        end
    end

    return compact
end

local function extendedCommands(message_data,sender)
    local words = string.gmatch(message_data, "%S+")
    local args = {}

    for arg in words do
        table.insert(args,arg)
    end

    local command = args[1]
    local data = string.sub(message_data,#command+2)

    local count

    if tonumber(data) then
        count = tonumber(data)
    end

    local generic_lookup = {
        Place = turtle.place,
        PlaceUp = turtle.placeUp,
        PlaceDownn = turtle.placeDown,

        Dig = turtle.dig,
        DigUp = turtle.digUp,
        DigDown = turtle.digDown,

        Inspect = turtle.inspect,
        InspectUp = turtle.inspectUp,
        InspectDown = turtle.inspectDown,

        Suck = turtle.suck,
        SuckUp = turtle.suckUp,
        SuckDown = turtle.suckDown,

        Drop = turtle.drop,
        DropUp = turtle.dropUp,
        DropDown = turtle.dropDown,

        Refuel = turtle.refuel,

        GetFuelLevel = turtle.getFuelLevel,
        GetFuelLimit = turtle.getFuelLimit,

        GetSelectedSlot = turtle.getSelectedSlot,

        Select = turtle.select,
        TransferTo = turtle.transferTo
    }

    if generic_lookup[command] then
        local result,result2 = generic_lookup[command](count)
        if result2 then
            if result2["tags"] then
                result2 = result2.name
            end
        else
            result2 = ""
        end

        sendResponse(sender,command.." "..tostring(result).." "..tostring(result2))
    elseif command == "Inventory" then
        local compact_inv = getInventory()
        sendResponse(sender,command.." "..compact_inv)
    end
end

local function init(webSock)
    ws = webSock
    print("Initalizing Extended Functionality plugin!")
    table.insert(hooks.onMessage,extendedCommands)
end

return {init = init, hooks = hooks}