local ws = nil
local helper = {}

local hooks = {
}

local function init(webSock, helper_functions)
    ws = webSock
    helper = helper_functions

    print("Initalizing Secure Channel plugin!")
    helper.sendMessage("#null-turtle-cont","Hello, world!")
end

return {init = init, hooks = hooks}