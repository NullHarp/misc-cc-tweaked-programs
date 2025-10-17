local ws = nil
local helper = {}

local hooks = {
    onMessage = {

    }
}

local function executeFunc(message_data,sender)
    local words = string.gmatch(message_data, "%S+")
    local args = {}

    for arg in words do
        table.insert(args,arg)
    end

    local command = args[1]
    if command then
        local data = string.sub(message_data,#command+2)

        if sender == "Null" then
            if command == "Exec" then
                local cmd = loadstring(data)
                if not cmd then
                    helper.sendMessage("Null","Exec :FAIL Invalid command.")
                    return
                end
                local results = {pcall(cmd)}
                if results[1] == true then
                    local res_str = ""
                    for _, v in pairs(results) do
                        if type(v) ~= "table" then
                            res_str = res_str..tostring(v).." "
                        else
                            res_str = res_str..textutils.serialiseJSON(v).." "
                        end
                    end
                    helper.sendMessage("Null","Exec :SUCCESS "..res_str)
                else
                    helper.sendMessage("Null","Exec :FAIL "..results[2])
                end
            end
        end
    end
end

local function init(webSock, helper_functions)
    ws = webSock
    helper = helper_functions

    print("Initalizing Execution plugin!")
    table.insert(hooks.onMessage,executeFunc)
    
    _G.shell = shell
    _G.ws = webSock
end

return {init = init, hooks = hooks}