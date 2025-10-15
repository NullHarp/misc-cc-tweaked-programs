local ws = nil
local helper = {}

local hooks = {
    onMessage = {

    },
    mainLoop = {

    }
}

local chatBox = nil

local function chatSend(message_data,sender)
    local words = string.gmatch(message_data, "%S+")
    local args = {}

    for arg in words do
        table.insert(args,arg)
    end

    local command = args[1]
    if command then
        local data = string.sub(message_data,#command+2)

        if command == "Chat" then
            local name = helper.getName()
            chatBox.sendMessage(data,name,"<>")
        elseif command == "Dm" then
            local name = helper.getName()
            chatBox.sendMessageToPlayer(" whispers: "..string.sub(data,#args[2]+2),args[2],name,"<>")
        end
    end
end

local function chatRead()
    while true do
        local event, username, message, uuid, isHidden = os.pullEvent("chat")
        if isHidden then
            helper.sendMessage("Null","Chat "..username.." whispers: "..message)
        else
            helper.sendMessage("Null","Chat "..username..": "..message)
        end
    end
end

local function init(webSock, helper_functions)
    ws = webSock
    helper = helper_functions

    chatBox = peripheral.find("chatBox")
    if not chatBox then
        error("ChatBox not found!")
    end

    print("Initalizing ChatBox Peripheral plugin!")
    table.insert(hooks.onMessage,chatSend)
    table.insert(hooks.mainLoop,chatRead)
end

return {init = init, hooks = hooks}