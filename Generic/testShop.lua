local shoppy = require("shoppy")

local monitor = peripheral.wrap("top")

shoppy.setShopMonitor(monitor)
shoppy.addItem("minecraft:dirt",4,1)
shoppy.constructShop()

for i = 1, 16 do
    local count = turtle.getItemCount(i)
    if count > 0 then
        turtle.select(i)
        if count > 64 then
            turtle.drop(64)
            turtle.drop()
        else
            turtle.drop(count)
        end
    end
end

parallel.waitForAll(shoppy.processBuy,shoppy.processFunds)