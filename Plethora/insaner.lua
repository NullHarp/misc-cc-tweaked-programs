local modules = peripheral.wrap("back")
local canvas = modules.canvas3d()
canvas.clear()
local design = canvas.create()

local filename = ...
local scale = {x = 0.1, y = 0.1, z = 0.1}

local file = fs.open(filename,"r")
local file_data = file.readAll()
local table_data = textutils.unserialiseJSON(file_data)
for i,data in pairs(table_data) do
    data.position.x = data.position.x * scale.x
    data.position.y = data.position.y * scale.y
    data.position.z = data.position.z * scale.z

    local error = pcall(design.addItem,data.position,data.block,scale.x)
end