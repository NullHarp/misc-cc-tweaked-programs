local storage = require("storageAPI")
local stringMathParse = require("stringMathParser")

local util = require("util")

--Peripherals
local chatbox = peripheral.find("chatBox")

local name = "NullHarp"

local helpDocs = {
    {
        title="Help",
        args={},
        description="Provides docs on all commands for Happy"
    },
    {
        title="Search",
        args={"name"},
        description="Searches for items based off inputed item name."
    },
}

util.title("Happy V2","V0.0.1")

local function sendMessage(message)
    chatbox.sendMessageToPlayer(message,name,"Happy","<>")
    sleep(1)
end

local function displayHelp()
    local msg = "Commands:\n"
    for index, entry in pairs(helpDocs) do
        msg = msg..entry.title.." | "..entry.description.."\n"
        if #entry.args > 0 then
            msg = msg.."  -> Args: "..table.concat(entry.args).."\n"
        end
    end
    sendMessage(msg)
end

local function searchCommand(itemName)
    local results = storage.searchItems(itemName)
    local msg = "Results:\n"
    for item, count in pairs(results) do
        if item ~= "n" then
            msg = msg..storage.getDisplayName(item).." Count: "..tostring(count).."\n"
        end
    end
    sendMessage(msg)
end

storage.refresh()

while true do
    local event, username, message, uuid, isHidden = os.pullEvent("chat")
    storage.refresh()
    if username == name then
        local words = string.gmatch(message, "%S+")
        local args = {}
        for arg in words do
            table.insert(args,arg)
        end
        if #args >= 2 then
            local command = args[2]
            if args[1] == "happy" then
                if command == "help" then
                    displayHelp()
                elseif command == "search" then
                    if args[3] then
                        searchCommand(args[3])
                    end
                end
            end
        end
    end
end