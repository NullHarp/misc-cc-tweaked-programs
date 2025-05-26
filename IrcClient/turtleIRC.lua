local backend = require("IRC_backend")
local compress = require("compressor")

local chatBox = peripheral.find("chatBox")

local scanner = peripheral.find("geoScanner")

local ws = backend.ws
local err = backend.err

if err then
    error(err)
end

local username = "turtle"
local nickname = "Gumpai"
local realname = "Hi, I am a bot!"

ws.send("USER " .. username .. " unused unused " .. realname)
ws.send("NICK " .. nickname)
backend.accountData.nickname = nickname

local function sendResponse(destination,response)
    ws.send("PRIVMSG "..destination.." :"..response)
end

local function processVisual(origin_nick)
    if scanner.getOperationCooldown("scanBlocks") == 0 then
        local visual_data = scanner.scan(4)
        local compressed_data = compress.compressBlockData(visual_data)
        local packets = {}
        local packetSize = 412
        local packetCount = #compressed_data/packetSize
        packetCount = math.ceil(packetCount)
        for i = 1, packetCount do
            packets[i] = string.sub(compressed_data,(i*packetSize)-(packetSize-1),i*packetSize)
        end
        sendResponse("VisualStart")
        for i = 1, packetCount do
            sendResponse(origin_nick,"Visual"..packets[i])
        end
        sendResponse("VisualEnd")
    end
end

local function primaryFeedback()
    while true do
        local message = ws.receive()
        if message then
            local msg_data, message_destination, cmd, numeric, message_origin = backend.processRawMessage(message)
            if cmd and not numeric then
                local origin_client, origin_nick
                if message_origin then
                    origin_client, origin_nick = backend.processMessageOrigin(message_origin)
                end

                if cmd == "PRIVMSG" then
                    print(msg_data)
                    local words = string.gmatch(msg_data, "%S+")
                    local args = {}

                    for arg in words do
                        table.insert(args,arg)
                    end

                    local command = args[1]
                    local data = string.sub(msg_data,#command+2)

                    local response = ""

                    if command == "Forward" then
                        turtle.forward()
                    elseif command == "Backward" then
                        turtle.back()
                    elseif command == "Left" then
                        turtle.turnLeft()
                    elseif command == "Right" then
                        turtle.turnRight()
                    elseif command == "Up" then
                        turtle.up()
                    elseif command == "Down" then
                        turtle.down()
                    elseif command == "Dig" then
                        turtle.dig()
                    elseif command == "DigUp" then
                        turtle.digUp()
                    elseif command == "DigDown" then
                        turtle.digDown()
                    elseif command == "Chat" then
                        chatBox.sendMessage(data,"Gumpai","<>")
                    elseif command == "Stop" then
                        ws.send("QUIT told to stop")
                        ws.close()
                        error("Program stopped!")
                    elseif command == "Visual" then
                        processVisual(origin_nick)
                    end
                end
            end
        end
    end
end

local function chatHandler()
    while true do
        local event, username, message, uuid, isHidden = os.pullEvent("chat")
        sendResponse("Null","Chat "..username..":"..message)
    end
end

parallel.waitForAll(primaryFeedback,chatHandler)