local turtUtil = require("turtUtil")

local materials = {
    move = "minecraft:dirt",
    move_down = "minecraft:smooth_stone",
    turnLeft = "minecraft:cobblestone",
    turnRight = "minecraft:stone",
    turnAround = "minecraft:dark_oak_planks",
    start = "minecraft:oak_planks",
    stop = "minecraft:dripstone_block"
}

local function mountRail()
    turtUtil.loadData()
    local isBlock, data = turtle.inspectDown()
    if isBlock then
        local name = data.name
        if name == materials.start then
            local railEnd = false
            print("Found rail.")
            turtUtil.forward()
            while not railEnd do
                local isBlock_down, data_down = turtle.inspectDown()
                isBlock, data = turtle.inspect()
                if isBlock then
                    name = data.name
                    if name == materials.move then
                        turtUtil.up()
                        turtUtil.forward()
                    elseif name == materials.move_down then
                        turtUtil.down()
                    end
                end
                if isBlock_down then
                    local name_down = data_down.name
                    if name_down == materials.move then
                        turtUtil.forward()
                    elseif name_down == materials.turnLeft then
                        turtUtil.turnLeft()
                        turtUtil.forward()
                    elseif name_down == materials.turnRight then
                        turtUtil.turnRight()
                        turtUtil.forward()
                    elseif name_down == materials.turnAround then
                        turtUtil.turnRight()
                        turtUtil.turnRight()
                        turtUtil.forward()
                    elseif name_down == materials.move_down then
                        turtUtil.forward()
                        turtUtil.turnRight()
                        turtUtil.turnRight()
                        turtUtil.down()
                    elseif name_down == materials.stop then
                        railEnd = true
                        print("Rail completed.")
                        return true
                    end
                end
                if not isBlock and not isBlock_down then
                    print("Rail stopped abruptly")
                    return false
                end
            end
        end
    else
        print("Could not find rail.")
        return false
    end
end

local success = mountRail()