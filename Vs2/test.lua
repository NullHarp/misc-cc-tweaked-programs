local quat = require("quat")

local rotData = ship.getQuaternion()

local pitch, yaw, roll = quat.quaternionToEuler(rotData.w,rotData.x,rotData.y,rotData.z)
print(math.floor(pitch),math.floor(yaw),math.floor(roll))