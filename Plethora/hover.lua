local pid = require("PID")

local modules = peripheral.find("neuralInterface")
local modem = peripheral.find("modem")
local target_y = ...
local _,pos_y,_ = gps.locate()


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
    error("Target Y-Level not specified.",0)
end
if type(pos_y) == "nil" then
    error("Y-Level undetectable.")
end

local start_y = pos_y

local pidData_y = pid.makePID(0.09,0.02,4,target_y,start_y)


while true do
    _,pos_y,_ = gps.locate()
    if type(pos_y) ~= "nil" then
        pidData_y.current = pos_y
    end
    local dir = 0
    local output = pid.PID(pidData_y)
    if output > 0 then
        dir = -90
    else
        dir = 90
    end
    local strength = math.abs(output)/16
    if strength > 4 then
        strength = 4
    elseif strength < 0.5 then
        strength = 0.5
    end
    modules.launch(0,dir,strength)
end