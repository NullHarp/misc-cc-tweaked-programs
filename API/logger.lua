local Log = {}

function Log.getLog(self)
    if fs.exists(self.name..".log") then
        local file = fs.open(self.name..".log","r")
        local fileData = file.readAll()
        file.close()
        local log = textutils.unserialiseJSON(fileData)
        self.log = log
    else
        self.log = {}
    end
end

function Log.saveLog(self)
    local file = fs.open(self.name..".log","w")
    file.write(textutils.serialiseJSON(self.log))
    file.close()
end

function Log.writeLog(self,text,level)
    self:getLog()
    local logData = {
        time = os.date("*t"),
        text = text,
        level = level
    }
    table.insert(self.log,logData)
    self:saveLog()
end

local function getLogHandle(name)
    local log = {name = name, writeLog = Log.writeLog, saveLog = Log.saveLog, getLog = Log.getLog}
    log:getLog()
    return log
end

return {getLogHandle = getLogHandle}