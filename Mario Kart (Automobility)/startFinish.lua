local data = {
    type = "",
    id = 1
}

local racer_req_channel = 25
local racer_resp_channel = 26

local checkpoint_count = ...
checkpoint_count = tonumber(checkpoint_count)

local modem = peripheral.find("modem")
modem.open(racer_req_channel)

while true do
    local event, side, channel, replyChannel, message, distance = os.pullEvent("modem_message")
    if type(message) == "table" then
        if distance < 7 and message.lap < 3 and message.checkpoint == checkpoint_count then
            data.id = message.id
            data.type = "lap"
            modem.transmit(racer_resp_channel,racer_req_channel,data)
        elseif distance < 7 and message.lap == 3 and message.checkpoint == checkpoint_count and not message.isFinished then
            data.id = message.id
            data.type = "finish"
            modem.transmit(racer_resp_channel,racer_req_channel,data)
        elseif distance < 7 and not message.isStarted then
            data.id = message.id
            data.type = "start"
            modem.transmit(racer_resp_channel,racer_req_channel,data)
        end
    end
    sleep(0)
end