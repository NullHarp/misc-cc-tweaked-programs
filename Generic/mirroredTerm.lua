local targetTerm = {}
local currentTerm = {}

local function write(sText)
    currentTerm.write(sText)
    targetTerm.write(sText)
end

local function scroll(y)
    currentTerm.scroll(y)
    targetTerm.scroll(y)
end

local function getCursorPos()
    return currentTerm.getCursorPos()
end

local function setCursorPos(x, y)
    currentTerm.setCursorPos(x, y)
    targetTerm.setCursorPos(x, y)
end

local function getCursorBlink()
    return currentTerm.getCursorBlink()
end

local function setCursorBlink(blink)
    currentTerm.setCursorBlink(blink)
    targetTerm.setCursorBlink(blink)
end

local function getSize()
    return currentTerm.getSize()
end

local function clear()
    currentTerm.clear()
    targetTerm.clear()
end

local function clearLine()
    currentTerm.clearLine()
    targetTerm.clearLine()
end

local function getTextColour()
    return currentTerm.getTextColour()
end

local function getTextColor()
    return currentTerm.getTextColor()
end

local function setTextColour(colour)
    currentTerm.setTextColour(colour)
    targetTerm.setTextColour(colour)
end

local function setTextColor(color)
    currentTerm.setTextColor(color)
    targetTerm.setTextColor(color)
end

local function getBackgroundColour()
    return currentTerm.getBackgroundColour()
end

local function getBackgroundColor()
    return currentTerm.getBackgroundColor()
end

local function setBackgroundColour(colour)
    currentTerm.setBackgroundColour(colour)
    targetTerm.setBackgroundColour(colour)
end

local function setBackgroundColor(color)
    currentTerm.setBackgroundColor(color)
    targetTerm.setBackgroundColor(color)
end

local function isColour()
    return currentTerm.isColour()
end

local function isColor()
    return currentTerm.isColor()
end

local function blit(sText, sTextColor, sBackgroundColor)
    currentTerm.blit(sText, sTextColor, sBackgroundColor)
    targetTerm.blit(sText, sTextColor, sBackgroundColor)
end

local function setPaletteColour(colour, ...)
    currentTerm.setPaletteColour(colour, ...)
    targetTerm.setPaletteColour(colour, ...)
end

local function setPaletteColor(color, ...)
    currentTerm.setPaletteColor(color, ...)
    targetTerm.setPaletteColor(color, ...)
end

local function getPaletteColour(colour)
    return currentTerm.getPaletteColour(colour)
end

local function getPaletteColor(color)
    return currentTerm.getPaletteColor(color)
end

local function mirrorTerm(terminal)
    targetTerm = terminal
end

local function setSourceTerm(terminal)
    currentTerm = terminal
end

return {
    mirrorTerm = mirrorTerm,
    setSourceTerm = setSourceTerm,
    write = write,
    scroll = scroll,
    getCursorPos = getCursorPos,
    setCursorPos = setCursorPos,
    getCursorBlink = getCursorBlink,
    setCursorBlink = setCursorBlink,
    getSize = getSize,
    clear = clear,
    clearLine = clearLine,
    getTextColour = getTextColour,
    getTextColor = getTextColor,
    setTextColour = setTextColour,
    setTextColor = setTextColor,
    getBackgroundColour = getBackgroundColour,
    getBackgroundColor = getBackgroundColor,
    setBackgroundColour = setBackgroundColour,
    setBackgroundColor = setBackgroundColor,
    isColour = isColour,
    isColor = isColor,
    blit = blit,
    setPaletteColour = setPaletteColour,
    setPaletteColor = setPaletteColor,
    getPaletteColour = getPaletteColour,
    getPaletteColor = getPaletteColor
}