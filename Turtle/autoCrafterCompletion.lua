local completion = require "cc.shell.completion"

local file = fs.open("recipes.json","r")
local file_data = file.readAll()
file.close()
local recipes = textutils.unserialiseJSON(file_data)
local recipe_names = {}
for i,v in pairs(recipes) do
    table.insert(recipe_names,i)
end

local complete = completion.build(
  { completion.choice, recipe_names }
)
shell.setCompletionFunction("autoCrafter.lua", complete)