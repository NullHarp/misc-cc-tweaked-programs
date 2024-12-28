local modem = peripheral.find("modem") or error("No modem attached", 0)

local scanner = peripheral.find("universal_scanner")

local receiver_channel = 0
local sender_channel = 24

modem.open(receiver_channel)

local function send()
    while true do
        sleep(0)
    end
end

local function receive()
    while true do
        local event, side, channel, replyChannel, message, distance = os.pullEvent("modem_message")
        if channel == receiver_channel then
            if type(message) == "table" then
                if message.target_id == os.getComputerID() then
                    if message.type == "command" then
                        if message.data == "forward" then
                            turtle.forward()
                        end
                    end
                    local table_data = scanner.scan("block",8)
                    if type(table_data) ~= "nil" then
                        local output_data = {}
                        for i,v in pairs(table_data) do
                            if v.name ~= "minecraft:air" then
                                table.insert(output_data,{block = v.name,position = {x = v.x,y = v.y, z = v.z}})
                            end
                            print(i.."/"..#table_data)
                        end
                        local package = {
                            type = "vision",
                            data = output_data,
                            target_id = os.getComputerID()
                        }
                        modem.transmit(sender_channel,receiver_channel,package)
                    end
                end
            end
        end
    end
end

parallel.waitForAll(send,receive)