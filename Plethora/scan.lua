local scanner = peripheral.find("universal_scanner")
local table_data = scanner.scan("block",8)

local range = ...
range = tonumber(range)
if range > 16 then
    range = 16
end
local output_data = {}
for i,v in pairs(table_data) do
    if v.name ~= "minecraft:air" then
        table.insert(output_data,{block = v.name,position = {x = v.x,y = v.y, z = v.z},orientation = -1})
    end
    print(i.."/"..#table_data)
end
local file = fs.open("output.json","w")
file.write(textutils.serialiseJSON(output_data))
file.close()