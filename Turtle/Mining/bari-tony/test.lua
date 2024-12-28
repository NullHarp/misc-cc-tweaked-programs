local util = require("util")
local version = "V0.1.2"

local turtUtil = require("turtUtil")

local home = {x=-744,y=67,z=-581}
local pos = {x=-1,y=-1,z=-1}

local scanner = peripheral.find("geoScanner")

turtUtil.recalibrateOrientation()
turtUtil.goTo(pos)