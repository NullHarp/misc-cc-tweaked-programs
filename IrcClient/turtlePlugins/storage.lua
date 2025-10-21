local ws = nil
local helper = {}

local hooks = {
    onMessage = {

    },
    mainLoop = {

    }
}

local storageApi = nil

local function interactStorage(message_data,sender)
    local words = string.gmatch(message_data, "%S+")
    local args = {}

    for arg in words do
        table.insert(args,arg)
    end

    local command = args[1]
    if command and sender == "Null" then
        if command == "Search" then -- GetPlayerPos
            local name = helper.getName()
            if type(args[2]) == "string" then
                local search = args[2]
                if search == "All" then
                    search = ""
                end
                local data = storageApi.searchItems(search)
                if data then
                    local resp = ""
                    for na, count in pairs(data) do
                        if na ~= "n" then
                            resp = resp..na..": "..tostring(count).."; "
                        end
                    end
                    helper.sendMessage("Null","Search :SUCCESS "..resp)
                end
            else
                helper.sendMessage("Null","Search :FAIL No item specified.")
            end
        end
    end
end

local function init(webSock, helper_functions)
    ws = webSock
    helper = helper_functions

    storageApi = require("storageAPI")

    print("Initalizing Storage plugin!")
    storageApi.refresh()
    table.insert(hooks.onMessage,interactStorage)
end

return {init = init, hooks = hooks}