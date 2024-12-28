local modem = peripheral.find("modem") or error("No modem attached", 0)
modem.open(255)

local storage = require("storageAPI")
local crafter = require("autoCraftAPI")

local function process()
    while true do
        if #crafter.getRecipeQueue() > 0 then
            crafter.processRecipe()
        else
            storage.refresh()
        end
        sleep(0)
    end
end

local function receive()
    while true do
        local event, side, channel, replyChannel, message, distance = os.pullEvent("modem_message")
        if type(message) == "table" then
            if type(message.type) ~= "nil" then
                if message.type == "queueRecipe" then
                    if crafter.isRecipe(message.recipe_name) then
                        crafter.queueRecipe(message.recipe_name,message.count)
                        print("Got request to queue: "..message.recipe_name)
                    else
                        print("No recipe exists for "..message.recipe_name)
                        modem.transmit(255,255,{type="recipeStatus",response="Invalid Recipe."})
                    end
                elseif message.type == "getRecipes" then
                    modem.transmit(255,255,{type="recipes",response=crafter.getRecipes()})
                end
            end

        end
        sleep(0)
    end
end

parallel.waitForAll(process,receive)