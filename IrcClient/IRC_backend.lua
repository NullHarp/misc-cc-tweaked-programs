local url = "wss://hexxytest.hexxy.media:8000"

local ws, err = http.websocket(url)

if err then
    error(err)
end

local accountData = {
    nickname = "",
    awaitingFirstPongResponse = true
}

local helper = {}

---Sends a notice to the specified destination
---@param destination string Valid destination, such as a channel or nick
---@param notice string Notice content to send
function helper.sendNotice(destination,notice)
    if destination and notice then
        ws.send("NOTICE "..destination.." :"..notice)
    end
end

---Sends a message to the specified destination
---@param destination string Valid destination, such as a channel or nick
---@param message string Message content to send
function helper.sendMessage(destination,message)
    if destination and message then
        ws.send("PRIVMSG "..destination.." :"..message)
    end
end

---Parses the UTC timestamp provided by a message-tag in the time tag
---@param timestamp string A string representing the UTC timestamp provided by the server
---@param utc_offset integer A integer representing how much to offset the time, if any
---@return table time_data Year, Month, Day, Hour, Minute, Second, Milisecond
local function convertTimestamp(timestamp,utc_offset)
    local time_data = {}

    --The number represnting the end of the date section, and the start of the time
    local date_end = string.find(timestamp,"T")
    --String representing unparsed YYYY-MM-DD 
    local date = string.sub(timestamp,1,date_end-1)
    local date_func = string.gmatch(date, "([^-]+)")

    time_data.year = date_func()
    time_data.month = date_func()
    time_data.day = date_func()

    --String representing unparsed HH:MM:SS.sss
    local time = string.sub(timestamp,date_end+1,#timestamp-1)
    local time_func = string.gmatch(time, "([^:]+)")

    time_data.hour = time_func()
    time_data.minute = time_func()

    local secondAndMilisecond = string.gmatch(time_func(),"([^.]+)")
    time_data.second = secondAndMilisecond()
    time_data.milisecond = secondAndMilisecond()

    --Offsets the current hour based on the UTC Offset
    time_data.hour = time_data.hour+utc_offset

    --Because the current hour can only be 0 - 24 and offseting it with another number can push it out of bounds,
    --we should change the date and hour accordingly to refelect this and prevent overflow / undervalue
    if time_data.hour > 24 then
        time_data.day = time_data.day + 1
        time_data.hour = 24
    elseif time_data.hour < 0 then
        time_data.day = time_data.day - 1
        time_data.hour = time_data.hour + 24
    end

    return time_data
end

---Removes the prefix from the message_origin
---@param msg string Message to remove prefix from
---@return string non_prefixed_message Message without the prefix
local function removePrefix(msg)
    if string.sub(msg,1,1) == ":" then
            return string.sub(msg,2)
    end
    return msg
end

---Processes provided message to parse any tags
---@param raw_message string
---@return table tags A table containing all tags within the message (if any)
---@return integer The length of the raw tags message, before parsing
local function processTags(raw_message)
    --We do this to remove the '@' tag at the begining of the message which marks the start of the tags
    raw_message = string.sub(raw_message,2)
    --We split the tags from the rest of the message, the first call of words() represents the unparsed tags string
    local words = string.gmatch(raw_message, "%S+")

    local tags = {}
    local tag_string = words()
    --We loop through all the tags and begin parsing for additional values, since tags can have a value
    for tag in string.gmatch(tag_string, "([^;]+)") do
        print(tag)
        if string.find(tag,"=",1,true) then
            --We find the = sign in the tag, if it exists then that means there is a key and a value, otherwise its just the key
            local start = string.find(tag,"=",1,true)
            if start then
                local key = string.sub(tag,1,start-1)
                local value = string.sub(tag,start+1)
                tags[key] = value
            end
        else
            tags[tag] = true
        end
    end

    return tags, #tag_string
end

---Processes numerics, a special type of message sent by the server in response to certain actions
---@param numeric number NYI
---@param message string The message to process the numeric of
---@param message_orgin string The origin of the message
---@return string message_content
---@return string message_destination
---@return string command_resp
local function numericsProcessor(numeric, message,message_orgin)
    local words = string.gmatch(message, "%S+")
    local args = {}

    for arg in words do
        table.insert(args,arg)
    end

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

    --Is this the start of the 'message_origin'
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
    --The specific command that was returned, ex QUIT, NOTICE, PRIVMSGs
    local command = words()

    --The destination for the command, like a channel or a specific nick
    local message_destination = words()

    local message_content = ""
    message_content = string.sub(message,#command+1+#message_destination+2)
    message_content = removePrefix(message_content)

    return command, message_content, message_destination
end

---Given the message origin, if a nick / user exist within it, parses them, otherwise returns nil
---@param message_origin string The origin of the message, represented as a string
---@return string|nil origin_client The client who sent the message
---@return string|nil origin_nick The nick of the client who sent the message
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
---@param msg string The raw message received via the websocket connection
---@return string msg_data The data found within the message
---@return string|nil message_destination The target destination of the message
---@return string command The command of the message
---@return number|nil numeric The numeric of the message
---@return string|nil message_origin Who sent the message
---@return table|nil tags Optional tags the message may have had, assuming message-tags capability was negotiated
local function processRawMessage(msg)
    -- May be nil. represents the tags found within the message
    local tags
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
    
    if string.sub(args[1],1,1) == "@" then
        -- This code-path means we have a tag(s)
        local tag_len = 0
        tags,tag_len = processTags(msg)
        table.remove(args,1)
        msg = string.sub(msg,tag_len+3)
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

    if command == "PING" then
        ws.send("PONG "..args[1])
        -- This exists because some commands can not be used before the first pong response is sent
        if accountData.awaitingFirstPongResponse then
            accountData.awaitingFirstPongResponse = false
        end
        return removePrefix(args[1]), nil, command, nil, nil, tags
    end
    -- Check if there was a message origin so we can trim it from the front of the message
    if message_origin then
        local message_parse_size = #message_origin+2
        msg = string.sub(msg,message_parse_size+1)
    end
    if command then
        local cmd, msg_data, message_destination = commandProcessor(msg)
        return msg_data, message_destination, cmd, nil, message_origin, tags
    end
    if numeric then
        local message_parse_size = 4
        local message_content = string.sub(msg,message_parse_size+1)
        local msg_data, message_destination, command_resp =  numericsProcessor(numeric,message_content,message_origin)
        return msg_data, message_destination, command_resp, numeric, message_origin, tags
    end
end

return {helper = helper, convertTimestamp = convertTimestamp, accountData = accountData,numericsProcessor = numericsProcessor, commandProcessor = commandProcessor, processRawMessage = processRawMessage, processMessageOrigin = processMessageOrigin, ws = ws, err=err}