local turtUtil = require("turtUtil")

local x, y, z, dir = ...

x = tonumber(x)
y = tonumber(y)
z = tonumber(z)

dir = tonumber(dir)

turtUtil.setPos({x=x,y=y,z=z})
turtUtil.setDirection(dir)

turtUtil.saveData()