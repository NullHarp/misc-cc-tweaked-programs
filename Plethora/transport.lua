local pid = require("PID")

local modules = peripheral.find("neuralInterface")
local modem = peripheral.find("modem")
local target_x,target_y,target_z = ...
local pos_x,pos_y,pos_z = gps.locate()


if type(modules) == "nil" then
    error("Neural Interface not found.",0)
end
if type(modem) == "nil" then
    error("Wireless Modem not found.",0)
end
if not modules.hasModule("plethora:kinetic") then
    error("Kinetic Augment module not found.",0)
end
if type(target_y) == "nil" then
    error("Target position not specified.",0)
end
if type(pos_y) == "nil" then
    error("Position undetectable.")
end

local start_x = pos_x
local start_y = pos_y
local start_z = pos_z

local pidData_x = pid.makePID(0.09,0.02,1,target_x,start_x)
local pidData_y = pid.makePID(0.09,0.02,1,target_y,start_y)
local pidData_z = pid.makePID(0.09,0.02,1,target_z,start_z)


while true do
    pos_x,pos_y,pos_z = gps.locate()
    if type(pos_x) ~= "nil" then
        pidData_x.current = pos_x
    end
    if type(pos_y) ~= "nil" then
        pidData_y.current = pos_y
    end
    if type(pos_z) ~= "nil" then
        pidData_z.current = pos_z
    end
    local dir_y = 0
    local output_x = pid.PID(pidData_x)
    local output_y = pid.PID(pidData_y)
    local output_z = pid.PID(pidData_z)
    local total_strength = math.sqrt(output_x^2 + output_y^2 + output_z^2)
    if total_strength > 0 then
        output_x = output_x / total_strength
        output_y = output_y / total_strength
        output_z = output_z / total_strength
    end
    if output_y > 0 then
        dir_y = -90
    else
        dir_y = 90
    end
    local yaw_angle = math.atan2(output_z, output_x) -- Radians
    -- Calculate pitch angle (vertical direction)
    local combined_xz_magnitude = math.sqrt(output_x^2 + output_z^2)
    local pitch_angle = math.atan2(output_y, combined_xz_magnitude) -- Radians
    local distance = math.sqrt((target_x - pos_x)^2 + (target_y - pos_y)^2 + (target_z - pos_z)^2)
    local strength = math.min(math.max(distance / 10, 0.5), 4) -- Scales between 0.5 and 4

    print(strength)
    local yaw_deg = math.deg(yaw_angle)
    local pitch_deg = math.deg(pitch_angle)
    modules.launch(yaw_deg,-pitch_deg,strength)
    sleep(0.1)
end