local backend = require("IRC_backend")

local ws = backend.ws
local err = backend.err

local monitor = peripheral.wrap("top")
monitor.setTextScale(0.5)
monitor.clear()
monitor.setCursorPos(1,1)

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

local function sendMessage(message,textColor,bgColor)
    if textColor then
        monitor.setTextColor(colors[textColor])
    end
    if bgColor then
        monitor.setTextColor(colors[bgColor])
    end
    local old_term = term.redirect(monitor)
    print(message)
    term.redirect(old_term)
end

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
            error("Passwords don't match.")
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
    backend.accountData.nickname = nickname
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

local function testFunc(message)
    print("testFunc ->",message)
end

--backend.registerSubscriber("onMessage",testFunc)

local function receiverEventLoop()
    while true do
        local message = ws.receive()
        if message then
            local msg_data, message_destination, cmd, numeric, message_origin = backend.processRawMessage(message)
            local origin_client, origin_nick
            if message_origin then
                origin_client, origin_nick = backend.processMessageOrigin(message_origin)
            end

            if cmd and not numeric then
                -- Special exception for this command because it comes from another client and has additional data
                if cmd == "PRIVMSG" then
                    origin_nick = origin_nick or message_origin

                    sendMessage(message_destination.." | <"..origin_nick.."> "..msg_data)
                elseif cmd == "PING" then
                    if not backend.accountData.awaitingFirstPongResponse then
                        interactNickServ()
                    end
                elseif cmd == "QUIT" then
                    sendMessage(origin_nick.." has left. Reason: "..msg_data)
                elseif message_destination then
                    if origin_nick then
                        sendMessage(message_destination.." | <"..origin_nick.."> "..msg_data)
                    else
                        sendMessage(message_destination.." | ["..cmd.."] "..msg_data)
                    end
                else
                    print("Command: "..message)
                end
            end
            if numeric then
                if message_destination and cmd then
                    sendMessage(message_destination.." | ["..cmd.."] "..msg_data)
                elseif message_destination then 
                    sendMessage(message_destination.." | "..msg_data)
                else
                    print("Numeric: "..message)
                end
            end
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