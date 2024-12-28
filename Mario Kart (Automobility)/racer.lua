local data = {
    type = "",
    id = 1,
    lap = 1,
    checkpoint = 0,
    isStarted = false,
    isFinished = false
}

local racer_req_channel = 25
local racer_resp_channel = 26

local speaker = peripheral.find("speaker")

local modem = peripheral.find("modem")
modem.open(racer_resp_channel)

local racer_id = ...
racer_id = tonumber(racer_id)
data.id = racer_id
local stopwatch = 0

if not modem.isWireless() then
    error("Not a wireless modem.")
end

local function send()
    while true do
        modem.transmit(racer_req_channel,racer_resp_channel,data)
        sleep(0.5)
    end
end

local function receive()
    while true do
        local event, side, channel, replyChannel, message, distance = os.pullEvent("modem_message")
        if type(message) == "table" then
            if message.id == data.id then
                if message.type == "checkpoint" then
                    data.checkpoint = data.checkpoint + 1
                    speaker.playNote("bell",1,1)
                    sleep(0)
                    speaker.playNote("bell",1,3)
                elseif message.type == "lap" then
                    data.lap = data.lap + 1
                    data.checkpoint = 0
                    shell.run("austream https://github.com/NullHarp/music/raw/refs/heads/main/Mario%20Kart%20Lap%20Sound.wav")
                elseif message.type == "finish" then
                    print("Race Finished.")
                    print("Race Time: "..math.floor(stopwatch/60%60)..":"..math.floor(stopwatch%60))
                    data.isFinished = true
                    shell.run("austream https://github.com/NullHarp/music/raw/refs/heads/main/Finish%20(1st%20Place)%20-%20Mario%20Kart%208%20Deluxe%20Music.wav")
                elseif message.type == "start" then
                    print("Race Started.")
                    data.isStarted = true
                end
                print("Checkpoint: "..data.checkpoint)
                print("Lap: "..data.lap)
            end
        end
        sleep(0)
    end
end

local function time()
    while not data.isStarted do
        sleep(0)
    end
    while not data.isFinished do
        stopwatch = stopwatch + 0.05
        sleep(0.05)
    end
end

parallel.waitForAll(send,receive,time)