local crafter = require("autoCraftAPI")

local item_name, count = ...

if type(count) == "nil" then
    count = 1
else
    count = tonumber(count)
end

if type(item_name) == "nil" then
    crafter.displayRecipes()
else
    crafter.queueRecipe(item_name,count)

    while #crafter.getRecipeQueue() > 0 do
        crafter.processRecipe()
        sleep(0)
    end
end