local ws = nil

local hooks = {
    onMessage = {

    }
}

---Function to demonstate how hooks work
---@param message_data string onMessage hooks get passed the message data by default
local function testFunc(message_data)
    print("test ->",message_data)
end

---The init for the plugin, do any setup inside this function rather than the main program execution
---@param webSock table Represents the websocket handle, gets passed to all inits
local function init(webSock)
    ws = webSock
    print("Initalizing test plugin!")
    table.insert(hooks.onMessage,testFunc)
end

return {init = init, hooks = hooks}