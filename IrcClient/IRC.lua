local chat = peripheral.wrap("bottom")

local ws, err = http.websocket("wss://hexxytest.hexxy.media:8000")

local hasAccount = false
local attemptRegistration = false

local password = ""

print("Please type username:")
local username = read()
print("Please insert realname (can be anything):")
local realname = read()
print("Please insert nick:")
local nickname = read()
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


local function init()
    if ws then
        ws.send("USER " .. username .. " unused unused " .. realname)
        ws.send("NICK " .. nickname)
    else
        error(err)
    end
end

local function processNumerics(rawMsg)
    local lookup = {
        RPL_WELCOME = 001,
        RPL_YOURHOST = 002,
        RPL_CREATED = 003,
        RPL_MYINFO = 004,
        RPL_ISUPPORT = 005,
        RPL_STATS = 210,
        RPL_ENDOFSTATS = 219,
        RPL_LUSERCLIENT = 251,
        RPL_LUSEROP = 252,
        RPL_LUSERUNKNOWN = 253,
        RPL_LUSERCHANNELS = 254,
        RPL_LUSERME = 255,
        RPL_LOCALUSERS = 265,
        RPL_GLOBALUSERS = 266,
        RPL_HELPHDR = 290,
        RPL_HELPTLR = 292,
        RPL_LISTSTART = 321,
        RPL_LIST = 322,
        RPL_LISTEND = 323,
        RPL_TOPIC = 332,
        RPL_TOPICWHOTIME = 333,
        RPL_NAMREPLY = 353,
        RPL_ENDOFNAMES = 366,
        RPL_MOTD = 372,
        RPL_MOTDSTART = 375,
        RPL_ENDOFMOTD = 376,
        RPL_VISIBLEHOST = 396,
        ERR_UNKNOWNCOMMAND = 421,
        ERR_CANNOTSENDTOCHAN = 404,
        ERR_BADCHANNELKEY = 475,
        ERR_NOPRIVILEGES = 481,
        RPL_LOGGEDIN = 900
    }

    local generic = {
        [001] = "[WELCOME]: ",
        [004] = "[INFO]: ",
        [003] = "[CREATED]: ",
        [005] = "[ISUPPORT]: ",
        [210] = "[STATS]: ",
        [219] = "[STATS]: ",
        [251] = "[USERS]: ",
        [252] = "[OPS]: ",
        [253] = "[UNK USER]: ",
        [254] = "[CHANNELS]: ",
        [255] = "[IRC]: ",
        [290] = "[HELP]: ",
        [292] = "[HELP]: ",
        [321] = "[LIST]: ",
        [322] = "[LIST]: ",
        [323] = "[LIST]: ",
        [332] = "[TOPIC]: ",
        [366] = "[NAMES]: ",
        [372] = "[MOTD]: ",
        [375] = "[MOTD]: ",
        [376] = "[MOTD]: ",
        [396] = "[VHOST]: ",
        [404] = "[ERR]: ",
        [421] = "[ERR]: ",
        [475] = "[ERR]: ",
        [481] = "[ERR]: ",
    }

    local words = string.gmatch(rawMsg, "%S+")
    local senderInfo = words()
    local sender = ""
    if string.sub(senderInfo,1,1) == ":" then
        local senderStart = 2
        local s, e = string.find(senderInfo,"!")
        if not s or not e then
            s, e = string.find(senderInfo," ")
        end
        if s or e then
            local senderEnd = e-1
            sender = string.sub(senderInfo,senderStart,senderEnd)
        end
    end
    local numeric = tonumber(words())
    local client = words()
    local cleanMsg = string.sub(rawMsg,#senderInfo+1+3+#client+3)
    local cleanWords = string.gmatch(cleanMsg, "%S+")
    local channel = ""
    if numeric == lookup.RPL_YOURHOST then
        chat.sendMessageToPlayer("[HOST]: "..cleanMsg, username)
    elseif numeric == lookup.RPL_TOPICWHOTIME then
        channel = words()
        local nick = words()

        local s, e = string.find(nick,"!")
        if s or e then
            local senderEnd = e-1
            nick = string.sub(nick,1,senderEnd)
        end
        local timestamp = words()
        chat.sendMessageToPlayer(channel.." | Topic set by "..nick.." on "..os.date("%x at %r",tonumber(timestamp)), username)
    elseif numeric == lookup.RPL_NAMREPLY then
        local names = string.sub(cleanMsg,3)
        local dest = sender
        chat.sendMessageToPlayer("[NAMES]: "..dest.." | "..names, username)
    elseif numeric == lookup.RPL_LOGGEDIN then
        chat.sendMessageToPlayer("[LOGIN]: "..cleanMsg,username)
    elseif numeric == lookup.RPL_GLOBALUSERS or numeric == lookup.RPL_LOCALUSERS then
        local cUsers = cleanWords()
        local mUsers = cleanWords()
        local msg = string.sub(cleanMsg,#cUsers+1+#mUsers+3)
        chat.sendMessageToPlayer("[USERS]: "..msg, username)
    elseif generic[numeric] then
        if sender == "" then
            chat.sendMessageToPlayer(generic[numeric]..cleanMsg, username)
        else
            chat.sendMessageToPlayer(generic[numeric]..sender.." | "..cleanMsg, username)
        end
    else
        print("["..numeric.."]",cleanMsg)
    end
end

local function simpleResponse(rawMsg)
    local lookup = {
        JOIN = " joined ",
        PART = " has left ",
        QUIT = " has quit: "
    }

    local words = string.gmatch(rawMsg, "%S+")
    local senderInfo = words()
    local command = words()
    local sender = ""
    if string.sub(senderInfo,1,1) == ":" then
        local senderStart = 2
        local s, e = string.find(senderInfo,"!")
        if s or e then
            local senderEnd = e-1
            sender = string.sub(senderInfo,senderStart,senderEnd)
        end
        if sender == "" then
            sender = string.sub(senderInfo,2)
        end
    end
    if command == "JOIN" or command == "PART" then
        local channel = words()
        if string.sub(channel,1,1) == ":" then
            channel = string.sub(channel,2)
        end
        local msg = string.sub(rawMsg,#senderInfo+1+#command+1+#channel+3)
        msg = msg or ""
        chat.sendMessageToPlayer(sender..lookup[command]..channel.." "..msg, username)
    elseif command == "QUIT" then
        local channel = words()
        channel = string.sub(channel,2)
        local msg = string.sub(rawMsg,#senderInfo+1+#command+1+#channel+3)
        msg = msg or ""
        if msg == sender then msg = "" end
        chat.sendMessageToPlayer(sender..lookup[command].." "..msg, username)
    elseif command == "NOTICE" then
        local dest = words()
        local msg = string.sub(rawMsg,#senderInfo+1+#command+1+#dest+3)
        chat.sendMessageToPlayer("[NOTICE]: "..dest.." | "..sender..": "..msg,username)
    else
        local dest = words()
        local msg = string.sub(rawMsg,#senderInfo+1+#command+1+#dest+3)
        local label = "["..command.."]: "
        chat.sendMessageToPlayer(label..dest.." | "..sender.." "..command.." : "..msg,username)
    end
end

local loggedIn = false

local function resp()
    while true do
        local response = ws.receive()
        local sender = nil
        local dest = nil
        if string.sub(response,1,4) == "PING" then
            ws.send("PONG " .. string.sub(response,6))
            if not loggedIn and hasAccount then
                ws.send("privmsg NickServ IDENTIFY "..password)
                loggedIn = true
            elseif not loggedIn and attemptRegistration then
                ws.send("privmsg NickServ REGISTER "..password)
                loggedIn = true
            end
        end
        if string.find(response,"VERSION",1,true) then

        end
        if string.sub(response,1,1) == ":" then
            local senderStart = 2
            local s, e = string.find(response,"!")
            if not s or not e then
                s, e = string.find(response," ")
            end
            if s or e then
                local senderEnd = e-1
                sender = string.sub(response,senderStart,senderEnd)
            end
        end
        if sender then
            local words = string.gmatch(response, "%S+")
            local senderInfo = words()
            local command = words()
            if tonumber(command) then
                processNumerics(response)
            else
                if command == "PRIVMSG" then
                    dest = words()
                    local firstWord = words()
                    if string.sub(firstWord,1,1) == ":" then
                        local start = #senderInfo+1+#command+1+#dest+3
                        local msg = string.sub(response,start)
                        if dest == nickname then
                            chat.sendMessageToPlayer("DM | "..sender..": "..msg,username)
                        else
                            chat.sendMessageToPlayer(dest.." | "..sender..": "..msg,username)
                        end
                    end
                else
                    simpleResponse(response)
                end
            end

        end
    end
end

--Default channel is #general
local channel = "#general"

local function message()
    while true do
        local event, user, msg, uuid, isHidden = os.pullEvent("chat")
        if user == username then
            if string.sub(msg,1,1) == "." then
                local newMsg = string.sub(msg,2)
                local words = string.gmatch(newMsg, "%S+")
                local arg1 = words()
                if arg1 == "join" then
                    local c = words()
                    if c then
                        channel = c
                    end
                    local pswd = words()
                    pswd = pswd or ""
                    ws.send("join "..channel.." "..pswd)
                elseif arg1 == "msg" then
                    local m = string.sub(newMsg,5)
                    ws.send("privmsg "..channel.." :"..m)
                elseif arg1 == "pMsg" then
                    local target = words()
                    local m = string.sub(newMsg,#"pMsg "+#target+2)
                    ws.send("privmsg "..target.." :"..m)
                elseif arg1 == "cmd" then
                    local cmd = string.sub(newMsg,5)
                    ws.send(cmd)
                elseif arg1 == "quit" then
                    ws.send(newMsg)
                    ws.close()
                    error()
                end
            end
        end
    end
end

init()
parallel.waitForAll(resp,message)