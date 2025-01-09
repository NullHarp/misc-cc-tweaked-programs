local logger = require("logger")

local logHandle = logger.getLogHandle("test")
logHandle:writeLog("id win",0)

for i,v in pairs(logHandle.log) do
    print(v.time)
    print(v.text)
end