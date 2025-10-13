local ws = nil
local helper = {}

local hooks = {
    mainLoop = {}
}

local function waitForTime()
    sleep(5)
    ws.send("JOIN #Null-turtle-cont")
    helper.sendMessage("#null-turtle-cont","Hello, world!")
end

local function init(webSock, helper_functions)
    ws = webSock
    helper = helper_functions

    print("Initalizing Secure Channel plugin!")
    table.insert(hooks.mainLoop,waitForTime)

end

return {init = init, hooks = hooks}