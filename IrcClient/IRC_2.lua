local monitor = peripheral.wrap("top")
monitor.clear()
monitor.setCursorPos(1,1)

local url = "wss://hexxytest.hexxy.media:8000"

local ws, err = http.websocket(url)

local capabilities = {"standard-replies"}


print("Username:")
local username = read()
print("Nickname:")
local nickname = read()
print("Realname (Does not have to be real):")
local realname = read()


local hasAccount = false
local attemptRegistration = false
local password = ""


print("Do you have a registered nick? Y/n:")
local registeredNick = string.lower(read())
if registeredNick == "y" or registeredNick == "yes" then
    print("Please insert password:")
    password = read("*")
    hasAccount = true
else
    print("Do you want to register your nick? Y/n:")
    local wantsRegister = string.lower(read())
    if wantsRegister == "y" or wantsRegister == "yes" then
        password = read("*")
        print("Confirm password:")
        local confirmPassword = read("*")
        if password ~= confirmPassword then
            error("Passwords dont match.")
        end
        print("Registration will be attempted for the nick: "..nickname)
        attemptRegistration = true
    end
end

if not ws then
    error(err)
else
    if #capabilities > 0 then
        for index, capability in pairs(capabilities) do
            ws.send("CAP REQ :"..capability)
        end
        ws.send("CAP END")
    end
    ws.send("USER " .. username .. " unused unused " .. realname)
    ws.send("NICK " .. nickname)
end

local function interactNickServ()
    if hasAccount then
        print("Attempting login to "..nickname)
        ws.send("privmsg NickServ IDENTIFY "..password)
        hasAccount = false
    elseif attemptRegistration then
        print("Attempting to register "..nickname)
        ws.send("privmsg NickServ REGISTER "..password)
        attemptRegistration = false
    end
end



local function sendMessage(message)
    local old_term = term.redirect(monitor)
    print(message)
    term.redirect(old_term)
end

local function removePrefix(msg)
    return string.sub(msg,2)
end

local function numericsProcessor(numeric, message,message_orgin)
    local words = string.gmatch(message, "%S+")
    local args = {}

    for arg in words do
        table.insert(args,arg)
    end

    local sender
    -- The client aka the nick of the user
    local client
    -- Content within the actual message
    local message_content

    local command_resp
    if args[1] == nickname then
        client = args[1]
        table.remove(args,1)
    end
    if string.sub(args[1],1,1) ~= ":" then
        if args[1] ~= nickname and args[1] ~= message_orgin then
            command_resp = args[1]
            table.remove(args,1)
        end
    end

    if string.sub(args[1],1,1) == ":" then
        local spacing = 0
        if client then
            spacing = spacing + #client+1
        end
        if command_resp then
            spacing = spacing + #command_resp+1
        end
        message_content = string.sub(message,spacing+2)
    else
        local spacing = 0
        if client then
            spacing = spacing + #client+1
        end
        if command_resp then
            spacing = spacing + #command_resp+1
        end
        message_content = string.sub(message,spacing+1)
    end
    return message_content, client, command_resp
end

local function commandProcessor(message)
    local words = string.gmatch(message, "%S+")
    local command = words()
    local client = words()
    local message_content = ""
    message_content = string.sub(message,#command+1+#client+3)
    return command, message_content, client
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

    if command == "PING" then
        ws.send("PONG "..args[1])
        interactNickServ()
        return
    end
    -- Check if there was a message origin so we can trim it from the front of the message
    if message_origin then
        local message_parse_size = #message_origin+2
        msg = string.sub(msg,message_parse_size+1)
    end
    if command then
        local cmd, msg_data, client = commandProcessor(msg)
        if cmd == "PRIVMSG" then
            local origin_client, origin_nick = processMessageOrigin(message_origin)
            origin_nick = origin_nick or message_origin

            sendMessage(origin_nick.." -> "..client.." | "..msg_data)
        else
            sendMessage(client.." | ["..cmd.."] "..msg_data)
        end
    end
    if numeric then
        local message_parse_size = 4
        local message_content = string.sub(msg,message_parse_size+1)
        local msg_data, client, command_resp =  numericsProcessor(numeric,message_content,message_origin)
        if client and command_resp then
            sendMessage(client.." | ["..command_resp.."] "..msg_data)
        elseif client then 
            sendMessage(client.." | "..msg_data)
        end
    end
end

local function receiverEventLoop()
    while true do
        local message = ws.receive()
        if message then
            processRawMessage(message)
        end
    end
end

local selected_channel = ""

local function messageSendLoop()
    while true do
        local message = read()
        if string.sub(message,1,1) == "/" then
            local words = string.gmatch(message, "%S+")
            local command = string.sub(words(),2)
            command = string.lower(command)
            if command == "quit" then
                ws.send(string.sub(message,2))
                ws.close()
                error("Session terminated.")
            elseif command == "select" or command == "join" then
                if command == "join" then
                    ws.send(string.sub(message,2))
                end
                selected_channel = words()
            else
                ws.send(string.sub(message,2))
            end
        else
            sendMessage(nickname.." -> "..selected_channel.." | "..message)
            ws.send("PRIVMSG "..selected_channel.." :"..message)
        end
    end
end

parallel.waitForAll(receiverEventLoop,messageSendLoop)