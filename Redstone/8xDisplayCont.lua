local io = {
    Data = {peripheral = "redstoneIntegrator_0"},
    PlotPixel = {peripheral = "redstoneIntegrator_1"},
    PlotAllPixel = {peripheral = "redstoneIntegrator_2"},
    XAddr1 = {peripheral = "redstoneIntegrator_3"},
    XAddr2 = {peripheral = "redstoneIntegrator_4"},
    XAddr4 = {peripheral = "redstoneIntegrator_5"},
    YAddr1 = {peripheral = "redstoneIntegrator_6"},
    YAddr2 = {peripheral = "redstoneIntegrator_7"},
    YAddr4 = {peripheral = "redstoneIntegrator_8"}
}

local peripherals = {}

for label, data in pairs(io) do
    peripherals[data.peripheral] = peripheral.wrap(data.peripheral)
end

local function setAddress(x,y)
    local label = "XAddr1"
    if x == 1 or x == 3 or x == 5 or x == 7 then
        peripherals[io[label].peripheral].setOutput("back",true)
    else
        peripherals[io[label].peripheral].setOutput("back",false)
    end

    label = "XAddr2"
    if x == 2 or x == 6 or x == 7 then
        peripherals[io[label].peripheral].setOutput("back",true)
    else
        peripherals[io[label].peripheral].setOutput("back",false)
    end

    label = "XAddr4"
    if x == 4 or x == 5 or x == 7 then
        peripherals[io[label].peripheral].setOutput("back",true)
    else
        peripherals[io[label].peripheral].setOutput("back",false)
    end

    label = "YAddr1"
    if y == 1 or y == 3 or y == 5 or y == 7 then
        peripherals[io[label].peripheral].setOutput("back",true)
    else
        peripherals[io[label].peripheral].setOutput("back",false)
    end

    label = "YAddr2"
    if y == 2 or y == 6 or y == 7 then
        peripherals[io[label].peripheral].setOutput("back",true)
    else
        peripherals[io[label].peripheral].setOutput("back",false)
    end

    label = "YAddr4"
    if y == 4 or y == 5 or y == 7 then
        peripherals[io[label].peripheral].setOutput("back",true)
    else
        peripherals[io[label].peripheral].setOutput("back",false)
    end
end

local function setData(state)
    peripherals[io["Data"].peripheral].setOutput("back",state)
    sleep(0.4)
end

local function drawPixel(state)
    setData(state)
    peripherals[io["PlotPixel"].peripheral].setOutput("back",true)
    sleep(0.4)
    peripherals[io["PlotPixel"].peripheral].setOutput("back",false)
    sleep(0.4)
end

local function drawEntireScreen(state)
    setData(state)
    peripherals[io["PlotAllPixel"].peripheral].setOutput("back",true)
    sleep(0.4)
    peripherals[io["PlotAllPixel"].peripheral].setOutput("back",false)
    sleep(0.4)
end

drawEntireScreen(false)
sleep(1)
while true do
    local numX = math.random(0,7)
    local numY = math.random(0,7)
    setAddress(numX,numY)
    drawPixel(true)
    sleep(0.4)
    drawPixel(false)
    sleep(0.4)
end