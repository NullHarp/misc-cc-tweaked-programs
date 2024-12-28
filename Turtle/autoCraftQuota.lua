local crafter = require("autoCraftAPI")

local quota = {
    ["computercraft:wired_modem"] = 1
}

while true do
    if #crafter.getRecipeQueue() == 0 then
        local recipes = crafter.getRecipes()
        for item, count in pairs(quota) do
            if crafter.getItemCount(item) < count then
                if crafter.isRecipe(item) then
                    for i = 1, math.ceil(count/recipes[item].count) do
                        crafter.queueRecipe(item)
                    end
                    print("Queued missing quota: ",item,count)
                end
            end
        end
    else
        crafter.processRecipe()
    end
    sleep(0)
end