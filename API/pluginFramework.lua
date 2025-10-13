local plugin = {}

local loadedPlugins = {}

local event = {}

local registeredEvents = {}

local api = {}

local registeredFunctions = {}

---Plugins

function plugin.load(filePath)
    local pluginProgram = require(filePath)
    if not pluginProgram then
        return false
    end
    pluginProgram.init = pluginProgram.init or error("No init detected for plugin: "..filePath)
    local hooks = pluginProgram.init({registeredApi=registeredFunctions,registeredEvents=registeredEvents,loadedPlugins=loadedPlugins})
    for hookName, hookFunctions in pairs(hooks) do
        if registeredEvents[hookName] then
            for _, func in pairs(hookFunctions) do
                table.insert(registeredEvents[hookName],func)
            end
        end
    end
    return true
end

function plugin.isLoaded(pluginName)
    if loadedPlugins[pluginName] then
        return true
    else
        return false
    end
end

function plugin.listLoadedPlugins()
    return loadedPlugins
end

---Events

function event.register(eventName)
    if registeredEvents[eventName] then
        return false
    end
    registeredEvents[eventName] = {}
    return true
end

function event.push(eventName, ...)
    if not registeredEvents[eventName] then
        error("Event: "..eventName.." is not registered.")
    end
    for _, func in pairs(registeredEvents[eventName]) do
        func(...)
    end
end

function event.isRegistered(eventName)
    if registeredEvents[eventName] then
        return true
    else
        return false
    end
end

function event.listRegisteredEvents()
    return registeredEvents
end

---API

function api.register(functionName,func)
    if registeredFunctions[functionName] then
        return false
    end
    registeredFunctions[functionName] = func
    return true
end

function api.listRegisteredFunctions()
    return registeredFunctions
end

function api.isRegistered(functionName)
    if registeredFunctions[functionName] then
        return true
    else
        return false
    end
end

--event.register("startup")
--api.register("test",test)

--plugin.load("/plugins/test")

--event.push("startup")

return {event = event, plugin = plugin, api = api}