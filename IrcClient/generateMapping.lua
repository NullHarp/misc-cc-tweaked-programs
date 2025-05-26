local scanner = peripheral.find("geoScanner")

local map_size = ...
map_size = tonumber(map_size)

local scan = scanner.scan(map_size)

local map = {}

for index, blockData in pairs(scan) do
    map[index] = {x=blockData.x,y=blockData.y,z=blockData.z}
end

local file = fs.open("map.json","w")
local json_map = textutils.serialiseJSON(map)
file.write(json_map)
print(#map)
file.close()