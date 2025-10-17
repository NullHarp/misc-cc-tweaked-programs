local ws = nil
local helper = {}

local hooks = {
    onMessage = {

    }
}

local generic_lookup = {
    P = turtle.place,
    PU = turtle.placeUp,
    PD = turtle.placeDown,

    Di = turtle.dig,
    DiU = turtle.digUp,
    DiD = turtle.digDown,

    I = turtle.inspect,
    IU = turtle.inspectUp,
    ID = turtle.inspectDown,

    S = turtle.suck,
    SU = turtle.suckUp,
    SD = turtle.suckDown,

    Dp = turtle.drop,
    DpU = turtle.dropUp,
    DpD = turtle.dropDown,

    Rf = turtle.refuel,

    GFLev = turtle.getFuelLevel,
    GFLim = turtle.getFuelLimit,

    GSelSlot = turtle.getSelectedSlot,

    Sel = turtle.select,
    TTo = turtle.transferTo
}

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

    local command = args[1] or ""
    local data = string.sub(message_data,#command+2)

    local count

    if tonumber(data) then
        count = tonumber(data)
    end

    if command and (sender == "Null" or sender == "Controler" or sender == "ControlerExtended") then
        if generic_lookup[command] then
            local success, result,result2 = pcall(generic_lookup[command],count)
            if result2 then
                if result2["tags"] then
                    result2 = result2.name
                end
            else
                result2 = ""
            end

            if success then
                helper.sendNotice(sender,command.." :SUCCESS "..tostring(result).." "..tostring(result2))
            else
                helper.sendNotice(sender,command.." :FAIL "..tostring(result).." "..tostring(result2))
            end
        elseif command == "Inventory" then
            local compact_inv = getInventory()
            helper.sendNotice(sender,command.." "..compact_inv)
        end
    end
end

local function init(webSock, helper_functions)
    ws = webSock
    helper = helper_functions

    print("Initalizing Extended Functionality plugin!")
    table.insert(hooks.onMessage,extendedCommands)
end

return {init = init, hooks = hooks}