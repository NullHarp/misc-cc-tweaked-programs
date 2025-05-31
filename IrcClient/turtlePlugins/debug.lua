local ws = nil
local helper = {}

local hooks = {
    mainLoop = {}
}

local function debugSendMessages()
    while true do
        local message = read()
        ws.send(message)
    end
end

local function init(webSock, helper_functions)
    ws = webSock
    helper = helper_functions
    
    print("Initalizing Secure Channel plugin!")
    table.insert(hooks.mainLoop,debugSendMessages)
end

return {init = init, hooks = hooks}