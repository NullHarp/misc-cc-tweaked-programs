local function getLabel()
    if os.getComputerLabel() == nil then
        return "N/A"
    else
        return os.getComputerLabel()
    end
end

local function title(text,version,partialClear)
    local oldX, oldY = term.getCursorPos()
    if type(partialClear) == "nil" then
        partialClear = false
    end
    if not partialClear then
        term.clear()
    end
    term.setCursorPos(1,1)
    term.clearLine()
    term.setTextColor(colors.yellow)
    term.write("NullSys "..version.." | Label: "..getLabel().." | ID: "..os.getComputerID())
    term.setCursorPos(1,2)
    term.clearLine()
    term.write(text)
    term.setTextColor(colors.white)
    if not partialClear then
        term.setCursorPos(1,4)
    else
        term.setCursorPos(oldX,oldY)
    end
end

local function calculateYawPitch(x, y, z)
    -- Calculate yaw (rotation around the y-axis)
    local yaw = math.atan2(x, z)
    
    -- Calculate distance on the xz-plane
    local distanceXZ = math.sqrt(x * x + z * z)
    
    -- Calculate pitch (rotation around the x-axis)
    local pitch = math.atan2(y, distanceXZ)
    
    -- Convert radians to degrees
    local yawDegrees = math.deg(yaw)
    local pitchDegrees = math.deg(pitch)
    
    return yawDegrees, pitchDegrees
end

local function prettyPrintJSON(json)
    local indent = 0
    local prettyJson = ""
    local inString = false

    for i = 1, #json do
        local char = json:sub(i, i)

        if char == "\"" and json:sub(i - 1, i - 1) ~= "\\" then
            inString = not inString
        end

        if not inString then
            if char == "{" or char == "[" then
                indent = indent + 1
                prettyJson = prettyJson .. char .. "\n" .. string.rep("  ", indent)
            elseif char == "}" or char == "]" then
                indent = indent - 1
                prettyJson = prettyJson .. "\n" .. string.rep("  ", indent) .. char
            elseif char == "," then
                prettyJson = prettyJson .. char .. "\n" .. string.rep("  ", indent)
            else
                prettyJson = prettyJson .. char
            end
        else
            prettyJson = prettyJson .. char
        end
    end

    return prettyJson
end

--- Creates a progress bar with a length of size, filled in between value and max_value with the main and secondary colors.
---@param posX integer
---@param posY integer
---@param value integer
---@param max_value integer
---@param size integer
---@param main_color integer
---@param secondary_color integer
local function progressBar(posX,posY,value,max_value,size,main_color,secondary_color)
    local normalized_value = (value/max_value)*size
    local remain = size-normalized_value
    local old_color = term.getTextColor()
    term.setCursorPos(posX,posY)
    term.setTextColor(main_color)
    term.write(string.rep("\149",normalized_value))
    term.setTextColor(secondary_color)
    term.write(string.rep("\149",remain))
    term.setTextColor(old_color)
    term.setCursorPos(1,posY+1)
end

return {getLabel = getLabel, title = title,calculateYawPitch = calculateYawPitch, prettyPrintJSON = prettyPrintJSON, progressBar = progressBar}