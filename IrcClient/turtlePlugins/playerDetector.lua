local ws = nil
local helper = {}

local hooks = {
    onMessage = {

    },
    mainLoop = {

    }
}

local playerDetector = nil

local function useDetector(message_data,sender)
    local words = string.gmatch(message_data, "%S+")
    local args = {}

    for arg in words do
        table.insert(args,arg)
    end

    local command = args[1]
    if command and sender == "Null" then
        if command == "gPP" then -- GetPlayerPos
            local name = helper.getName()
            if type(args[2]) == "string" then
                local data = playerDetector.getPlayerPos(args[2])
                if data then
                    if data.x then
                        helper.sendMessage("Null","gPP :SUCCESS "..args[2].." "..tostring(data.x).." "..tostring(data.y).." "..tostring(data.z).." "..data.dimension)
                    end
                else
                    helper.sendMessage("Null","gPP :FAIL "..args[2].." Player not found")
                end
            end
        elseif command == "lP" then -- list players
            local data = playerDetector.getOnlinePlayers()
            if #data > 0 then
                local list = ""
                for _, v in pairs(data) do
                    list = list..v..";"
                end
                helper.sendMessage("Null","lP :SUCCESS "..list)
            else
                helper.sendMessage("Null","lP :FAIL No players online!")
            end
        end
    end
end

local function init(webSock, helper_functions)
    ws = webSock
    helper = helper_functions

    playerDetector = peripheral.find("playerDetector")
    if not playerDetector then
        error("playerDetector not found!")
    end

    print("Initalizing Player Detector Peripheral plugin!")
    table.insert(hooks.onMessage,useDetector)
end

return {init = init, hooks = hooks}