local modules = peripheral.wrap("back")
local canvas = modules.canvas3d()
canvas.clear()
local design = canvas.create()

local filename = ...
local offset = {x = 0, y = 0, z = 0}
local gps_x,gps_y,gps_z = gps.locate()
offset.x = (math.floor(gps_x)+0.5)-gps_x
offset.y = (math.floor(gps_y)+0.5001)-gps_y
offset.z = (math.floor(gps_z)+0.5)-gps_z

local file = fs.open(filename,"r")
local file_data = file.readAll()
local table_data = textutils.unserialiseJSON(file_data)
for i,data in pairs(table_data) do
    data.position.x = data.position.x + offset.x
    data.position.y = data.position.y + offset.y
    data.position.z = data.position.z + offset.z

    local error = pcall(design.addItem,data.position,data.block)
end