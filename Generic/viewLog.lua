local logger =require("logger")

local log_name, start = ...
start = start or 1
start = tonumber(start)
if not log_name then
    error("Must specify name of log file.")
end

local logHandle = logger.getLogHandle(log_name)



for i, v in pairs(logHandle.log) do
    if start < 0 then
        if i <= -start then
            print(v.text)
        end
    else
        if i >= start then
            print(v.text)
        end
    end
end