local ws = nil
local helper = {}

local monitor = nil

local hooks = {
    onMessage = {},
    mainLoop = {}
}

local function debugPrint(message)
    local old_term = term.redirect(monitor)
    print(message)
    term.redirect(old_term)
end

local function debugSendMessages()
    while true do
        local message = read()
        ws.send(message)
    end
end

local function init(webSock, helper_functions)
    ws = webSock
    helper = helper_functions

    monitor = peripheral.find("monitor")
    if monitor then
        monitor.setTextScale(0.5)
        monitor.clear()
        monitor.setCursorPos(1,1)
        table.insert(hooks.onMessage,debugPrint)
    end
    print("Initalizing Debug plugin!")
    table.insert(hooks.mainLoop,debugSendMessages)
end

return {init = init, hooks = hooks}