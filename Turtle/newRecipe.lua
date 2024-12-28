-- Create new recipes for the autoCrafter program

local util = require("util")

local recipe = {
    ingredients = {},
    count = 1
}
for i = 2, 16 do
    local slot_data = turtle.getItemDetail(i)
    if type(slot_data) ~= "nil" and i ~= 1 then
        recipe.ingredients[tostring(i)] = slot_data.name
    end
end
recipe.count = turtle.getItemCount(1)

if fs.exists("/recipes.json") then
    local file = fs.open("recipes.json","r")
    local file_data = file.readAll()
    file.close()
    local recipes = textutils.unserialiseJSON(file_data)
    recipes[turtle.getItemDetail(1).name] = recipe
    local json_recipes = util.prettyPrintJSON(textutils.serialiseJSON(recipes))
    file = fs.open("recipes.json","w")
    file.write(json_recipes)
    file.close()
else
    local recipes = {}
    recipes[turtle.getItemDetail(1).name] = recipe
    local json_recipes = util.prettyPrintJSON(textutils.serialiseJSON(recipes))
    local file = fs.open("recipes.json","w")
    file.write(json_recipes)
    file.close()
end