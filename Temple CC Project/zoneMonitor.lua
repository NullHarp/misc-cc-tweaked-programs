local mod = require("http_module")

local chatBox = peripheral.find("chatBox")
local redInt = peripheral.find("redstoneIntegrator")
local det = peripheral.find("playerDetector")

local range = ...
range = tonumber(range)

local last_detection = 0
while true do
    local detection = det.getPlayersInRange(range)
    if #detection > 0 and detection ~= last_detection then
        redInt.setOutput("back",false)
    else
        redInt.setOutput("back",true)
    end
    last_detection = detection
    sleep(0)
end