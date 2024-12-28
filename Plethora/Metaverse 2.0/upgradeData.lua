
local file_name = ...

local file = fs.open(file_name,"r")
local file_data = file.readAll()
file.close()
local data = textutils.unserialiseJSON(file_data)
for i, block in pairs(data) do
    if type(block.orientation) == "nil" then
        block.orientation = -1
    end
end
local new_file_data = textutils.serialiseJSON(data)
file = fs.open(file_name,"w")
file.write(new_file_data)
file.close()