local util = require("util")

local request_channel = 65530
local reply_channel = 65529

---Reads incoming reply's on the reply_channel
---@param modem table
---@param reply_type string
---@return table data
local function readReply(modem,reply_type)
    modem.open(reply_channel)
    local data = nil
    local success = false
    local satisfied = false
    local event, side, channel, replyChannel, message, distance
    while not satisfied do
        event, side, channel, replyChannel, message, distance = os.pullEvent("modem_message")
        if channel == reply_channel then
            satisfied = true
            success,data = pcall(textutils.unserialiseJSON,message)
            if success then
                if data.type == reply_type then
                    return data
                end
            end
        end
        sleep(0)
    end
    modem.close(reply_channel)
end

---Gets the key and value pairs for the file paths located in storageLocations.json
---@return table paths
local function getStoragePaths()
    local file = fs.open("storageLocations.json","r")
    local data = file.readAll()
    file.close()
    local locations = textutils.unserialiseJSON(data)
    return locations
end

---Requests info for a provided file in the index
---@param modem table
---@param filename string
---@return table file_info
local function requestFileInfo(modem,filename)
    local message = {
        type = "req_file_info",
        filename = filename,
        id = os.getComputerID()
    }
    local json_message = textutils.serialiseJSON(message)
    modem.transmit(request_channel,reply_channel,json_message)


    local data = readReply(modem,"file_info")
    return data
end

---Requests file data and its associated info
---@param modem table
---@param filename string
---@return table file_data
local function requestFile(modem,filename)
    local message = {
        type = "req_file",
        filename = filename,
        id = os.getComputerID()
    }
    local json_message = textutils.serialiseJSON(message)
    modem.transmit(request_channel,reply_channel,json_message)
    local data = readReply(modem,"file")

    return data
end

---Requests the file index
---@param modem table
---@return table index
local function requestIndex(modem)
    local message = {
        type = "req_index",
        id = os.getComputerID()
    }
    local json_message = textutils.serialiseJSON(message)
    modem.transmit(request_channel,reply_channel,json_message)
    local data = readReply(modem,"file_index")
    return data.index
end

---Gets the info.json file data
---@return table
local function getFileIndex()
    local file = fs.open("info.json","r")
    local data = file.readAll()
    local info = textutils.unserialiseJSON(data)
    return info
end

---Sends requested index data to the reply channel
---@param modem table
---@param index table
---@param id integer
local function sendFileIndex(modem,index,id)
    local message = {
        type = "file_index",
        index = index,
        id = id
    }
    local json_message = textutils.serialiseJSON(message)
    modem.transmit(reply_channel,request_channel,json_message)
end

local function sendFile(modem,file,id)
    local message = {
        type = "file",
        file_data = file.data,
        name = file.name,
        version = file.version,
        description = file.description,
        id = id
    }
    local json_message = textutils.serialiseJSON(message)
    modem.transmit(reply_channel,request_channel,json_message)
end

---Sends file Info to the reply channel
---@param modem table
---@param file table
---@param id integer
local function sendFileInfo(modem,file,id)
    local message = {
        type = "file_info",
        name = file.name,
        version = file.version,
        description = file.description,
        id = id
    }
    local json_message = textutils.serialiseJSON(message)
    modem.transmit(reply_channel,request_channel,json_message)
end

---Adds a new entry to the end of the index
---@param entry table
local function addIndexEntry(entry)
    local index = getFileIndex()
    table.insert(index,entry)
    local pretty_index = util.prettyPrintJSON(textutils.serialiseJSON(index))
    local file = fs.open("info.json","w")
    file.write(pretty_index)
    file.close()
end

---Removes a existing entry from the index
---@param entry_name table
local function removeIndexEntry(entry_name)
    local index = getFileIndex()
    for i,v in pairs(index) do
        if v.name == entry_name then
            table.remove(index,i)
        end
    end
    local pretty_index = util.prettyPrintJSON(textutils.serialiseJSON(index))
    local file = fs.open("info.json","w")
    file.write(pretty_index)
    file.close()
end

---Replaces a existing entry with new entry data
---@param entry table
local function replaceIndexEntry(entry)
    local index = getFileIndex()
    for i, v in ipairs(index) do
        if v.name == entry.name then
            if entry.description ~= "" then
                index[i].description = entry.description
            end
            if entry.version ~= "" then
                index[i].version = entry.version
            end
            if entry.location ~= "" then
                index[i].location = entry.location
            end
        end
    end
    local pretty_index = util.prettyPrintJSON(textutils.serialiseJSON(index))
    local file = fs.open("info.json","w")
    file.write(pretty_index)
    file.close()
end

return {
    request_channel = request_channel,
    reply_channel = reply_channel,
    requestIndex = requestIndex,
    getFileIndex = getFileIndex,
    sendFileIndex = sendFileIndex,
    requestFile = requestFile,
    sendFile = sendFile,
    requestFileInfo = requestFileInfo,
    sendFileInfo = sendFileInfo,
    getStoragePaths = getStoragePaths,
    addIndexEntry = addIndexEntry,
    removeIndexEntry = removeIndexEntry,
    replaceIndexEntry = replaceIndexEntry,
    readReply = readReply
}