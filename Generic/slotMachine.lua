local speaker = peripheral.find("speaker")
local monitor = peripheral.find("monitor")
local modem = peripheral.find("modem")

modem.open(255)

local patterns = {"\1","\2","\3","\4","\5","\6","\7","\8","\14","\15","\16","$","\18","\20","\21"}

local patternPayout = {
    { pattern = { "$", "$", "$" }, multiplier = 5 },
    { pattern = { "$", "\3", "\8" }, multiplier = 2 },
    { pattern = { "\1", "\2", "\3" }, multiplier = 1.5 },
    { pattern = { "\3", "\2", "\1" }, multiplier = 1.5 },
    { pattern = { "\1", "\3", "\1" }, multiplier = 2 },
    { pattern = { "\7", "\14", "\16" }, multiplier = 2.5 },
    { pattern = { "\20", "\20", "\20" }, multiplier = 4 },
    { pattern = { "$", "$", "\21" }, multiplier = 3 },
    { pattern = { "\8", "\8", "\8" }, multiplier = 3.5 },
    { pattern = { "$", "$", "*" }, multiplier = 2 },
    { pattern = { "*", "\3", "\8" }, multiplier = 2 }
}
local betCount = 0

local iterator1 = 0
local iterator2 = 0
local iterator3 = 0

---How long between each cycle of the slots
---0.05 expert
---0.10 normal
---0.15 easy
local delay = 0.1
monitor.clear()

local function playMelody(melody)
    for i = 1, #melody do
        sleep(melody[i].d)
        speaker.playNote("bell", 1, melody[i].n)
    end
end

local function shuffle(t)
    local tbl = {}
    for i = 1, #t do
      tbl[i] = t[i]
    end
    for i = #tbl, 2, -1 do
      local j = math.random(i)
      tbl[i], tbl[j] = tbl[j], tbl[i]
    end
    return tbl
end

local p1 = shuffle(patterns)
local p2 = shuffle(patterns)
local p3 = shuffle(patterns)

local time1 = 3
local time2 = 4
local time3 = 5

local slotStarted = false

local jackpot_melody = {
    {n=5, d=0.2}, {n=5, d=0.2}, {n=6, d=0.1}, {n=7, d=0.1}, {n=8, d=0.1}, 
    {n=5, d=0.2}, {n=6, d=0.1}, {n=5, d=0.2}, {n=5, d=0.2}, {n=6, d=0.1}, 
    {n=7, d=0.1}, {n=8, d=0.1}, 
    -- Extended part
    {n=8, d=0.15}, {n=10, d=0.15}, {n=12, d=0.1}, {n=10, d=0.1}, {n=8, d=0.1},
    {n=7, d=0.15}, {n=8, d=0.15}, {n=10, d=0.1}, {n=12, d=0.2},
    {n=8, d=0.1}, {n=6, d=0.15}, {n=5, d=0.15}, 
    -- Climax
    {n=12, d=0.15}, {n=15, d=0.2}, {n=12, d=0.1}, {n=10, d=0.1}, {n=8, d=0.15},
    {n=10, d=0.2}, {n=12, d=0.1}, {n=15, d=0.25}
}
local win_melody = {{n=5,d=0.4},{n=5,d=0.4},{n=6,d=0.2},{n=7,d=0.2},{n=8,d=0.2},{n=5,d=0.4},{n=6,d=0.2}}
local lose_melody = {
    {n=1, d=0.8}, -- Slow, heavy start
    {n=1, d=0.8}, 
    {n=4, d=0.5}, 
    {n=3, d=0.5}, -- A downward step
    {n=2, d=0.6}, 
    {n=1, d=0.8}, -- Return to the root, emphasizing loss
    {n=5, d=0.4}, {n=4, d=0.4}, -- Brief tension before falling
    {n=3, d=0.6}, {n=2, d=0.6}, 
    {n=1, d=1.0} -- Long, drawn-out ending note to leave a sense of emptiness
}
local function centeredWrite(sText,xOffset,yOffset)
    xOffset = xOffset or 0
    yOffset = yOffset or 0
    local sizeX, sizeY = monitor.getSize()
    monitor.setCursorPos(math.floor((1+sizeX)/2-(#sText/2-1)),math.floor((1+sizeY)/2)+yOffset)
    monitor.write(sText)
end

local function drawRow(patterns1,patterns2,patterns3, i1, i2, i3,isColor,yOffset)
    yOffset = yOffset or 0
    isColor = isColor or false
    if isColor then
        monitor.setTextColor(colors.white)
    else
        monitor.setTextColor(colors.lightGray)
    end
    centeredWrite(patterns1[i1]..patterns2[i2]..patterns3[i3],0,yOffset)
end

local function drawGame(patterns1,patterns2,patterns3)
    if time1 > 0 then
        iterator1 = iterator1-1
        if type(patterns1[iterator1]) == "nil" then
            iterator1 = #patterns1-2
            p1 = shuffle(patterns)
        end
    end
    if time2 > 0 then
        iterator2 = iterator2-1
        if type(patterns2[iterator2]) == "nil" then
            iterator2 = #patterns2-2
            p2 = shuffle(patterns)
        end
    end
    if time3 > 0 then
        iterator3 = iterator3-1
        if type(patterns3[iterator3]) == "nil" then
            iterator3 = #patterns3-2
            p3 = shuffle(patterns)
        end
    end
    drawRow(patterns1,patterns2,patterns3,iterator1+2,iterator2+2,iterator3+2,false,1)
    drawRow(patterns1,patterns2,patterns3,iterator1+1,iterator2+1,iterator3+1,true)
    drawRow(patterns1,patterns2,patterns3,iterator1,iterator2,iterator3,false,-1)
    speaker.playNote("bell",1,2)
    sleep(delay)
    time1 = time1 - delay
    time2 = time2 - delay
    time3 = time3 - delay
end

local function gameLoop()
    while not slotStarted do
        sleep(0)
    end
    while time3 > 0 do
        drawGame(p1,p2,p3)
    end
end


local function interupt()
    local wasOn = false
    while true do
        local signal = redstone.getInput("front")
        if signal and not wasOn then
            if not slotStarted then
                slotStarted = true
                speaker.playNote("bell",1,5)
            end
            wasOn = true
        elseif not signal and wasOn then
            wasOn = false
        end
        sleep(0)
    end
end

local function checkJackpot()
    for _, jackpot in ipairs(patternPayout) do
        local match = true
        for i = 1, #jackpot.pattern do
            if jackpot.pattern[i] ~= "*" and jackpot.pattern[i] ~= p1[iterator1] and jackpot.pattern[i] ~= p2[iterator2] and jackpot.pattern[i] ~= p3[iterator3] then
                match = false
                break
            end
        end
        if match then
            return jackpot.multiplier
        end
    end
    return 0 -- Default to no jackpot
end

local function gameFinish()
    monitor.clear()
    monitor.setTextScale(1.5)

    local sizeX, sizeY = monitor.getSize()
    local betMultipler = checkJackpot()

    if betMultipler < 5 and betMultipler > 0 then
        monitor.setTextColor(colors.green)
        centeredWrite("YOU WIN!!!")
        playMelody(win_melody)
    elseif betMultipler == 5 then
        monitor.setTextColor(colors.yellow)
        centeredWrite("JACKPOT!!!")
        playMelody(jackpot_melody)
    else
        monitor.setTextColor(colors.red)
        centeredWrite("Maybe next time.")
        playMelody(lose_melody)
    end

    local packet = {
        type = "gameFinished",
        payoutCount = betCount * betMultipler
    }
    modem.transmit(255, 255, packet)
    sleep(5)
    monitor.clear()
end

local function gameStart()
    monitor.clear()
    monitor.setTextScale(1.5)
    monitor.setTextColor(colors.yellow)
    centeredWrite("Insert bet to start")
    local notStarted = true
    while notStarted do
        local event, side, channel, replyChannel, message, distance = os.pullEvent("modem_message")
        if type(message) == "table" then
            if message.type == "startGame" then
                if type(message.betCount) ~= "nil" then
                    betCount = message.betCount
                    notStarted = false
                end
            end
        end
        sleep(0)
    end
    monitor.clear()
    centeredWrite("Pull the lever!")
end

gameStart()
sleep(2)

monitor.setTextScale(4)
parallel.waitForAny(gameLoop,interupt)

sleep(1)
gameFinish()
shell.run("slotMachine")