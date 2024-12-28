local data = {
    type = "checkpoint",
    id = 1
}

local racer_req_channel = 25
local racer_resp_channel = 26

local checkpoint_id = ...
checkpoint_id = tonumber(checkpoint_id)

local modem = peripheral.find("modem")
modem.open(racer_req_channel)

while true do
    local event, side, channel, replyChannel, message, distance = os.pullEvent("modem_message")
    if type(message) == "table" then
        if distance < 9 and message.checkpoint < checkpoint_id then
            data.id = message.id
            modem.transmit(racer_resp_channel,racer_req_channel,data)
        end
    end
    sleep(0)
end