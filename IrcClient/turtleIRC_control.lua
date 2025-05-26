local backend = require("IRC_backend")
local compress = require("compressor")

local ws = backend.ws
local err = backend.err

local username = "turtleCont"
local nickname = "Controler"
local realname = "Hi, I am a bot!"

ws.send("USER " .. username .. " unused unused " .. realname)
ws.send("NICK " .. nickname)
backend.accountData.nickname = nickname

local compressedVisualData = ""

local vPacketCount = 0

-- North
local facing = 0

local function drawMap(blockData,y_level)
    local max_x = math.abs(blockData[1].x)
    term.setTextColor(colors.white)
    term.setBackgroundColor(colors.black)
    term.setCursorPos(1,1)
    term.clear()
    paintutils.drawBox(1,1,(max_x*2)+2,(max_x*2)+2,colors.lightGray)

    term.setTextColor(colors.white)
    term.setBackgroundColor(colors.black)
    for i = 1, #blockData do
        if blockData[i].y == y_level then
            if blockData[i].name ~= 1 then
                term.setTextColor(colors.white)
            else
                term.setTextColor(colors.black)
            end
            term.setCursorPos(blockData[i].x+max_x+1,blockData[i].z+max_x+1)
            if blockData[i].x == 0 and blockData[i].z == 0 then
                term.setTextColor(colors.yellow)
            end
            term.write("O")
        end
    end
    term.setTextColor(colors.white)
end

local function receive()
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
                    local words = string.gmatch(msg_data, "%S+")
                    local args = {}

                    for arg in words do
                        table.insert(args,arg)
                    end

                    local command = args[1]
                    local data = string.sub(msg_data,#command+2)


                    if command == "VisualStart" then
                        compressedVisualData = ""
                        vPacketCount = 0
                    elseif command == "VisualEnd" then
                        local visionData = compress.decompressBlockData(compressedVisualData)
                        drawMap(visionData,0)
                    elseif command == "Visual" then
                        vPacketCount = vPacketCount+1
                        --print("vPacket: "..tostring(vPacketCount).."/16")
                        --print(#data)
                        compressedVisualData = compressedVisualData..data
                    end
                end
            end
        end
    end
end

local function sendCommand(command)
    ws.send("PRIVMSG Gumpai :"..command)
end

local function send()
    while true do
        local event, key, is_held = os.pullEvent("key")
        if event then
            if key == keys.w then
                sendCommand("Forward")
            elseif key == keys.s then
                sendCommand("Backward")
            elseif key == keys.a then
                sendCommand("Left")
            elseif key == keys.d then
                sendCommand("Right")
            elseif key == keys.up then
                sendCommand("Up")
            elseif key == keys.down then
                sendCommand("Down")
            elseif key == keys.e then
                sendCommand("DigUp")
            elseif key == keys.t then
                sendCommand("Dig")
            elseif key == keys.y then
                sendCommand("DigDown")
            elseif key == keys.r then
                sendCommand("Visual")
            elseif key == keys.enter then
                sendCommand("Stop")
                ws.send("QUIT")
                ws.close()
                error("Closing")
            end
        end
    end
end


parallel.waitForAll(receive,send)