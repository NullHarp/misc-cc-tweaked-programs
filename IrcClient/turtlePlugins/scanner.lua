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
    if message_data == "Vi" then
        if scanner.getOperationCooldown("scanBlocks") == 0 then
            local visual_data = scanner.scan(4)
            local compressed_data, compressed_lookup = compress.compressBlockData(visual_data)

            local lookup_packets = {}
            local lookup_packet_size = 412
            local lookup_packet_count = #compressed_lookup/lookup_packet_size
            lookup_packet_count = math.ceil(lookup_packet_count)

            for i = 1, lookup_packet_count do
                lookup_packets[i] = string.sub(compressed_lookup,(i*lookup_packet_size)-(lookup_packet_size-1),i*lookup_packet_size)
            end
            sendResponse(sender,"ViLS")
            for i = 1, lookup_packet_count do
                sendResponse(sender,"ViL "..lookup_packets[i])
            end
            sendResponse(sender,"ViLE")
            local packets = {}
            local packetSize = 412
            local packetCount = #compressed_data/packetSize
            packetCount = math.ceil(packetCount)
            for i = 1, packetCount do
                packets[i] = string.sub(compressed_data,(i*packetSize)-(packetSize-1),i*packetSize)
            end
            sendResponse(sender,"ViS")
            for i = 1, packetCount do
                sendResponse(sender,"Vi "..packets[i])
            end
            sendResponse(sender,"ViE")
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