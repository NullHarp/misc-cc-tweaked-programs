local playerDet = peripheral.find("playerDetector") or error("Player detector not found!",0)
local chatbox = peripheral.find("chatBox") or error("Chat box not found!",0)
local monitor = peripheral.find("monitor") or error("Monitor not found!",0)

local alertList = {
    "VoidViolin",
    "Blista__Compact",
    "BigCrazyClaw",
    "awesomehome7_dj"
}

local position = {
    x = 223,
    y= 256,
    z = 184 
}

local players = {}
local playerData = {}

local playersInRangeFilter = {}

local function sendMessage(message,targetPlayer)
    chatbox.sendMessageToPlayer(message,targetPlayer,"RILEY","<>")
    sleep(1)
end

local function sendAlert(alertText,level)
    local message = level.." alert, "..alertText
    for _, player in pairs(alertList) do
        sendMessage(message,player)
    end
end

sendAlert("System init completed!","Information")

local function getThreatPos(threats)
    local positions = {}
    for _, player in pairs(threats) do
        local data = playerDet.getPlayerPos(player)
        if data then
            positions[player] = data
        end
    end
    return positions
end

local function convertToFilter(labels)
    local filter = {}
    for index, label in pairs(labels) do
        filter[label] = true
    end
    return filter
end

local function passiveDetector()
    while true do
        local playersInRange = playerDet.getPlayersInRange(500)
        playersInRangeFilter = convertToFilter(playersInRange)
        players = playerDet.getOnlinePlayers()
        playerData = getThreatPos(players)
        for name, position in pairs(playerData) do
            local file = fs.open("disk/playerData/"..name..".dat","w")
            local searializedData = textutils.serialiseJSON(position)
            file.write(searializedData)
            file.close()
        end
        sleep(0)
    end
end

local function displayPositions()
    while true do
        monitor.setBackgroundColor(colors.black)
        monitor.clear()
        monitor.setCursorPos(1,1)
        for name, data in pairs(playerData) do
            local dist = math.sqrt((data.x-position.x)^2+(data.y-position.y)^2+(data.z-position.z)^2)
            dist = math.floor(dist*100)/100
            if playersInRangeFilter[name] then
                monitor.setBackgroundColor(colors.red)
            else
                monitor.setBackgroundColor(colors.green)
            end
            local x,y = monitor.getCursorPos()
            monitor.write("Name: "..name.." X: "..tostring(data.x).." Y: "..tostring(data.y).." Z: "..tostring(data.z).." Dist: "..tostring(dist).."\n")
            monitor.setCursorPos(1,y+1)
        end
        sleep(0)
    end
end

parallel.waitForAll(passiveDetector,displayPositions)