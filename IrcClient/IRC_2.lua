local backend = require("IRC_backend")
local specRead = require("specialRead")

local utc_offset = -4

local ws = backend.ws
local err = backend.err

local monitor = peripheral.wrap("top")
monitor.setTextScale(0.5)

local monSizeX, monSizeY = monitor.getSize()

local display_box = window.create(monitor,1,1,monSizeX,monSizeY-4)
local msg_box = window.create(monitor,1,monSizeY-3,monSizeX,monSizeY)

local keyboard = peripheral.wrap("right")

if keyboard then
    if keyboard.setFireNativeEvents then
        keyboard.setFireNativeEvents(true)
    end
end

local capabilities = {"standard-replies","message-tags","server-time","echo-message"}

local messages = {}

local currently_typing = {}

local hasAccount = false
local attemptRegistration = false
local password = ""

local username = ""
local nickname = ""
local realname = ""

local function sendMessage(message,tags,textColor,bgColor)
    local old_term = term.redirect(display_box)
    if textColor then
        term.setTextColor(colors[textColor])
    end
    if bgColor then
        term.setBackgroundColor(colors[bgColor])
    end
    if tags then
        if tags["time"] then
            local date = backend.convertTimestamp(tags["time"],utc_offset)
            local formated_date = date.hour..":"..date.minute
            message = "<["..formated_date.."]> "..message
        end
    end

    print(message)

    term.setBackgroundColor(colors.black)
    term.setTextColor(colors.white)
    term.clearLine()
    term.redirect(old_term)
end

local function interactNickServ()
    if hasAccount then
        print("Attempting login to "..nickname)
        ws.send("NS IDENTIFY "..password)
        hasAccount = false
    elseif attemptRegistration then
        print("Attempting to register "..nickname)
        ws.send("NS REGISTER "..password)
        attemptRegistration = false
    end
end

local function typingReset()
    while true do
        for name, time in pairs(currently_typing) do
            if os.clock() - time > 10 then
                currently_typing[name] = nil
            end
        end
        sleep(0.1)
    end
end

local function receiverEventLoop()
    while true do
        local containsSensitiveInfo = false
        local message = ws.receive()
        if message then
            local msg_data, message_destination, cmd, numeric, message_origin, tags = backend.processRawMessage(message)
            local origin_client, origin_nick
            if message_origin then
                origin_client, origin_nick = backend.processMessageOrigin(message_origin)
            end
            --Checks if there are tags
            if tags then
                --Assuming tags exists, checks for the +typing client tag to show typing status
                if tags["+typing"] then
                    if tags["+typing"] == "active" then
                        if origin_nick then
                            currently_typing[origin_nick] = os.clock()
                        end
                    else
                        if origin_nick then
                            currently_typing[origin_nick] = nil
                        end
                    end
                end
            end
            if cmd and not numeric then
                if origin_nick then
                    if string.find(origin_nick,"NickServ") then
                        if string.find(msg_data,"IDENTIFY") then
                            containsSensitiveInfo = true
                        end
                    end
                end

                -- Special exception for this command because it comes from another client and has additional data
                if cmd == "PRIVMSG" and not containsSensitiveInfo then
                    origin_nick = origin_nick or message_origin

                    if string.find(msg_data,backend.accountData.nickname) then
                        sendMessage(message_destination.." | <"..origin_nick.."> "..msg_data,tags,"black","yellow")
                    else
                        sendMessage(message_destination.." | <"..origin_nick.."> "..msg_data,tags)
                    end
                elseif cmd == "FAIL" or cmd == "NOTE" or cmd == "WARN" then
                    local type, cmand, code, description = backend.processStandardReply(cmd.." "..msg_data)
                    sendMessage(message_destination.." | ["..type.."] ["..cmand.."] ["..code.."] "..description)
                elseif cmd == "NOTICE" then
                    if origin_client then
                        sendMessage(message_destination.." | [NOTICE] <"..origin_nick.."> "..msg_data,tags)
                    else
                        sendMessage(message_destination.." | [NOTICE] "..msg_data,tags)
                    end
                elseif cmd == "PING" then
                    if not backend.accountData.awaitingFirstPongResponse then
                        interactNickServ()
                    end
                elseif cmd == "QUIT" then
                    sendMessage(origin_nick.." has left. Reason: "..msg_data,tags)
                elseif cmd == "JOIN" then
                    sendMessage(origin_nick.." has joined the chat!",tags)
                elseif message_destination then
                    if origin_nick then
                        if #msg_data > 0 then
                            sendMessage(message_destination.." | <"..origin_nick.."> "..msg_data,tags)
                        end
                    else
                        sendMessage(message_destination.." | ["..cmd.."] "..msg_data,tags)
                    end
                else
                    print("Command: "..message)
                end
            end
            if numeric then
                if message_destination and cmd then
                    sendMessage(message_destination.." | ["..cmd.."] "..msg_data,tags)
                elseif message_destination then 
                    sendMessage(message_destination.." | "..msg_data,tags)
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
        msg_box.clear()
        msg_box.setCursorPos(1,1)
        for name, status in pairs(currently_typing) do
            msg_box.write(name.."... ")
        end
        msg_box.setCursorPos(1,3)
        msg_box.write("Message "..selected_channel..": ")
        local message = specRead.customRead(msg_box)
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
            --sendMessage(selected_channel.." | <"..nickname.."> "..message)
            ws.send("PRIVMSG "..selected_channel.." :"..message)
        end
    end
end

monitor.clear()
monitor.setCursorPos(1,1)

print("Username:")
username = read()
print("Nickname:")
nickname = read()
print("Realname (Does not have to be real):")
realname = read()

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

parallel.waitForAll(receiverEventLoop,messageSendLoop,typingReset)