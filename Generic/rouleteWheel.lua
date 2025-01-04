-- Peripheral setup
local monitor = peripheral.find("monitor")
monitor.setTextScale(0.5)
local width, height = monitor.getSize()
monitor.clear()

-- Define the wheel layout
local wheelSlots = {
    {symbol = "0", color = colors.green},
    {symbol = "32", color = colors.red},
    {symbol = "15", color = colors.black},
    {symbol = "19", color = colors.red},
    {symbol = "4", color = colors.black},
    {symbol = "21", color = colors.red},
    {symbol = "2", color = colors.black},
    {symbol = "25", color = colors.red},
    {symbol = "17", color = colors.black},
    {symbol = "34", color = colors.red},
    {symbol = "6", color = colors.black},
    {symbol = "27", color = colors.red},
    {symbol = "13", color = colors.black},
    {symbol = "36", color = colors.red},
    {symbol = "11", color = colors.black},
    {symbol = "30", color = colors.red},
    {symbol = "8", color = colors.black},
    {symbol = "23", color = colors.red},
    {symbol = "10", color = colors.black},
    {symbol = "5", color = colors.red},
    {symbol = "24", color = colors.black},
    {symbol = "16", color = colors.red},
    {symbol = "33", color = colors.black},
    {symbol = "1", color = colors.red},
    {symbol = "20", color = colors.black},
    {symbol = "14", color = colors.red},
    {symbol = "31", color = colors.black},
    {symbol = "9", color = colors.red},
    {symbol = "22", color = colors.black},
    {symbol = "18", color = colors.red},
    {symbol = "29", color = colors.black},
    {symbol = "7", color = colors.red},
    {symbol = "28", color = colors.black},
    {symbol = "12", color = colors.red},
    {symbol = "35", color = colors.black}
}

-- Helper function to draw text centered at x, y with a specific color
local function drawCenteredText(x, y, text, color)
    local oldX, oldY = monitor.getCursorPos()
    local oldColor = monitor.getTextColor()

    local centerX = math.floor(x - #text / 2)
    monitor.setCursorPos(centerX, y)
    monitor.setTextColor(color)
    monitor.write(text)

    monitor.setCursorPos(oldX, oldY)
    monitor.setTextColor(oldColor)
end

-- Function to draw the roulette wheel
local function drawRouletteWheel()
    local centerX, centerY = math.floor(width / 2), math.floor(height / 2)
    local radius = math.min(centerX, centerY) - 2
    local slots = #wheelSlots
    local anglePerSlot = 2 * math.pi / slots

    -- Draw the wheel sections
    for i = 1, slots do
        local angle = (i - 1) * anglePerSlot
        local nextAngle = i * anglePerSlot
        local color = wheelSlots[i].color
        local symbol = wheelSlots[i].symbol

        -- Calculate position for text
        local x = centerX + radius * math.cos(angle + anglePerSlot / 2)
        local y = centerY + radius * math.sin(angle + anglePerSlot / 2)

        -- Draw colored section in the wheel
        monitor.setCursorPos(math.floor(x), math.floor(y))
        monitor.setTextColor(color)
        drawCenteredText(math.floor(x), math.floor(y), symbol, color)
    end

    -- Draw the wheel's arrow at the top
    drawCenteredText(centerX, 1, "▲", colors.white)
end

-- Function to simulate the wheel spin
local function spinWheel(duration)
    monitor.clear()
    drawRouletteWheel()
    os.sleep(duration)
end

-- Simulate a wheel spin
spinWheel(5)