local util = require("util")

local target, targetY, offsetX, offsetY, offsetZ = ...

if type(target) == "nil" then
    print("Proper format is queueJob target targetY offsetX? offsetY? offsetZ?")
    print("? at end of arg means its optional.")
    return
end
if type(targetY) == "nil" then
    error("Target Y-Level not specified.")
end
targetY = tonumber(targetY)

if type(offsetX) == "nil" or type(offsetY) == "nil" or type(offsetZ) == "nil" then
    offsetX = 0
    offsetY = 0
    offsetZ = 0
end

local jobs = {}

local job = {
    target = target,
    targetY = targetY,
    offsetPos = {x=offsetX,y=offsetY,z=offsetZ},
    status = "queued"
}
if fs.exists("/jobs.json") then
    local file = fs.open("jobs.json","r")
    local file_data = file.readAll()
    file.close()
    jobs = textutils.unserialiseJSON(file_data)
end


table.insert(jobs,job)
local pretty_json = util.prettyPrintJSON(textutils.serialiseJSON(jobs))
local file = fs.open("jobs.json","w")
file.write(pretty_json)
file.close()