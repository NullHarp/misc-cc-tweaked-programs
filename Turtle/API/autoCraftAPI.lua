local modem = peripheral.find("modem")
local crafter = peripheral.find("workbench")


local storage = require("storageAPI")
local ignore_chests = {"minecraft:chest_3"}
storage.setIgnoredChests(ignore_chests)

if type(turtle) == "nil" then
    error("Not a turtle, exiting")
end

---The turtles name on the network
local turtle_name = modem.getNameLocal()

if not fs.exists("/recipes.json") then
    error("Could not find recipes file, exiting")
end

local file = fs.open("/recipes.json","r")
local file_data = file.readAll()
file.close()

---Key-Value indexed list of recipes
local recipes = textutils.unserialiseJSON(file_data)

---Table representing all currently queued recipes
local recipe_queue = {}


---Helper function to quickly complete all coroutines given
---@param coroutines table
local function executeCorutines(coroutines,shouldSleep)
    shouldSleep = shouldSleep or false
    -- Resume all coroutines
    while #coroutines > 0 do
        for i3 = #coroutines, 1, -1 do
            local co = coroutines[i3]
            local success, err = coroutine.resume(co)
            if not success then
                print("Error in coroutine:", err)
            end

            -- Check if the coroutine is dead and remove it from the list
            if coroutine.status(co) == "dead" then
                table.remove(coroutines, i3)
            end
        end
        if shouldSleep then
            sleep(0)
        end
    end
end

---Returns the current recipe queue with all queued recipes
---@return table recipeQueue Table representing all currently queued recipes
local function getRecipeQueue()
    return recipe_queue
end

---Returns a table with all existing recipes
---@return table recipes Key-Value indexed list of recipes
local function getRecipes()
    local recipe_returns = recipes
    local n = 0
    for i,v in pairs(recipes) do
        n = n + 1
    end
    recipe_returns.n = n-1
    return recipe_returns
end

---Does the provided recipe name exist
---@param recipe_name string Name of recipe to check
---@return boolean isRecipe Does the recipe exist or not
local function isRecipe(recipe_name)
    if type(recipes[recipe_name]) == "table" then
        return true
    else
        return false
    end
end

---Can we craft the provided recipe
---@param recipe table Recipe data such as ingredients and count
---@param count integer How many of the item to craft
---@return boolean success
---@return string|nil missingIngredient What are we missing, or nil
---@return integer|nil count How much of the item are we missing, or nil
local function canCraft(recipe,count)
    count = count or 1
    local required_items = {}
    if type(recipe) ~= "nil" then
        for index, ingredient in pairs(recipe.ingredients) do
            if type(ingredient) ~= "nil" then
                if type(required_items[ingredient]) ~= "nil" then
                    required_items[ingredient] = required_items[ingredient] + 1
                else
                    required_items[ingredient] = 1
                end
            end
        end
        for i,v in pairs(required_items) do
            local c = storage.getItemCount(i)
            if v * count > c  then
                return false, i, (required_items[i]*count)-c
            end
        end
        return true, nil, nil
    else
        return false, nil, nil
    end
end

---Attempts to craft the recipe, will error if missing ingredients so always check canCraft first
---@param recipe table Recipe data such as ingredients and count
---@param count integer How many of the item to craft
local function craft(recipe,count)
    count = count or 1
    for index, ingredient in pairs(recipe.ingredients) do
        if type(ingredient) ~= "nil" then
            local success = storage.exportItems(turtle_name,ingredient,count,tonumber(index))
            if not success then
                error("Missing ingredient: "..ingredient)
            end
        end
    end
    turtle.select(1)
    crafter.craft(count)
    for i = 1, 16 do
        if turtle.getItemCount(i) > 0 then
            storage.importItems(turtle_name,i,count*recipe.count)
        end
    end
end

local function queueRecipe(recipe_name,count)
    table.insert(recipe_queue,{recipe_name=recipe_name,count=count})
end

---Prints a list of all recipes and their count
local function displayRecipes()
    local i = 0
    for index, recipe in pairs(recipes) do
        i = i + 1
        if i % 2 == 0 then
            term.setTextColor(colors.lightGray)
        else
            term.setTextColor(colors.white)
        end
        textutils.pagedPrint(index.." | C: "..recipe.count)
        term.setTextColor(colors.white)
    end
end

---Processes the most recent recipe in the recipe queue (FILO Stack)
local function processRecipe()
    if #recipe_queue > 0 then
        local position = #recipe_queue
        local recipe_name = recipe_queue[position].recipe_name
        local count = recipe_queue[position].count
        if isRecipe(recipe_name) then
            local craftable, missingIngredient, missingIngredientCount = canCraft(recipes[recipe_name],count)
            if craftable then
                craft(recipes[recipe_name],count)
                table.remove(recipe_queue,position)
                print("Crafted: "..recipe_name)
            elseif missingIngredient then
                print("Couldent queue: "..recipe_name)
                print("Reason: Missing ingredient(s)")
                if isRecipe(missingIngredient) then
                    queueRecipe(missingIngredient,math.ceil(missingIngredientCount/recipes[missingIngredient].count))
                    print("Queued: "..missingIngredient)
                else
                    print("Couldent queue: "..missingIngredient)
                    print("Reason: No valid recipe")
                    print("Skipping "..recipe_name)
                    table.remove(recipe_queue,position)
                end
            end
        else
            print("Skipping: "..recipe_name)
            print("Reason: No valid recipe")
            table.remove(recipe_queue,position)
        end
    end
end

storage.refresh()

return {
    isRecipe = isRecipe,
    canCraft = canCraft,
    craft = craft,
    queueRecipe = queueRecipe,
    displayRecipes = displayRecipes,
    processRecipe = processRecipe,
    getRecipeQueue = getRecipeQueue,
    getRecipes = getRecipes
}