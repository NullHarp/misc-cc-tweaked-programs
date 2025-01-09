local util = require("util")
local version = "V0.1.0"

local wood_type = "oak"

local turtUtil = require("turtUtil")
util.title("Automated Tree Farm",version)

local hasRefueled = false

while true do
    local isBlock, block_data = turtle.inspect()
    if isBlock then
        if block_data.name == "minecraft:"..wood_type.."_log" or block_data.name == "minecraft:"..wood_type.."_leaves" then
            turtUtil.dig()
            turtUtil.digUp()
            turtUtil.up()
        end
        hasRefueled = false
    else
        if not hasRefueled then
            if turtUtil.selectItem("minecraft:"..wood_type.."_log") then
                turtle.refuel(1)
                turtle.select(1)
            end
            hasRefueled = true
        end
        while turtUtil.down() do
            sleep(0)
        end
        if turtUtil.selectItem("minecraft:"..wood_type.."_sapling") then
            turtle.place()
            turtle.select(1)
        end

    end
end