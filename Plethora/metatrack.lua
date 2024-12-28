local modules = peripheral.wrap("back")
local canvas = modules.canvas3d()
canvas.clear()
local design = canvas.create()
rednet.open("top")
while true do
    local event, sender, message, protocol = os.pullEvent("rednet_message")
    if protocol == "Meta" then
        local gps_x,gps_y,gps_z = gps.locate()
        local offset = {x = 0, y = 0, z = 0}
        local offset_1 = {x = 0, y = 0, z = 0}
        local offset_2 = {x = 0, y = 0, z = 0}

        local d = textutils.unserialiseJSON(message)
        local position = d.position
        offset.x = (math.floor(position.gps_x)+0.5) - position.gps_x
        offset.y = (math.floor(position.gps_x)+0.5) - position.gps_y
        offset.z = (math.floor(position.gps_x)+0.5) - position.gps_z
        offset_1.x = (math.floor(gps_x)+0.5)-gps_x
        offset_1.y = (math.floor(gps_y)+0.5001)-gps_y
        offset_1.z = (math.floor(gps_z)+0.5)-gps_z
        offset_2.x = offset.x - offset_1.x
        offset_2.y = offset.y - offset_1.y
        offset_2.z = offset.z - offset_1.z
        local table_data = textutils.unserialiseJSON(d.file_data)
        for i,data in pairs(table_data) do
            data.position.x = data.position.x + offset_2.x
            data.position.y = data.position.y + offset_2.y
            data.position.z = data.position.z + offset_2.z
        
            design.addItem(data.position,data.block)
        end
    end
    sleep(0)
  end