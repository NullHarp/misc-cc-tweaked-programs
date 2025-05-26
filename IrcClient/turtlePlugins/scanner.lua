local ws = nil
local scanner

local compress

local hooks = {
    onMessage = {

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

local function processVisual(message_data, sender)
    if message_data == "Visual" then
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
            sendResponse(sender,"VisualStart")
            for i = 1, packetCount do
                sendResponse(sender,"Visual "..packets[i])
            end
            sendResponse(sender,"VisualEnd")
        end
    end
end

local function init(webSock)
    compress = require("compressor")
    if not compress then
        error("Could not find compressor lib!")
    end
    scanner = peripheral.find("geoScanner")
    if not scanner then
        error("GeoScanner not found!")
    end
    ws = webSock
    print("Initalizing GeoScanner Peripheral plugin!")
    table.insert(hooks.onMessage,processVisual)
end

return {init = init, hooks = hooks}