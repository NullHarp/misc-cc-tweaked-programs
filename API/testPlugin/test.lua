local api = {}
local events = {}
local plugins = {}

local function startupHookTest()
    print("Hook is working, hello from startup test hook!")
end

local function init(data)
    api = data.registeredApi
    events = data.registeredEvents
    plugins = data.loadedPlugins
    
    print("Test plugin init started!")
    local hooks = {}
    hooks["startup"] = {startupHookTest}

    return hooks
end

return {init = init}