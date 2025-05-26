local ws = nil
local chatBox = nil

local hooks = {
    onMessage = {

    },
    mainLoop = {

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

local function chatSend(message_data,sender)
    local words = string.gmatch(message_data, "%S+")
    local args = {}

    for arg in words do
        table.insert(args,arg)
    end

    local command = args[1]
    local data = string.sub(message_data,#command+2)

    if command == "Chat" then
        chatBox.sendMessage(data,"Gumpai","<>")
    end
end

local function chatRead()
    while true do
        local event, username, message, uuid, isHidden = os.pullEvent("chat")
        sendMessage("Null","Chat "..username..":"..message)
    end
end

local function init(webSock)
    chatBox = peripheral.find("chatBox")
    if not chatBox then
        error("ChatBox not found!")
    end
    ws = webSock
    print("Initalizing ChatBox Peripheral plugin!")
    table.insert(hooks.onMessage,chatSend)
    table.insert(hooks.mainLoop,chatRead)
end

return {init = init, hooks = hooks}