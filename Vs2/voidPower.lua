local engine = peripheral.find("EngineController") or error("No engine controller found.",0)
local tweaked_controller = peripheral.wrap("front")

local pid = require("PID")

engine.setIdle(false)

local pos = ship.getWorldspacePosition()

local yPid = pid.makePID(0.13,0.05,0.01,130,pos.y)

-- Rotate a vector by a quaternion (local to world)
local function rotateVectorByQuaternion(q, v)
    local qx, qy, qz, qw = q.x, q.y, q.z, q.w

    -- Quaternion * vector
    local ix =  qw * v.x + qy * v.z - qz * v.y
    local iy =  qw * v.y + qz * v.x - qx * v.z
    local iz =  qw * v.z + qx * v.y - qy * v.x
    local iw = -qx * v.x - qy * v.y - qz * v.z

    -- Result * quaternion conjugate
    return {
        x = ix * qw + iw * -qx + iy * -qz - iz * -qy,
        y = iy * qw + iw * -qy + iz * -qx - ix * -qz,
        z = iz * qw + iw * -qz + ix * -qy - iy * -qx
    }
end

local function hover()
    while true do
        pos = ship.getWorldspacePosition()
        yPid.current = pos.y
        local yRes = pid.PID(yPid)
        engine.applyInvariantForce(0,yRes*50000,0)
        print(yRes)
        sleep(0)
    end
end



local function moveControls()
    while true do
        -- Left/Right Joystick 1
        local axis_1 = tweaked_controller.getAxis(1)
        -- Up/Down Joystick 1
        local axis_2 = tweaked_controller.getAxis(2)

        -- Left/Right Joystick 2
        local axis_3 = tweaked_controller.getAxis(3)
        -- Up/Down Joystick 2
        local axis_4 = tweaked_controller.getAxis(4)

        local turn_left = tweaked_controller.getButton(15)
        local turn_right  = tweaked_controller.getButton(13)

        if turn_left then
            engine.applyRotDependentTorque(0,10000,0)
        elseif turn_right then
            engine.applyRotDependentTorque(0,-10000,0)
        end
        if axis_1 ~= 0 or axis_2 ~= 0 or axis_4 ~= 0 then
            engine.applyRotDependentForce(axis_1*-500000,5000000*axis_4,axis_2*-500000)
        end
        if axis_3 ~= 0 then
            engine.applyRotDependentTorque(axis_3*10000,0,0)
        end
        sleep()
    end
end

parallel.waitForAll(moveControls)
