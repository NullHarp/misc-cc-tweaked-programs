local storage = require("storageAPI")
local util = require("util")
local logger = require("logger")

local log = logger.getLogHandle("storageServer")

local request_channel = 12354
local response_channel = 12354

local example_request = {
    command = "",
    args = {},
    from = "INSERT-UUID"
}

local example_response = {
    command = "",
    results = {},
    to = "INSERT-UUID"
}

local modem = peripheral.find("modem")

if not modem then
    log:writeLog("Modem not detected, exiting")
    error("Modem not detected, exiting",0)
end

modem.open(request_channel)

local function requestHandler()
    while true do
        local event, side, channel, replyChannel, message, distance = os.pullEvent("modem_message")
        if channel == request_channel and replyChannel == response_channel then
            if type(message) == "table" then
                if message.command == "refresh" then
                    local doRefresh = message.args[1] or false
                    storage.refresh(doRefresh)
                end
            end
        end
        sleep(0.05)
    end
end

requestHandler()