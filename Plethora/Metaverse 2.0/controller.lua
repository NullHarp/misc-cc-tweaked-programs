local modem = peripheral.find("modem") or error("No modem attached", 0)

local receiver_channel = 0
local sender_channel = 24

modem.open(sender_channel)

local target_id = ...
target_id = tonumber(target_id)

local modules = peripheral.wrap("back")
local canvas = modules.canvas3d()
canvas.clear()
local design = canvas.create()

local p_data = modules.getMetaOwner()
local withinBlock = p_data.withinBlock

local function send()
    while true do
        local event, key, is_held = os.pullEvent("key")
        if key == keys.w then
            local package = {
                type = "command",
                data = "forward",
                target_id = target_id
            }
            modem.transmit(receiver_channel,sender_channel,package)
        end
    end
end

local function receive()
    while true do
        local event, side, channel, replyChannel, message, distance = os.pullEvent("modem_message")
        if channel == sender_channel then
            if type(message) == "table" then
                if message.target_id == target_id then
                    if message.type == "vision" then
                        design.clear()
                        local table_data = message.data
                        for i,data in pairs(table_data) do
                            data.position.x = data.position.x + withinBlock.x
                            data.position.y = data.position.y + withinBlock.y
                            data.position.z = data.position.z + withinBlock.z
                        
                            local error = pcall(design.addItem,data.position,data.block)
                        end
                    end
                end
            end
        end
    end
end

parallel.waitForAll(send,receive)