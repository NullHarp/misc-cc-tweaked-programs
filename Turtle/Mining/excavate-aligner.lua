if turtle.getFuelLevel() < turtle.getFuelLimit()*0.1 then
    error("Less than 10 Percent Fuel, cannot start.")
end

local world_pos = {x=207,z=1888}
local start_pos = {x=187,z=1911}
local dir_X = -1
local dir_Z = 1

local grid_size = 4
local targetGridX,targetGridZ = ...
local targetX = world_pos.x + (targetGridX*grid_size*dir_X)
local targetZ = world_pos.z + (targetGridZ*grid_size*dir_Z)
print(targetX)
print(targetZ)

local offsetX = targetX - start_pos.x
local offsetZ = targetZ - start_pos.z
print(offsetX,offsetZ)

if offsetX < 0 then
    turtle.turnLeft()
    turtle.turnLeft()
end
for x = 1, math.abs(offsetX) do
    turtle.forward()
end
if offsetX < 0 then
    turtle.turnRight()
    turtle.turnRight()
end

if offsetZ < 0 then
    turtle.turnLeft()
else
    turtle.turnRight()
end
for z = 1, math.abs(offsetZ) do
    turtle.forward()
end
if offsetZ < 0 then
    turtle.turnLeft()
    turtle.turnLeft()
end
shell.run("excavate",tostring(grid_size))