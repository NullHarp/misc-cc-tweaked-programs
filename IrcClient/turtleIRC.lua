local backend = require("IRC_backend")

local scanner = peripheral.find("geoScanner")

local ws = backend.ws

local plugins = {}
local hooks = {
    onMessage = {},
    mainLoop = {}
}

local function executeHooks(hookName,...)
    for index, func in pairs(hooks[hookName]) do
        func(...)
    end
end

local function initPlugins()
    local path = "/plugins/"
    local files = fs.list(path)
    for index, file in pairs(files) do
        if not fs.isDir(file) then
            if string.sub(file,#file-3) == ".lua" then
                file = string.sub(file,1,#file-4)
            end
            local plugin = require(path..file)
            if not plugin.init then
                error(path..file.." has no init!")
            end
            plugin.init(ws)
            table.insert(plugins,plugin)
            for name, functions in pairs(hooks) do
                if plugin.hooks[name] then
                    if #plugin.hooks[name] > 0 then
                        for _, func in pairs(plugin.hooks[name]) do
                            table.insert(hooks[name],func)
                        end
                    end
                end
            end
        end
    end
end

local username = "turtle"
local nickname = "Gumpai"
local realname = "Hi, I am a bot!"

ws.send("USER " .. username .. " unused unused " .. realname)
ws.send("NICK " .. nickname)
ws.send("MODE +B")
backend.accountData.nickname = nickname

local function sendResponse(destination,response)
    if destination and response then
        ws.send("NOTICE "..destination.." :"..response)
    end
end

local function primaryFeedback()
    while true do
        local message = ws.receive()
        if message then
            local msg_data, message_destination, cmd, numeric, message_origin = backend.processRawMessage(message)
            local origin_client, origin_nick
            if message_origin then
                origin_client, origin_nick = backend.processMessageOrigin(message_origin)
            end
            executeHooks("onMessage",msg_data, origin_nick)
            if cmd and not numeric then
                if cmd == "PRIVMSG" then
                    print(msg_data)
                    local words = string.gmatch(msg_data, "%S+")
                    local args = {}

                    for arg in words do
                        table.insert(args,arg)
                    end

                    local command = args[1]
                    local data = string.sub(msg_data,#command+2)

                    local response = ""
                    local validCommand = true
                    local success = false

                    if command == "Forward" then
                        success = turtle.forward()
                    elseif command == "Backward" then
                        success = turtle.back()
                    elseif command == "Left" then
                        success = turtle.turnLeft()
                    elseif command == "Right" then
                        success = turtle.turnRight()
                    elseif command == "Up" then
                        success = turtle.up()
                    elseif command == "Down" then
                        success = turtle.down()
                    elseif command == "Stop" then
                        ws.send("QUIT told to stop")
                        ws.close()
                        error("Program stopped!")
                    else
                        validCommand = false
                    end
                    if validCommand then
                        sendResponse(origin_nick,command.." "..tostring(success))
                    end
                end
            end
        end
    end
end

initPlugins()
parallel.waitForAll(primaryFeedback,table.unpack(hooks.mainLoop))