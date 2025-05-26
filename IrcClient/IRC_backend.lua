local url = "wss://hexxytest.hexxy.media:8000"

local ws, err = http.websocket(url)

if err then
    error(err)
end

local accountData = {
    nickname = "",
    awaitingFirstPongResponse = true
}

local subscribers = {
    onMessage = {},
}

local function executeSubscribers(subscribers_list, data)
    for index, funct in pairs(subscribers[subscribers_list]) do
        funct(data)
    end
end

local function registerSubscriber(subscriber_type,func)
    table.insert(subscribers[subscriber_type],func)
end

local function removePrefix(msg)
    if string.sub(msg,1,1) == ":" then
            return string.sub(msg,2)
    end
    return msg
end

local function numericsProcessor(numeric, message,message_orgin)
    local words = string.gmatch(message, "%S+")
    local args = {}

    for arg in words do
        table.insert(args,arg)
    end

    local sender
    -- The message destination
    local message_destination
    -- Content within the actual message
    local message_content

    local command_resp
    if args[1] == accountData.nickname then
        message_destination = args[1]
        table.remove(args,1)
    end
    if string.sub(args[1],1,1) ~= ":" then
        if args[1] ~= message_destination and args[1] ~= message_orgin then
            command_resp = args[1]
            table.remove(args,1)
        end
    end

    if string.sub(args[1],1,1) == ":" then
        local spacing = 0
        if message_destination then
            spacing = spacing + #message_destination+1
        end
        if command_resp then
            spacing = spacing + #command_resp+1
        end
        message_content = string.sub(message,spacing+2)
    else
        local spacing = 0
        if message_destination then
            spacing = spacing + #message_destination+1
        end
        if command_resp then
            spacing = spacing + #command_resp+1
        end
        message_content = string.sub(message,spacing+1)
    end
    return message_content, message_destination, command_resp
end

---Processes command response messages into the pure data within the message
---@param message string 
---@return string command
---@return string message_content
---@return string message_destination
local function commandProcessor(message)
    local words = string.gmatch(message, "%S+")
    local command = words()
    local message_destination = words()
    local message_content = ""
    message_content = string.sub(message,#command+1+#message_destination+2)
    message_content = removePrefix(message_content)
    return command, message_content, message_destination
end

local function processMessageOrigin(message_origin)
    local origin_client
    local origin_nick

    local nick_end = string.find(message_origin,"!")
    local client_end = string.find(message_origin,"@")
    if nick_end then
        origin_nick = string.sub(message_origin,1,nick_end-1)
    end
    if nick_end and client_end then
        origin_client = string.sub(message_origin,nick_end+1,client_end-1)
    end
    return origin_client, origin_nick
end

---Processes raw messages into the associated data
---@param msg string
---@return string msg_data
---@return string|nil message_destination
---@return string command
---@return number|nil numeric
---@return string|nil message_origin
local function processRawMessage(msg)
    -- May be nil, represents the origin of the message
    local message_origin
    -- May be nil, represents the numeric of the command
    local numeric
    -- May be nil, represents the command included in the message
    local command

    local words = string.gmatch(msg, "%S+")
    local args = {}

    for arg in words do
        table.insert(args,arg)
    end

    -- Extracts the origin prefix if it exists
    if string.sub(msg,1,1) == ":" then
        message_origin = removePrefix(args[1])
        table.remove(args,1)
    end
    -- Checks if the arg is a numeric, if it is, extracts it
    if tonumber(args[1]) then
        numeric = tonumber(args[1])
        table.remove(args,1)
    else
        -- Assumes the arg is a command and not a numeric
        command = args[1]
        table.remove(args,1)
    end

    executeSubscribers("onMessage",msg)

    if command == "PING" then
        ws.send("PONG "..args[1])
        -- This exists because some commands can not be used before the first pong response is sent
        if accountData.awaitingFirstPongResponse then
            accountData.awaitingFirstPongResponse = false
        end
        return removePrefix(args[1]), nil, command, nil, nil
    end
    -- Check if there was a message origin so we can trim it from the front of the message
    if message_origin then
        local message_parse_size = #message_origin+2
        msg = string.sub(msg,message_parse_size+1)
    end
    if command then
        local cmd, msg_data, message_destination = commandProcessor(msg)
        return msg_data, message_destination, cmd, nil, message_origin
    end
    if numeric then
        local message_parse_size = 4
        local message_content = string.sub(msg,message_parse_size+1)
        local msg_data, message_destination, command_resp =  numericsProcessor(numeric,message_content,message_origin)
        return msg_data, message_destination, command_resp, numeric, message_origin
    end
end

return {registerSubscriber = registerSubscriber, accountData = accountData,numericsProcessor = numericsProcessor, commandProcessor = commandProcessor, processRawMessage = processRawMessage, processMessageOrigin = processMessageOrigin, ws = ws, err=err}